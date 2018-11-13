Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAC36B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 18:50:50 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id y6so2105171lfy.11
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 15:50:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7sor4911824lfk.50.2018.11.13.15.50.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 15:50:47 -0800 (PST)
From: Timofey Titovets <timofey.titovets@synesis.ru>
Subject: [PATCH V5] KSM: allow dedup all tasks memory
Date: Wed, 14 Nov 2018 02:50:39 +0300
Message-Id: <20181113235039.6205-1-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Matthew Wilcox <willy@infradead.org>, Oleksandr Natalenko <oleksandr@natalenko.name>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org

From: Timofey Titovets <nefelim4ag@gmail.com>

ksm by default working only on memory that added by
madvise().

And only way get that work on other applications:
  * Use LD_PRELOAD and libraries
  * Patch kernel

Lets use kernel task list and add logic to import VMAs from tasks.

That behaviour controlled by new attributes:
  * mode:
    I try mimic hugepages attribute, so mode have two states:
      * madvise      - old default behaviour
      * always [new] - allow ksm to get tasks vma and
                       try working on that.
  * seeker_sleep_millisecs:
    Add pauses between imports tasks VMA

For rate limiting proporses and tasklist locking time,
ksm seeker thread only import VMAs from one task per loop.

For security proporses add VM_UNMERGEABLE flag,
that allow users who really care about security to
use MADV_UNMERGEABLE to forbid new ksm code to process their VMAs.

Some numbers from different not madvised workloads.
Formulas:
  Percentage ratio = (pages_sharing - pages_shared)/pages_unshared
  Memory saved = (pages_sharing - pages_shared)*4/1024 MiB
  Memory used = free -h

  * Name: My working laptop
    Description: Many different chrome/electron apps + KDE
    Ratio: 5%
    Saved: ~100  MiB
    Used:  ~2000 MiB

  * Name: K8s test VM
    Description: Some small random running docker images
    Ratio: 40%
    Saved: ~160 MiB
    Used:  ~920 MiB

  * Name: Ceph test VM
    Description: Ceph Mon/OSD, some containers
    Ratio: 20%
    Saved: ~60 MiB
    Used:  ~600 MiB

  * Name: BareMetal K8s backend server
    Description: Different server apps in containers C, Java, GO & etc
    Ratio: 72%
    Saved: ~5800 MiB
    Used:  ~35.7 GiB

  * Name: BareMetal K8s processing server
    Description: Many instance of one CPU intensive application
    Ratio: 55%
    Saved: ~2600 MiB
    Used:  ~28.0 GiB

  * Name: BareMetal Ceph node
    Description: Only OSD storage daemons running
    Raio: 2%
    Saved: ~190 MiB
    Used:  ~11.7 GiB

Changes:
  v1 -> v2:
    * Rebase on v4.19.1 (must also apply on 4.20-rc2+)
  v2 -> v3:
    * Reformat patch description
    * Rename mode normal to madvise
    * Add some memory numbers
    * Separate ksm vma seeker to another kthread
    * Fix: "BUG: scheduling while atomic: ksmd"
      by move seeker to another thread
  v3 -> v4:
    * Fix again "BUG: scheduling while atomic"
      by get()/put() task API
    * Remove unused variable error
  v4 -> v5:
    * That nowonly be available on 64-bit arch
      because VM_UNMERGEABLE use 37 bit in vm_flags
    * Add VM_UNMERGEABLE VMA flag to allow users
      forbid ksm do anything with VMAs

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Oleksandr Natalenko <oleksandr@natalenko.name>
CC: Pavel Tatashin <pasha.tatashin@soleen.com>
CC: linux-mm@kvack.org
CC: linux-doc@vger.kernel.org
---
 Documentation/admin-guide/mm/ksm.rst |  15 ++
 include/linux/mm.h                   |   7 +
 include/trace/events/mmflags.h       |   7 +
 mm/ksm.c                             | 247 +++++++++++++++++++++++----
 4 files changed, 245 insertions(+), 31 deletions(-)

