Date: Fri, 25 Aug 2000 13:46:33 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <Pine.LNX.3.96.1000825125457.23502B-100000@kanga.kvack.org>
References: <20000825165116Z131177-250+7@kanga.kvack.org>
Subject: Re: pgd/pmd/pte and x86 kernel virtual addresses
Message-Id: <20000825185716Z131186-247+10@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from "Benjamin C.R. LaHaise" <blah@kvack.org> on Fri, 25
Aug 2000 12:59:19 -0400 (EDT)


> > 2) ioremap_nocache() allocates virtual RAM.  I already have a virtual address,
> > I don't need another one.
> 
> That's because there are no ptes for most RAM in the kernel.
> ioremap_nocache does not allocate RAM, only a mapping for the address
> space.  Actually, passing in physical RAM to ioremap_nocache may not work
> on all platforms.

It only needs to work on one: x86

If I use ioremap_nocache(), I effectively have two virtual pointers to the same
physical pointer.  The first is the normal virtual pointer for kernel memory,
and the second is the one returned by ioremap_nocache().  I was under the
understanding that caching is enabled on physical pages only, so it shouldn't
matter which virtual address I use.  Is that correct?

> > 4) Even with all this, it appears that the function isn't working.  I've
> > attached a logical analyzer to the memory bus, and writes are not being sent
> > out, leading me to believe the memory is still being cached.
> 
> On x86, you're better off setting the MTRRs to get non-cached behaviour,
> but that's still the wrong thing to do when you're talking about main
> memory.  Better still is to not rely on uncachable mappings at all.  x86
> is a cache coherent architechure -- why do you need uncachable mappings of
> main memory???.

MTRR's are not an option, because chances are we won't have any free MTRR's to
work with.  Besides, I can do what I want on Windows 2000 without MTRR's.  My
driver is for a device which sits on the memory bus itself and responds to
memory reads/writes.  If I can't disable caching, I can't talk to the device.

The odd thing is that ioremap_nocache() did work at one point, but not any
more, and I can't figure out why.



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
