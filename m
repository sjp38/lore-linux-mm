Date: Sat, 9 Oct 1999 09:38:20 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <37FF407F.155D7C64@colorfullife.com>
Message-ID: <Pine.GSO.4.10.9910090921020.14891-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sat, 9 Oct 1999, Manfred Spraul wrote:

> Alexander Viro wrote:
> > Moreover, sys_uselib() may do
> > interesting things to cloned processes. IMO the right thing would be to
> > check for the number of mm users.
> 
> I don't know the details of the mm implementation, but if there is only
> one user, then down(&mm->mmap_sem) will never sleep, and you loose
> nothing by getting the semaphore.

Yes (especially since sys_uselib() is not _too_ time-critical), but
consider what will happen if the thread A does sys_uselib() while the
thread B runs in the affected area. It's a different problem. As for the
details - check where the new users may come from.

I don't think that it calls for ASSERT-style macros, though. IMO it's a
matter of one big grep. As of 2.3.20-pre2 affected places are
arch/mips/kernel/sysirix.c
arch/sparc64/kernel/binfmt_aout32.c
fs/binfmt_aout.c
fs/binfmt_elf.c
drivers/char/drm/bufs.c (WTF is that?)
drivers/sgi/char/{graphics.c,shmiq.c}

So there... I'm not sure that we need to protect calls in ->load_binary(),
though - it's really unnecessary. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
