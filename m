Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F25D56B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:00:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so38803676wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:00:23 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id on1si10819441wjc.56.2016.06.17.02.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 02:00:22 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r201so2869348wme.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:00:22 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] vhost, mm: make sure that oom_reaper doesn't reap memory read by vhost
Date: Fri, 17 Jun 2016 11:00:17 +0200
Message-Id: <1466154017-2222-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

vhost driver relies on copy_from_user/get_user from a kernel thread.
This makes it impossible to reap the memory of an oom victim which
shares mm with the vhost kernel thread because it could see a zero
page unexpectedly and theoretically make an incorrect decision visible
outside of the killed task context.

Make sure that each place which can read from userspace is annotated
properly and it uses copy_from_user_mm, __get_user_mm resp.
copy_from_iter_mm. Each will get the target mm as an argument and it
performs a pessimistic check to rule out that the oom_reaper could
possibly unmap the particular page. __oom_reap_task then just needs to
mark the mm as unstable before it unmaps any page.

This is a preparatory patch without any functional changes because
the oom reaper doesn't touch mm shared with kthreads yet.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Michael,
we have discussed [1] that vhost_worker pins the mm of a potential
oom victim for too long which result into an OOM storm when other
processes have to be killed. One way to address this issue would
be to pin mm_count rather than mm_users and revalidate it before
actually doing the copy (mmget_not_zero). You had concerns about
more atomic operations in the data path. Another way would be to
postpone exit_mm_victim to after exit_task_work but as it turned
out other task might have the device open and pin the mm indirectly
[2].

Now I would like to attack the issue from another side which would
be more generic. I would like to make mm's which are shared with
kthreads oom reapable in general. This is currently not allowed
because we do not want to risk that a kthread would see an already
unmapped page - aka see a newly allocated zero page. At the same
time this is really desirable because it helps to guarantee a forward
progress on the OOM.

It seems that vhost usage would suffer from this problem because
it reads from the userspace to get (status) flags and makes some
decisions based on the read value.  I do not understand the code so I
couldn't evaluate whether that would lead to some real problems so I
conservatively assumed it wouldn't handle that gracefully. If this is
incorrect and all the paths can just cope with seeing zeros unexpectedly
then great and I will drop the patch and move over to the oom specific
further steps.

Therefore I am proposing a kthread safe API which allows to read from
userspace and also makes sure to do a proper exclusion with the oom
reaper. A race would be reported by EFAULT which is already handled.
Performance wise it would add two tests to the copy from user
paths. Does the following change makes sense to you and would be
acceptable? If yes I will follow up with another patch which will allow
oom reaper for mm shared with kthread.

Thanks!

[1] http://lkml.kernel.org/r/1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com
[2] http://lkml.kernel.org/r/20160301181136-mutt-send-email-mst@redhat.com

 drivers/vhost/scsi.c    |  2 +-
 drivers/vhost/vhost.c   | 18 +++++++++---------
 include/linux/sched.h   |  1 +
 include/linux/uaccess.h | 22 ++++++++++++++++++++++
 include/linux/uio.h     | 10 ++++++++++
 mm/oom_kill.c           |  6 ++++++
 6 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 0e6fd556c982..2c8dc0b9a21f 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -932,7 +932,7 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 		 */
 		iov_iter_init(&out_iter, WRITE, vq->iov, out, out_size);
 
-		ret = copy_from_iter(req, req_size, &out_iter);
+		ret = copy_from_iter_mm(vq->dev->mm, req, req_size, &out_iter);
 		if (unlikely(ret != req_size)) {
 			vq_err(vq, "Faulted on copy_from_iter\n");
 			vhost_scsi_send_bad_target(vs, vq, head, out);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 669fef1e2bb6..14959ba43cb4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1212,7 +1212,7 @@ int vhost_vq_init_access(struct vhost_virtqueue *vq)
 		r = -EFAULT;
 		goto err;
 	}
-	r = __get_user(last_used_idx, &vq->used->idx);
+	r = __get_user_mm(vq->dev->mm, last_used_idx, &vq->used->idx);
 	if (r)
 		goto err;
 	vq->last_used_idx = vhost16_to_cpu(vq, last_used_idx);
@@ -1328,7 +1328,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
 			       i, count);
 			return -EINVAL;
 		}
