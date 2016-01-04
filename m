Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E2E546B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 09:11:34 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id f206so141708389wmf.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 06:11:34 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id q3si71301382wmb.104.2016.01.04.06.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 06:11:33 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id f206so141707635wmf.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 06:11:33 -0800 (PST)
Date: Mon, 4 Jan 2016 16:11:30 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RESEND] ipc/shm: handle removed segments gracefully in
 shm_mmap()
Message-ID: <20160104141130.GA13515@node.shutemov.name>
References: <1447232220-36879-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151111170347.GA3502@linux-uzut.site>
 <20151111195023.GA17310@node.shutemov.name>
 <20151113053137.GB3502@linux-uzut.site>
 <20151113091259.GB28904@node.shutemov.name>
 <20151113192310.GC3502@linux-uzut.site>
 <5687B843.2040804@colorfullife.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5687B843.2040804@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>

On Sat, Jan 02, 2016 at 12:45:07PM +0100, Manfred Spraul wrote:
> On 11/13/2015 08:23 PM, Davidlohr Bueso wrote:
> >
> >So considering EINVAL, even your approach to bumping up nattach by calling
> >_shm_open earlier isn't enough. Races exposed to user called rmid can
> >still
> >occur between dropping the lock and doing ->mmap(). Ultimately this leads
> >to
> >all ipc_valid_object() checks, as we totally ignore SHM_DEST segments
> >nowadays
> >since we forbid mapping previously removed segments.
> >
> >I think this is the first thing we must decide before going forward with
> >this
> >mess. ipc currently defines invalid objects by merely checking the deleted
> >flag.
> >
> >Manfred, any thoughts?
> >
> With regards to locking: Sorry, shm is too different to msg/sem/mqueue.
> 
> With regards to EIDRM / EINVAL:
> When all kernel memory was released, then the kernel cannot find out if the
> ID was valid at one time or not.
> Thus EIDRM can only be a hint, the OS (kernel/libc) cannot guarantee that
> user space will never see something else.
> (trivial example: user space sleeps just before the syscall)
> 
> So I would not create special code to optimize EIDRM handling for races. If
> we sometimes report EINVAL, it would be probably ok as well.

Guys, here's yet another attempt to fix the issue.

The key idea this time is to use shm_ids(ns).rwsem taken for read in shm_mmap()
to prevent rmid under us.

Any problem with this?

diff --git a/ipc/shm.c b/ipc/shm.c
index ed3027d0f277..b306fb3d9586 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -156,11 +156,12 @@ static inline struct shmid_kernel *shm_lock(struct ipc_namespace *ns, int id)
 	struct kern_ipc_perm *ipcp = ipc_lock(&shm_ids(ns), id);
 
 	/*
-	 * We raced in the idr lookup or with shm_destroy().  Either way, the
-	 * ID is busted.
+	 * Callers of shm_lock() must validate the status of the returned ipc
+	 * object pointer (as returned by ipc_lock()), and error out as
+	 * appropriate.
 	 */
-	WARN_ON(IS_ERR(ipcp));
-
+	if (IS_ERR(ipcp))
+		return (void *)ipcp;
 	return container_of(ipcp, struct shmid_kernel, shm_perm);
 }
 
@@ -194,6 +195,14 @@ static void shm_open(struct vm_area_struct *vma)
 	struct shmid_kernel *shp;
 
 	shp = shm_lock(sfd->ns, sfd->id);
+
+	/*
+	 * We raced in the idr lookup or with shm_destroy().
+	 * Either way, the ID is busted.
+	 */
+	if (WARN_ON(IS_ERR(shp)))
+		return ;
+
 	shp->shm_atim = get_seconds();
 	shp->shm_lprid = task_tgid_vnr(current);
 	shp->shm_nattch++;
@@ -386,18 +395,34 @@ static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
 static int shm_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct shm_file_data *sfd = shm_file_data(file);
+	struct shmid_kernel *shp;
 	int ret;
 
+	/* Prevent rmid under us */
+	down_read(&shm_ids(sfd->ns).rwsem);
+
+	/* Check if we can map the segment */
+	shp = shm_lock(sfd->ns, sfd->id);
+	if (IS_ERR(shp)) {
+		ret = PTR_ERR(shp);
+		goto out;
+	}
+	ret = shp->shm_perm.mode & SHM_DEST ? -EINVAL : 0;
+	shm_unlock(shp);
+	if (ret)
+		goto out;
+
 	ret = sfd->file->f_op->mmap(sfd->file, vma);
 	if (ret != 0)
-		return ret;
+		goto out;
 	sfd->vm_ops = vma->vm_ops;
 #ifdef CONFIG_MMU
 	WARN_ON(!sfd->vm_ops->fault);
 #endif
 	vma->vm_ops = &shm_vm_ops;
 	shm_open(vma);
-
+out:
+	up_read(&shm_ids(sfd->ns).rwsem);
 	return ret;
 }
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
