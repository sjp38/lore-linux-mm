Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62B176B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:00:24 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k8-v6so4253582qtj.18
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:00:24 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f16-v6si1809933qvo.117.2018.06.26.10.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 10:00:21 -0700 (PDT)
Subject: Re: [PATCH] userfaultfd: hugetlbfs: Fix userfaultfd_huge_must_wait
 pte access
References: <20180626132421.78084-1-frankja@linux.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c9c5c76c-23e5-671f-1fdc-8326e42917b9@oracle.com>
Date: Tue, 26 Jun 2018 10:00:15 -0700
MIME-Version: 1.0
In-Reply-To: <20180626132421.78084-1-frankja@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janosch Frank <frankja@linux.ibm.com>, aarcange@redhat.com
Cc: linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 06/26/2018 06:24 AM, Janosch Frank wrote:
> Use huge_ptep_get to translate huge ptes to normal ptes so we can
> check them with the huge_pte_* functions. Otherwise some architectures
> will check the wrong values and will not wait for userspace to bring
> in the memory.
> 
> Signed-off-by: Janosch Frank <frankja@linux.ibm.com>
> Fixes: 369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges")

Adding linux-mm and Andrew on Cc:

Thanks for catching and fixing this.
I think this needs to be fixed in stable as well.  Correct?  Assuming
userfaultfd is/can be enabled for impacted architectures.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  fs/userfaultfd.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 123bf7d516fc..594d192b2331 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -222,24 +222,26 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
>  					 unsigned long reason)
>  {
>  	struct mm_struct *mm = ctx->mm;
> -	pte_t *pte;
> +	pte_t *ptep, pte;
>  	bool ret = true;
>  
>  	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
>  
> -	pte = huge_pte_offset(mm, address, vma_mmu_pagesize(vma));
> -	if (!pte)
> +	ptep = huge_pte_offset(mm, address, vma_mmu_pagesize(vma));
> +
> +	if (!ptep)
>  		goto out;
>  
>  	ret = false;
> +	pte = huge_ptep_get(ptep);
>  
>  	/*
>  	 * Lockless access: we're in a wait_event so it's ok if it
>  	 * changes under us.
>  	 */
> -	if (huge_pte_none(*pte))
> +	if (huge_pte_none(pte))
>  		ret = true;
> -	if (!huge_pte_write(*pte) && (reason & VM_UFFD_WP))
> +	if (!huge_pte_write(pte) && (reason & VM_UFFD_WP))
>  		ret = true;
>  out:
>  	return ret;
> 
