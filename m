Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CAA96B0390
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 14:57:43 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id n73so36305345vke.6
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 11:57:43 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id t186si1095182vke.114.2017.03.31.11.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 11:57:42 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id r69so101494915vke.2
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 11:57:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170331180341.2v7iwln3gndqfmut@codemonkey.org.uk>
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk> <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170331171724.nm22iqiellfsvj5z@codemonkey.org.uk> <CAGXu5jL7MGNut_izksDKJHNJjPZqvu_84GBwHjqVeRbjDJyMWw@mail.gmail.com>
 <20170331180341.2v7iwln3gndqfmut@codemonkey.org.uk>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 31 Mar 2017 11:57:20 -0700
Message-ID: <CALCETrWm+FkoFKN-g3p8G59PNDgE4MMR9yh7aBqz6C+TZyBgzg@mail.gmail.com>
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Kees Cook <keescook@chromium.org>, Tommi Rantala <tommi.t.rantala@nokia.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>, X86 ML <x86@kernel.org>, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Mar 31, 2017 at 11:03 AM, Dave Jones <davej@codemonkey.org.uk> wrote:
> On Fri, Mar 31, 2017 at 10:32:04AM -0700, Kees Cook wrote:
>
>  > >  > >  > > Full dmesg output here: https://pastebin.com/raw/Kur2mpZq
>  > >  > >  > >
>  > >  > >  > > [   51.418954] usercopy: kernel memory exposure attempt detected from
>  > >  > >  > > ffff880000090000 (dma-kmalloc-256) (4096 bytes)
>  > >  > >  >
>  > >  > >  > This seems like a real exposure: the copy is attempting to read 4096
>  > >  > >  > bytes from a 256 byte object.
>  > >  > >
>  > >  > > The code[1] is doing a 4k read from /dev/mem in the range 0x90000 -> 0xa0000
>  > >  > > According to arch/x86/mm/init.c:devmem_is_allowed, that's still valid..
>  > >  > >
>  > >  > > Note that the printk is using the direct mapping address. Is that what's
>  > >  > > being passed down to devmem_is_allowed now ? If so, that's probably what broke.
>  > >  >
>  > >  > So this is attempting to read physical memory 0x90000 -> 0xa0000, but
>  > >  > that's somehow resolving to a virtual address that is claimed by
>  > >  > dma-kmalloc?? I'm confused how that's happening...
>  > >
>  > > /dev/mem is using physical addresses that the kernel translates through the
>  > > direct mapping.  __check_object_size seems to think that anything passed
>  > > into it is always allocated by the kernel, but in this case, I think read_mem()
>  > > is just passing through the direct mapping to copy_to_user.
>  >
>  > How is ffff880000090000 both in the direct mapping and a slab object?
>  >
>  > It would need to pass all of these checks, and be marked as PageSlab
>  > before it could be evaluated by __check_heap_object:
>  >
>  >         if (is_vmalloc_or_module_addr(ptr))
>  >                 return NULL;
>  >
>  >         if (!virt_addr_valid(ptr))
>  >                 return NULL;
>  >
>  >         page = virt_to_head_page(ptr);
>  >
>  >         /* Check slab allocator for flags and size. */
>  >         if (PageSlab(page))
>  >                 return __check_heap_object(ptr, n, page);
>
> Looking at Tommi's dmesg output closer, it appears that he's booting in
> EFI mode (which isn't unusual these days).  I'm not sure that the EBDA
> (that x86info is trying to read) even exists under EFI, which is
> probably why the memory range is showing up as usable, and then ending
> up as a slab page, rather than being reserved by the BIOS.
>

This stuff all sucks.  Presumably the only reason that we pay
attention to the EBDA at all in EFI mode is that no one has the guts
to change it: maybe there's a firmware out there that puts something
important in the EBDA and fails to properly reserve it in the EFI
memory map.

> ...
> reserve setup_data: [mem 0x0000000000059000-0x000000000009dfff] usable
> ...
>
> If EBDA under EFI isn't a valid thing, the puzzling part is why there's
> still an EBDA pointer in lowmem. x86 people ?
>
> Longterm, I think I'm just going to gut all the ebda code from x86info,
> as it isn't really necessary.  Whether we still need to change /dev/mem
> to cope with this situation depends on whether there are other valid
> usecases.

I would like to at least consider a stricter alternative: make
/dev/mem a real whitelist.  The rules would be that, by default,
/dev/mem access is always rejected.  Kernel code could explicitly
register resources that would be permitted via /dev/mem -- each
resource would be tagged with a bit saying "devmem okay" along with
some indication of caching mode.  For example, on very recent kernels,
some crappy HP tools are busted because they try to access SMBIOS
using explicit uncached devmem accesses, but that's verboten because
the kernel accesses it with ioremap_cache().

There are really very few cases where /dev/mem is okay at all, I
think.  Maybe the EBDA is one of them.  And we could make up some hack
where devmem access to certain ranges just gets all zeros regardless
of what's actually there.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
