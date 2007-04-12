Date: Thu, 12 Apr 2007 00:55:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
Message-Id: <20070412005535.951ccb4b.akpm@linux-foundation.org>
In-Reply-To: <1176363565.6893.73.camel@twins>
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
	<20070411153040.a7e6c3b8.akpm@linux-foundation.org>
	<1176363565.6893.73.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Zhao Forrest <forrest.zhao@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Apr 2007 09:39:25 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Wed, 2007-04-11 at 15:30 -0700, Andrew Morton wrote:
> 
> > There used to be a cond_resched() in invalidate_mapping_pages() which would
> > have prevented this, but I rudely removed it to support
> > /proc/sys/vm/drop_caches (which needs to call invalidate_inode_pages()
> > under spinlock).
> > 
> > We could resurrect that cond_resched() by passing in some flag, I guess. 
> > Or change the code to poke the softlockup detector.  The former would be
> > better.
> 
> cond_resched() is conditional on __resched_legal(0)

What's __resched_legal()?

> which should take
> care of being called under a spinlock.

We only increment preempt_count() in spin_lock() if CONFIG_PREEMPT.

> so I guess we can just reinstate the call in invalidate_mapping_pages()
> 
> (still waiting on the compile to finish...)
> ---
> invalidate_mapping_pages() is called under locks (usually preemptable)
> but can do a _lot_ of work, stick in a voluntary preemption point to
> avoid excessive latencies (over 10 seconds was reported by softlockup).
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  mm/truncate.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-2.6-mm/mm/truncate.c
> ===================================================================
> --- linux-2.6-mm.orig/mm/truncate.c
> +++ linux-2.6-mm/mm/truncate.c
> @@ -292,6 +292,8 @@ unsigned long invalidate_mapping_pages(s
>  			pgoff_t index;
>  			int lock_failed;
>  
> +			cond_resched();
> +
>  			lock_failed = TestSetPageLocked(page);

Is deadlocky on the drop_caches path and if CONFIG_PREEMPT we'll get
scheduling-in-spinlock warnings.

For the blkdev_close() path the change is unneeded if CONFIG_PREEMPT and
will fix things if !CONFIG_PREEMPT.

We can presumably just remove the invalidate_mapping_pages() call from the
kill_bdev() path (at least) - kill_bdev()'s truncate_inode_pages() will do
the same thing.

It might be time to remove that unused-for-six-years destroy_dirty_buffers
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
