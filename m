Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1076F5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 20:13:20 -0400 (EDT)
Date: Tue, 7 Apr 2009 19:13:30 -0500
From: Russ Anderson <rja@sgi.com>
Subject: [PATCH 2/2] ia64: Call migration code on correctable errors
Message-ID: <20090408001330.GC27170@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
Cc: Russ Anderson <rja@sgi.com>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Migrate data off pages with correctable memory errors.  This patch is 
ia64 specific.  It connects the CPE handler to the page migration
code.  It is implemented as a kernel loadable module, similar to the mca
recovery code (mca_recovery.ko).  This allows the feature to be turned off
by uninstalling the module.  

It adds a /sys/firmware/badram/ interface to control migrate_threshold,
cpe_polling_threshold, and cmc_polling_threshold.


Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/Kconfig              |   10 
 arch/ia64/include/asm/mca.h    |   14 
 arch/ia64/include/asm/page.h   |    1 
 arch/ia64/kernel/Makefile      |    1 
 arch/ia64/kernel/cpe_migrate.c |  628 +++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/mca.c         |  120 ++++++-
 6 files changed, 753 insertions(+), 21 deletions(-)

Index: linux-next/arch/ia64/Kconfig
===================================================================
--- linux-next.orig/arch/ia64/Kconfig	2009-04-07 18:31:43.494292010 -0500
+++ linux-next/arch/ia64/Kconfig	2009-04-07 18:37:00.045826021 -0500
@@ -512,6 +512,16 @@ config COMPAT_FOR_U64_ALIGNMENT
 config IA64_MCA_RECOVERY
 	tristate "MCA recovery from errors other than TLB."
 
+config IA64_CPE_MIGRATE
+	tristate "Migrate data off pages with correctable errors"
+	depends on MEMORY_FAILURE
+	default m
+	help
+	  Migrate data off pages with correctable memory errors.  Selecting
+	  Y will build this functionality into the kernel.  Selecting M will
+	  build this functionality as a kernel loadable module.  Installing
+	  the module will turn on the functionality.
+
 config PERFMON
 	bool "Performance monitor support"
 	help
Index: linux-next/arch/ia64/include/asm/mca.h
===================================================================
--- linux-next.orig/arch/ia64/include/asm/mca.h	2009-04-07 18:31:43.518295478 -0500
+++ linux-next/arch/ia64/include/asm/mca.h	2009-04-07 18:37:00.061826624 -0500
@@ -137,6 +137,9 @@ extern unsigned long __per_cpu_mca[NR_CP
 
 extern int cpe_vector;
 extern int ia64_cpe_irq;
+extern int cpe_poll_enabled;
+extern int cpe_poll_threshold;
+extern int cmc_poll_threshold;
 extern void ia64_mca_init(void);
 extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);
@@ -150,14 +153,25 @@ extern void ia64_slave_init_handler(void
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_state *));
 extern void ia64_unreg_MCA_extension(void);
+extern int  ia64_reg_CE_extension(int (*fn)(void *));
+extern void ia64_unreg_CE_extension(void);
+extern int isolate_lru_page(struct page *page);
 extern u64 ia64_get_rnat(u64 *);
 extern void ia64_mca_printk(const char * fmt, ...)
 	 __attribute__ ((format (printf, 1, 2)));
 
