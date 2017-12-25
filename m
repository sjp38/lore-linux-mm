Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4EAD6B0038
	for <linux-mm@kvack.org>; Mon, 25 Dec 2017 04:07:40 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id u124so24029922qkd.18
        for <linux-mm@kvack.org>; Mon, 25 Dec 2017 01:07:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r73si1297912qka.55.2017.12.25.01.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Dec 2017 01:07:39 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBP95Han130764
	for <linux-mm@kvack.org>; Mon, 25 Dec 2017 04:07:38 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f2va5b37p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Dec 2017 04:07:37 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 25 Dec 2017 09:07:35 -0000
Date: Mon, 25 Dec 2017 11:07:27 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] userfaultfd: clear the vma->vm_userfaultfd_ctx if
 UFFD_EVENT_FORK fails
References: <20171222222346.GB28786@zzz.localdomain>
 <20171223002505.593-1-aarcange@redhat.com>
 <20171223002505.593-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171223002505.593-2-aarcange@redhat.com>
Message-Id: <20171225090726.GA11724@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Sat, Dec 23, 2017 at 01:25:05AM +0100, Andrea Arcangeli wrote:
> The previous fix 384632e67e0829deb8015ee6ad916b180049d252 corrected
> the refcounting in case of UFFD_EVENT_FORK failure for the fork
> userfault paths. That still didn't clear the vma->vm_userfaultfd_ctx
> of the vmas that were set to point to the aborted new uffd ctx earlier
> in dup_userfaultfd.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  fs/userfaultfd.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 896f810b6a06..1a88916455bd 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -591,11 +591,14 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>  static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
>  					      struct userfaultfd_wait_queue *ewq)
>  {
> +	struct userfaultfd_ctx *release_new_ctx;

Nit: we could have set release_new_ctx to NULL here...
> +
>  	if (WARN_ON_ONCE(current->flags & PF_EXITING))
>  		goto out;
> 
>  	ewq->ctx = ctx;
>  	init_waitqueue_entry(&ewq->wq, current);
> +	release_new_ctx = NULL;
> 
>  	spin_lock(&ctx->event_wqh.lock);
>  	/*
> @@ -622,8 +625,7 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
>  				new = (struct userfaultfd_ctx *)
>  					(unsigned long)
>  					ewq->msg.arg.reserved.reserved1;
> -
> -				userfaultfd_ctx_put(new);
> +				release_new_ctx = new;
>  			}
>  			break;
>  		}
> @@ -638,6 +640,20 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
>  	__set_current_state(TASK_RUNNING);
>  	spin_unlock(&ctx->event_wqh.lock);
> 
> +	if (release_new_ctx) {
> +		struct vm_area_struct *vma;
> +		struct mm_struct *mm = release_new_ctx->mm;
> +
> +		/* the various vma->vm_userfaultfd_ctx still points to it */
> +		down_write(&mm->mmap_sem);
> +		for (vma = mm->mmap; vma; vma = vma->vm_next)
> +			if (vma->vm_userfaultfd_ctx.ctx == release_new_ctx)
> +				vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
> +		up_write(&mm->mmap_sem);
> +
> +		userfaultfd_ctx_put(release_new_ctx);
> +	}
> +
>  	/*
>  	 * ctx may go away after this if the userfault pseudo fd is
>  	 * already released.
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
