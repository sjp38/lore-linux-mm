Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 313716B0038
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 19:41:34 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so543536223pfx.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 16:41:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j130si17512068pfc.6.2017.01.31.16.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 16:41:33 -0800 (PST)
Date: Tue, 31 Jan 2017 16:41:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/5] userfaultfd: non-cooperative: add event for
 exit() notification
Message-Id: <20170131164132.439f9d30e3a9b3c79bcada3a@linux-foundation.org>
In-Reply-To: <1485542673-24387-4-git-send-email-rppt@linux.vnet.ibm.com>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1485542673-24387-4-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 27 Jan 2017 20:44:31 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Allow userfaultfd monitor track termination of the processes that have
> memory backed by the uffd.
> 
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -774,6 +774,30 @@ void userfaultfd_unmap_complete(struct mm_struct *mm, struct list_head *uf)
>  	}
>  }
>  
> +void userfaultfd_exit(struct mm_struct *mm)
> +{
> +	struct vm_area_struct *vma = mm->mmap;
> +
> +	while (vma) {
> +		struct userfaultfd_ctx *ctx = vma->vm_userfaultfd_ctx.ctx;
> +
> +		if (ctx && (ctx->features & UFFD_FEATURE_EVENT_EXIT)) {
> +			struct userfaultfd_wait_queue ewq;
> +
> +			userfaultfd_ctx_get(ctx);
> +
> +			msg_init(&ewq.msg);
> +			ewq.msg.event = UFFD_EVENT_EXIT;
> +
> +			userfaultfd_event_wait_completion(ctx, &ewq);
> +
> +			ctx->features &= ~UFFD_FEATURE_EVENT_EXIT;
> +		}
> +
> +		vma = vma->vm_next;
> +	}
> +}

And we can do the vma walk without locking because the caller (exit_mm)
knows it now has exclusive access.  Worth a comment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