+extern struct list_head badpagelist;
+extern unsigned int total_badpages;
+
 struct ia64_mca_notify_die {
 	struct ia64_sal_os_state *sos;
 	int *monarch_cpu;
 	int *data;
+};
+
+struct ce_history {
+	struct list_head list;
+	unsigned long time;
 };
 
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
Index: linux-next/arch/ia64/include/asm/page.h
===================================================================
--- linux-next.orig/arch/ia64/include/asm/page.h	2009-04-07 18:31:43.526296672 -0500
+++ linux-next/arch/ia64/include/asm/page.h	2009-04-07 18:37:00.077829455 -0500
@@ -121,6 +121,7 @@ extern unsigned long max_low_pfn;
 #endif
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
+#define phys_to_page(kaddr)	(pfn_to_page(kaddr >> PAGE_SHIFT))
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 
Index: linux-next/arch/ia64/kernel/Makefile
===================================================================
--- linux-next.orig/arch/ia64/kernel/Makefile	2009-04-07 18:31:43.542298125 -0500
+++ linux-next/arch/ia64/kernel/Makefile	2009-04-07 18:37:00.097832955 -0500
@@ -31,6 +31,7 @@ obj-$(CONFIG_PERFMON)		+= perfmon_defaul
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
+obj-$(CONFIG_IA64_CPE_MIGRATE)	+= cpe_migrate.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
 obj-$(CONFIG_DYNAMIC_FTRACE)	+= ftrace.o
 obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o crash.o
