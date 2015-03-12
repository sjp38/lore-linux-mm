Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8F29F8299B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 11:23:15 -0400 (EDT)
Received: by pdbft15 with SMTP id ft15so20906633pdb.6
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:23:15 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id re3si13934497pab.70.2015.03.12.08.23.14
        for <linux-mm@kvack.org>;
        Thu, 12 Mar 2015 08:23:14 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V4] Allow compaction of unevictable pages
Date: Thu, 12 Mar 2015 11:22:56 -0400
Message-Id: <1426173776-23471-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, pages which are marked as unevictable are protected from
compaction, but not from other types of migration.  The mlock
desctription does not promise that all page faults will be avoided, only
major ones so this protection is not necessary.  This extra protection
can cause problems for applications that are using mlock to avoid
swapping pages out, but require order > 0 allocations to continue to
succeed in a fragmented environment.  This patch adds a sysctl entry
that will be used to allow root to enable compaction of unevictable
pages.

To illustrate this problem I wrote a quick test program that mmaps a
large number of 1MB files filled with random data.  These maps are
created locked and read only.  Then every other mmap is unmapped and I
attempt to allocate huge pages to the static huge page pool.  When the
compact_unevictable sysctl is 0, I cannot allocate hugepages after
fragmenting memory.  When the value is set to 1, allocations succeed.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
Changes from V3:
Instead of removing the ISOLATE_UNEVICTABLE mode and checks, allow the
sysadmin to control if compaction of unevictable pages is allowable.

 include/linux/compaction.h |    1 +
 kernel/sysctl.c            |    7 +++++++
 mm/compaction.c            |    3 +++
 3 files changed, 11 insertions(+)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a014559..9dd7e7c 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -34,6 +34,7 @@ extern int sysctl_compaction_handler(struct ctl_table *table, int write,
 extern int sysctl_extfrag_threshold;
 extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
+extern int sysctl_compact_unevictable;
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 88ea2d6..cc1a678 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1313,6 +1313,13 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &min_extfrag_threshold,
 		.extra2		= &max_extfrag_threshold,
 	},
+	{
+		.procname	= "compact_unevictable",
+		.data		= &sysctl_compact_unevictable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 
 #endif /* CONFIG_COMPACTION */
 	{
diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..b2c1e4e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1046,6 +1046,8 @@ typedef enum {
 	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
 } isolate_migrate_t;
 
+int sysctl_compact_unevictable;
+
 /*
  * Isolate all pages that can be migrated from the first suitable block,
  * starting at the block pointed to by the migrate scanner pfn within
@@ -1057,6 +1059,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long low_pfn, end_pfn;
 	struct page *page;
 	const isolate_mode_t isolate_mode =
+		(sysctl_compact_unevictable ? ISOLATE_UNEVICTABLE: 0) |
 		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
