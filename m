Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D77E06B0006
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 16:46:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x18-v6so1292056wmc.7
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 13:46:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f73-v6si299705wme.205.2018.06.29.13.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 13:46:17 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5TKiY52011405
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 16:46:14 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jwt6pm3qk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 16:46:14 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 29 Jun 2018 21:46:12 +0100
Date: Fri, 29 Jun 2018 23:46:05 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH/RFC] mm: do not drop unused pages when userfaultd is
 running
References: <20180628123916.96106-1-borntraeger@de.ibm.com>
 <a2602470-a2b8-adc5-5057-fc8f489ab949@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a2602470-a2b8-adc5-5057-fc8f489ab949@de.ibm.com>
Message-Id: <20180629204604.GF4799@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, kvm@vger.kernel.org, Janosch Frank <frankja@linux.ibm.com>, David Hildenbrand <david@redhat.com>, Cornelia Huck <cohuck@redhat.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Jun 29, 2018 at 08:51:23AM +0200, Christian Borntraeger wrote:
> 
> 
> On 06/28/2018 02:39 PM, Christian Borntraeger wrote:
> > KVM guests on s390 can notify the host of unused pages. This can result
> > in pte_unused callbacks to be true for KVM guest memory.
> > 
> > If a page is unused (checked with pte_unused) we might drop this page
> > instead of paging it. This can have side-effects on userfaultd, when the
> > page in question was already migrated:
> > 
> > The next access of that page will trigger a fault and a user fault
> > instead of faulting in a new and empty zero page. As QEMU does not
> > expect a userfault on an already migrated page this migration will fail.
> > 
> > The most straightforward solution is to ignore the pte_unused hint if a
> > userfault context is active for this VMA.
> > 
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> > ---
> >  mm/rmap.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 6db729dc4c50..3f3a72aa99f2 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1481,7 +1481,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  				set_pte_at(mm, address, pvmw.pte, pteval);
> >  			}
> >  
> > -		} else if (pte_unused(pteval)) {
> > +		} else if (pte_unused(pteval) && !vma->vm_userfaultfd_ctx.ctx) {
> 
> FWIW, this needs a fix for !CONFIG_USERFAULTFD.

There's userfaultfd_armed() in include/linux/userfaultfd_k.h. Just
s/!vma->vm_userfaultfd_ctx.ctx/!userfaultfd_armed(vma)

> Still: more opinions on the patch itself? 

If the only use case for pte_unused() hint is guest notification for host,
the patch seems Ok to me.

> >  			/*
> >  			 * The guest indicated that the page content is of no
> >  			 * interest anymore. Simply discard the pte, vmscan
> > 
> 

-- 
Sincerely yours,
Mike.