Index: linux-next/arch/ia64/kernel/cpe_migrate.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-next/arch/ia64/kernel/cpe_migrate.c	2009-04-07 18:44:14.364066972 -0500
@@ -0,0 +1,628 @@
+/*
+ * File:	cpe_migrate.c
+ * Purpose:	Migrate data from physical pages with excessive correctable
+ *		errors to new physical pages.  Keep the old pages on a discard
+ *		list.
+ *
+ * Copyright (C) 2009 SGI - Silicon Graphics Inc.
+ * Copyright (C) 2009 Russ Anderson <rja@sgi.com>
+ */
+
+#include <linux/sysdev.h>
+#include <linux/types.h>
+#include <linux/sched.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/smp.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/vmalloc.h>
+#include <linux/migrate.h>
+#include <linux/page-isolation.h>
+#include <linux/memcontrol.h>
+#include <linux/kobject.h>
+#include <linux/kthread.h>
+#include <asm/page.h>
+#include <asm/system.h>
+#include <asm/sn/sn_cpuid.h>
+#include <asm/mca.h>
+
+struct kobject *badram_kobj;
+
+struct cpe_info {
+	struct list_head list;
+	u64 	paddr;
+	u16	node;
+	u16	count;
+};
+LIST_HEAD(ce_list);
+
+static int cpe_polling_enabled = 1;
+static int record_to_process;
+unsigned int migrate_threshold = 1;
+static int mstat_cannot_isolate;
+static int mstat_failed_to_discard;
+static int mstat_already_marked;
+static int mstat_already_on_list;
+
+/* IRQ handler notifies this wait queue on receipt of an IRQ */
+DECLARE_WAIT_QUEUE_HEAD(cpe_activate_IRQ_wq);
+static DECLARE_COMPLETION(kthread_cpe_migrated_exited);
+int cpe_active;
+DEFINE_SPINLOCK(cpe_migrate_lock);
+
+static void
+get_physical_address(void *buffer, u64 *paddr, u16 *node)
+{
+	sal_log_record_header_t *rh;
+	sal_log_mem_dev_err_info_t *mdei;
+	ia64_err_rec_t *err_rec;
+	sal_log_platform_err_info_t *plat_err;
+	efi_guid_t guid;
+
+	err_rec = buffer;
+	rh = &err_rec->sal_elog_header;
+	*paddr = 0;
+	*node = 0;
+
+	/*
+	 * Make sure it is a corrected error.
+	 */
+	if (rh->severity != sal_log_severity_corrected)
+		return;
+
+	plat_err = (sal_log_platform_err_info_t *)&err_rec->proc_err;
+
+	guid = plat_err->mem_dev_err.header.guid;
+	if (efi_guidcmp(guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) == 0) {
+		/*
+		 * Memory cpe
+		 */
+		mdei = &plat_err->mem_dev_err;
+		if (mdei->valid.oem_data) {
+			if (mdei->valid.physical_addr)
+				*paddr = mdei->physical_addr;
+
+			if (mdei->valid.node) {
+				if (ia64_platform_is("sn2"))
+					*node = nasid_to_cnodeid(mdei->node);
+				else
+					*node = mdei->node;
+			}
+		}
+	}
+}
+
+static struct page *
+alloc_migrate_page(struct page *ignored, unsigned long node, int **x)
+{
+
+	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
+}
+
+static int
+validate_paddr_page(u64 paddr)
+{
+	struct page *page;
+
+	if (!paddr)
+		return -EINVAL;
+
+	if (!ia64_phys_addr_valid(paddr))
+		return -EINVAL;
+
+	if (!pfn_valid(paddr >> PAGE_SHIFT))
+		return -EINVAL;
+
+	page = phys_to_page(paddr);
+	if (PagePoison(page))
+		mstat_already_marked++;
+	return 0;
+}
+
+static int
+ia64_mca_cpe_move_page(u64 paddr, u32 node)
+{
+	LIST_HEAD(pagelist);
+	struct page *page;
+	int ret;
+
+	ret = validate_paddr_page(paddr);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * convert physical address to page number
+	 */
+	page = phys_to_page(paddr);
+
+	migrate_prep();
+	ret = isolate_lru_page(page);
+	if (ret) {
+		mstat_cannot_isolate++;
+		return ret;
+	}
+	list_add_tail(&page->lru, &pagelist);
+	SetPagePoison(page);		/* Mark the page as bad */
+	ret = migrate_pages(&pagelist, alloc_migrate_page, node);
+	if (ret == 0) {
+		total_badpages++;
+		list_add_tail(&page->lru, &badpagelist);
+	} else {
+		mstat_failed_to_discard++;
+		/*
+		 * The page failed to migrate and is not on the bad page list.
+		 * Clearing the error bit will allow another attempt to migrate
+		 * if it gets another correctable error.
+		 */
+		ClearPagePoison(page);
+	}
+
+	return 0;
+}
+
+DEFINE_SPINLOCK(cpe_list_lock);
+
+/*
+ * cpe_process_queue
+ *	Pulls the physical address off the list and calls the migration code.
+ *	Will process all the addresses on the list.
+ */
+void
+cpe_process_queue(void)
+{
+	int ret;
+	struct cpe_info *entry, *entry2;
+
+	if (!spin_trylock(&cpe_list_lock))
+		return;
+
+	list_for_each_entry_safe(entry, entry2, &ce_list, list) {
+		if (entry->count >= migrate_threshold) {
+			/*
+			 * There is a valid entry that needs processing.
+			 */
+			ret = ia64_mca_cpe_move_page(entry->paddr, entry->node);
+			if (ret <= 0) {
+				/*
+				 * Even though the return status is negative,
+				 * clear the entry.  If the same address has
+				 * another CPE it will be re-added to the list.
+				 */
+				list_del(&entry->list);
+				kfree(entry);
+			}
+		}
+	}
+	spin_unlock(&cpe_list_lock);
+
+	record_to_process = 0;
+	return;
+}
+
+/*
+ * kthread_cpe_migrate
+ *	kthread_cpe_migrate is created at module load time and lives
+ *	until the module is removed.  When not active, it will sleep.
+ */
+static int
+kthread_cpe_migrate(void *ignore)
+{
+	while (cpe_active) {
+		/*
+		 * wait for work
+		 */
+		(void)wait_event_interruptible(cpe_activate_IRQ_wq,
+						(record_to_process ||
+						!cpe_active));
+		cpe_process_queue();		/* process work */
+	}
+	complete(&kthread_cpe_migrated_exited);
+	return 0;
+}
+
+/*
+ * cpe_setup_migrate
+ *	Get the physical address out of the CPE record, add it
+ *	to the list of addresses to migrate (if not already on),
+ *	and schedule the back end worker task.  This is called
+ *	in interrupt context so cannot directly call the migration
+ *	code.
+ *
+ *  Inputs
+ *	rec	The CPE record
+ *  Outputs
+ *	1 on Success, -1 on failure
+ */
+static int
+cpe_setup_migrate(void *rec)
+{
+	u64 paddr;
+	u16 node;
+	int ret;
+	struct cpe_info *entry, *entry2;
+
+	if (!rec)
+		return -EINVAL;
+
+	get_physical_address(rec, &paddr, &node);
+	ret = validate_paddr_page(paddr);
+	if (ret < 0)
+		return -EINVAL;
+
+	if (!spin_trylock(&cpe_list_lock)) {
+		/*
+		 * Someone else has the lock.  To avoid spinning in interrupt
+		 * handler context, bail.
+		 */
+		return 1;
+	}
+
+	list_for_each_entry_safe(entry, entry2, &ce_list, list) {
+		if (PAGE_ALIGN(paddr) == entry->paddr) {
+			if (entry->count++ > migrate_threshold) {
+				mstat_already_on_list++;
+			} else {
+				/*
+				 * Exceeded the migration threshold,
+				 * try to migrate
+				 */
+				record_to_process = 1;
+				wake_up_interruptible(&cpe_activate_IRQ_wq);
+			}
+			spin_unlock(&cpe_list_lock);
+			return 1;
+		}
+	}
+	/*
+	 * New entry, add to the list.
+	 */
+	entry = kmalloc(sizeof(struct cpe_info), GFP_KERNEL);
+	entry->node = node;
+	entry->paddr = paddr;
+	entry->count = 1;
+	list_add_tail(&entry->list, &ce_list);
+	if (migrate_threshold == 1) {
+		record_to_process = 1;
+		wake_up_interruptible(&cpe_activate_IRQ_wq);
+	}
+	spin_unlock(&cpe_list_lock);
+
+	return 1;
+}
+
+/*
+ * =============================================================================
+ */
+
+/*
+ * free_one_bad_page
+ *	Free one page from the list of bad pages.
+ */
+static int
+free_one_bad_page(unsigned long paddr)
+{
+	LIST_HEAD(pagelist);
+	struct page *page, *page2, *target;
+
+	/*
+	 * Verify page address
+	 */
+	target = phys_to_page(paddr);
+	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
+		if (page != target)
+			continue;
+
+		ClearPagePoison(page);        /* Mark the page as good */
+		total_badpages--;
+		list_move_tail(&page->lru, &pagelist);
+		putback_lru_pages(&pagelist);
+		break;
+	}
+	return 0;
+}
+
+/*
+ * free_all_bad_pages
+ *	Free all of the pages on the bad pages list.
+ */
+static int
+free_all_bad_pages(void)
+{
+	struct page *page, *page2;
+
+	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
+		ClearPagePoison(page);        /* Mark the page as good */
+		total_badpages--;
+	}
+	putback_lru_pages(&badpagelist);
+	return 0;
+}
+
+#define OPT_LEN	16
+
+static ssize_t
+badpage_store(struct kobject *kobj,
+	      struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	char optstr[OPT_LEN];
+	unsigned long opt;
+	int len = OPT_LEN;
+	int err;
+
+	if (count < len)
+		len = count;
+
+	strlcpy(optstr, buf, len);
+
+	err = strict_strtoul(optstr, 16, &opt);
+	if (err)
+		return err;
+
+	if (opt == 0)
+		free_all_bad_pages();
+	else
+		free_one_bad_page(opt);
+
+	return count;
+}
+
+/*
+ * badpage_show
+ *	Display the number, size, and addresses of all the pages on the
+ *	bad page list.
+ *
+ *	Note that sysfs provides buf of PAGE_SIZE length.  bufend tracks
+ *	the remaining space in buf to avoid overflowing.
+ */
+static ssize_t
+badpage_show(struct kobject *kobj,
+	     struct kobj_attribute *attr, char *buf)
+{
+	struct page *page, *page2;
+	int i = 0, cnt = 0;
+	char *bufend = buf + PAGE_SIZE;
+
+	cnt = snprintf(buf, bufend - (buf + cnt),
+			"Memory marked bad:        %d kB\n"
+			"Pages marked bad:         %d\n"
+			"Unable to isolate on LRU: %d\n"
+			"Unable to migrate:        %d\n"
+			"Already marked bad:       %d\n"
+			"Already on list:          %d\n"
+			"List of bad physical pages\n",
+			total_badpages << (PAGE_SHIFT - 10), total_badpages,
+			mstat_cannot_isolate, mstat_failed_to_discard,
+			mstat_already_marked, mstat_already_on_list
+			);
+
+	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
+		if (bufend - (buf + cnt) < 20)
+			break;		/* Avoid overflowing the buffer */
+		cnt += snprintf(buf + cnt, bufend - (buf + cnt),
+				" 0x%011lx", page_to_phys(page));
+		if (!(++i % 5))
+			cnt += snprintf(buf + cnt, bufend - (buf + cnt), "\n");
+	}
+	cnt += snprintf(buf + cnt, bufend - (buf + cnt), "\n");
+
+	return cnt;
+}
+
+static struct kobj_attribute badram_attr = {
+	.attr    = {
+		.name = "bad_pages",
+		.mode = S_IWUSR | S_IRUGO,
+	},
+	.show = badpage_show,
+	.store = badpage_store,
+};
+
+
+static ssize_t
+cpe_poll_threshold_store(struct kobject *kobj,
+	      struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	char optstr[OPT_LEN];
+	unsigned long opt;
+	int len = OPT_LEN;
+	int err;
+
+	if (count < len)
+		len = count;
+
+	strlcpy(optstr, buf, len);
+
+	err = strict_strtoul(optstr, 16, &opt);
+	if (err)
+		return err;
+	cpe_poll_threshold = opt;
+
+	return count;
+}
+
+static ssize_t
+cpe_poll_threshold_show(struct kobject *kobj,
+	     struct kobj_attribute *attr, char *buf)
+{
+	int cnt = 0;
+	char *bufend = buf + PAGE_SIZE;
+
+	cnt = snprintf(buf, bufend - (buf + cnt), "%d\n", cpe_poll_threshold);
+	return cnt;
+}
+
+static struct kobj_attribute cpe_poll_threshold_attr = {
+	.attr    = {
+		.name = "cpe_polling_threshold",
+		.mode = S_IWUSR | S_IRUGO,
+	},
+	.show = cpe_poll_threshold_show,
+	.store = cpe_poll_threshold_store,
+};
+
+
+static ssize_t
+cmc_poll_threshold_store(struct kobject *kobj,
+	      struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	char optstr[OPT_LEN];
+	unsigned long opt;
+	int len = OPT_LEN;
+	int err;
+
+	if (count < len)
+		len = count;
+
+	strlcpy(optstr, buf, len);
+
+	err = strict_strtoul(optstr, 16, &opt);
+	if (err)
+		return err;
+	cmc_poll_threshold = opt;
+
+	return count;
+}
+
+static ssize_t
+cmc_poll_threshold_show(struct kobject *kobj,
+	     struct kobj_attribute *attr, char *buf)
+{
+	int cnt = 0;
+	char *bufend = buf + PAGE_SIZE;
+
+	cnt = snprintf(buf, bufend - (buf + cnt), "%d\n", cmc_poll_threshold);
+	return cnt;
+}
+
+static struct kobj_attribute cmc_poll_threshold_attr = {
+	.attr    = {
+		.name = "cmc_polling_threshold",
+		.mode = S_IWUSR | S_IRUGO,
+	},
+	.show = cmc_poll_threshold_show,
+	.store = cmc_poll_threshold_store,
+};
+
+static ssize_t
+migrate_threshold_store(struct kobject *kobj,
+	      struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	char optstr[OPT_LEN];
+	unsigned long opt;
+	int len = OPT_LEN;
+	int err;
+
+	if (count < len)
+		len = count;
+
+	strlcpy(optstr, buf, len);
+
+	err = strict_strtoul(optstr, 16, &opt);
+	if (err)
+		return err;
+	migrate_threshold = opt;
+
+	return count;
+}
+
+static ssize_t
+migrate_threshold_show(struct kobject *kobj,
+	     struct kobj_attribute *attr, char *buf)
+{
+	int cnt = 0;
+	char *bufend = buf + PAGE_SIZE;
+
+	cnt = snprintf(buf, bufend - (buf + cnt), "%d\n", migrate_threshold);
+	return cnt;
+}
+
+static struct kobj_attribute migrate_threshold_attr = {
+	.attr    = {
+		.name = "migrate_threshold",
+		.mode = S_IWUSR | S_IRUGO,
+	},
+	.show = migrate_threshold_show,
+	.store = migrate_threshold_store,
+};
+
+static int __init
+cpe_migrate_external_handler_init(void)
+{
+	int error;
+	struct task_struct *kthread;
+
+	if (!badram_kobj)
+		badram_kobj = kobject_create_and_add("badram", firmware_kobj);
+	if (!badram_kobj) {
+		printk(KERN_WARNING "kobject_create_and_add badram failed \n");
+		return -EINVAL;
+	}
+
+	error = sysfs_create_file(badram_kobj, &badram_attr.attr);
+	if (error)
+		return -EINVAL;
+
+	error = sysfs_create_file(badram_kobj, &cpe_poll_threshold_attr.attr);
+	if (error)
+		return -EINVAL;
+
+	error = sysfs_create_file(badram_kobj, &cmc_poll_threshold_attr.attr);
+	if (error)
+		return -EINVAL;
+
+	error = sysfs_create_file(badram_kobj, &migrate_threshold_attr.attr);
+	if (error)
+		return -EINVAL;
+
+	/*
+	 * set up the kthread
+	 */
+	cpe_active = 1;
+	kthread = kthread_run(kthread_cpe_migrate, NULL, "cpe_migrate");
+	if (IS_ERR(kthread)) {
+		complete(&kthread_cpe_migrated_exited);
+		return -EFAULT;
+	}
+
+	/*
+	 * register external ce handler
+	 */
+	if (ia64_reg_CE_extension(cpe_setup_migrate)) {
+		printk(KERN_ERR "ia64_reg_CE_extension failed.\n");
+		return -EFAULT;
+	}
+	cpe_poll_enabled = cpe_polling_enabled;
+
+	printk(KERN_INFO "Registered badram Driver\n");
+	return 0;
+}
+
+static void __exit
+cpe_migrate_external_handler_exit(void)
+{
+	/* unregister external mca handlers */
+	ia64_unreg_CE_extension();
+
+	/* Stop kthread */
+	cpe_active = 0;			/* tell kthread_cpe_migrate to exit */
+	wake_up_interruptible(&cpe_activate_IRQ_wq);
+	wait_for_completion(&kthread_cpe_migrated_exited);
+
+	sysfs_remove_file(kernel_kobj, &migrate_threshold_attr.attr);
+	sysfs_remove_file(kernel_kobj, &cpe_poll_threshold_attr.attr);
+	sysfs_remove_file(kernel_kobj, &cmc_poll_threshold_attr.attr);
+	sysfs_remove_file(kernel_kobj, &badram_attr.attr);
+	kobject_put(badram_kobj);
+}
+
+module_init(cpe_migrate_external_handler_init);
+module_exit(cpe_migrate_external_handler_exit);
+
+module_param(cpe_polling_enabled, int, 0644);
+MODULE_PARM_DESC(cpe_polling_enabled,
+		"Enable polling with migration");
+
+MODULE_AUTHOR("Russ Anderson <rja@sgi.com>");
+MODULE_DESCRIPTION("ia64 Corrected Error page migration driver");
+MODULE_LICENSE("GPL");
Index: linux-next/arch/ia64/kernel/mca.c
===================================================================
--- linux-next.orig/arch/ia64/kernel/mca.c	2009-04-07 18:31:43.554299960 -0500
+++ linux-next/arch/ia64/kernel/mca.c	2009-04-07 18:37:00.121835074 -0500
@@ -68,6 +68,9 @@
  *
  * 2007-04-27 Russ Anderson <rja@sgi.com>
  *	      Support multiple cpus going through OS_MCA in the same event.
