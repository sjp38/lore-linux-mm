Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0234405F9
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:09 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id w20so38470676qtb.3
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:09 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id f63si7647982qkd.153.2017.02.17.07.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:08 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 06/14] sysctl: Add global tunable mt_page_copy
Date: Fri, 17 Feb 2017 10:05:43 -0500
Message-Id: <20170217150551.117028-7-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

A new global sysctl tunable 'mt_page_copy' is added which will override
syscall specific requests and enable multi threaded page copy during
all migrations on the system. This tunable is disabled by default.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 kernel/sysctl.c | 11 +++++++++++
 mm/migrate.c    |  5 +++++
 2 files changed, 16 insertions(+)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5b8c0fb3f0ea..70a654146519 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -97,6 +97,8 @@
 
 #if defined(CONFIG_SYSCTL)
 
+extern int mt_page_copy;
+
 /* External variables not in a header file. */
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1360,6 +1362,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
 	},
 #endif
+	{
+		.procname	= "mt_page_copy",
+		.data		= &mt_page_copy,
+		.maxlen		= sizeof(mt_page_copy),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	 {
 		.procname	= "hugetlb_shm_group",
 		.data		= &sysctl_hugetlb_shm_group,
diff --git a/mm/migrate.c b/mm/migrate.c
index 2e58aad7c96f..0e9b1f17cf8b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -48,6 +48,8 @@
 
 #include "internal.h"
 
+int mt_page_copy = 0;
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -618,6 +620,9 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = hpage_nr_pages(src);
 	}
 
+	if (mt_page_copy)
+		mode |= MIGRATE_MT;
+
 	if (mode & MIGRATE_MT)
 		rc = copy_pages_mthread(dst, src, nr_pages);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
