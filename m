Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3676B0345
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 11:42:24 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hr10so40257875pac.2
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:42:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 8si17171363pgc.318.2016.11.04.08.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 08:42:23 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA4FdM5b077393
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 11:42:23 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26gsftrsmx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 04 Nov 2016 11:42:23 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 4 Nov 2016 15:42:20 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 64CA3219005F
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 15:41:32 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA4FgHpI39714998
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 15:42:17 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA4FgGB0002485
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 09:42:17 -0600
Date: Fri, 4 Nov 2016 09:42:02 -0600
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
Message-Id: <20161104154159.GC5605@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'Michael Rapoport' <RAPOPORT@il.ibm.com>, Dr.David.Alan.Gilbert@v2.random, dgilbert@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Shaohua Li <shli@fb.com>, Pavel Emelyanov <xemul@parallels.com>, ""@v2.random

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
> 
> > +}
> > +

Below is the updated patch that accesses mmap_sem via local reference to
mm_struct rather than via vma.