diff --git a/Documentation/admin-guide/mm/ksm.rst b/Documentation/admin-guide/mm/ksm.rst
index 9303786632d1..7cffd47f9b38 100644
--- a/Documentation/admin-guide/mm/ksm.rst
+++ b/Documentation/admin-guide/mm/ksm.rst
@@ -116,6 +116,21 @@ run
         Default: 0 (must be changed to 1 to activate KSM, except if
         CONFIG_SYSFS is disabled)
 
+mode
+        * set always to allow ksm deduplicate memory of every process
+        * set madvise to use only madvised memory
+
+        Default: madvise (dedupulicate only madvised memory as in
+        earlier releases)
+
+seeker_sleep_millisecs
+        how many milliseconds ksmd task seeker should sleep try another
+        task.
+        e.g. ``echo 1000 > /sys/kernel/mm/ksm/seeker_sleep_millisecs``
+
+        Default: 1000 (chosen for rate limit purposes)
+
+
 use_zero_pages
         specifies whether empty pages (i.e. allocated pages that only
         contain zeroes) should be treated specially.  When set to 1,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..3d8ee297d776 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -224,13 +224,20 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
+#ifdef VM_HIGH_ARCH_5
+/* Forbid ksm to autopickup VMA and try dedup it */
+#define VM_UNMERGEABLE	VM_HIGH_ARCH_5
+#endif
+
 #ifdef CONFIG_ARCH_HAS_PKEYS
 # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
 # define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a1675d43777e..e109a08e1e78 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -130,6 +130,12 @@ IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
 #define IF_HAVE_VM_SOFTDIRTY(flag,name)
 #endif
 
+#ifdef CONFIG_ARCH_USES_HIGH_VMA_FLAGS
+#define IF_HAVE_HIGH_VMA_FLAGS(flag,name) {flag, name },
+#else
+#define IF_HAVE_HIGH_VMA_FLAGS(flag,name)
+#endif
+
 #define __def_vmaflag_names						\
 	{VM_READ,			"read"		},		\
 	{VM_WRITE,			"write"		},		\
@@ -161,6 +167,7 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	{VM_MIXEDMAP,			"mixedmap"	},		\
 	{VM_HUGEPAGE,			"hugepage"	},		\
 	{VM_NOHUGEPAGE,			"nohugepage"	},		\
+IF_HAVE_HIGH_VMA_FLAGS(VM_UNMERGEABLE,	"unmergeable"	)		\
 	{VM_MERGEABLE,			"mergeable"	}		\
 
 #define show_vma_flags(flags)						\
diff --git a/mm/ksm.c b/mm/ksm.c
index 5b0894b45ee5..1984e9371d9a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -273,6 +273,11 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+#ifdef VM_UNMERGEABLE
+/* Milliseconds ksmd seeker should sleep between runs */
+static unsigned int ksm_thread_seeker_sleep_millisecs = 1000;
+#endif
+
 /* Checksum of an empty (zeroed) page */
 static unsigned int zero_checksum __read_mostly;
 
@@ -295,6 +300,13 @@ static int ksm_nr_node_ids = 1;
 static unsigned long ksm_run = KSM_RUN_STOP;
 static void wait_while_offlining(void);
 
+#ifdef VM_UNMERGEABLE
+#define KSM_MODE_MADVISE 0
+#define KSM_MODE_ALWAYS	1
+static unsigned long ksm_mode = KSM_MODE_MADVISE;
+static DECLARE_WAIT_QUEUE_HEAD(ksm_seeker_thread_wait);
+#endif
+
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
 static DEFINE_SPINLOCK(ksm_mmlist_lock);
@@ -303,6 +315,13 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+#ifdef VM_UNMERGEABLE
+static inline int ksm_mode_always(void)
+{
+	return (ksm_mode == KSM_MODE_ALWAYS);
+}
+#endif
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -2389,6 +2408,114 @@ static int ksmd_should_run(void)
 	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
 }
 
