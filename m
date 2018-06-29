Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1F76B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 02:51:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id s15-v6so4111741wrn.16
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 23:51:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j125-v6si680705wmb.201.2018.06.28.23.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 23:51:33 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5T6n5Xr126630
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 02:51:31 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jwe65c5be-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 02:51:31 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 29 Jun 2018 07:51:29 +0100
Subject: Re: [PATCH/RFC] mm: do not drop unused pages when userfaultd is
 running
References: <20180628123916.96106-1-borntraeger@de.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Fri, 29 Jun 2018 08:51:23 +0200
MIME-Version: 1.0
In-Reply-To: <20180628123916.96106-1-borntraeger@de.ibm.com>
Content-Language: en-US
Message-Id: <a2602470-a2b8-adc5-5057-fc8f489ab949@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-s390@vger.kernel.org
Cc: kvm@vger.kernel.org, Janosch Frank <frankja@linux.ibm.com>, David Hildenbrand <david@redhat.com>, Cornelia Huck <cohuck@redhat.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>



On 06/28/2018 02:39 PM, Christian Borntraeger wrote:
> KVM guests on s390 can notify the host of unused pages. This can result
> in pte_unused callbacks to be true for KVM guest memory.
> 
> If a page is unused (checked with pte_unused) we might drop this page
> instead of paging it. This can have side-effects on userfaultd, when the
> page in question was already migrated:
> 
> The next access of that page will trigger a fault and a user fault
> instead of faulting in a new and empty zero page. As QEMU does not
> expect a userfault on an already migrated page this migration will fail.
> 
> The most straightforward solution is to ignore the pte_unused hint if a
> userfault context is active for this VMA.
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> ---
>  mm/rmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 6db729dc4c50..3f3a72aa99f2 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1481,7 +1481,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				set_pte_at(mm, address, pvmw.pte, pteval);
>  			}
>  
> -		} else if (pte_unused(pteval)) {
> +		} else if (pte_unused(pteval) && !vma->vm_userfaultfd_ctx.ctx) {

FWIW, this needs a fix for !CONFIG_USERFAULTFD.
Still: more opinions on the patch itself?

>  			/*
>  			 * The guest indicated that the page content is of no
>  			 * interest anymore. Simply discard the pte, vmscan
> 
