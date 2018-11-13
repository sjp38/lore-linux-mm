Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAF1E6B0010
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 13:20:45 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id g16-v6so6882820eds.20
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:20:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19-v6sor3461865ejv.42.2018.11.13.10.20.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 10:20:43 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V4] KSM: allow dedup all tasks memory
Date: Tue, 13 Nov 2018 21:20:36 +0300
Message-Id: <20181113182036.21524-1-nefelim4ag@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Matthew Wilcox <willy@infradead.org>, Oleksandr Natalenko <oleksandr@natalenko.name>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org

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
    * Remove unused variable "error"

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Oleksandr Natalenko <oleksandr@natalenko.name>
CC: Pavel Tatashin <pasha.tatashin@soleen.com>
CC: linux-mm@kvack.org
CC: linux-doc@vger.kernel.org
---
 Documentation/admin-guide/mm/ksm.rst |  15 ++
 mm/ksm.c                             | 217 +++++++++++++++++++++++----
 2 files changed, 200 insertions(+), 32 deletions(-)

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
diff --git a/mm/ksm.c b/mm/ksm.c
index 5b0894b45ee5..f087eefda8b2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -273,6 +273,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Milliseconds ksmd seeker should sleep between runs */
+static unsigned int ksm_thread_seeker_sleep_millisecs = 1000;
+
 /* Checksum of an empty (zeroed) page */
 static unsigned int zero_checksum __read_mostly;
 
@@ -295,7 +298,12 @@ static int ksm_nr_node_ids = 1;
 static unsigned long ksm_run = KSM_RUN_STOP;
 static void wait_while_offlining(void);
 
+#define KSM_MODE_MADVISE 0
+#define KSM_MODE_ALWAYS	1
+static unsigned long ksm_mode = KSM_MODE_MADVISE;
+
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
+static DECLARE_WAIT_QUEUE_HEAD(ksm_seeker_thread_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
 static DEFINE_SPINLOCK(ksm_mmlist_lock);
 
@@ -303,6 +311,11 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+static inline int ksm_mode_always(void)
+{
+	return (ksm_mode == KSM_MODE_ALWAYS);
+}
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -2389,6 +2402,108 @@ static int ksmd_should_run(void)
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
+
 static int ksm_scan_thread(void *nothing)
 {
 	set_freezable();
@@ -2422,33 +2537,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 
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
-#endif
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
@@ -2829,6 +2920,29 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
 }
 KSM_ATTR(sleep_millisecs);
 
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
+
 static ssize_t pages_to_scan_show(struct kobject *kobj,
 				  struct kobj_attribute *attr, char *buf)
 {
@@ -2852,6 +2966,34 @@ static ssize_t pages_to_scan_store(struct kobject *kobj,
 }
 KSM_ATTR(pages_to_scan);
 
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
+
 static ssize_t run_show(struct kobject *kobj, struct kobj_attribute *attr,
 			char *buf)
 {
@@ -3108,7 +3250,9 @@ KSM_ATTR_RO(full_scans);
 
 static struct attribute *ksm_attrs[] = {
 	&sleep_millisecs_attr.attr,
+	&seeker_sleep_millisecs_attr.attr,
 	&pages_to_scan_attr.attr,
+	&mode_attr.attr,
 	&run_attr.attr,
 	&pages_shared_attr.attr,
 	&pages_sharing_attr.attr,
@@ -3134,7 +3278,7 @@ static const struct attribute_group ksm_attr_group = {
 
 static int __init ksm_init(void)
 {
-	struct task_struct *ksm_thread;
+	struct task_struct *ksm_thread[2];
 	int err;
 
 	/* The correct value depends on page size and endianness */
@@ -3146,10 +3290,18 @@ static int __init ksm_init(void)
 	if (err)
 		goto out;
 
-	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
-	if (IS_ERR(ksm_thread)) {
+	ksm_thread[0] = kthread_run(ksm_scan_thread, NULL, "ksmd");
+	if (IS_ERR(ksm_thread[0])) {
 		pr_err("ksm: creating kthread failed\n");
-		err = PTR_ERR(ksm_thread);
+		err = PTR_ERR(ksm_thread[0]);
+		goto out_free;
+	}
+
+	ksm_thread[1] = kthread_run(ksm_seeker_thread, NULL, "ksmd_seeker");
+	if (IS_ERR(ksm_thread[1])) {
+		pr_err("ksm: creating seeker kthread failed\n");
+		err = PTR_ERR(ksm_thread[1]);
+		kthread_stop(ksm_thread[0]);
 		goto out_free;
 	}
 
@@ -3157,7 +3309,8 @@ static int __init ksm_init(void)
 	err = sysfs_create_group(mm_kobj, &ksm_attr_group);
 	if (err) {
 		pr_err("ksm: register sysfs failed\n");
-		kthread_stop(ksm_thread);
+		kthread_stop(ksm_thread[0]);
+		kthread_stop(ksm_thread[1]);
 		goto out_free;
 	}
 #else
-- 
2.19.1
