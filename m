Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 045AB8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 08:25:47 -0400 (EDT)
Date: Mon, 21 Mar 2011 13:25:26 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] xfs: flush vmap aliases when mapping fails
Message-ID: <20110321122526.GX2140@cmpxchg.org>
References: <1299713876-7747-1-git-send-email-david@fromorbit.com>
 <20110310073751.GB25374@infradead.org>
 <20110310224945.GA15097@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310224945.GA15097@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, xfs@oss.sgi.com, linux-mm@kvack.org

On Fri, Mar 11, 2011 at 09:49:45AM +1100, Dave Chinner wrote:
> On Thu, Mar 10, 2011 at 02:37:51AM -0500, Christoph Hellwig wrote:
> > On Thu, Mar 10, 2011 at 10:37:56AM +1100, Dave Chinner wrote:
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > On 32 bit systems, vmalloc space is limited and XFS can chew through
> > > it quickly as the vmalloc space is lazily freed. This can result in
> > > failure to map buffers, even when there is apparently large amounts
> > > of vmalloc space available. Hence, if we fail to map a buffer, purge
> > > the aliases that have not yet been freed to hopefuly free up enough
> > > vmalloc space to allow a retry to succeed.
> > 
> > IMHO this should be done by vm_map_ram internally.  If we can't get the
> > core code fixes we can put this in as a last resort.
> 
> OK. The patch was done as part of the triage for this bug:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=27492
> 
> where the vmalloc space on 32 bit systems is getting exhausted. I
> can easily move this flush-and-retry into the vmap code.

The problem appears to be with the way vmap blocks are allocated.  It
would explain the symptoms perfectly: failing allocations long before
vmap space is exhausted.  I had the following test patch applied to a
vanilla -mmotm and a patched one:

---

diff --git a/init/main.c b/init/main.c
index 4a9479e..62f92f9 100644
--- a/init/main.c
+++ b/init/main.c
@@ -559,6 +559,9 @@ asmlinkage void __init start_kernel(void)
 	if (panic_later)
 		panic(panic_later, panic_param);
 
+	extern void vmalloc_test(void);
+	vmalloc_test();
+
 	lockdep_info();
 
 	/*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cbd9f9f..d6f75dc 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1116,6 +1116,16 @@ void __init vmalloc_init(void)
 	vmap_initialized = true;
 }
 
+void vmalloc_test(void)
+{
+	struct page *pages[] = { ZERO_PAGE(0) };
+	unsigned long total = 0;
+
+	while (vm_map_ram(pages, 1, -1, PAGE_KERNEL))
+		total++;
+	panic("Vmapped %lu single pages\n", total);
+}
+
 /**
  * map_kernel_range_noflush - map kernel VM area with the specified pages
  * @addr: start of the VM area to map

---

where the results are:

	vanilla: Kernel panic - not syncing: Vmapped 15360 single pages
	patched: Kernel panic - not syncing: Vmapped 30464 single pages

The patch with a more accurate problem description is attached at the
end of this email.

> FWIW, while the VM folk might be paying attention about vmap realted
> stuff, this vmap BUG() also needs triage:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=27002

I stared at this bug and the XFS code for a while over the weekend.
What you are doing in there is really scary!

So xfs_buf_free() does vm_unmap_ram if the buffer has the XBF_MAPPED
flag set and spans multiple pages (b_page_count > 1).

In xlog_sync() you have that split case where you do XFS_BUF_SET_PTR
on that in-core log's l_xbuf which changes that buffer to, as far as I
could understand, linear kernel memory.  Later in xlog_dealloc_log you
call xfs_buf_free() on that buffer.

I was unable to determine if this can ever be more than one page in
the buffer for the split case.  But if this is the case, you end up
invoking vm_unmap_ram() on something you never vm_map_ram'd, which
could explain why this triggers the BUG_ON() for the dirty area map.

But even if this is all fine and working, this looks subtle as hell.

This BUG_ON() is not necessarily a sign of a faulty vmap allocator,
but could just as much indicate a faulty caller.

> And, finally, the mm-vmap-area-cache.patch in the current mmotm also
> needs to be pushed forward because we've been getting reports of
> excessive CPU time being spent walking the vmap area rbtree during
> vm_map_ram operations and this patch supposedly fixes that
> problem....

It looks good to me.  After Nick's original hole searching code did my
head in, I am especially fond of Hugh's simplifications in that area
;-)  So for what it's worth:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

And here is the patch that should improve on the vmap exhaustion
problems observed with XFS on 32-bit.

It removes the guard page allocation from the basic vmap area
allocator and leaves it to __get_vmap_area() and thus vmalloc to take
care of the guard page.  If it's deemed necessary to have guard pages
also for vm_map_ram(), I think it should be handled in there instead.
This patch does not do this.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: vmalloc: remove guard pages from between basic vmap areas

The vmap allocator is used, among other things, to allocate per-cpu
vmap blocks, where each vmap block is naturally aligned to its own
size.  Obviously, leaving a guard page after each vmap area forbids
packing vmap blocks efficiently and can make the kernel run out of
possible vmap blocks long before vmap space is exhausted.

The vmap code to map a user-supplied page array into linear vmalloc
space insists on using a vmap block (instead of falling back to a
custom area) when the area size is beneath a certain threshold.  With
heavy users of this interface (e.g. XFS) and limited vmalloc space on
32-bit, vmap block exhaustion is a real problem.

Remove the guard page from this allocator level.  It's still there for
vmalloc allocations, but enforced higher up.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmalloc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cbd9f9f..5d8666b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -307,7 +307,7 @@ nocache:
 	/* find starting point for our search */
 	if (free_vmap_cache) {
 		first = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
-		addr = ALIGN(first->va_end + PAGE_SIZE, align);
+		addr = ALIGN(first->va_end, align);
 		if (addr < vstart)
 			goto nocache;
 		if (addr + size - 1 < addr)
@@ -338,10 +338,10 @@ nocache:
 	}
 
 	/* from the starting point, walk areas until a suitable hole is found */
-	while (addr + size >= first->va_start && addr + size <= vend) {
+	while (addr + size > first->va_start && addr + size <= vend) {
 		if (addr + cached_hole_size < first->va_start)
 			cached_hole_size = first->va_start - addr;
-		addr = ALIGN(first->va_end + PAGE_SIZE, align);
+		addr = ALIGN(first->va_end, align);
 		if (addr + size - 1 < addr)
 			goto overflow;
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
