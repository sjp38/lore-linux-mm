Date: Wed, 22 Jun 2005 09:40:07 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050622164007.25515.4780.50462@tomahawk.engr.sgi.com>
In-Reply-To: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
Subject: [PATCH 2.6.12-rc5 9/10] mm: manual page migration-rc3 -- sys_migrate_pages-permissions-check-rc3.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Add permissions checking to migrate_pages() system call.
The basic idea is that if you could send an arbitary
signal to a process then you are allowed to migrate
that process, or if the calling process has capability
CAP_SYS_ADMIN.  The permissions check is based
on that in check_kill_permission() in kernel/signal.c.

Signed-off-by: Ray Bryant <raybry@sgi.com>
--

 include/linux/capability.h |    2 ++
 mm/mmigrate.c              |   12 ++++++++++++
 2 files changed, 14 insertions(+)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/capability.h
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/include/linux/capability.h	2005-06-13 11:12:33.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/capability.h	2005-06-13 11:13:09.000000000 -0700
@@ -233,6 +233,8 @@ typedef __u32 kernel_cap_t;
 /* Allow enabling/disabling tagged queuing on SCSI controllers and sending
    arbitrary SCSI commands */
 /* Allow setting encryption key on loopback filesystem */
+/* Allow using the migrate_pages() system call to migrate a process's pages
+   from one set of NUMA nodes to another */
 
 #define CAP_SYS_ADMIN        21
 
Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-06-13 11:13:04.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c	2005-06-13 11:13:09.000000000 -0700
@@ -15,6 +15,8 @@
 #include <linux/module.h>
 #include <linux/swap.h>
 #include <linux/pagemap.h>
+#include <linux/sched.h>
+#include <linux/capability.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/writeback.h>
@@ -725,6 +727,16 @@ sys_migrate_pages(pid_t pid, __u32 count
 	task = find_task_by_pid(pid);
 	if (task) {
 		task_lock(task);
+		/* does this task have permission to migrate that task?
+		 * (ala check_kill_permission() ) */
+	        if ((current->euid ^ task->suid) && (current->euid ^ task->uid)
+	           && (current->uid ^ task->suid) && (current->uid ^ task->uid)
+	           && !capable(CAP_SYS_ADMIN)) {
+		   	ret = -EPERM;
+			task_unlock(task);
+			read_unlock(&tasklist_lock);
+			goto out;
+		}
 		mm = task->mm;
 		if (mm) {
 			atomic_inc(&mm->mm_users);

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
