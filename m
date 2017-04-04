Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C79EA6B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:37:09 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c67so51896933itg.23
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:37:09 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id 78si19557057ior.244.2017.04.04.15.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:37:08 -0700 (PDT)
Received: by mail-io0-x231.google.com with SMTP id b140so105419329iof.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:37:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a6543d13-6247-08de-903e-f4d1bbb52881@nokia.com>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk> <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170331171724.nm22iqiellfsvj5z@codemonkey.org.uk> <CAGXu5jL7MGNut_izksDKJHNJjPZqvu_84GBwHjqVeRbjDJyMWw@mail.gmail.com>
 <CA+55aFwOCnhSF4Tyk8x0+EpcWmaDd9X5bi1w=O1aReEK53OY8A@mail.gmail.com> <a6543d13-6247-08de-903e-f4d1bbb52881@nokia.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 4 Apr 2017 15:37:07 -0700
Message-ID: <CAGXu5jJAd9Qg4gkXE=1+8q6Ej=8boiH4ovkzX5n+PbhkBrnt5g@mail.gmail.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tommi Rantala <tommi.t.rantala@nokia.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On Fri, Mar 31, 2017 at 12:32 PM, Tommi Rantala
<tommi.t.rantala@nokia.com> wrote:
> On 31.03.2017 21:26, Linus Torvalds wrote:
>>
>> Hmm. Thinking more about this, we do allow access to the first 1MB of
>> physical memory unconditionally (see devmem_is_allowed() in
>> arch/x86/mm/init.c). And I think we only _reserve_ the first 64kB or
>> something. So I guess even STRICT_DEVMEM isn't actually all that
>> strict.
>>
>> So this should be visible even *with* STRICT_DEVMEM.
>>
>> Does a simple
>>
>>      sudo dd if=/dev/mem of=/dev/null bs=4096 count=256
>>
>> also show the same issue? Maybe regardless of STRICT_DEVMEM?
>
>
> Yep, it is enough to trigger the bug.
>
> Also crashes with the fedora kernel that has STRICT_DEVMEM:
>
> $ sudo dd if=/dev/mem of=/dev/null bs=4096 count=256
> Segmentation fault
>
> [   73.224025] usercopy: kernel memory exposure attempt detected from
> ffff893a80059000 (dma-kmalloc-16) (4096 bytes)
> [   73.224049] ------------[ cut here ]------------
> [   73.224056] kernel BUG at mm/usercopy.c:75!
> [   73.224060] invalid opcode: 0000 [#1] SMP
> [   73.224237] CPU: 5 PID: 2860 Comm: dd Not tainted 4.9.14-200.fc25.x86_64
> #1

As root, what does dumping /proc/iomem show you?

For one of my systems, I see something like this:

00000000-00000fff : reserved
00001000-0008efff : System RAM
0008f000-0008ffff : reserved
00090000-0009f7ff : System RAM
0009f800-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM
000e0000-000fffff : reserved
  000e0000-000effff : PCI Bus 0000:00
  000f0000-000fffff : System ROM
00100000-cdee6fff : System RAM
  cbc00000-cc49a653 : Kernel code
  cc49a654-ccb661bf : Kernel data
  cccf3000-cce30fff : Kernel bss
...

I note that there are two "System RAM" areas below 0x100000. In
arch/x86/mm/init.c, devmem_is_allowed() says:

/*
 * devmem_is_allowed() checks to see if /dev/mem access to a certain address
 * is valid. The argument is a physical page number.
 *
 *
 * On x86, access has to be given to the first megabyte of ram because that area
 * contains BIOS code and data regions used by X and dosemu and similar apps.
 * Access has to be given to non-kernel-ram areas as well, these contain the PCI
 * mmio resources as well as potential bios/acpi data regions.
 */
int devmem_is_allowed(unsigned long pagenr)
{
        if (pagenr < 256)
                return 1;
        if (iomem_is_exclusive(pagenr << PAGE_SHIFT))
                return 0;
        if (!page_is_ram(pagenr))
                return 1;
        return 0;
}

This means that it allows reads into even System RAM below 0x100000,
but I think that's a mistake. Shouldn't BIOS code and data regions
already be marked as "reserved", as seen in my /proc/iomem output? I
feel like the "pagenr < 256" exception should be dropped, but I don't
know all the minor details on the history here.

When I remove this exception, x86info blows up for me ("error reading
EBDA pointer").

So, my question is: are there actually BIOS code/data in memory areas
marked as System RAM? If so, what normally keeps them from being used
for kernel memory? If not, then I assume x86info is wrong?

Dave, you implied the latter, but I wanted to make sure this is
actually true? (And if so, we need to do something like what Linus
suggested to return zeros to keep old x86info "happy" -- would that
keep it happy?)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
