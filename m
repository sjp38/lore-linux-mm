Date: Thu, 4 Oct 2007 10:46:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-Id: <20071004104650.d158121f.akpm@linux-foundation.org>
In-Reply-To: <1191516427.5574.7.camel@lappy>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	<1191501626.22357.14.camel@twins>
	<E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
	<1191504186.22357.20.camel@twins>
	<E1IdR58-0002Fq-00@dorka.pomaz.szeredi.hu>
	<1191516427.5574.7.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Miklos Szeredi <miklos@szeredi.hu>, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 04 Oct 2007 18:47:07 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > > > > But that said, there might be better ways to do that.
> > > > 
> > > > Sure, if we do need to globally limit the number of under-writeback
> > > > pages, then I think we need to do it independently of the dirty
> > > > accounting.
> > > 
> > > It need not be global, it could be per BDI as well, but yes.
> > 
> > For per-bdi limits we have the queue length.
> 
> Agreed, except for:
> 
> static int may_write_to_queue(struct backing_dev_info *bdi)
> {
> 	if (current->flags & PF_SWAPWRITE)
> 		return 1;
> 	if (!bdi_write_congested(bdi))
> 		return 1;
> 	if (bdi == current->backing_dev_info)
> 		return 1;
> 	return 0;
> }
> 
> Which will write to congested queues. Anybody know why?


commit c4e2d7ddde9693a4c05da7afd485db02c27a7a09
Author: akpm <akpm>
Date:   Sun Dec 22 01:07:33 2002 +0000

    [PATCH] Give kswapd writeback higher priority than pdflush
    
    The `low latency page reclaim' design works by preventing page
    allocators from blocking on request queues (and by preventing them from
    blocking against writeback of individual pages, but that is immaterial
    here).
    
    This has a problem under some situations.  pdflush (or a write(2)
    caller) could be saturating the queue with highmem pages.  This
    prevents anyone from writing back ZONE_NORMAL pages.  We end up doing
    enormous amounts of scenning.
    
    A test case is to mmap(MAP_SHARED) almost all of a 4G machine's memory,
    then kill the mmapping applications.  The machine instantly goes from
    0% of memory dirty to 95% or more.  pdflush kicks in and starts writing
    the least-recently-dirtied pages, which are all highmem.  The queue is
    congested so nobody will write back ZONE_NORMAL pages.  kswapd chews
    50% of the CPU scanning past dirty ZONE_NORMAL pages and page reclaim
    efficiency (pages_reclaimed/pages_scanned) falls to 2%.
    
    So this patch changes the policy for kswapd.  kswapd may use all of a
    request queue, and is prepared to block on request queues.
    
    What will now happen in the above scenario is:
    
    1: The page alloctor scans some pages, fails to reclaim enough
       memory and takes a nap in blk_congetion_wait().
    
    2: kswapd() will scan the ZONE_NORMAL LRU and will start writing
       back pages.  (These pages will be rotated to the tail of the
       inactive list at IO-completion interrupt time).
    
       This writeback will saturate the queue with ZONE_NORMAL pages.
       Conveniently, pdflush will avoid the congested queues.  So we end up
       writing the correct pages.
    
    In this test, kswapd CPU utilisation falls from 50% to 2%, page reclaim
    efficiency rises from 2% to 40% and things are generally a lot happier.
    
    
    The downside is that kswapd may now do a lot less page reclaim,
    increasing page allocation latency, causing more direct reclaim,
    increasing lock contention in the VM, etc.  But I have not been able to
    demonstrate that in testing.
    
    
    The other problem is that there is only one kswapd, and there are lots
    of disks.  That is a generic problem - without being able to co-opt
    user processes we don't have enough threads to keep lots of disks saturated.
    
    One fix for this would be to add an additional "really congested"
    threshold in the request queues, so kswapd can still perform
    nonblocking writeout.  This gives kswapd priority over pdflush while
    allowing kswapd to feed many disk queues.  I doubt if this will be
    called for.
    
    BKrev: 3e051055aitHp3bZBPSqmq21KGs5aQ

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c635f39..9ab0209 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -7,6 +7,7 @@ #include <linux/kdev_t.h>
 #include <linux/linkage.h>
 #include <linux/mmzone.h>
 #include <linux/list.h>
+#include <linux/sched.h>
 #include <asm/atomic.h>
 #include <asm/page.h>
 
@@ -14,6 +15,11 @@ #define SWAP_FLAG_PREFER	0x8000	/* set i
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
 
+static inline int current_is_kswapd(void)
+{
+	return current->flags & PF_KSWAPD;
+}
+
 /*
  * MAX_SWAPFILES defines the maximum number of swaptypes: things which can
  * be swapped to.  The swap type and the offset into that swap type are
diff --git a/mm/vmscan.c b/mm/vmscan.c
index aeab1e3..a8b9d2c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -204,6 +204,19 @@ static inline int is_page_cache_freeable
 	return page_count(page) - !!PagePrivate(page) == 2;
 }
 
+static int may_write_to_queue(struct backing_dev_info *bdi)
+{
+	if (current_is_kswapd())
+		return 1;
+	if (current_is_pdflush())	/* This is unlikely, but why not... */
+		return 1;
+	if (!bdi_write_congested(bdi))
+		return 1;
+	if (bdi == current->backing_dev_info)
+		return 1;
+	return 0;
+}
+
 /*
  * shrink_list returns the number of reclaimed pages
  */
@@ -303,8 +316,6 @@ #endif /* CONFIG_SWAP */
 		 * See swapfile.c:page_queue_congested().
 		 */
 		if (PageDirty(page)) {
-			struct backing_dev_info *bdi;
-
 			if (!is_page_cache_freeable(page))
 				goto keep_locked;
 			if (!mapping)
@@ -313,9 +324,7 @@ #endif /* CONFIG_SWAP */
 				goto activate_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
-			bdi = mapping->backing_dev_info;
-			if (bdi != current->backing_dev_info &&
-					bdi_write_congested(bdi))
+			if (!may_write_to_queue(mapping->backing_dev_info))
 				goto keep_locked;
 			write_lock(&mapping->page_lock);
 			if (test_clear_page_dirty(page)) {
@@ -424,7 +433,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	mod_page_state(pgsteal, ret);
-	if (current->flags & PF_KSWAPD)
+	if (current_is_kswapd())
 		mod_page_state(kswapd_steal, ret);
 	mod_page_state(pgactivate, pgactivate);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
