Date: Fri, 28 Sep 2007 13:08:36 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] splice mmap_sem deadlock
In-Reply-To: <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org>
Message-ID: <alpine.LFD.0.999.0709281303250.3579@woody.linux-foundation.org>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk>
 <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
 <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org>
 <20070928193017.GC11717@kernel.dk>
 <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 28 Sep 2007, Linus Torvalds wrote:
> 
> So something like the appended might work. Untested.

Btw, it migth be cleaner to separate out this thing as a function of it's 
own, ie something like

  /*
   * Do a copy-from-user while holding the mmap_semaphore for reading
   */
  int copy_from_user_mmap_sem(void *dst, const void __user *src, size_t n)
  {
	int partial;

	pagefault_disable();
	partial = __copy_from_user_inatomic(dst, src, n);
	pagefault_enable();

	if (!partial)
		return 0;
	up_read(&current->mm->mmap_sem);
	partial = copy_from_user(dst, src, n);
	down_read(&current->mm->mmap_sem);

	return partial ? -EFAULT : 0;
  }

in case anybody else needs it. And even if nobody else does, making it a 
static inline function in fs/splice.c would at least separate out this 
thing from the core functionality, and just help keep things clear.

Wanna test that thing?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
