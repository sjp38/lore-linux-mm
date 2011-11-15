Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 308DF6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 01:54:33 -0500 (EST)
Subject: [patch v2 1/4]thp: improve the error code path
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Nov 2011 15:04:11 +0800
Message-ID: <1321340651.22361.294.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>

Improve the error code path. Delete unnecessary sysfs file for example.
Also remove the #ifdef xxx to make code better.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/huge_memory.c |   71 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 50 insertions(+), 21 deletions(-)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-11-10 15:51:03.000000000 +0800
+++ linux/mm/huge_memory.c	2011-11-11 13:32:44.000000000 +0800
@@ -487,41 +487,68 @@ static struct attribute_group khugepaged
 	.attrs = khugepaged_attr,
 	.name = "khugepaged",
 };
-#endif /* CONFIG_SYSFS */
 
-static int __init hugepage_init(void)
+static int __init hugepage_init_sysfs(struct kobject **hugepage_kobj)
 {
 	int err;
-#ifdef CONFIG_SYSFS
-	static struct kobject *hugepage_kobj;
-#endif
 
-	err = -EINVAL;
-	if (!has_transparent_hugepage()) {
-		transparent_hugepage_flags = 0;
-		goto out;
-	}
-
-#ifdef CONFIG_SYSFS
-	err = -ENOMEM;
-	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
-	if (unlikely(!hugepage_kobj)) {
+	*hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
+	if (unlikely(!*hugepage_kobj)) {
 		printk(KERN_ERR "hugepage: failed kobject create\n");
-		goto out;
+		return -ENOMEM;
 	}
 
-	err = sysfs_create_group(hugepage_kobj, &hugepage_attr_group);
+	err = sysfs_create_group(*hugepage_kobj, &hugepage_attr_group);
 	if (err) {
 		printk(KERN_ERR "hugepage: failed register hugeage group\n");
-		goto out;
+		goto delete_obj;
 	}
 
-	err = sysfs_create_group(hugepage_kobj, &khugepaged_attr_group);
+	err = sysfs_create_group(*hugepage_kobj, &khugepaged_attr_group);
 	if (err) {
 		printk(KERN_ERR "hugepage: failed register hugeage group\n");
-		goto out;
+		goto remove_hp_group;
 	}
-#endif
+
+	return 0;
+
+remove_hp_group:
+	sysfs_remove_group(*hugepage_kobj, &hugepage_attr_group);
+delete_obj:
+	kobject_put(*hugepage_kobj);
+	return err;
+}
+
+static void __init hugepage_exit_sysfs(struct kobject *hugepage_kobj)
+{
+	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
+	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
+	kobject_put(hugepage_kobj);
+}
+#else
+static inline int hugepage_init_sysfs(struct kobject **hugepage_kobj)
+{
+	return 0;
+}
+
+static inline void hugepage_exit_sysfs(struct kobject *hugepage_kobj)
+{
+}
+#endif /* CONFIG_SYSFS */
+
+static int __init hugepage_init(void)
+{
+	int err;
+	struct kobject *hugepage_kobj;
+
+	if (!has_transparent_hugepage()) {
+		transparent_hugepage_flags = 0;
+		return -EINVAL;
+	}
+
+	err = hugepage_init_sysfs(&hugepage_kobj);
+	if (err)
+		return err;
 
 	err = khugepaged_slab_init();
 	if (err)
@@ -545,7 +572,9 @@ static int __init hugepage_init(void)
 
 	set_recommended_min_free_kbytes();
 
+	return 0;
 out:
+	hugepage_exit_sysfs(hugepage_kobj);
 	return err;
 }
 module_init(hugepage_init)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
