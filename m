Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 837236B00E3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 16:02:13 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so848353wib.5
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 13:02:13 -0800 (PST)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com. [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id jx1si842374wid.26.2014.11.13.13.02.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 13:02:12 -0800 (PST)
Received: by mail-wg0-f49.google.com with SMTP id x13so17627687wgg.22
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 13:02:12 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [RESEND][PATCH V3 2/4] KSM: Add to sysfs - mark_new_vma
Date: Fri, 14 Nov 2014 00:01:56 +0300
Message-Id: <1415912518-8508-3-git-send-email-nefelim4ag@gmail.com>
In-Reply-To: <1415912518-8508-1-git-send-email-nefelim4ag@gmail.com>
References: <1415912518-8508-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Timofey Titovets <nefelim4ag@gmail.com>

It allow to control user mark new vma as VM_MERGEABLE or not
Create new sysfs interface /sys/kernel/mm/ksm/mark_new_vma
1 - enabled - mark new allocated vma as VM_MERGEABLE and add it to ksm queue
0 - disable it

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 include/linux/ksm.h | 10 +++++++++-
 mm/ksm.c            | 39 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index c3fff64..deb60fc 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -76,6 +76,12 @@ struct page *ksm_might_need_to_copy(struct page *page,
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 
+
+/* Mark new vma as mergeable */
+#define ALLOW	1
+#define DENY	0
+extern unsigned mark_new_vma __read_mostly;
+
 /*
  * Allow to mark new vma as VM_MERGEABLE
  */
@@ -84,6 +90,8 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 #endif
 static inline void ksm_vm_flags_mod(unsigned long *vm_flags)
 {
+	if (!mark_new_vma)
+		return;
 	if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 			 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
 			 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP   | VM_SAO) )
@@ -94,7 +102,7 @@ static inline void ksm_vm_flags_mod(unsigned long *vm_flags)
 static inline void ksm_vma_add_new(struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+	if (mark_new_vma && !test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
 		__ksm_enter(mm);
 	}
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 6b2e337..7bfb616 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -223,6 +223,12 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Mark new vma as mergeable */
+#ifndef CONFIG_KSM_MARK_NEW_VMA
+#define CONFIG_KSM_MARK_NEW_VMA DENY
+#endif
+unsigned mark_new_vma = CONFIG_KSM_MARK_NEW_VMA;
+
 #ifdef CONFIG_NUMA
 /* Zeroed when merging across nodes is not allowed */
 static unsigned int ksm_merge_across_nodes = 1;
@@ -2127,6 +2133,34 @@ static ssize_t pages_to_scan_store(struct kobject *kobj,
 }
 KSM_ATTR(pages_to_scan);
 
+static ssize_t mark_new_vma_show(struct kobject *kobj, struct kobj_attribute *attr,
+			char *buf)
+{
+	return sprintf(buf, "%u\n", mark_new_vma);
+}
+static ssize_t mark_new_vma_store(struct kobject *kobj,
+				  struct kobj_attribute *attr,
+				  const char *buf, size_t count)
+{
+	int err;
+	unsigned long flags;
+
+	err = kstrtoul(buf, 10, &flags);
+	if (err || flags > UINT_MAX || flags > ALLOW)
+		return -EINVAL;
+
+	/*
+	 * ALLOW = 1 - sets allow for mark new vma as
+	 * VM_MERGEABLE and adding it to ksm
+	 * DENY = 0 - disable it
+	 */
+	if (mark_new_vma != flags) {
+		mark_new_vma = flags;
+	}
+	return count;
+}
+KSM_ATTR(mark_new_vma);
+
 static ssize_t run_show(struct kobject *kobj, struct kobj_attribute *attr,
 			char *buf)
 {
@@ -2287,6 +2321,7 @@ static struct attribute *ksm_attrs[] = {
 	&pages_unshared_attr.attr,
 	&pages_volatile_attr.attr,
 	&full_scans_attr.attr,
+	&mark_new_vma_attr.attr,
 #ifdef CONFIG_NUMA
 	&merge_across_nodes_attr.attr,
 #endif
@@ -2323,7 +2358,9 @@ static int __init ksm_init(void)
 		goto out_free;
 	}
 #else
-	ksm_run = KSM_RUN_MERGE;	/* no way for user to start it */
+	/* no way for user to start it */
+	mark_new_vma = ALLOW;
+	ksm_run = KSM_RUN_MERGE;
 
 #endif /* CONFIG_SYSFS */
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
