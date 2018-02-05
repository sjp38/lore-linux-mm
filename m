Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB52F6B02AA
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:45 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w19so6567469pgv.4
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si4097415pfg.288.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 60/64] drivers/xen: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:50 +0100
Message-Id: <20180205012754.23615-61-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

All callers use mmap_sem within the same function
context. No change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/xen/gntdev.c  |  5 +++--
 drivers/xen/privcmd.c | 12 +++++++-----
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index bd56653b9bbc..9181eee4e160 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -648,12 +648,13 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	struct vm_area_struct *vma;
 	struct grant_map *map;
 	int rv = -EINVAL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (copy_from_user(&op, u, sizeof(op)) != 0)
 		return -EFAULT;
 	pr_debug("priv %p, offset for vaddr %lx\n", priv, (unsigned long)op.vaddr);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma(current->mm, op.vaddr);
 	if (!vma || vma->vm_ops != &gntdev_vmops)
 		goto out_unlock;
@@ -667,7 +668,7 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	rv = 0;
 
  out_unlock:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	if (rv == 0 && copy_to_user(u, &op, sizeof(op)) != 0)
 		return -EFAULT;
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 1c909183c42a..3736752556c5 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -257,6 +257,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	int rc;
 	LIST_HEAD(pagelist);
 	struct mmap_gfn_state state;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* We only support privcmd_ioctl_mmap_batch for auto translated. */
 	if (xen_feature(XENFEAT_auto_translated_physmap))
@@ -276,7 +277,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	if (rc || list_empty(&pagelist))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	{
 		struct page *page = list_first_entry(&pagelist,
@@ -301,7 +302,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 
 
 out_up:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 out:
 	free_page_list(&pagelist);
@@ -451,6 +452,7 @@ static long privcmd_ioctl_mmap_batch(
 	unsigned long nr_pages;
 	LIST_HEAD(pagelist);
 	struct mmap_batch_state state;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	switch (version) {
 	case 1:
@@ -497,7 +499,7 @@ static long privcmd_ioctl_mmap_batch(
 		}
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	vma = find_vma(mm, m.addr);
 	if (!vma ||
@@ -553,7 +555,7 @@ static long privcmd_ioctl_mmap_batch(
 	BUG_ON(traverse_pages_block(m.num, sizeof(xen_pfn_t),
 				    &pagelist, mmap_batch_fn, &state));
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	if (state.global_error) {
 		/* Write back errors in second pass. */
@@ -574,7 +576,7 @@ static long privcmd_ioctl_mmap_batch(
 	return ret;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	goto out;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