+
+static int ksm_enter(struct mm_struct *mm, unsigned long *vm_flags)
+{
+	int err;
+
+	if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
+			 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
+			 VM_HUGETLB | VM_MIXEDMAP))
+		return 0;
+
+#ifdef VM_SAO
+	if (*vm_flags & VM_SAO)
+		return 0;
+#endif
+#ifdef VM_SPARC_ADI
+	if (*vm_flags & VM_SPARC_ADI)
+		return 0;
+#endif
+#ifdef VM_UNMERGEABLE
+	if (*vm_flags & VM_UNMERGEABLE)
+		return 0;
+#endif
+	if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+		err = __ksm_enter(mm);
+		if (err)
+			return err;
+	}
+
+	*vm_flags |= VM_MERGEABLE;
+
+	return 0;
+}
+
+#ifdef VM_UNMERGEABLE
+/*
+ * Register all vmas for all processes in the system with KSM.
+ * Note that every call to ksm_, for a given vma, after the first
+ * does nothing but set flags.
+ */
+void ksm_import_task_vma(struct task_struct *task)
+{
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+
+	mm = get_task_mm(task);
+	if (!mm)
+		return;
+	down_write(&mm->mmap_sem);
+	vma = mm->mmap;
+	while (vma) {
+		ksm_enter(vma->vm_mm, &vma->vm_flags);
+		vma = vma->vm_next;
+	}
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+}
+
+static int ksm_seeker_thread(void *nothing)
+{
+	pid_t last_pid = 1;
+	pid_t curr_pid;
+	struct task_struct *task;
+
+	set_freezable();
+	set_user_nice(current, 5);
+
+	while (!kthread_should_stop()) {
+		wait_while_offlining();
+
+		try_to_freeze();
+
+		if (!ksm_mode_always()) {
+			wait_event_freezable(ksm_seeker_thread_wait,
+				ksm_mode_always() || kthread_should_stop());
+			continue;
+		}
+
+		/*
+		 * import one task's vma per run
+		 */
+		read_lock(&tasklist_lock);
+
+		/* Try always get next task */
+		for_each_process(task) {
+			curr_pid = task_pid_nr(task);
+			if (curr_pid == last_pid) {
+				task = next_task(task);
+				break;
+			}
+
+			if (curr_pid > last_pid)
+				break;
+		}
+
+		get_task_struct(task);
+		read_unlock(&tasklist_lock);
+
+		last_pid = task_pid_nr(task);
+		ksm_import_task_vma(task);
+		put_task_struct(task);
+
+		schedule_timeout_interruptible(
+			msecs_to_jiffies(ksm_thread_seeker_sleep_millisecs));
+	}
+	return 0;
+}
+#endif
+
 static int ksm_scan_thread(void *nothing)
 {
 	set_freezable();
@@ -2422,36 +2549,18 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 
 	switch (advice) {
 	case MADV_MERGEABLE:
-		/*
-		 * Be somewhat over-protective for now!
-		 */
-		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
-				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_MIXEDMAP))
-			return 0;		/* just ignore the advice */
-
-		if (vma_is_dax(vma))
-			return 0;
-
-#ifdef VM_SAO
-		if (*vm_flags & VM_SAO)
-			return 0;
-#endif
-#ifdef VM_SPARC_ADI
-		if (*vm_flags & VM_SPARC_ADI)
-			return 0;
+#ifdef VM_UNMERGEABLE
+		*vm_flags &= ~VM_UNMERGEABLE;
 #endif
-
-		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
-			err = __ksm_enter(mm);
-			if (err)
-				return err;
-		}
-
-		*vm_flags |= VM_MERGEABLE;
+		err = ksm_enter(mm, vm_flags);
+		if (err)
+			return err;
 		break;
 
 	case MADV_UNMERGEABLE:
+#ifdef VM_UNMERGEABLE
+		*vm_flags |= VM_UNMERGEABLE;
+#endif
 		if (!(*vm_flags & VM_MERGEABLE))
 			return 0;		/* just ignore the advice */
 
@@ -2829,6 +2938,31 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
 }
 KSM_ATTR(sleep_millisecs);
 
