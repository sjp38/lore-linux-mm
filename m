Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 010D76B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 01:35:19 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so476706081pgb.0
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 22:35:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o6si18256325pfi.109.2017.01.31.22.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 22:35:18 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116YNxW069432
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 01:35:17 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28b8wuts5u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:35:16 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 1 Feb 2017 06:35:13 -0000
Date: Wed, 1 Feb 2017 08:35:07 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/5] userfaultfd: non-cooperative: add event for
 exit() notification
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1485542673-24387-4-git-send-email-rppt@linux.vnet.ibm.com>
 <20170131164132.439f9d30e3a9b3c79bcada3a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170131164132.439f9d30e3a9b3c79bcada3a@linux-foundation.org>
Message-Id: <20170201063506.GA7921@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 31, 2017 at 04:41:32PM -0800, Andrew Morton wrote:
> On Fri, 27 Jan 2017 20:44:31 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > Allow userfaultfd monitor track termination of the processes that have
> > memory backed by the uffd.
> > 
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -774,6 +774,30 @@ void userfaultfd_unmap_complete(struct mm_struct *mm, struct list_head *uf)
> >  	}
> >  }
> >  
> > +void userfaultfd_exit(struct mm_struct *mm)
> > +{
> > +	struct vm_area_struct *vma = mm->mmap;
> > +
> > +	while (vma) {
> > +		struct userfaultfd_ctx *ctx = vma->vm_userfaultfd_ctx.ctx;
> > +
> > +		if (ctx && (ctx->features & UFFD_FEATURE_EVENT_EXIT)) {
> > +			struct userfaultfd_wait_queue ewq;
> > +
> > +			userfaultfd_ctx_get(ctx);
> > +
> > +			msg_init(&ewq.msg);
> > +			ewq.msg.event = UFFD_EVENT_EXIT;
> > +
> > +			userfaultfd_event_wait_completion(ctx, &ewq);
> > +
> > +			ctx->features &= ~UFFD_FEATURE_EVENT_EXIT;
> > +		}
> > +
> > +		vma = vma->vm_next;
> > +	}
> > +}
> 
> And we can do the vma walk without locking because the caller (exit_mm)
> knows it now has exclusive access.  Worth a comment?
 
Sure, will add. Do you prefer an incremental patch or update this one?

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
