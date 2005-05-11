Date: Tue, 10 May 2005 21:38:47 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050511043847.10876.65016.55033@jackhammer.engr.sgi.com>
In-Reply-To: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.12-rc3 8/8] mm: manual page migration-rc2 -- sys_migrate_pages-permissions-check-rc2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>
List-ID: <linux-mm.kvack.org>

Add permissions checking to migrate_pages() system call.  The basic
idea is that if the calling process could send an arbitary signal to a
process then you are allowed to migrate that process, or if the calling
process has capability CAP_SYS_ADMIN.  The permissions check is based
on that in check_kill_permission() in kernel/signal.c.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 include/linux/capability.h |    2 ++
 mm/mmigrate.c              |   14 ++++++++++++++
 2 files changed, 16 insertions(+)

Index: linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/capability.h
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/include/linux/capability.h	2005-05-10 12:29:49.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/capability.h	2005-05-10 12:31:16.000000000 -0700
@@ -233,6 +233,8 @@ typedef __u32 kernel_cap_t;
 /* Allow enabling/disabling tagged queuing on SCSI controllers and sending
    arbitrary SCSI commands */
 /* Allow setting encryption key on loopback filesystem */
+/* Allow using the migrate_pages() system call to migrate a process's pages
+   from one set of NUMA nodes to another */
 
 #define CAP_SYS_ADMIN        21
 
Index: linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-05-10 12:29:49.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c	2005-05-10 12:54:26.000000000 -0700
@@ -15,6 +15,8 @@
 #include <linux/module.h>
 #include <linux/swap.h>
 #include <linux/pagemap.h>
+#include <linux/sched.h>
+#include <linux/capability.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/writeback.h>
@@ -775,6 +777,18 @@ sys_migrate_pages(const pid_t pid, const
 	task = find_task_by_pid(pid);
 	if (task) {
 		task_lock(task);
+		/*
+		 * does this task have permission to migrate that task?
+		 * (ala check_kill_permission() )
+		 */
+	        if ((current->euid ^ task->suid) && (current->euid ^ task->uid)
+	           && (current->uid ^ task->suid) && (current->uid ^ task->uid)
+	           && !capable(CAP_SYS_ADMIN)) {
+		   	ret = -EPERM;
+			task_unlock(task);
+			read_unlock(&tasklist_lock);
+			goto out;
+		}
 		mm = task->mm;
 		if (mm)
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
