Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF9966B02DA
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 13:25:19 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hc3so17406993pac.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 10:25:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b68si7628801pfg.70.2016.11.03.10.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 10:25:19 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA3HO1ap133364
	for <linux-mm@kvack.org>; Thu, 3 Nov 2016 13:25:18 -0400
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26g66jdbey-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 03 Nov 2016 13:25:18 -0400
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 3 Nov 2016 17:25:16 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id F00BE17D8042
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:27:32 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA3HPE6E22741194
	for <linux-mm@kvack.org>; Thu, 3 Nov 2016 17:25:14 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA3HPEkQ026299
	for <linux-mm@kvack.org>; Thu, 3 Nov 2016 11:25:14 -0600
Date: Thu, 3 Nov 2016 11:24:46 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 12/33] userfaultfd: non-cooperative: Add madvise() event
 for MADV_DONTNEED request
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-13-git-send-email-aarcange@redhat.com>
 <072b01d235a8$7238d230$56aa7690$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <072b01d235a8$7238d230$56aa7690$@alibaba-inc.com>
Message-Id: <20161103172441.GA14111@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Shaohua Li <shli@fb.com>, Pavel Emelyanov <xemul@virtuozzo.com>

(changed 'CC:
- Michael Rapoport <RAPOPORT@il.ibm.com>,
- Dr. David Alan Gilbert@v2.random,  <dgilbert@redhat.com>,
+ Dr. David Alan Gilbert  <dgilbert@redhat.com>,
- Pavel Emelyanov <xemul@parallels.com>@v2.random
+ Pavel Emelyanov <xemul@virtuozzo.com>
)

On Thu, Nov 03, 2016 at 04:01:12PM +0800, Hillf Danton wrote:
> On Thursday, November 03, 2016 3:34 AM Andrea Arcangeli wrote:
> > +void madvise_userfault_dontneed(struct vm_area_struct *vma,
> > +				struct vm_area_struct **prev,
> > +				unsigned long start, unsigned long end)
> > +{
> > +	struct userfaultfd_ctx *ctx;
> > +	struct userfaultfd_wait_queue ewq;
> > +
> > +	ctx = vma->vm_userfaultfd_ctx.ctx;
> > +	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_MADVDONTNEED))
> > +		return;
> > +
> > +	userfaultfd_ctx_get(ctx);
> > +	*prev = NULL; /* We wait for ACK w/o the mmap semaphore */
> > +	up_read(&vma->vm_mm->mmap_sem);
> > +
> > +	msg_init(&ewq.msg);
> > +
> > +	ewq.msg.event = UFFD_EVENT_MADVDONTNEED;
> > +	ewq.msg.arg.madv_dn.start = start;
> > +	ewq.msg.arg.madv_dn.end = end;
> > +
> > +	userfaultfd_event_wait_completion(ctx, &ewq);
> > +
> > +	down_read(&vma->vm_mm->mmap_sem);
> 
> After napping with mmap_sem released, is vma still valid?

You are right, vma may be invalid at that point. Thanks for spotting.

Andrea, how do you prefer the fix, incremental or the entire patch updated?

> > +}
> > +

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
