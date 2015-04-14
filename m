Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A1F4C6B006E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 15:54:51 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so23691418pdb.2
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 12:54:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ag7si3241682pad.120.2015.04.14.12.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 12:54:50 -0700 (PDT)
Date: Tue, 14 Apr 2015 12:54:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm/compaction.c:250:13: warning: 'suitable_migration_target'
 defined but not used
Message-Id: <20150414125449.f97ea3286a90a55531d25924@linux-foundation.org>
In-Reply-To: <201504141443.QeT7AHmI%fengguang.wu@intel.com>
References: <201504141443.QeT7AHmI%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 14 Apr 2015 14:53:45 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   b79013b2449c23f1f505bdf39c5a6c330338b244
> commit: f8224aa5a0a4627926019bba7511926393fbee3b mm, compaction: do not recheck suitable_migration_target under lock
> date:   6 months ago
> config: x86_64-randconfig-ib0-04141359 (attached as .config)
> reproduce:
>   git checkout f8224aa5a0a4627926019bba7511926393fbee3b
>   # save the attached .config to linux build tree
>   make ARCH=x86_64 
> 
> All warnings:
> 
> >> mm/compaction.c:250:13: warning: 'suitable_migration_target' defined but not used [-Wunused-function]
>     static bool suitable_migration_target(struct page *page)
>                 ^

Easy enough - it only has one callsite.

--- a/mm/compaction.c~mm-compactionc-fix-suitable_migration_target-unused-warning
+++ a/mm/compaction.c
@@ -391,28 +391,6 @@ static inline bool compact_should_abort(
 	return false;
 }
 
-/* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
-{
-	/* If the page is a large free page, then disallow migration */
-	if (PageBuddy(page)) {
-		/*
-		 * We are checking page_order without zone->lock taken. But
-		 * the only small danger is that we skip a potentially suitable
-		 * pageblock, so it's not worth to check order for valid range.
-		 */
-		if (page_order_unsafe(page) >= pageblock_order)
-			return false;
-	}
-
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(get_pageblock_migratetype(page)))
-		return true;
-
-	/* Otherwise skip the block */
-	return false;
-}
-
 /*
  * Isolate free pages onto a private freelist. If @strict is true, will abort
  * returning 0 on any invalid PFNs or non-free pages inside of the pageblock
@@ -896,6 +874,29 @@ isolate_migratepages_range(struct compac
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+
+/* Returns true if the page is within a block suitable for migration to */
+static bool suitable_migration_target(struct page *page)
+{
+	/* If the page is a large free page, then disallow migration */
+	if (PageBuddy(page)) {
+		/*
+		 * We are checking page_order without zone->lock taken. But
+		 * the only small danger is that we skip a potentially suitable
+		 * pageblock, so it's not worth to check order for valid range.
+		 */
+		if (page_order_unsafe(page) >= pageblock_order)
+			return false;
+	}
+
+	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
+	if (migrate_async_suitable(get_pageblock_migratetype(page)))
+		return true;
+
+	/* Otherwise skip the block */
+	return false;
+}
+
 /*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
