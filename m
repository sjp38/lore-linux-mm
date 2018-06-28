Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4A686B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 09:18:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i7-v6so5522552qtp.4
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 06:18:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f36-v6si4458255qtf.100.2018.06.28.06.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 06:18:49 -0700 (PDT)
Subject: Re: [PATCH/RFC] mm: do not drop unused pages when userfaultd is
 running
References: <20180628123916.96106-1-borntraeger@de.ibm.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <df95ae10-0c78-0d76-d2bb-c91712c145ea@redhat.com>
Date: Thu, 28 Jun 2018 15:18:47 +0200
MIME-Version: 1.0
In-Reply-To: <20180628123916.96106-1-borntraeger@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-s390@vger.kernel.org
Cc: kvm@vger.kernel.org, Janosch Frank <frankja@linux.ibm.com>, Cornelia Huck <cohuck@redhat.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On 28.06.2018 14:39, Christian Borntraeger wrote:
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
>  			/*
>  			 * The guest indicated that the page content is of no
>  			 * interest anymore. Simply discard the pte, vmscan
> 

To understand the implications better:

This is like a MADV_DONTNEED from user space while a userfaultfd
notifier is registered for this vma range.

While we can block such calls in QEMU ("we registered it, we know it
best"), we can't do the same in the kernel.

These "intern MADV_DONTNEED" can actually trigger "deferred", so e.g. if
the pte_unused() was set before userfaultfd has been registered, we can
still get the same result, right?

-- 

Thanks,

David / dhildenb
