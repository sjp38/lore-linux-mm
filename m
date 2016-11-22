Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF1536B0268
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:26:26 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id h201so15312545qke.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:26:26 -0800 (PST)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id s5si16816987qkd.293.2016.11.22.08.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:26:26 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH 5/5] mm: migrate: Add vm.accel_page_copy in sysfs to control whether to use multi-threaded to accelerate page copy.
Date: Tue, 22 Nov 2016 11:25:30 -0500
Message-Id: <20161122162530.2370-6-zi.yan@sent.com>
In-Reply-To: <20161122162530.2370-1-zi.yan@sent.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

From: Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <ziy@nvidia.com>

Since base page migration did not gain any speedup from
multi-threaded methods, we only accelerate the huge page case.

Signed-off-by: Zi Yan <ziy@nvidia.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 kernel/sysctl.c | 11 +++++++++++
 mm/migrate.c    |  6 ++++++
 2 files changed, 17 insertions(+)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d54ce12..6c79444 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -98,6 +98,8 @@
 #if defined(CONFIG_SYSCTL)
 
 
+extern int accel_page_copy;
+
 /* External variables not in a header file. */
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1361,6 +1363,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
 	},
 #endif
+	{
+		.procname	= "accel_page_copy",
+		.data		= &accel_page_copy,
+		.maxlen		= sizeof(accel_page_copy),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	 {
 		.procname	= "hugetlb_shm_group",
 		.data		= &sysctl_hugetlb_shm_group,
diff --git a/mm/migrate.c b/mm/migrate.c
index 244ece6..e64b490 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -48,6 +48,8 @@
 
 #include "internal.h"
 
+int accel_page_copy = 1;
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -651,6 +653,10 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = hpage_nr_pages(src);
 	}
 
+	/* Try to accelerate page migration if it is not specified in mode  */
+	if (accel_page_copy)
+		mode |= MIGRATE_MT;
+
 	if (mode & MIGRATE_MT)
 		rc = copy_page_mt(dst, src, nr_pages);
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
