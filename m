Date: Thu, 6 Dec 2001 12:48:30 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] VM system in 2.4.16 doesn't try hard enough for user memory...
Message-ID: <20011206124830.C2029@redhat.com>
References: <4.2.2.20011205174951.00ab0e20@slither>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4.2.2.20011205174951.00ab0e20@slither>; from linux@sparker.net on Wed, Dec 05, 2001 at 05:54:44PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "S. Parker" <linux@sparker.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Dec 05, 2001 at 05:54:44PM -0800, S. Parker wrote:
 
> Attached below is "memstride.c", a simple program to exercise a process which
> wishes to grow to the largest size of available VM the system can handle,
> scribble in it all.  Actually, scribble in it all several times.
> 
> Under at least 2.4.14 -> 2.4.16, the VM system *always* over-commits to
> memstride, even on an otherwise idle system, and ends up killing it.
> This is wrong.  It should be possible for memstride to be told when
> it has over-stepped the size of the system's total VM resources, by
> having sbrk() return -1 (out of memory).

Yes, over-commit protection is far from perfect.  However, it's a
difficult problem to get right.

> Also attached is my proposed fix for this problem.  It has the following
> changes:
> 
> 1.  Do a better job estimating how much VM is available
>          vm_enough_memory() was changed to take the sum of all free RAM
>          and all free swap, subtract up to 1/8th of physical RAM (but not
>          more than 16MB) as a reserve for system buffers to prevent deadlock,
>          and compare this to the request.  If the VM request is <= the
>          available free stuff, then we're set.

That's still just a guestimate: do you have any hard data to back
up the magic numbers here?

> 2.  Be willing to sleep for memory chunks larger than 8 pages.
>          __alloc_pages had an uncommented piece of code, that I couldn't
>          see any reason to have.  It doesn't matter how big the piece of
>          memory is--if we're low, and it's a sleepable request, we should
>          sleep.  Now it does.  (Can anyone explain to me why this coded was
>          added originally??)

That's totally separate: *all* user VM allocations are done with
order-0 allocations, so this can't have any effect on VM overcommit.

Ultimately, your patch still doesn't protect against overcommit: if
you run two large, lazy memory using applications in parallel, you'll
still get each of them being told there's enough VM left at the time
of sbrk/mmap, and they will both later on find out at page fault time
that there's not enough memory to go round.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
