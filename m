Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 936CA280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 11:17:29 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p89so1236340pfk.5
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 08:17:29 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a6si2548622plt.76.2018.01.04.08.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 08:17:28 -0800 (PST)
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8E3A421927
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 16:17:27 +0000 (UTC)
Received: by mail-io0-f174.google.com with SMTP id i143so2743871ioa.3
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 08:17:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801041320360.1771@nanos>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems> <DE0BC12C-4BA8-46AF-BD90-6904B9F87187@amacapital.net>
 <CAD3Vwcptxyf+QJO7snZs_-MHGV3ARmLeaFVR49jKM=6MAGMk7Q@mail.gmail.com>
 <CALCETrW8NxLd4v_U_g8JyW5XdVXWhM_MZOUn05J8VTuWOwkj-A@mail.gmail.com> <alpine.DEB.2.20.1801041320360.1771@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 4 Jan 2018 08:17:06 -0800
Message-ID: <CALCETrVg=XQh+9VczkoC-0oLnBHGD=5hswTmyWQUR8_TTpnDsQ@mail.gmail.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509 certs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Benjamin Gilbert <benjamin.gilbert@coreos.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable <stable@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Garnier <thgarnie@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>

On Thu, Jan 4, 2018 at 4:28 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Wed, 3 Jan 2018, Andy Lutomirski wrote:
>> On Wed, Jan 3, 2018 at 8:35 PM, Benjamin Gilbert
>> <benjamin.gilbert@coreos.com> wrote:
>> > On Wed, Jan 03, 2018 at 04:37:53PM -0800, Andy Lutomirski wrote:
>> >> Maybe try rebuilding a bad kernel with free_ldt_pgtables() modified
>> >> to do nothing, and the read /sys/kernel/debug/page_tables/current (or
>> >> current_kernel, or whatever it's called).  The problem may be obvious.
>> >
>> > current_kernel attached.  I have not seen any crashes with
>> > free_ldt_pgtables() stubbed out.
>>
>> I haven't reproduced it, but I think I see what's wrong.  KASLR sets
>> vaddr_end to a totally bogus value.  It should be no larger than
>> LDT_BASE_ADDR.  I suspect that your vmemmap is getting randomized into
>> the LDT range.  If it weren't for that, it could just as easily land
>> in the cpu_entry_area range.  This will need fixing in all versions
>> that aren't still called KAISER.
>>
>> Our memory map code is utter shite.  This kind of bug should not be
>> possible without a giant warning at boot that something is screwed up.
>
> You're right it's utter shite and the KASLR folks who added this insanity
> of making vaddr_end depend on a gazillion of config options and not
> documenting it in mm.txt or elsewhere where it's obvious to find should
> really sit back and think hard about their half baken 'security' features.
>
> Just look at the insanity of comment above the vaddr_end ifdef maze.
>
> Benjamin, can you test the patch below please?
>
> Thanks,
>
>         tglx
>
> 8<--------------
> --- a/Documentation/x86/x86_64/mm.txt
> +++ b/Documentation/x86/x86_64/mm.txt
> @@ -12,8 +12,9 @@ ffffea0000000000 - ffffeaffffffffff (=40
>  ... unused hole ...
>  ffffec0000000000 - fffffbffffffffff (=44 bits) kasan shadow memory (16TB)
>  ... unused hole ...
> -fffffe0000000000 - fffffe7fffffffff (=39 bits) LDT remap for PTI
> -fffffe8000000000 - fffffeffffffffff (=39 bits) cpu_entry_area mapping
> +                                   vaddr_end for KASLR
> +fffffe0000000000 - fffffe7fffffffff (=39 bits) cpu_entry_area mapping
> +fffffe8000000000 - fffffeffffffffff (=39 bits) LDT remap for PTI
>  ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
>  ... unused hole ...
>  ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
> @@ -37,7 +38,9 @@ ffd4000000000000 - ffd5ffffffffffff (=49
>  ... unused hole ...
>  ffdf000000000000 - fffffc0000000000 (=53 bits) kasan shadow memory (8PB)
>  ... unused hole ...
> -fffffe8000000000 - fffffeffffffffff (=39 bits) cpu_entry_area mapping
> +                                   vaddr_end for KASLR
> +fffffe0000000000 - fffffe7fffffffff (=39 bits) cpu_entry_area mapping
> +... unused hole ...
>  ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
>  ... unused hole ...
>  ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
> --- a/arch/x86/include/asm/pgtable_64_types.h
> +++ b/arch/x86/include/asm/pgtable_64_types.h
> @@ -88,7 +88,7 @@ typedef struct { pteval_t pte; } pte_t;
>  # define VMALLOC_SIZE_TB       _AC(32, UL)
>  # define __VMALLOC_BASE                _AC(0xffffc90000000000, UL)
>  # define __VMEMMAP_BASE                _AC(0xffffea0000000000, UL)
> -# define LDT_PGD_ENTRY         _AC(-4, UL)
> +# define LDT_PGD_ENTRY         _AC(-3, UL)
>  # define LDT_BASE_ADDR         (LDT_PGD_ENTRY << PGDIR_SHIFT)
>  #endif

If you actually change the memory map order, you need to change the
shadow copy in mm/dump_pagetables.c, too.  I have a draft patch to
just sort the damn list, but that's not ready yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
