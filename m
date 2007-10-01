Date: Mon, 1 Oct 2007 08:11:40 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] splice mmap_sem deadlock
In-Reply-To: <20071001120330.GE5303@kernel.dk>
Message-ID: <alpine.LFD.0.999.0710010807360.3579@woody.linux-foundation.org>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk>
 <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
 <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org>
 <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org>
 <alpine.LFD.0.999.0709281303250.3579@woody.linux-foundation.org>
 <20071001120330.GE5303@kernel.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The comment is wrong.

On Mon, 1 Oct 2007, Jens Axboe wrote:
>  
>  /*
> + * Do a copy-from-user while holding the mmap_semaphore for reading. If we
> + * have to fault the user page in, we must drop the mmap_sem to avoid a
> + * deadlock in the page fault handling (it wants to grab mmap_sem too, but for
> + * writing). This assumes that we will very rarely hit the partial != 0 path,
> + * or this will not be a win.
> + */

Page faulting only grabs it for reading, and having a page fault happen is 
not problematic in itself. Readers *do* nest.

What is problematic is:

	thread#1			thread#2

	get_iovec_page_array
	down_read()
	.. everything ok so far ..
					mmap()
					down_write()
					.. correctly blocks on the reader ..
					.. everything ok so far ..

	.. pagefault ..
	down_read()
	.. fairness code now blocks on the waiting writer! ..
	.. oops. We're deadlocked ..

So the problem is that while readers do nest nicely, they only do so if no 
potential writers can possibly exist (which of course never happens: an 
rwlock with no writers is a no-op ;).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
