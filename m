Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 968094402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 14:11:31 -0500 (EST)
Received: by mail-qk0-f175.google.com with SMTP id t125so102598017qkh.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:11:31 -0800 (PST)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id y188si12518384qhc.72.2015.12.17.11.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 11:11:30 -0800 (PST)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 1/8] hugetlb: make mm and fs code explicitly non-modular
Date: Thu, 17 Dec 2015 14:10:59 -0500
Message-ID: <1450379466-23115-2-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1450379466-23115-1-git-send-email-paul.gortmaker@windriver.com>
References: <1450379466-23115-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

The Kconfig currently controlling compilation of this code is:

config HUGETLBFS
        bool "HugeTLB file system support"

...meaning that it currently is not being built as a module by anyone.

Lets remove the modular code that is essentially orphaned, so that
when reading the driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering gets moved to earlier levels when we use the
more appropriate initcalls here.

Originally I had the fs part and the mm part as separate commits,
just by happenstance of the nature of how I detected these
non-modular use cases.  But that can possibly introduce regressions
if the patch merge ordering puts the fs part 1st -- as the 0-day
testing reported a splat at mount time.

Investigating with "initcall_debug" showed that the delta was
init_hugetlbfs_fs being called _before_ hugetlb_init instead of
after.  So both the fs change and the mm change are here together.

In addition, it worked before due to luck of link order, since they
were both in the same initcall category.  So we now have the fs
part using fs_initcall, and the mm part using subsys_initcall,
which puts it one bucket earlier.  It now passes the basic sanity
test that failed in earlier 0-day testing.

We delete the MODULE_LICENSE tag and capture that information at the
top of the file alongside author comments, etc.

We don't replace module.h with init.h since the file already has that.
Also note that MODULE_ALIAS is a no-op for non-modular code.

Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org
Reported-by: kernel test robot <ying.huang@linux.intel.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 fs/hugetlbfs/inode.c | 27 ++-------------------------
 mm/hugetlb.c         | 39 +--------------------------------------
 2 files changed, 3 insertions(+), 63 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index de4bdfac0cec..dd04c2ad23b3 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -4,11 +4,11 @@
  * Nadia Yvette Chambers, 2002
  *
  * Copyright (C) 2002 Linus Torvalds.
+ * License: GPL
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include <linux/module.h>
 #include <linux/thread_info.h>
 #include <asm/current.h>
 #include <linux/sched.h>		/* remove ASAP */
@@ -1201,7 +1201,6 @@ static struct file_system_type hugetlbfs_fs_type = {
 	.mount		= hugetlbfs_mount,
 	.kill_sb	= kill_litter_super,
 };
-MODULE_ALIAS_FS("hugetlbfs");
 
 static struct vfsmount *hugetlbfs_vfsmount[HUGE_MAX_HSTATE];
 
@@ -1355,26 +1354,4 @@ static int __init init_hugetlbfs_fs(void)
  out2:
 	return error;
 }
-
-static void __exit exit_hugetlbfs_fs(void)
-{
-	struct hstate *h;
-	int i;
-
-
-	/*
-	 * Make sure all delayed rcu free inodes are flushed before we
-	 * destroy cache.
-	 */
-	rcu_barrier();
-	kmem_cache_destroy(hugetlbfs_inode_cachep);
-	i = 0;
-	for_each_hstate(h)
-		kern_unmount(hugetlbfs_vfsmount[i++]);
-	unregister_filesystem(&hugetlbfs_fs_type);
-}
-
-module_init(init_hugetlbfs_fs)
-module_exit(exit_hugetlbfs_fs)
-
-MODULE_LICENSE("GPL");
+fs_initcall(init_hugetlbfs_fs)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ef6963b577fd..be934df69b85 100644
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
@@ -2549,25 +2548,6 @@ static void hugetlb_unregister_node(struct node *node)
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
@@ -2632,27 +2612,10 @@ static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
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
@@ -2690,7 +2653,7 @@ static int __init hugetlb_init(void)
 		mutex_init(&hugetlb_fault_mutex_table[i]);
 	return 0;
 }
-module_init(hugetlb_init);
+subsys_initcall(hugetlb_init);
 
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_add_hstate(unsigned int order)
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
