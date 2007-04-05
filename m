Date: Thu, 5 Apr 2007 10:08:48 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: missing madvise functionality
Message-Id: <20070405100848.db97d835.dada1@cosmosbay.com>
In-Reply-To: <4614A5CC.5080508@redhat.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<4614A5CC.5080508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 03:31:24 -0400
Rik van Riel <riel@redhat.com> wrote:

> Jakub Jelinek wrote:
> 
> > My guess is that all the page zeroing is pretty expensive as well and
> > takes significant time, but I haven't profiled it.
> 
> With the attached patch (Andrew, I'll change the details around
> if you want - I just wanted something to test now), your test
> case run time went down considerably.
> 
> I modified the test case to only run 1000 loops, so it would run
> a bit faster on my system.  I also modified it to use MADV_DONTNEED
> to zap the pages, instead of the mmap(PROT_NONE) thing you use.
> 

Interesting...

Could you please add this patch and see if it helps on your machine ?

[PATCH] VM : mm_struct's mmap_cache should be close to mmap_sem

Avoids cache line dirtying : The first cache line of mm_struct is/should_be mostly read.

In case find_vma() hits the cache, we dont need to access the begining of mm_struct.
Since we just dirtied mmap_sem, access to its cache line is free.

In case find_vma() misses the cache, we dont need to dirty the begining of mm_struct.


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--- linux-2.6.21-rc5/include/linux/sched.h
+++ linux-2.6.21-rc5-ed/include/linux/sched.h
@@ -310,7 +310,6 @@ typedef unsigned long mm_counter_t;
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
-	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
@@ -324,6 +323,7 @@ struct mm_struct {
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
+	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
