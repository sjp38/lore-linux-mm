Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2FB3A6B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 22:52:54 -0400 (EDT)
Date: Fri, 9 Jul 2010 10:52:50 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]shmem: reduce one time of locking in pagefault
Message-ID: <20100709025250.GA29570@sli10-desk.sh.intel.com>
References: <1278465346.11107.8.camel@sli10-desk.sh.intel.com>
 <alpine.DEB.1.00.1007081741290.1132@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.1007081741290.1132@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 09, 2010 at 09:13:55AM +0800, Hugh Dickins wrote:
> On Wed, 7 Jul 2010, Shaohua Li wrote:
> 
> > I'm running a shmem pagefault test case (see attached file) under a 64 CPU
> > system. Profile shows shmem_inode_info->lock is heavily contented and 100%
> > CPUs time are trying to get the lock. In the pagefault (no swap) case,
> > shmem_getpage gets the lock twice, the last one is avoidable if we prealloc a
> > page so we could reduce one time of locking. This is what below patch does.
> 
> Right.  As usual, I'm rather unenthusiastic about a patch which has to
> duplicate code paths to satisfy an artificial testcase; but I can see
> the appeal.
> 
> We can ignore that you're making the swap path slower, that will be lost
> in its noise.  I did like the way the old code checked the max_blocks
> limit before it let you allocate the page: whereas you might have many
> threads simultaneously over-allocating before reaching that check; but
> I guess we can live with that.
> 
> > 
> > The result of the test case:
> > 2.6.35-rc3: ~20s
> > 2.6.35-rc3 + patch: ~12s
> > so this is 40% improvement.
> 
> Was that with or without Tim's shmem_sb_info max_blocks scalability
> changes (that I've still not studied)?  Or max_blocks 0 (unlimited)?
no Tim's patch. max_blocks 0.
 
> I notice your test case lets each thread fault in from its own
> disjoint part of the whole area.  Please also test with each thread
> touching each page in the whole area at the same time: which I think
> is just as likely a case, but not obvious to me how well it would
> work with your changes - what numbers does it show?
Tried this (I must use less memory (1G) because this is quite slow):
2.6.35-rc5: ~78s (quite stable in 6 run)
2.6.35-rc5 + patch: not stable. I collect 6 data: 75.5s, 20.9s, 76.1s, 14.6s
22.3s, 75.7s. So sometimes there are big improvements, sometimes not. But
not worse anyway.

> > One might argue if we could have better locking for shmem. But even shmem is lockless,
> > the pagefault will soon have pagecache lock heavily contented because shmem must add
> > new page to pagecache. So before we have better locking for pagecache, improving shmem
> > locking doesn't have too much improvement. I did a similar pagefault test against
> > a ramfs file, the test result is ~10.5s.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > 
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index f65f840..c5f2939 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> ...
> > @@ -1258,7 +1258,19 @@ repeat:
> >  		if (error)
> >  			goto failed;
> >  		radix_tree_preload_end();
> > +		if (sgp != SGP_READ) {
> 
> Don't you need to check that prealloc_page is not already set there?
> There are several places in the swap path where it has to goto repeat.
Thanks for pointing out this. Updated patch.


I'm running a shmem pagefault test case (see attached file) under a 64 CPU
system. Profile shows shmem_inode_info->lock is heavily contented and 100%
CPUs time are trying to get the lock. In the pagefault (no swap) case,
shmem_getpage gets the lock twice, the last one is avoidable if we prealloc a
page so we could reduce one time of locking. This is what below patch does.

The result of the test case:
2.6.35-rc3: ~20s
2.6.35-rc3 + patch: ~12s
so this is 40% improvement.

One might argue if we could have better locking for shmem. But even shmem is lockless,
the pagefault will soon have pagecache lock heavily contented because shmem must add
new page to pagecache. So before we have better locking for pagecache, improving shmem
locking doesn't have too much improvement. I did a similar pagefault test against
a ramfs file, the test result is ~10.5s.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/shmem.c |   69 +++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 49 insertions(+), 20 deletions(-)

Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2010-07-10 09:15:05.000000000 +0800
+++ linux-2.6/mm/shmem.c	2010-07-10 09:24:34.000000000 +0800
@@ -1223,6 +1223,7 @@
 	struct shmem_sb_info *sbinfo;
 	struct page *filepage = *pagep;
 	struct page *swappage;
+	struct page *prealloc_page = NULL;
 	swp_entry_t *entry;
 	swp_entry_t swap;
 	gfp_t gfp;
@@ -1247,7 +1248,6 @@
 		filepage = find_lock_page(mapping, idx);
 	if (filepage && PageUptodate(filepage))
 		goto done;
-	error = 0;
 	gfp = mapping_gfp_mask(mapping);
 	if (!filepage) {
 		/*
@@ -1258,7 +1258,19 @@
 		if (error)
 			goto failed;
 		radix_tree_preload_end();
+		if (sgp != SGP_READ && !prealloc_page) {
+			/* don't care if this successes */
+			prealloc_page = shmem_alloc_page(gfp, info, idx);
+			if (prealloc_page) {
+				if (mem_cgroup_cache_charge(prealloc_page,
+				    current->mm, GFP_KERNEL)) {
+					page_cache_release(prealloc_page);
+					prealloc_page = NULL;
+				}
+			}
+		}
 	}
+	error = 0;
 
 	spin_lock(&info->lock);
 	shmem_recalc_inode(inode);
@@ -1407,28 +1419,37 @@
 		if (!filepage) {
 			int ret;
 
-			spin_unlock(&info->lock);
-			filepage = shmem_alloc_page(gfp, info, idx);
-			if (!filepage) {
-				shmem_unacct_blocks(info->flags, 1);
-				shmem_free_blocks(inode, 1);
-				error = -ENOMEM;
-				goto failed;
-			}
-			SetPageSwapBacked(filepage);
+			if (!prealloc_page) {
+				spin_unlock(&info->lock);
+				filepage = shmem_alloc_page(gfp, info, idx);
+				if (!filepage) {
+					shmem_unacct_blocks(info->flags, 1);
+					shmem_free_blocks(inode, 1);
+					error = -ENOMEM;
+					goto failed;
+				}
+				SetPageSwapBacked(filepage);
 
-			/* Precharge page while we can wait, compensate after */
-			error = mem_cgroup_cache_charge(filepage, current->mm,
-					GFP_KERNEL);
-			if (error) {
-				page_cache_release(filepage);
-				shmem_unacct_blocks(info->flags, 1);
-				shmem_free_blocks(inode, 1);
-				filepage = NULL;
-				goto failed;
+				/* Precharge page while we can wait, compensate
+				 * after
+				 */
+				error = mem_cgroup_cache_charge(filepage,
+					current->mm, GFP_KERNEL);
+				if (error) {
+					page_cache_release(filepage);
+					shmem_unacct_blocks(info->flags, 1);
+					shmem_free_blocks(inode, 1);
+					filepage = NULL;
+					goto failed;
+				}
+
+				spin_lock(&info->lock);
+			} else {
+				filepage = prealloc_page;
+				prealloc_page = NULL;
+				SetPageSwapBacked(filepage);
 			}
 
-			spin_lock(&info->lock);
 			entry = shmem_swp_alloc(info, idx, sgp);
 			if (IS_ERR(entry))
 				error = PTR_ERR(entry);
@@ -1469,6 +1490,10 @@
 	}
 done:
 	*pagep = filepage;
+	if (prealloc_page) {
+		mem_cgroup_uncharge_cache_page(prealloc_page);
+		page_cache_release(prealloc_page);
+	}
 	return 0;
 
 failed:
@@ -1476,6 +1501,10 @@
 		unlock_page(filepage);
 		page_cache_release(filepage);
 	}
+	if (prealloc_page) {
+		mem_cgroup_uncharge_cache_page(prealloc_page);
+		page_cache_release(prealloc_page);
+	}
 	return error;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
