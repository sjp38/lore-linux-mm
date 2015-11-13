Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B60516B0270
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:59:02 -0500 (EST)
Received: by wmdw130 with SMTP id w130so42968082wmd.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:59:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kg3si28013798wjb.25.2015.11.13.11.59.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 11:59:01 -0800 (PST)
Date: Fri, 13 Nov 2015 11:58:53 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH, RESEND] ipc/shm: handle removed segments gracefully in
 shm_mmap()
Message-ID: <20151113195853.GD3502@linux-uzut.site>
References: <1447232220-36879-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151111170347.GA3502@linux-uzut.site>
 <20151111195023.GA17310@node.shutemov.name>
 <20151113053137.GB3502@linux-uzut.site>
 <20151113091259.GB28904@node.shutemov.name>
 <20151113192310.GC3502@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151113192310.GC3502@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>, Manfred Spraul <manfred@colorfullife.com>

On Fri, 13 Nov 2015, Bueso wrote:


>So considering EINVAL, even your approach to bumping up nattach by calling
>_shm_open earlier isn't enough. Races exposed to user called rmid can still
>occur between dropping the lock and doing ->mmap(). Ultimately this leads to
>all ipc_valid_object() checks, as we totally ignore SHM_DEST segments nowadays
>since we forbid mapping previously removed segments.
>
>I think this is the first thing we must decide before going forward with this
>mess. ipc currently defines invalid objects by merely checking the deleted flag.

Particularly something like this, which we could then add to the vma validity
check, thus saving the lookup as well.

diff --git a/ipc/shm.c b/ipc/shm.c
index 4178727..d9b2fb1 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -64,6 +64,20 @@ static const struct vm_operations_struct shm_vm_ops;
  #define shm_unlock(shp)			\
  	ipc_unlock(&(shp)->shm_perm)
  
+/*
+ * shm object validity is different than the rest of ipc
+ * as shm needs to deal with segments previously marked
+ * for deletion, which can occur at any time via user calls.
+ */
+static inline int shm_invalid_object(struct kern_ipc_perm *perm)
+{
+	if (perm->mode & SHM_DEST)
+		return -EINVAL;
+	if (ipc_valid_object(perm))
+		return -EIDRM;
+	return 0; /* yay */
+}
+
  static int newseg(struct ipc_namespace *, struct ipc_params *);
  static void shm_open(struct vm_area_struct *vma);
  static void shm_close(struct vm_area_struct *vma);
@@ -985,11 +999,9 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
  
  		ipc_lock_object(&shp->shm_perm);
  
-		/* check if shm_destroy() is tearing down shp */
-		if (!ipc_valid_object(&shp->shm_perm)) {
-			err = -EIDRM;
+		err = shm_invalid_object(&shp->shm_perm);
+		if (err)
  			goto out_unlock0;
-		}
  
  		if (!ns_capable(ns->user_ns, CAP_IPC_LOCK)) {
  			kuid_t euid = current_euid();
@@ -1124,10 +1136,9 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
  
  	ipc_lock_object(&shp->shm_perm);
  
-	/* check if shm_destroy() is tearing down shp */
-	if (!ipc_valid_object(&shp->shm_perm)) {
+	err = shm_invalid_object(&shp->shm_perm);
+	if (err) {
  		ipc_unlock_object(&shp->shm_perm);
-		err = -EIDRM;
  		goto out_unlock;
  	}
  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
