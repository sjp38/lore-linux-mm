Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B03656B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 20:29:24 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5688384dak.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 17:29:24 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH v5] remove no longer use of pdflush interface
Date: Mon, 11 Jun 2012 08:29:03 +0800
Message-Id: <1339374543-2681-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Rob Landley <rob@landley.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Curt Wohlgemuth <curtw@google.com>, Mike Frysinger <vapier@gentoo.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <jweiner@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Vasily Averin <vvs@sw.ru>, Michel Lespinasse <walken@google.com>, Jens Axboe <axboe@kernel.dk>, Rabin Vincent <rabin@rab.in>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>, Wanpeng Li <liwp@linux.vnet.ibm.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Since per-BDI flusher introduced to linux 2.6, pdflush mechanism is not
used any more, but the old interface of pdflush exported through /proc/sys/vm/
is still existing and obviously useless. In order for back-compatibility,
printk warning information and return 0 to notify the users that the
interface is removed.

Signed-off-by: Wanpeng Li <liwp@linux.vnet.ibm.com>

"V4 -> V5":

* remove useless comment
* copy "0\n" out to userspace and return 2

"V3 -> V4":

* replace generic proc_obsolete() by pdflush_proc_obsolete() which just
  addresses old pdflush interface

"V2 -> V3":

* rename proc_deprecated() to proc_obsolete()
* replace printk in proc_obsolete by prink_once and change warning
* information

"V1 -> V2":

* add printk warning
* add description in Documentation
---
 .../ABI/obsolete/proc-sys-vm-nr_pdflush_threads    |    5 +++++
 Documentation/feature-removal-schedule.txt         |    8 ++++++++
 Documentation/sysctl/vm.txt                        |   11 -----------
 fs/fs-writeback.c                                  |    5 -----
 include/linux/backing-dev.h                        |    3 +++
 include/linux/writeback.h                          |    5 -----
 kernel/sysctl.c                                    |    8 +++-----
 kernel/sysctl_binary.c                             |    2 +-
 mm/backing-dev.c                                   |   20 ++++++++++++++++++++
 9 files changed, 40 insertions(+), 27 deletions(-)
 create mode 100644 Documentation/ABI/obsolete/proc-sys-vm-nr_pdflush_threads

diff --git a/Documentation/ABI/obsolete/proc-sys-vm-nr_pdflush_threads b/Documentation/ABI/obsolete/proc-sys-vm-nr_pdflush_threads
new file mode 100644
index 0000000..b0b0eeb
--- /dev/null
+++ b/Documentation/ABI/obsolete/proc-sys-vm-nr_pdflush_threads
@@ -0,0 +1,5 @@
+What:		/proc/sys/vm/nr_pdflush_threads
+Date:		June 2012
+Contact:	Wanpeng Li <liwp@linux.vnet.ibm.com>
+Description: Since pdflush is replaced by per-BDI flusher, the interface of old pdflush
+             exported in /proc/sys/vm/ should be removed.
diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 56000b3..8e4a60c 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -13,6 +13,14 @@ Who:	Jim Cromie <jim.cromie@gmail.com>, Jason Baron <jbaron@redhat.com>
 
 ---------------------------
 
+What: /proc/sys/vm/nr_pdflush_threads
+When: 2012
+Why: Since pdflush is deprecated, the interface exported in /proc/sys/vm/
+     should be removed.
+Who: Wanpeng Li <liwp@linux.vnet.ibm.com>
+
+---------------------------
+
 What:	CONFIG_APM_CPU_IDLE, and its ability to call APM BIOS in idle
 When:	2012
 Why:	This optional sub-feature of APM is of dubious reliability,
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 96f0ee8..71c17d2 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -42,7 +42,6 @@ Currently, these files are in /proc/sys/vm:
 - mmap_min_addr
 - nr_hugepages
 - nr_overcommit_hugepages
