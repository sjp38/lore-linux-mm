Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3C8B6B0268
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 04:01:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a136so10398604pfa.5
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 01:01:33 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id y64si8202245pgb.270.2016.11.03.01.01.31
        for <linux-mm@kvack.org>;
        Thu, 03 Nov 2016 01:01:32 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com> <1478115245-32090-13-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-13-git-send-email-aarcange@redhat.com>
Subject: Re: [PATCH 12/33] userfaultfd: non-cooperative: Add madvise() event for MADV_DONTNEED request
Date: Thu, 03 Nov 2016 16:01:12 +0800
Message-ID: <072b01d235a8$7238d230$56aa7690$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'Michael Rapoport' <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

On Thursday, November 03, 2016 3:34 AM Andrea Arcangeli wrote:
> +void madvise_userfault_dontneed(struct vm_area_struct *vma,
> +				struct vm_area_struct **prev,
> +				unsigned long start, unsigned long end)
> +{
> +	struct userfaultfd_ctx *ctx;
> +	struct userfaultfd_wait_queue ewq;
> +
> +	ctx = vma->vm_userfaultfd_ctx.ctx;
> +	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_MADVDONTNEED))
> +		return;
> +
> +	userfaultfd_ctx_get(ctx);
> +	*prev = NULL; /* We wait for ACK w/o the mmap semaphore */
> +	up_read(&vma->vm_mm->mmap_sem);
> +
> +	msg_init(&ewq.msg);
> +
> +	ewq.msg.event = UFFD_EVENT_MADVDONTNEED;
> +	ewq.msg.arg.madv_dn.start = start;
> +	ewq.msg.arg.madv_dn.end = end;
> +
> +	userfaultfd_event_wait_completion(ctx, &ewq);
> +
> +	down_read(&vma->vm_mm->mmap_sem);

After napping with mmap_sem released, is vma still valid?

> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
