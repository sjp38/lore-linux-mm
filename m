Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 115D76B0263
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:10:24 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id l6so185198436wml.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:10:24 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id q68si1840384wmb.14.2016.04.12.05.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 05:10:22 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id f198so184780467wme.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:10:22 -0700 (PDT)
Date: Tue, 12 Apr 2016 14:10:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm woes, mainly compaction
Message-ID: <20160412121020.GC10771@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 12-04-16 00:18:00, Hugh Dickins wrote:
> Michal, I'm sorry to say that I now find that I misinformed you.
> 
> You'll remember when we were chasing the order=2 OOMs on two of my
> machines at the end of March (in private mail).  And you sent me a
> mail containing two patches, the second "Another thing to try ...
> so this on top" doing a *migrate_mode++.
> 
> I answered you definitively that the first patch worked,
> so "I haven't tried adding the one below at all".
> 
> Not true, I'm afraid.  Although I had split the *migrate_mode++ one
> off into a separate patch that I did not apply, I found looking back
> today (when trying to work out why order=2 OOMs were still a problem
> on mmotm 2016-04-06) that I never deleted that part from the end of
> the first patch; so in fact what I'd been testing had included the
> second; and now I find that _it_ was the effective solution.
> 
> Which is particularly sad because I think we were both a bit
> uneasy about the *migrate_mode++ one: partly the style of it
> incrementing the enum; but more seriously that it advances all the
> way to MIGRATE_SYNC, when the first went only to MIGRATE_SYNC_LIGHT.

Yeah, I was thinking about this some more and I have dropped
MIGRATE_SYNC patch because this is just too dangerous. It gets all the
way to to writeout() and this is a great stack overflow hazard. But I
guess we do not need this writeout and wait_on_page_writeback (done from
__unmap_and_move) would be sufficient. I was already thinking about
splitting MIGRATE_SYNC into two states one allowing the wait on events
and the other to allow the writeout.

> But without it, I am still stuck with the order=2 OOMs.
> 
> And worse: after establishing that that fixes the order=2 OOMs for
> me on 4.6-rc2-mm1, I thought I'd better check that the three you
> posted today (the 1/2 classzone_idx one, the 2/2 prevent looping
> forever, and the "ction-abstract-compaction-feedback-to-helpers-fix";
> but I'm too far behind to consider or try the RFC thp backoff one)
> (a) did not surprisingly fix it on their own, and (b) worked well
> with the *migrate_mode++ one added in.

I am not really sure what you have been testing here. The hugetlb load
or the same make on tmpfs? I would be really surprised if any of the
above pathces made any difference for the make workload. 
 
> (a) as you'd expect, they did not help on their own; and (b) they
> worked fine together on the G5 (until it hit the powerpc swapping
> sigsegv, which I think the powerpc guys are hoping is a figment of
> my imagination); but (b) they did not work fine together on the
> laptop, that combination now gives it order=1 OOMs.  Despair.

Something is definitelly wrong here. I have already seen that compaction
is sometimes giving surprising results. I have seen Vlastimil has posted
some fixes so maybe this would be a side effect. I also hope to come up
with some reasonable set of trace points to tell us more but let's see
whether the order-2 issue can be solved first.

This is still with the ugly enum++ but let's close eyes and think about
something nicer...

Thanks!
---
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index ebf3d89a3919..e1947d7af63f 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -6,11 +6,14 @@
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
  * MIGRATE_SYNC will block when migrating pages
+ * MIGRATE_SYNC_WRITEOUT will trigger the IO when migrating pages. Make sure
+ * 	to not use this flag from deep stacks.
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
+	MIGRATE_SYNC_WRITEOUT,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index 539b25a76111..0f14c65865ad 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -9,7 +9,8 @@
 #define MIGRATE_MODE						\
 	EM( MIGRATE_ASYNC,	"MIGRATE_ASYNC")		\
 	EM( MIGRATE_SYNC_LIGHT,	"MIGRATE_SYNC_LIGHT")		\
-	EMe(MIGRATE_SYNC,	"MIGRATE_SYNC")
+	EM( MIGRATE_SYNC,	"MIGRATE_SYNC")			\
+	EMe(MIGRATE_SYNC_WRITEOUT, "MIGRATE_SYNC_WRITEOUT")
 
 
 #define MIGRATE_REASON						\
diff --git a/mm/compaction.c b/mm/compaction.c
index 68dfbc07692d..7f631a6e234f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1839,7 +1839,7 @@ static void compact_node(int nid)
 {
 	struct compact_control cc = {
 		.order = -1,
-		.mode = MIGRATE_SYNC,
+		.mode = MIGRATE_SYNC_WRITEOUT,
 		.ignore_skip_hint = true,
 	};
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 5a544c6c0717..a591b29a25ba 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1571,7 +1571,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	}
 
 	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-				MIGRATE_SYNC, MR_MEMORY_FAILURE);