+ *
+ * 2008-04-22 Russ Anderson <rja@sgi.com>
+ *	      Migrate data off pages with correctable memory errors.
  */
 #include <linux/jiffies.h>
 #include <linux/types.h>
@@ -163,7 +166,23 @@ static int cmc_polling_enabled = 1;
  * but encounters problems retrieving CPE logs.  This should only be
  * necessary for debugging.
  */
-static int cpe_poll_enabled = 1;
+
+int cpe_poll_enabled = 1;
+EXPORT_SYMBOL(cpe_poll_enabled);
+LIST_HEAD(cpe_history_list);
+EXPORT_SYMBOL(cpe_history_list);
+int cpe_poll_threshold;
+EXPORT_SYMBOL(cpe_poll_threshold);
+LIST_HEAD(cmc_history_list);
+EXPORT_SYMBOL(cmc_history_list);
+int cmc_poll_threshold;
+EXPORT_SYMBOL(cmc_poll_threshold);
+
+unsigned int total_badpages;
+EXPORT_SYMBOL(total_badpages);
+
+LIST_HEAD(badpagelist);
+EXPORT_SYMBOL(badpagelist);
 
 extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
 
@@ -523,6 +542,28 @@ int mca_recover_range(unsigned long addr
 }
 EXPORT_SYMBOL_GPL(mca_recover_range);
 
