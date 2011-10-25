Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CC63A6B002D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 22:51:09 -0400 (EDT)
Subject: [patch 1/5]thp: improve the error code path
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Oct 2011 10:58:41 +0800
Message-ID: <1319511521.22361.135.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Improve the error code path. Delete unnecessary sysfs file for example.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/huge_memory.c |   23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-10-19 14:07:27.000000000 +0800
+++ linux/mm/huge_memory.c	2011-10-24 19:24:31.000000000 +0800
@@ -512,25 +512,23 @@ static int __init hugepage_init(void)
 	err = sysfs_create_group(hugepage_kobj, &hugepage_attr_group);
 	if (err) {
 		printk(KERN_ERR "hugepage: failed register hugeage group\n");
-		goto out;
+		goto delete_obj;
 	}
 
 	err = sysfs_create_group(hugepage_kobj, &khugepaged_attr_group);
 	if (err) {
 		printk(KERN_ERR "hugepage: failed register hugeage group\n");
-		goto out;
+		goto remove_hp_group;
 	}
 #endif
 
 	err = khugepaged_slab_init();
 	if (err)
-		goto out;
+		goto remove_khp_group;
 
 	err = mm_slots_hash_init();
-	if (err) {
-		khugepaged_slab_free();
-		goto out;
-	}
+	if (err)
+		goto free_slab;
 
 	/*
 	 * By default disable transparent hugepages on smaller systems,
@@ -544,7 +542,18 @@ static int __init hugepage_init(void)
 
 	set_recommended_min_free_kbytes();
 
+	return err;
+free_slab:
+	khugepaged_slab_free();
+remove_khp_group:
+#ifdef CONFIG_SYSFS
+	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
+remove_hp_group:
+	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
+delete_obj:
+	kobject_put(hugepage_kobj);
 out:
+#endif
 	return err;
 }
 module_init(hugepage_init)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