+				MIGRATE_SYNC_WRITEOUT, MR_MEMORY_FAILURE);
 	if (ret) {
 		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 			pfn, ret, page->flags);
@@ -1651,7 +1651,7 @@ static int __soft_offline_page(struct page *page, int flags)
 					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-					MIGRATE_SYNC, MR_MEMORY_FAILURE);
+					MIGRATE_SYNC_WRITEOUT, MR_MEMORY_FAILURE);
 		if (ret) {
 			if (!list_empty(&pagelist)) {
 				list_del(&page->lru);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7ad0d2eb9a2c..6cd8664c9e6e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1554,7 +1554,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		 * migrate_pages returns # of failed pages.
 		 */
 		ret = migrate_pages(&source, alloc_migrate_target, NULL, 0,
-					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
+					MIGRATE_SYNC_WRITEOUT, MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_movable_pages(&source);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7f80ebcd6552..a6a947980773 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1001,7 +1001,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_node_page, NULL, dest,
-					MIGRATE_SYNC, MR_SYSCALL);
+					MIGRATE_SYNC_WRITEOUT, MR_SYSCALL);
 		if (err)
 			putback_movable_pages(&pagelist);
 	}
@@ -1242,7 +1242,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 		if (!list_empty(&pagelist)) {
 			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
 			nr_failed = migrate_pages(&pagelist, new_page, NULL,
-				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
+				start, MIGRATE_SYNC_WRITEOUT, MR_MEMPOLICY_MBIND);
 			if (nr_failed)
 				putback_movable_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 028814625eea..3e907354cfec 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -809,7 +809,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
-		if (mode != MIGRATE_SYNC)
+		if (mode != MIGRATE_SYNC_WRITEOUT)
 			return -EBUSY;
 		return writeout(mapping, page);
 	}
@@ -938,7 +938,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		if (mode != MIGRATE_SYNC) {
+		if (mode < MIGRATE_SYNC) {
 			rc = -EBUSY;
 			goto out_unlock;
 		}
@@ -1187,7 +1187,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (!trylock_page(hpage)) {
-		if (!force || mode != MIGRATE_SYNC)
+		if (!force || mode < MIGRATE_SYNC)
 			goto out;
 		lock_page(hpage);
 	}
@@ -1447,7 +1447,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node, NULL,
-				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
+				(unsigned long)pm, MIGRATE_SYNC_WRITEOUT, MR_SYSCALL);
 		if (err)
 			putback_movable_pages(&pagelist);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d1da0ceaf1e..d80c9755ffc7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3030,8 +3030,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * failure could be caused by weak migration mode.
 	 */
 	if (compaction_failed(compact_result)) {
-		if (*migrate_mode == MIGRATE_ASYNC) {
-			*migrate_mode = MIGRATE_SYNC_LIGHT;
+		if (*migrate_mode < MIGRATE_SYNC) {
+			*migrate_mode++;
 			return true;
 		}
 		return false;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
