Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5F09F829BE
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 13:26:46 -0400 (EDT)
Received: by pdbnh10 with SMTP id nh10so30368883pdb.3
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 10:26:46 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id qn11si5179878pdb.229.2015.03.13.10.26.44
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 10:26:45 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V5] Allow compaction of unevictable pages
Date: Fri, 13 Mar 2015 13:26:37 -0400
Message-Id: <1426267597-25811-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, pages which are marked as unevictable are protected from
compaction, but not from other types of migration.  The POSIX real time
extension explicitly states that mlock() will prevent a major page
fault, but the spirit of is is that mlock() should give a process the
ability to control sources of latency, including minor page faults.
However, the mlock manpage only explicitly says that a locked page will
not be written to swap and this can cause some confusion.  The
compaction code today, does not give a developer who wants to avoid swap
but wants to have large contiguous areas available any method to achieve
this state.  This patch introduces a sysctl for controlling compaction
behavoir with respect to the unevictable lru.  Users that demand no page
faults after a page is present can set compact_unevictable to 0 and
users who need the large contiguous areas can enable compaction on
locked memory by setting it to 1.

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
Cc: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
Changes from V3:
* Updated changelog
* Restrict valid input to 0 or 1 in sysctl
* Add documentation to sysctl/vm.txt

 Documentation/sysctl/vm.txt |   11 +++++++++++
 include/linux/compaction.h  |    1 +
 kernel/sysctl.c             |    9 +++++++++
 mm/compaction.c             |    3 +++
 4 files changed, 24 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 902b457..812f0d4 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -21,6 +21,7 @@ Currently, these files are in /proc/sys/vm:
 - admin_reserve_kbytes
 - block_dump
 - compact_memory
+- compact_unevictable
 - dirty_background_bytes
 - dirty_background_ratio
 - dirty_bytes
@@ -106,6 +107,16 @@ huge pages although processes will also directly compact memory as required.
 
 ==============================================================
 
+compact_unevictable
+
+Available only when CONFIG_COMPACTION is set. When set to 1, compaction is
+allowed to examine the unevictable lru (mlocked pages) for pages to compact.
+This should be used on systems where stalls for minor page faults are an
+acceptable trade for large contiguous free memory.  Set to 0 to prevent
+compaction from moving pages that are unevictable.
+
+==============================================================
+
 dirty_background_bytes
 
 Contains the amount of dirty memory at which the background kernel
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
index 88ea2d6..9272568 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1313,6 +1313,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &min_extfrag_threshold,
 		.extra2		= &max_extfrag_threshold,
 	},
+	{
+		.procname	= "compact_unevictable",
+		.data		= &sysctl_compact_unevictable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 
 #endif /* CONFIG_COMPACTION */
 	{
diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..342b221 100644
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
+		(sysctl_compact_unevictable ? ISOLATE_UNEVICTABLE : 0) |
 		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
