From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14319.31833.53685.244682@dukat.scot.redhat.com>
Date: Mon, 27 Sep 1999 15:16:57 +0100 (BST)
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909252050590.25425-100000@imperial.edgeglobal.com>
References: <Pine.LNX.4.10.9909251905110.4120-100000@laser.random>
	<Pine.LNX.4.10.9909252050590.25425-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 25 Sep 1999 21:19:59 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> To be exactly I'm trying to do cooperative locking between a mmaping of
> the accel region of /dev/gfx and the framebuffer region of /dev/fb. 

I thought you might be.  Look at the DRI (XI's direct rendering
infrastructure): they implement a cooperative locking mechanism which
optimises the fast case (current locker was also the last holder of the
lock) not to require a syscall at all.

Using any form of physical memory protection will be too slow.

> I notice that after mmapping the kernel can no long control access to
> the memory regions. So I need to block any process from accessing the
> framebuffer while the accel engine is running. Since many low end
> cards lock if you access the framebuffer and accel engine at the same
> time.

I know.  The hardware sucks.  There is no fast way to deal with it.  The
closest you might get to it is ia32 segmentation, but we don't support
that in the kernel and never will.

> Will this work for mmap regions as well?

We're talking about _cooperative_ locking.  We are relying on the
applications to do the correct locking, so sure, if the application
takes a lock before accessing an mmaped region, that will work too.

You still don't prevent a rogue application from locking the graphics
adapter. 

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
