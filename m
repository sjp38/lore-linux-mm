Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7242B6B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 19:26:09 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id a5so8370081plp.0
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 16:26:09 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id b3si6172382pgc.496.2018.02.26.16.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 16:26:07 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 1/4 v2] mm: add access_remote_vm_killable APIs
Date: Tue, 27 Feb 2018 08:25:48 +0800
Message-Id: <1519691151-101999-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org, adobriyan@gmail.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Extracted common part (without acquiring mmap_sem) of
__access_remote_vm() into raw_access_remote_vm() then create
__access_remote_vm_killable() and access_remote_vm_killable() with
acquiring mmap_sem by down_read_killable().
Keep non-killable versions using down_read().

The killable version will be used by reading /proc/*/cmdline and
/proc/*/environ for the time being.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/mm.h |  5 +++++
 mm/memory.c        | 44 +++++++++++++++++++++++++++++++++++++-------
 mm/nommu.c         | 36 ++++++++++++++++++++++++++++++++----
 3 files changed, 74 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..4574b19 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1372,8 +1372,13 @@ extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags);
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags);
+extern int access_remote_vm_killable(struct mm_struct *mm, unsigned long addr,
+		void *buf, int len, unsigned int gup_flags);
 extern int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, unsigned int gup_flags);
+extern int __access_remote_vm_killable(struct task_struct *tsk,
+		struct mm_struct *mm, unsigned long addr, void *buf, int len,
+		unsigned int gup_flags);
 
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long start, unsigned long nr_pages,
diff --git a/mm/memory.c b/mm/memory.c
index dd8de96..8d7e223 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4415,18 +4415,13 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 EXPORT_SYMBOL_GPL(generic_access_phys);
 #endif
 
-/*
- * Access another process' address space as given in mm.  If non-NULL, use the
- * given task for page fault accounting.
- */
-int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+static int raw_access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, unsigned int gup_flags)
 {
 	struct vm_area_struct *vma;
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -4475,11 +4470,40 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
 
 	return buf - old_buf;
 }
 
+/*
+ * Access another process' address space as given in mm.  If non-NULL, use the
+ * given task for page fault accounting.
+ */
+int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long addr, void *buf, int len, unsigned int gup_flags)
+{
+	int ret;
+
+	down_read(&mm->mmap_sem);
+	ret = raw_access_remote_vm(tsk, mm, addr, buf, len, gup_flags);
+	up_read(&mm->mmap_sem);
+	return ret;
+}
+
+int __access_remote_vm_killable(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long addr, void *buf, int len, unsigned int gup_flags)
+{
+	int ret;
+
+	ret = down_read_killable(&mm->mmap_sem);
+	if (ret)
+		goto out;
+
+	ret = raw_access_remote_vm(tsk, mm, addr, buf, len, gup_flags);
+	up_read(&mm->mmap_sem);
+out:
+	return ret;
+}
+
 /**
  * access_remote_vm - access another process' address space
  * @mm:		the mm_struct of the target address space
@@ -4490,6 +4514,12 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
  *
  * The caller must hold a reference on @mm.
  */
+int access_remote_vm_killable(struct mm_struct *mm, unsigned long addr,
+		void *buf, int len, unsigned int gup_flags)
+{
+	return __access_remote_vm_killable(NULL, mm, addr, buf, len, gup_flags);
+}
+
 int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index ebb6e61..ea043b3 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1802,14 +1802,12 @@ void filemap_map_pages(struct vm_fault *vmf,
 }
 EXPORT_SYMBOL(filemap_map_pages);
 
-int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+static int raw_access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long addr, void *buf, int len, unsigned int gup_flags)
 {
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
-
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
 	if (vma) {
@@ -1830,9 +1828,33 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		len = 0;
 	}
 
+	return len;
+}
+
+int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long addr, void *buf, int len, unsigned int gup_flags)
+{
+	int ret;
+
+	down_read(&mm->mmap_sem);
+	ret = raw_access_remote_vm(tsk, mm, addr, buf, len, gup_flags);
 	up_read(&mm->mmap_sem);
+	return ret;
+}
 
-	return len;
+int __access_remote_vm_killable(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long addr, void *buf, int len, unsigned int gup_flags)
+{
+	int ret;
+
+	ret = down_read_killable(&mm->mmap_sem);
+	if (ret)
+		goto out;
+
+	ret = raw_access_remote_vm(tsk, mm, addr, buf, len, gup_flags);
+	up_read(&mm->mmap_sem);
+out:
+	return ret;
 }
 
 /**
@@ -1845,6 +1867,12 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
  *
  * The caller must hold a reference on @mm.
  */
+int access_remote_vm_killable(struct mm_struct *mm, unsigned long addr,
+		void *buf, int len, unsigned int gup_flags)
+{
+	return __access_remote_vm_killable(NULL, mm, addr, buf, len, gup_flags);
+}
+
 int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags)
 {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
