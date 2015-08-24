Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 77DC66B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 19:42:39 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so4371940pad.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:42:39 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id a12si29892483pbu.61.2015.08.24.16.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Aug 2015 16:42:38 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 03/10] mm: make hugetlb.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:35 -0400
Message-ID: <1440454482-12250-4-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>

The Kconfig currently controlling compilation of this code is:

config HUGETLBFS
        bool "HugeTLB file system support"

...meaning that it currently is not being built as a module by anyone.

Lets remove the modular code that is essentially orphaned, so that
when reading the file there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  However
one could argue that fs_initcall() would make more sense here.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/hugetlb.c | 39 +--------------------------------------
 1 file changed, 1 insertion(+), 38 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 586aa69df900..1154152c8b99 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4,7 +4,6 @@
  */
 #include <linux/list.h>
 #include <linux/init.h>
-#include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/seq_file.h>
 #include <linux/sysctl.h>
@@ -2439,25 +2438,6 @@ static void hugetlb_unregister_node(struct node *node)
 	nhs->hugepages_kobj = NULL;
 }
 
-/*
- * hugetlb module exit:  unregister hstate attributes from node devices
- * that have them.
- */
-static void hugetlb_unregister_all_nodes(void)
-{
-	int nid;
-
-	/*
-	 * disable node device registrations.
-	 */
-	register_hugetlbfs_with_node(NULL, NULL);
-
-	/*
-	 * remove hstate attributes from any nodes that have them.
-	 */
-	for (nid = 0; nid < nr_node_ids; nid++)
-		hugetlb_unregister_node(node_devices[nid]);
-}
 
 /*
  * Register hstate attributes for a single node device.
@@ -2522,27 +2502,10 @@ static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
 	return NULL;
 }
 
-static void hugetlb_unregister_all_nodes(void) { }
-
 static void hugetlb_register_all_nodes(void) { }
 
 #endif
 
-static void __exit hugetlb_exit(void)
-{
-	struct hstate *h;
-
-	hugetlb_unregister_all_nodes();
-
-	for_each_hstate(h) {
-		kobject_put(hstate_kobjs[hstate_index(h)]);
-	}
-
-	kobject_put(hugepages_kobj);
-	kfree(hugetlb_fault_mutex_table);
-}
-module_exit(hugetlb_exit);
-
 static int __init hugetlb_init(void)
 {
 	int i;
@@ -2580,7 +2543,7 @@ static int __init hugetlb_init(void)
 		mutex_init(&hugetlb_fault_mutex_table[i]);
 	return 0;
 }
-module_init(hugetlb_init);
+device_initcall(hugetlb_init);
 
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_add_hstate(unsigned order)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
