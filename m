Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0739228027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 06:45:34 -0400 (EDT)
Received: by wiga1 with SMTP id a1so125021091wig.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 03:45:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hg7si8345801wib.66.2015.07.15.03.45.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 03:45:32 -0700 (PDT)
Date: Wed, 15 Jul 2015 11:45:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: 4.2-rc2: hitting "file-max limit 8192 reached"
Message-ID: <20150715104526.GB6812@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <1430231830-7702-8-git-send-email-mgorman@suse.de>
 <55A530A3.2080301@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55A530A3.2080301@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jul 14, 2015 at 08:54:11AM -0700, Dave Hansen wrote:
> My laptop has been behaving strangely with 4.2-rc2.  Once I log in to my
> X session, I start getting all kinds of strange errors from applications
> and see this in my dmesg:
> 
> 	VFS: file-max limit 8192 reached
> 
> Could this be from CONFIG_DEFERRED_STRUCT_PAGE_INIT=y?  files_init()
> seems top be sizing files_stat.max_files from memory sizes.
> 

Yep.

I'm very sick at the moment and running a temperature so this needs double
checking. Medication is helping but I'm nowhere near 100%.

Andrew mentioned nr_free_buffer_pages and nr_free_pagecache_pages.
They are both live calculation that walks through zonelists with return
values based on zone->managed_pages. They are not affected by deferred
memory initialisation which leaves managed_pages alone.

AFAICS, the key problem is to watch for initialisations that are based on
free memory. It appears that only file_table.c cares and the calculation
of limits can be done after deferred memory initialisation like this;

---8<---
fs, file table: Reinit files_stat.max_files after deferred memory initialisation

Dave Hansen reported the following;

	My laptop has been behaving strangely with 4.2-rc2.  Once I log
	in to my X session, I start getting all kinds of strange errors
	from applications and see this in my dmesg:

        	VFS: file-max limit 8192 reached

The problem is that the file-max is calculated before memory is fully
initialised and miscalculates how much memory the kernel is using. This
patch recalculates file-max after deferred memory initialisation. Note
that using memory hotplug infrastructure would not have avoided this
problem as the value is not recalculated after memory hot-add.

4.1:             files_stat.max_files = 6582781
4.2-rc2:         files_stat.max_files = 8192
4.2-rc2 patched: files_stat.max_files = 6562467

Small differences with the patch applied and 4.1 but not enough to matter.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/dcache.c        | 13 +++----------
 fs/file_table.c    | 24 +++++++++++++++---------
 include/linux/fs.h |  5 +++--
 init/main.c        |  2 +-
 mm/page_alloc.c    |  3 +++
 5 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 5c8ea15e73a5..9b5fe503f6cb 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3442,22 +3442,15 @@ void __init vfs_caches_init_early(void)
 	inode_init_early();
 }
 
-void __init vfs_caches_init(unsigned long mempages)
+void __init vfs_caches_init(void)
 {
-	unsigned long reserve;
-
-	/* Base hash sizes on available memory, with a reserve equal to
-           150% of current kernel size */
-
-	reserve = min((mempages - nr_free_pages()) * 3/2, mempages - 1);
-	mempages -= reserve;
-
 	names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
 
 	dcache_init();
 	inode_init();
-	files_init(mempages);
+	files_init();
+	files_maxfiles_init();
 	mnt_init();
 	bdev_cache_init();
 	chrdev_init();
diff --git a/fs/file_table.c b/fs/file_table.c
index 7f9d407c7595..ad17e05ebf95 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -25,6 +25,7 @@
 #include <linux/hardirq.h>
 #include <linux/task_work.h>
 #include <linux/ima.h>
+#include <linux/swap.h>
 
 #include <linux/atomic.h>
 
@@ -308,19 +309,24 @@ void put_filp(struct file *file)
 	}
 }
 
-void __init files_init(unsigned long mempages)
+void __init files_init(void)
 { 
-	unsigned long n;
-
 	filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
 			SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	percpu_counter_init(&nr_files, 0, GFP_KERNEL);
+}
 
-	/*
-	 * One file with associated inode and dcache is very roughly 1K.
-	 * Per default don't use more than 10% of our memory for files. 
-	 */ 
+/*
+ * One file with associated inode and dcache is very roughly 1K. Per default
+ * do not use more than 10% of our memory for files.
+ */
+void __init files_maxfiles_init(void)
+{
+	unsigned long n;
+	unsigned long memreserve = (totalram_pages - nr_free_pages()) * 3/2;
+
+	memreserve = min(memreserve, totalram_pages - 1);
+	n = ((totalram_pages - memreserve) * (PAGE_SIZE / 1024)) / 10;
 
-	n = (mempages * (PAGE_SIZE / 1024)) / 10;
 	files_stat.max_files = max_t(unsigned long, n, NR_FILE);
-	percpu_counter_init(&nr_files, 0, GFP_KERNEL);
 } 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a0653e560c26..e6ceaae3a50e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -55,7 +55,8 @@ struct vm_fault;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
-extern void __init files_init(unsigned long);
+extern void __init files_init(void);
+extern void __init files_maxfiles_init(void);
 
 extern struct files_stat_struct files_stat;
 extern unsigned long get_max_files(void);
@@ -2235,7 +2236,7 @@ extern int ioctl_preallocate(struct file *filp, void __user *argp);
 
 /* fs/dcache.c */
 extern void __init vfs_caches_init_early(void);
-extern void __init vfs_caches_init(unsigned long);
+extern void __init vfs_caches_init(void);
 
 extern struct kmem_cache *names_cachep;
 
diff --git a/init/main.c b/init/main.c
index c5d5626289ce..56506553d4d8 100644
--- a/init/main.c
+++ b/init/main.c
@@ -656,7 +656,7 @@ asmlinkage __visible void __init start_kernel(void)
 	key_init();
 	security_init();
 	dbg_late_init();
-	vfs_caches_init(totalram_pages);
+	vfs_caches_init();
 	signals_init();
 	/* rootfs populating might need page-writeback */
 	page_writeback_init();
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a69e78c396a0..94e2599830c2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1203,6 +1203,9 @@ void __init page_alloc_init_late(void)
 
 	/* Block until all are initialised */
 	wait_for_completion(&pgdat_init_all_done_comp);
+
+	/* Reinit limits that are based on free pages after the kernel is up */
+	files_maxfiles_init();
 }
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
