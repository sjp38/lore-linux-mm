Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F16C86B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 17:27:22 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so577777619pfw.5
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 14:27:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j5si15550111pgh.413.2017.02.01.14.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 14:27:22 -0800 (PST)
Date: Wed, 1 Feb 2017 14:27:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/5] userfaultfd: non-cooperative: add event for
 exit() notification
Message-Id: <20170201142720.2d3f06ad1ba4410995e5ae0d@linux-foundation.org>
In-Reply-To: <20170201063506.GA7921@rapoport-lnx>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1485542673-24387-4-git-send-email-rppt@linux.vnet.ibm.com>
	<20170131164132.439f9d30e3a9b3c79bcada3a@linux-foundation.org>
	<20170201063506.GA7921@rapoport-lnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 1 Feb 2017 08:35:07 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> On Tue, Jan 31, 2017 at 04:41:32PM -0800, Andrew Morton wrote:
> > On Fri, 27 Jan 2017 20:44:31 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > 
> > > Allow userfaultfd monitor track termination of the processes that have
> > > memory backed by the uffd.
> > > 
> > > --- a/fs/userfaultfd.c
> > > +++ b/fs/userfaultfd.c
> > > @@ -774,6 +774,30 @@ void userfaultfd_unmap_complete(struct mm_struct *mm, struct list_head *uf)
> > >  	}
> > >  }
> > >  
> > > +void userfaultfd_exit(struct mm_struct *mm)
> > > +{
> > > +	struct vm_area_struct *vma = mm->mmap;
> > > +
> > > +	while (vma) {
> > > +		struct userfaultfd_ctx *ctx = vma->vm_userfaultfd_ctx.ctx;
> > > +
> > > +		if (ctx && (ctx->features & UFFD_FEATURE_EVENT_EXIT)) {
> > > +			struct userfaultfd_wait_queue ewq;
> > > +
> > > +			userfaultfd_ctx_get(ctx);
> > > +
> > > +			msg_init(&ewq.msg);
> > > +			ewq.msg.event = UFFD_EVENT_EXIT;
> > > +
> > > +			userfaultfd_event_wait_completion(ctx, &ewq);
> > > +
> > > +			ctx->features &= ~UFFD_FEATURE_EVENT_EXIT;
> > > +		}
> > > +
> > > +		vma = vma->vm_next;
> > > +	}
> > > +}
> > 
> > And we can do the vma walk without locking because the caller (exit_mm)
> > knows it now has exclusive access.  Worth a comment?
>  
> Sure, will add. Do you prefer an incremental patch or update this one?

Either is OK.  I routinely turn replacement patches into deltas so I
and others can see what changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
