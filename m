Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 917DF6B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 08:55:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so19791605pgf.3
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 05:55:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w72si22322455pfa.220.2017.02.02.05.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 05:54:59 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v12DrWPV123999
	for <linux-mm@kvack.org>; Thu, 2 Feb 2017 08:54:59 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28c1gfj6p1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Feb 2017 08:54:58 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 2 Feb 2017 13:54:55 -0000
Date: Thu, 2 Feb 2017 15:54:48 +0200
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
Message-Id: <20170202135448.GB19804@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello Andrew,

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

I've just used your wording, seems to me neat and to the point.
 