+#ifdef VM_UNMERGEABLE
+static ssize_t seeker_sleep_millisecs_show(struct kobject *kobj,
+				    struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_thread_seeker_sleep_millisecs);
+}
+
+static ssize_t seeker_sleep_millisecs_store(struct kobject *kobj,
+				     struct kobj_attribute *attr,
+				     const char *buf, size_t count)
+{
+	unsigned long msecs;
+	int err;
+
+	err = kstrtoul(buf, 10, &msecs);
+	if (err || msecs > UINT_MAX)
+		return -EINVAL;
+
+	ksm_thread_seeker_sleep_millisecs = msecs;
+
+	return count;
+}
+KSM_ATTR(seeker_sleep_millisecs);
+#endif
+
 static ssize_t pages_to_scan_show(struct kobject *kobj,
 				  struct kobj_attribute *attr, char *buf)
 {
@@ -2852,6 +2986,36 @@ static ssize_t pages_to_scan_store(struct kobject *kobj,
 }
 KSM_ATTR(pages_to_scan);
 
+#ifdef VM_UNMERGEABLE
+static ssize_t mode_show(struct kobject *kobj, struct kobj_attribute *attr,
+			char *buf)
+{
+	switch (ksm_mode) {
+	case KSM_MODE_ALWAYS:
+		return sprintf(buf, "[always] madvise\n");
+	case KSM_MODE_MADVISE:
+		return sprintf(buf, "always [madvise]\n");
+	}
+
+	return sprintf(buf, "always [madvise]\n");
+}
+
+static ssize_t mode_store(struct kobject *kobj, struct kobj_attribute *attr,
+			 const char *buf, size_t count)
+{
+	if (!memcmp("always", buf, min(sizeof("always")-1, count))) {
+		ksm_mode = KSM_MODE_ALWAYS;
+		wake_up_interruptible(&ksm_seeker_thread_wait);
+	} else if (!memcmp("madvise", buf, min(sizeof("madvise")-1, count))) {
+		ksm_mode = KSM_MODE_MADVISE;
+	} else
+		return -EINVAL;
+
+	return count;
+}
+KSM_ATTR(mode);
+#endif
+
 static ssize_t run_show(struct kobject *kobj, struct kobj_attribute *attr,
 			char *buf)
 {
@@ -3108,6 +3272,10 @@ KSM_ATTR_RO(full_scans);
 
 static struct attribute *ksm_attrs[] = {
 	&sleep_millisecs_attr.attr,
+#ifdef VM_UNMERGEABLE
+	&mode_attr.attr,
+	&seeker_sleep_millisecs_attr.attr,
+#endif
 	&pages_to_scan_attr.attr,
 	&run_attr.attr,
 	&pages_shared_attr.attr,
@@ -3134,7 +3302,11 @@ static const struct attribute_group ksm_attr_group = {
 
 static int __init ksm_init(void)
 {
-	struct task_struct *ksm_thread;
+#ifdef VM_UNMERGEABLE
+	struct task_struct *ksm_thread[2];
+#else
+	struct task_struct *ksm_thread[1];
+#endif
 	int err;
 
 	/* The correct value depends on page size and endianness */
@@ -3146,18 +3318,31 @@ static int __init ksm_init(void)
 	if (err)
 		goto out;
 
-	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
-	if (IS_ERR(ksm_thread)) {
+	ksm_thread[0] = kthread_run(ksm_scan_thread, NULL, "ksmd");
+	if (IS_ERR(ksm_thread[0])) {
 		pr_err("ksm: creating kthread failed\n");
-		err = PTR_ERR(ksm_thread);
+		err = PTR_ERR(ksm_thread[0]);
 		goto out_free;
 	}
 
+#ifdef VM_UNMERGEABLE
+	ksm_thread[1] = kthread_run(ksm_seeker_thread, NULL, "ksmd_seeker");
+	if (IS_ERR(ksm_thread[1])) {
+		pr_err("ksm: creating seeker kthread failed\n");
+		err = PTR_ERR(ksm_thread[1]);
+		kthread_stop(ksm_thread[0]);
+		goto out_free;
+	}
+#endif
+
 #ifdef CONFIG_SYSFS
 	err = sysfs_create_group(mm_kobj, &ksm_attr_group);
 	if (err) {
 		pr_err("ksm: register sysfs failed\n");
-		kthread_stop(ksm_thread);
+		kthread_stop(ksm_thread[0]);
+#ifdef VM_UNMERGEABLE
+		kthread_stop(ksm_thread[1]);
+#endif
 		goto out_free;
 	}
 #else
-- 
2.19.1