-		if (unlikely(copy_from_iter(&desc, sizeof(desc), &from) !=
+		if (unlikely(copy_from_iter_mm(vq->dev->mm, &desc, sizeof(desc), &from) !=
 			     sizeof(desc))) {
 			vq_err(vq, "Failed indirect descriptor: idx %d, %zx\n",
 			       i, (size_t)vhost64_to_cpu(vq, indirect->addr) + i * sizeof desc);
@@ -1392,7 +1392,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	/* Check it isn't doing very strange things with descriptor numbers. */
 	last_avail_idx = vq->last_avail_idx;
-	if (unlikely(__get_user(avail_idx, &vq->avail->idx))) {
+	if (unlikely(__get_user_mm(vq->dev->mm, avail_idx, &vq->avail->idx))) {
 		vq_err(vq, "Failed to access avail idx at %p\n",
 		       &vq->avail->idx);
 		return -EFAULT;
@@ -1414,7 +1414,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	/* Grab the next descriptor number they're advertising, and increment
 	 * the index we've seen. */
-	if (unlikely(__get_user(ring_head,
+	if (unlikely(__get_user_mm(vq->dev->mm, ring_head,
 				&vq->avail->ring[last_avail_idx & (vq->num - 1)]))) {
 		vq_err(vq, "Failed to read head: idx %d address %p\n",
 		       last_avail_idx,
@@ -1450,7 +1450,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 			       i, vq->num, head);
 			return -EINVAL;
 		}
-		ret = __copy_from_user(&desc, vq->desc + i, sizeof desc);
+		ret = __copy_from_user_mm(vq->dev->mm, &desc, vq->desc + i, sizeof desc);
 		if (unlikely(ret)) {
 			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
 			       i, vq->desc + i);
@@ -1622,7 +1622,7 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 
 	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
 		__virtio16 flags;
-		if (__get_user(flags, &vq->avail->flags)) {
+		if (__get_user_mm(dev->mm, flags, &vq->avail->flags)) {
 			vq_err(vq, "Failed to get flags");
 			return true;
 		}
@@ -1636,7 +1636,7 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	if (unlikely(!v))
 		return true;
 
-	if (__get_user(event, vhost_used_event(vq))) {
+	if (__get_user_mm(dev->mm, event, vhost_used_event(vq))) {
 		vq_err(vq, "Failed to get used event idx");
 		return true;
 	}
@@ -1678,7 +1678,7 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	__virtio16 avail_idx;
 	int r;
 
-	r = __get_user(avail_idx, &vq->avail->idx);
+	r = __get_user_mm(dev->mm, avail_idx, &vq->avail->idx);
 	if (r)
 		return false;
 
@@ -1713,7 +1713,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	/* They could have slipped one in as we were doing that: make
 	 * sure it's written, then check again. */
 	smp_mb();
-	r = __get_user(avail_idx, &vq->avail->idx);
+	r = __get_user_mm(dev->mm,avail_idx, &vq->avail->idx);
 	if (r) {
 		vq_err(vq, "Failed to check avail idx at %p: %d\n",
 		       &vq->avail->idx, r);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d81a1eb974a..2b00ac7faa18 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -513,6 +513,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
 #define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
+#define MMF_UNSTABLE		23	/* mm is unstable for copy_from_user */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index 349557825428..b1f314fca3c8 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -76,6 +76,28 @@ static inline unsigned long __copy_from_user_nocache(void *to,
 #endif		/* ARCH_HAS_NOCACHE_UACCESS */
 
 /*
+ * A safe variant of __get_user for for use_mm() users to have a
+ * gurantee that the address space wasn't reaped in the background
+ */
+#define __get_user_mm(mm, x, ptr)				\
+({								\
+	int ___gu_err = __get_user(x, ptr);			\
+	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
+		___gu_err = -EFAULT;				\
+	___gu_err;						\
+})
+
+/* similar to __get_user_mm */
+static inline __must_check long __copy_from_user_mm(struct mm_struct *mm,
+		void *to, const void __user * from, unsigned long n)
+{
+	long ret = __copy_from_user(to, from, n);
+	if (!ret && test_bit(MMF_UNSTABLE, &mm->flags))
+		return -EFAULT;
+	return ret;
+}
+
+/*
  * probe_kernel_read(): safely attempt to read from a location
  * @dst: pointer to the buffer that shall take the data
  * @src: address to read from
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 1b5d1cd796e2..4be6b24003d8 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -9,6 +9,7 @@
 #ifndef __LINUX_UIO_H
 #define __LINUX_UIO_H
 
+#include <linux/sched.h>
 #include <linux/kernel.h>
 #include <uapi/linux/uio.h>
 
@@ -84,6 +85,15 @@ size_t copy_page_from_iter(struct page *page, size_t offset, size_t bytes,
 			 struct iov_iter *i);
 size_t copy_to_iter(const void *addr, size_t bytes, struct iov_iter *i);
 size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i);
+
+static inline size_t copy_from_iter_mm(struct mm_struct *mm, void *addr,
+		size_t bytes, struct iov_iter *i)
+{
+	size_t ret = copy_from_iter(addr, bytes, i);
+	if (!IS_ERR_VALUE(ret) && test_bit(MMF_UNSTABLE, &mm->flags))
+		return -EFAULT;
+	return ret;
+}
 size_t copy_from_iter_nocache(void *addr, size_t bytes, struct iov_iter *i);
 size_t iov_iter_zero(size_t bytes, struct iov_iter *);
 unsigned long iov_iter_alignment(const struct iov_iter *i);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6303bc7caeda..3fa43e96a59b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -506,6 +506,12 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		goto mm_drop;
 	}
 
+	/*
+	 * Tell all users of get_user_mm/copy_from_user_mm that the content
+	 * is no longer stable.
+	 */
+	set_bit(MMF_UNSTABLE, &mm->flags);
+
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (is_vm_hugetlb_page(vma))
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