-- nr_pdflush_threads
 - nr_trim_pages         (only if CONFIG_MMU=n)
 - numa_zonelist_order
 - oom_dump_tasks
@@ -426,16 +425,6 @@ See Documentation/vm/hugetlbpage.txt
 
 ==============================================================
 
-nr_pdflush_threads
-
-The current number of pdflush threads.  This value is read-only.
-The value changes according to the number of dirty pages in the system.
-
-When necessary, additional pdflush threads are created, one per second, up to
-nr_pdflush_threads_max.
-
-==============================================================
-
 nr_trim_pages
 
 This is available only on NOMMU kernels.
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d462fe7..37e9ced 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -52,11 +52,6 @@ struct wb_writeback_work {
 	struct completion *done;	/* set if the caller waits */
 };
 
-/*
- * We don't actually have pdflush, but this one is exported though /proc...
- */
-int nr_pdflush_threads;
-
 /**
  * writeback_in_progress - determine whether there is writeback in progress
  * @bdi: the device's backing_dev_info structure.
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index b1038bd..db7a5ab 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -17,6 +17,7 @@
 #include <linux/timer.h>
 #include <linux/writeback.h>
 #include <linux/atomic.h>
+#include <linux/sysctl.h>
 
 struct page;
 struct device;
@@ -304,6 +305,8 @@ void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
 void set_bdi_congested(struct backing_dev_info *bdi, int sync);
 long congestion_wait(int sync, long timeout);
 long wait_iff_congested(struct zone *zone, int sync, long timeout);
+int pdflush_proc_obsolete(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos);
 
 static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
 {
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 6d0a0fc..c66fe33 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -189,9 +189,4 @@ void tag_pages_for_writeback(struct address_space *mapping,
 
 void account_page_redirty(struct page *page);
 
-/* pdflush.c */
-extern int nr_pdflush_threads;	/* Global so it can be exported to sysctl
-				   read-only. */
-
-
 #endif		/* WRITEBACK_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4ab1187..b3b9ba4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1095,11 +1095,9 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 	{
-		.procname	= "nr_pdflush_threads",
-		.data		= &nr_pdflush_threads,
-		.maxlen		= sizeof nr_pdflush_threads,
-		.mode		= 0444 /* read-only*/,
-		.proc_handler	= proc_dointvec,
+		.procname       = "nr_pdflush_threads",
+		.mode           = 0444 /* read-only */,
+		.proc_handler   = pdflush_proc_obsolete,
 	},
 	{
 		.procname	= "swappiness",
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index a650694..65bdcf1 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -147,7 +147,7 @@ static const struct bin_table bin_vm_table[] = {
 	{ CTL_INT,	VM_DIRTY_RATIO,			"dirty_ratio" },
 	/* VM_DIRTY_WB_CS "dirty_writeback_centisecs" no longer used */
 	/* VM_DIRTY_EXPIRE_CS "dirty_expire_centisecs" no longer used */
-	{ CTL_INT,	VM_NR_PDFLUSH_THREADS,		"nr_pdflush_threads" },
+	/* VM_NR_PDFLUSH_THREADS "nr_pdflush_threads" no longer used */
 	{ CTL_INT,	VM_OVERCOMMIT_RATIO,		"overcommit_ratio" },
 	/* VM_PAGEBUF unused */
 	/* VM_HUGETLB_PAGES "nr_hugepages" no longer used */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index dd8e2aa..e9caa10 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -886,3 +886,23 @@ out:
 	return ret;
 }
 EXPORT_SYMBOL(wait_iff_congested);
+
+int pdflush_proc_obsolete(struct ctl_table *table, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	char kbuf[] = "0\n";
+
+	if (*ppos) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (copy_to_user(buffer, kbuf, sizeof(kbuf)))
+		return -EFAULT;
+	printk_once(KERN_WARNING "%s exported in /proc is scheduled for removal\n",
+			table->procname);
+
+	*lenp = 2;
+	*ppos += *lenp;
+	return 0;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
