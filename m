Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 46DF16B0157
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:31:21 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 4/4] ksm: add support for scanning procsses that were not modifided to use ksm
Date: Thu, 14 May 2009 03:30:48 +0300
Message-Id: <1242261048-4487-5-git-send-email-ieidus@redhat.com>
In-Reply-To: <1242261048-4487-4-git-send-email-ieidus@redhat.com>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <1242261048-4487-2-git-send-email-ieidus@redhat.com>
 <1242261048-4487-3-git-send-email-ieidus@redhat.com>
 <1242261048-4487-4-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, linux-mm@kvack.org, riel@redhat.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

This patch add merge_pid and unmerge_pid fields into /sys/kernel/mm/ksm
this feild allow merging memory of any application in the system,
just run:
echo pid_num > /sys/kernel/mm/ksm/merge_pid - and memory will be merged.

This patch add MMF_VM_MERGEALL flag into the mm flags, this flags mean that
all the vmas inside this mm_struct are mergeable by ksm.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/sched.h |    1 +
 mm/ksm.c              |  110 +++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 107 insertions(+), 4 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7dc786a..c23af0c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -440,6 +440,7 @@ extern int get_dumpable(struct mm_struct *mm);
 #endif
 
 #define MMF_VM_MERGEABLE	9
+#define MMF_VM_MERGEALL		10
 
 struct sighand_struct {
 	atomic_t		count;
diff --git a/mm/ksm.c b/mm/ksm.c
index 901cce3..5bb42d8 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -479,7 +479,10 @@ static int try_to_merge_one_page(struct mm_struct *mm,
 	unsigned long page_addr_in_vma;
 	pte_t orig_pte, *orig_ptep;
 
-	if(!(vma->vm_flags & VM_MERGEABLE))
+
+
+	if(!(vma->vm_flags & VM_MERGEABLE) &&
+	   !test_bit(MMF_VM_MERGEALL, &mm->flags))
 		goto out;
 
 	if (!PageAnon(oldpage))
@@ -1213,7 +1216,8 @@ static struct mm_slot *get_next_mmlist(struct list_head *cur,
 	cur = cur->next;
 	while (cur != &init_mm.mmlist) {
 		mm = list_entry(cur, struct mm_struct, mmlist);
-		if (test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+		if (test_bit(MMF_VM_MERGEABLE, &mm->flags) ||
+		    test_bit(MMF_VM_MERGEALL, &mm->flags)) {
 			mm_slot = get_mm_slot(mm);
 			if (unlikely(atomic_read(&mm->mm_users) == 1)) {
 				if (mm_slot)
@@ -1245,6 +1249,7 @@ static struct mm_slot *get_next_mmlist(struct list_head *cur,
 	int used_slot = 0;
 	int used_rmap = 0;
 	int ret = -EAGAIN;
+	int merge_all;
 
 	pre_alloc_rmap_item = alloc_rmap_item();
 	if (!pre_alloc_rmap_item)
@@ -1287,8 +1292,10 @@ static struct mm_slot *get_next_mmlist(struct list_head *cur,
 	ksm_scan->addr_index += PAGE_SIZE;
 
 again:
+	merge_all = test_bit(MMF_VM_MERGEALL, &slot->mm->flags);
+
 	vma = find_vma(slot->mm, ksm_scan->addr_index);
-	if (vma && vma->vm_flags & VM_MERGEABLE) {
+	if (vma && (vma->vm_flags & VM_MERGEABLE || merge_all)) {
 		if (ksm_scan->addr_index < vma->vm_start)
 			ksm_scan->addr_index = vma->vm_start;
 		up_read(&slot->mm->mmap_sem);
@@ -1304,7 +1311,7 @@ again:
 		ret = 0;
 		goto out_free;
 	} else {
-		while (vma && !(vma->vm_flags & VM_MERGEABLE))
+		while (vma && (!(vma->vm_flags & VM_MERGEABLE) && !merge_all))
 			vma = vma->vm_next;
 
 		if (vma) {
@@ -1455,6 +1462,99 @@ int ksm_scan_thread(void *nothing)
 	static struct kobj_attribute _name##_attr = \
 		__ATTR(_name, 0644, _name##_show, _name##_store)
 
+static ssize_t merge_pid_show(struct kobject *kobj, struct kobj_attribute *attr,
+			      char *buf)
+{
+	unsigned int usecs;
+
+	down_read(&ksm_thread_lock);
+	usecs = ksm_thread_sleep;
+	up_read(&ksm_thread_lock);
+
+	return sprintf(buf, "\n");
+}
+
+static ssize_t merge_pid_store(struct kobject *kobj,
+			       struct kobj_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct task_struct *task;
+	struct mm_struct *mm = NULL;
+	unsigned long pid;
+	int err;
+
+	err = strict_strtoul(buf, 10, &pid);
+	if (err)
+		return 0;
+
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		mm = get_task_mm(task);
+	read_unlock(&tasklist_lock);
+
+	if (mm) {
+		down_write(&mm->mmap_sem);
+		set_bit(MMF_VM_MERGEALL, &mm->flags);
+		up_write(&mm->mmap_sem);
+
+		spin_lock(&mmlist_lock);
+		if (unlikely(list_empty(&mm->mmlist)))
+			list_add(&mm->mmlist, &init_mm.mmlist);
+		if (unlikely(!(mmlist_mask & MMLIST_KSM)))
+			mmlist_mask |= MMLIST_KSM;
+		spin_unlock(&mmlist_lock);
+
+		mmput(mm);
+	}
+
+	return count;
+}
+KSM_ATTR(merge_pid);
+
+static ssize_t unmerge_pid_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	unsigned int usecs;
+
+	down_read(&ksm_thread_lock);
+	usecs = ksm_thread_sleep;
+	up_read(&ksm_thread_lock);
+
+	return sprintf(buf, "\n");
+}
+
+static ssize_t unmerge_pid_store(struct kobject *kobj,
+				 struct kobj_attribute *attr,
+				 const char *buf, size_t count)
+{
+	struct task_struct *task;
+	struct mm_struct *mm = NULL;
+	unsigned long pid;
+	int err;
+
+	err = strict_strtoul(buf, 10, &pid);
+	if (err)
+		return 0;
+
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		mm = get_task_mm(task);
+	read_unlock(&tasklist_lock);
+
+	if (mm) {
+		down_write(&mm->mmap_sem);
+		clear_bit(MMF_VM_MERGEALL, &mm->flags);
+		up_write(&mm->mmap_sem);
+
+		mmput(mm);
+	}
+
+	return count;
+}
+KSM_ATTR(unmerge_pid);
+
 static ssize_t sleep_show(struct kobject *kobj, struct kobj_attribute *attr,
 			  char *buf)
 {
@@ -1605,6 +1705,8 @@ static ssize_t max_kernel_pages_show(struct kobject *kobj,
 KSM_ATTR(max_kernel_pages);
 
 static struct attribute *ksm_attrs[] = {
+	&merge_pid_attr.attr,
+	&unmerge_pid_attr.attr,
 	&sleep_attr.attr,
 	&pages_to_scan_attr.attr,
 	&run_attr.attr,
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
