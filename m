Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36F076B0069
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 07:33:12 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id h67so86651659vkf.4
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 04:33:12 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q18si3896614uaa.35.2016.12.18.04.33.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 04:33:11 -0800 (PST)
From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH 3/4] mm: use mmget_not_zero() helper
Date: Sun, 18 Dec 2016 13:32:28 +0100
Message-Id: <20161218123229.22952-3-vegard.nossum@oracle.com>
In-Reply-To: <20161218123229.22952-1-vegard.nossum@oracle.com>
References: <20161218123229.22952-1-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>

We already have the helper, we can convert the rest of the kernel
mechanically using:

  git grep -l 'atomic_inc_not_zero.*mm_users' | xargs sed -i 's/atomic_inc_not_zero(&\(.*\)->mm_users)/mmget_not_zero\(\1\)/'

This is needed for a later patch that hooks into the helper, but might be
a worthwhile cleanup on its own.

Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 drivers/gpu/drm/i915/i915_gem_userptr.c | 2 +-
 drivers/iommu/intel-svm.c               | 2 +-
 fs/proc/base.c                          | 4 ++--
 fs/proc/task_mmu.c                      | 4 ++--
 fs/proc/task_nommu.c                    | 2 +-
 kernel/events/uprobes.c                 | 2 +-
 mm/swapfile.c                           | 2 +-
 7 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 1f27529cb48e..89be48ed7c77 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -507,7 +507,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 			flags |= FOLL_WRITE;
 
 		ret = -EFAULT;
-		if (atomic_inc_not_zero(&mm->mm_users)) {
+		if (mmget_not_zero(mm)) {
 			down_read(&mm->mmap_sem);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index cb72e0011310..51f2b228723f 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -579,7 +579,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		if (!svm->mm)
 			goto bad_req;
 		/* If the mm is already defunct, don't handle faults. */
-		if (!atomic_inc_not_zero(&svm->mm->mm_users))
+		if (!mmget_not_zero(svm->mm))
 			goto bad_req;
 		down_read(&svm->mm->mmap_sem);
 		vma = find_extend_vma(svm->mm, address);
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 32f04999d930..ec7304f5117a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -845,7 +845,7 @@ static ssize_t mem_rw(struct file *file, char __user *buf,
 		return -ENOMEM;
 
 	copied = 0;
-	if (!atomic_inc_not_zero(&mm->mm_users))
+	if (!mmget_not_zero(mm))
 		goto free;
 
 	/* Maybe we should limit FOLL_FORCE to actual ptrace users? */
@@ -953,7 +953,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		return -ENOMEM;
 
 	ret = 0;
-	if (!atomic_inc_not_zero(&mm->mm_users))
+	if (!mmget_not_zero(mm))
 		goto free;
 
 	down_read(&mm->mmap_sem);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 958f32545064..6c07c7813b26 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -167,7 +167,7 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 		return ERR_PTR(-ESRCH);
 
 	mm = priv->mm;
-	if (!mm || !atomic_inc_not_zero(&mm->mm_users))
+	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
 	down_read(&mm->mmap_sem);
@@ -1352,7 +1352,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	unsigned long end_vaddr;
 	int ret = 0, copied = 0;
 
-	if (!mm || !atomic_inc_not_zero(&mm->mm_users))
+	if (!mm || !mmget_not_zero(mm))
 		goto out;
 
 	ret = -EINVAL;
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 37175621e890..1ef97cfcf422 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -219,7 +219,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 		return ERR_PTR(-ESRCH);
 
 	mm = priv->mm;
-	if (!mm || !atomic_inc_not_zero(&mm->mm_users))
+	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
 	down_read(&mm->mmap_sem);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 215871bda3a2..f164fe8ca5ff 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -741,7 +741,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 			continue;
 		}
 
-		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
+		if (!mmget_not_zero(vma->vm_mm))
 			continue;
 
 		info = prev;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 914c31cc143c..5502feef0a4a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1493,7 +1493,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 			while (swap_count(*swap_map) && !retval &&
 					(p = p->next) != &start_mm->mmlist) {
 				mm = list_entry(p, struct mm_struct, mmlist);
-				if (!atomic_inc_not_zero(&mm->mm_users))
+				if (!mmget_not_zero(mm))
 					continue;
 				spin_unlock(&mmlist_lock);
 				mmput(prev_mm);
-- 
2.11.0.1.gaa10c3f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