+/* Function pointer to Corrected Error memory migration driver */
+int (*ia64_mca_ce_extension)(void *);
+
+int
+ia64_reg_CE_extension(int (*fn)(void *))
+{
+	if (ia64_mca_ce_extension)
+		return 1;
+
+	ia64_mca_ce_extension = fn;
+	return 0;
+}
+EXPORT_SYMBOL(ia64_reg_CE_extension);
+
+void
+ia64_unreg_CE_extension(void)
+{
+	if (ia64_mca_ce_extension)
+		ia64_mca_ce_extension = NULL;
+}
+EXPORT_SYMBOL(ia64_unreg_CE_extension);
+
 #ifdef CONFIG_ACPI
 
 int cpe_vector = -1;
@@ -531,9 +572,8 @@ int ia64_cpe_irq = -1;
 static irqreturn_t
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg)
 {
-	static unsigned long	cpe_history[CPE_HISTORY_LENGTH];
-	static int		index;
 	static DEFINE_SPINLOCK(cpe_history_lock);
+	int recover;
 
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __func__, cpe_irq, smp_processor_id());
@@ -544,18 +584,34 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 	spin_lock(&cpe_history_lock);
 	if (!cpe_poll_enabled && cpe_vector >= 0) {
 
-		int i, count = 1; /* we know 1 happened now */
+		int i = 0, count = 1; /* we know 1 happened now */
 		unsigned long now = jiffies;
+		struct ce_history *entry, *entry2;
 
-		for (i = 0; i < CPE_HISTORY_LENGTH; i++) {
-			if (now - cpe_history[i] <= HZ)
+		list_for_each_entry_safe(entry, entry2,
+						&cpe_history_list, list) {
+			if (now - entry->time <= HZ)
 				count++;
+			else {			/* remove expired entry */
+				list_del(&entry->list);
+				kfree(entry);
+			}
 		}
 
-		IA64_MCA_DEBUG(KERN_INFO "CPE threshold %d/%d\n", count, CPE_HISTORY_LENGTH);
-		if (count >= CPE_HISTORY_LENGTH) {
+		IA64_MCA_DEBUG(KERN_INFO "CPE threshold %d/%d\n",
+						count, cpe_poll_threshold);
+		if (count >= cpe_poll_threshold) {
 
 			cpe_poll_enabled = 1;
+			/*
+			 * Remove all entries from the history list, they will
+			 * be expired when we leave polling mode.
+			 */
+			list_for_each_entry_safe(entry, entry2,
+						&cpe_history_list, list) {
+				list_del(&entry->list);
+				kfree(entry);
+			}
 			spin_unlock(&cpe_history_lock);
 			disable_irq_nosync(local_vector_to_irq(IA64_CPE_VECTOR));
 
@@ -571,15 +627,20 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
 			/* lock already released, get out now */
 			goto out;
 		} else {
-			cpe_history[index++] = now;
-			if (index == CPE_HISTORY_LENGTH)
-				index = 0;
+			/*
+			 * Add this entry to the list.
+			 */
+			entry = kmalloc(sizeof(struct ce_history), GFP_KERNEL);
+			entry->time = now;
+			list_add_tail(&entry->list, &cpe_history_list);
 		}
 	}
 	spin_unlock(&cpe_history_lock);
 out:
 	/* Get the CPE error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
+	recover = (ia64_mca_ce_extension && ia64_mca_ce_extension(
+				IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_CPE)));
 
 	return IRQ_HANDLED;
 }
@@ -1372,8 +1433,6 @@ static DECLARE_WORK(cmc_enable_work, ia6
 static irqreturn_t
 ia64_mca_cmc_int_handler(int cmc_irq, void *arg)
 {
-	static unsigned long	cmc_history[CMC_HISTORY_LENGTH];
-	static int		index;
 	static DEFINE_SPINLOCK(cmc_history_lock);
 
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
@@ -1384,18 +1443,34 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 
 	spin_lock(&cmc_history_lock);
 	if (!cmc_polling_enabled) {
-		int i, count = 1; /* we know 1 happened now */
+		struct ce_history *entry, *entry2;
+		int i = 0, count = 1; /* we know 1 happened now */
 		unsigned long now = jiffies;
 
-		for (i = 0; i < CMC_HISTORY_LENGTH; i++) {
-			if (now - cmc_history[i] <= HZ)
+		list_for_each_entry_safe(entry, entry2,
+						&cmc_history_list, list) {
+			if (now - entry->time <= HZ)
 				count++;
+			else {			/* remove expired entry */
+				list_del(&entry->list);
+				kfree(entry);
+			}
 		}
 
-		IA64_MCA_DEBUG(KERN_INFO "CMC threshold %d/%d\n", count, CMC_HISTORY_LENGTH);
-		if (count >= CMC_HISTORY_LENGTH) {
+		IA64_MCA_DEBUG(KERN_INFO "CMC threshold %d/%d\n",
+						count, cmc_poll_threshold);
+		if (count >= cmc_poll_threshold) {
 
 			cmc_polling_enabled = 1;
+			/*
+			 * Remove all entries from the history list, they will
+			 * be expired when we leave polling mode.
+			 */
+			list_for_each_entry_safe(entry, entry2,
+						&cmc_history_list, list) {
+				list_del(&entry->list);
+				kfree(entry);
+			}
 			spin_unlock(&cmc_history_lock);
 			/* If we're being hit with CMC interrupts, we won't
 			 * ever execute the schedule_work() below.  Need to
@@ -1416,9 +1491,12 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 			/* lock already released, get out now */
 			goto out;
 		} else {
-			cmc_history[index++] = now;
-			if (index == CMC_HISTORY_LENGTH)
-				index = 0;
+			/*
+			 * Add this entry to the list.
+			 */
+			entry = kmalloc(sizeof(struct ce_history), GFP_KERNEL);
+			entry->time = now;
+			list_add_tail(&entry->list, &cmc_history_list);
 		}
 	}
 	spin_unlock(&cmc_history_lock);
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
