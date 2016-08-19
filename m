Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38BA66B025E
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 08:33:12 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n128so82146896ith.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 05:33:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f27si7917403ioi.41.2016.08.19.05.33.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 05:33:11 -0700 (PDT)
Subject: Re: [PATCH v4] powerpc: Do not make the entire heap executable
References: <20160810130030.5268-1-dvlasenk@redhat.com>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <2ef3a274-a1ed-53bc-4881-fce0d75fb1ac@redhat.com>
Date: Fri, 19 Aug 2016 14:33:06 +0200
MIME-Version: 1.0
In-Reply-To: <20160810130030.5268-1-dvlasenk@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Kees Cook <keescook@chromium.org>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/10/2016 03:00 PM, Denys Vlasenko wrote:
> On 32-bit powerpc the ELF PLT sections of binaries (built with --bss-plt,
> or with a toolchain which defaults to it) look like this:
>
>   [17] .sbss             NOBITS          0002aff8 01aff8 000014 00  WA  0   0  4
>   [18] .plt              NOBITS          0002b00c 01aff8 000084 00 WAX  0   0  4
>   [19] .bss              NOBITS          0002b090 01aff8 0000a4 00  WA  0   0  4
>
> Which results in an ELF load header:
>
>   Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
>   LOAD           0x019c70 0x00029c70 0x00029c70 0x01388 0x014c4 RWE 0x10000
>
> This is all correct, the load region containing the PLT is marked as
> executable. Note that the PLT starts at 0002b00c but the file mapping ends at
> 0002aff8, so the PLT falls in the 0 fill section described by the load header,
> and after a page boundary.
>
> Unfortunately the generic ELF loader ignores the X bit in the load headers
> when it creates the 0 filled non-file backed mappings. It assumes all of these
> mappings are RW BSS sections, which is not the case for PPC.
>
> gcc/ld has an option (--secure-plt) to not do this, this is said to incur
> a small performance penalty.
>
> Currently, to support 32-bit binaries with PLT in BSS kernel maps *entire
> brk area* with executable rights for all binaries, even --secure-plt ones.
>
> Stop doing that.
>
> Teach the ELF loader to check the X bit in the relevant load header
> and create 0 filled anonymous mappings that are executable
> if the load header requests that.
>
> The patch was originally posted in 2012 by Jason Gunthorpe
> and apparently ignored:
>
> https://lkml.org/lkml/2012/9/30/138
>
> Lightly run-tested.


Ping powerpc/mm people.
How does this patch look? Are you taking it?

> -static int do_brk(unsigned long addr, unsigned long request)
> +static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long flags)
>  {
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma, *prev;
> -	unsigned long flags, len;
> +	unsigned long len;
>  	struct rb_node **rb_link, *rb_parent;
>  	pgoff_t pgoff = addr >> PAGE_SHIFT;
>  	int error;
> @@ -2668,7 +2668,7 @@ static int do_brk(unsigned long addr, unsigned long request)
>  	if (!len)
>  		return 0;
>
> -	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
> +	flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
>
>  	error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);

Regarding "maybe VM_LOCKED needs to be masked out of flags?"
in the fragment above.

I agree. In a sense that "Yes, maybe. I don't really know
whether mm people feel it is worth the cost."
I'd be happy to send a new version if someone will express
a definite request to add that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
