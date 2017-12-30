Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A98196B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 20:49:31 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id p9so11917059wre.22
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 17:49:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19sor7320574wrg.78.2017.12.29.17.49.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Dec 2017 17:49:29 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [RFC PATCH Resend] ksm: allow dedup all tasks memory
Date: Sat, 30 Dec 2017 04:49:20 +0300
Message-Id: <20171230014920.16666-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>

ksm by default working only on memory that added by
madvice().

And only way get that work on other applications:
 - Use LD_PRELOAD and libraries
 - Patch kernel

Lets use kernel task list in ksm_scan_thread and add logic to allow ksm
import VMA from tasks.
That behaviour controlled by new attribute: mode
I try mimic hugepages attribute, so mode have two states:
 - normal       - old default behaviour
 - always [new] - allow ksm to get tasks vma and try working on that.

To reduce CPU load & tasklist locking time,
ksm try import VMAs from one task per loop.

So add new attribute "mode"
Two passible values:
 - normal [default] - ksm use only madvice
 - always [new]     - ksm will search vma over all processes memory and
                      add it to the dedup list

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 Documentation/vm/ksm.txt |   3 +
 mm/ksm.c                 | 139 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 121 insertions(+), 21 deletions(-)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index 6686bd267dc9..3ba6a558c48e 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -84,6 +84,9 @@ run              - set 0 to stop ksmd from running but keep merged pages,
                    Default: 0 (must be changed to 1 to activate KSM,
                                except if CONFIG_SYSFS is disabled)

+mode             - set always to allow ksm dedup whole memory
+                   set normal to use only madvice [default]
+
 use_zero_pages   - specifies whether empty pages (i.e. allocated pages
                    that only contain zeroes) should be treated specially.
                    When set to 1, empty pages are merged with the kernel
diff --git a/mm/ksm.c b/mm/ksm.c
index 15dd7415f7b3..78ecb62ad7e6 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -276,6 +276,10 @@ static int ksm_nr_node_ids = 1;
 static unsigned long ksm_run = KSM_RUN_STOP;
 static void wait_while_offlining(void);

+#define KSM_MODE_NORMAL 0
+#define KSM_MODE_ALWAYS	1
+static unsigned long ksm_mode = KSM_MODE_NORMAL;
+
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
 static DEFINE_SPINLOCK(ksm_mmlist_lock);
@@ -284,6 +288,11 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
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
@@ -2314,17 +2323,91 @@ static void ksm_do_scan(unsigned int scan_npages)

 static int ksmd_should_run(void)
 {
-	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
+	return (ksm_run & KSM_RUN_MERGE) &&
+		(!list_empty(&ksm_mm_head.mm_list) || ksm_mode_always());
+}
+
+
+int ksm_enter(struct mm_struct *mm, unsigned long *vm_flags)
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
+
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
+ * Note that every call to ksm_madvise, for a given vma, after the first
+ * does nothing but set flags.
+ */
+void ksm_import_task_vma(struct task_struct *task)
+{
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	int error;
+
+	mm = get_task_mm(task);
+	if (!mm)
+		return;
+	down_write(&mm->mmap_sem);
+	vma = mm->mmap;
+	while (vma) {
+		error = ksm_enter(vma->vm_mm, &vma->vm_flags);
+		vma = vma->vm_next;
+	}
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+	return;
 }

 static int ksm_scan_thread(void *nothing)
 {
+	pid_t last_pid = 1;
+	pid_t curr_pid;
+	struct task_struct *task;
+
 	set_freezable();
 	set_user_nice(current, 5);

 	while (!kthread_should_stop()) {
 		mutex_lock(&ksm_thread_mutex);
 		wait_while_offlining();
+		if (ksm_mode_always()) {
+			/*
+			 * import one task's vma per run
+			 */
+			read_lock(&tasklist_lock);
+
+			for_each_process(task) {
+				curr_pid = task_pid_nr(task);
+				if (curr_pid == last_pid)
+					break;
+			}
+
+			task = next_task(task);
+			last_pid = task_pid_nr(task);
+
+			ksm_import_task_vma(task);
+			read_unlock(&tasklist_lock);
+		}
 		if (ksmd_should_run())
 			ksm_do_scan(ksm_thread_pages_to_scan);
 		mutex_unlock(&ksm_thread_mutex);
@@ -2350,26 +2433,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,

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
-#ifdef VM_SAO
-		if (*vm_flags & VM_SAO)
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
@@ -2769,6 +2835,36 @@ static ssize_t pages_to_scan_store(struct kobject *kobj,
 }
 KSM_ATTR(pages_to_scan);

+static ssize_t mode_show(struct kobject *kobj, struct kobj_attribute *attr,
+			char *buf)
+{
+	switch (ksm_mode) {
+		case KSM_MODE_NORMAL:
+			return sprintf(buf, "always [normal]\n");
+			break;
+		case KSM_MODE_ALWAYS:
+			return sprintf(buf, "[always] normal\n");
+			break;
+	}
+
+	return sprintf(buf, "always [normal]\n");
+}
+
+static ssize_t mode_store(struct kobject *kobj, struct kobj_attribute *attr,
+			 const char *buf, size_t count)
+{
+	if (!memcmp("always", buf, min(sizeof("always")-1, count))) {
+		ksm_mode = KSM_MODE_ALWAYS;
+		wake_up_interruptible(&ksm_thread_wait);
+	} else if (!memcmp("normal", buf, min(sizeof("normal")-1, count))) {
+		ksm_mode = KSM_MODE_NORMAL;
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
@@ -3026,6 +3122,7 @@ KSM_ATTR_RO(full_scans);
 static struct attribute *ksm_attrs[] = {
 	&sleep_millisecs_attr.attr,
 	&pages_to_scan_attr.attr,
+	&mode_attr.attr,
 	&run_attr.attr,
 	&pages_shared_attr.attr,
 	&pages_sharing_attr.attr,
--
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
