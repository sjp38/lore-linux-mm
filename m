Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 753886B4F34
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 17:10:55 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id x21-v6so19851235pln.10
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 14:10:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v69si8271510pgb.3.2018.11.28.14.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 14:10:54 -0800 (PST)
Date: Wed, 28 Nov 2018 14:10:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 4/5] mm/hugetlb: Add prot_modify_start/commit
 sequence for hugetlb update
Message-Id: <20181128141051.ff38f23023f652759b06f828@linux-foundation.org>
In-Reply-To: <20181128143438.29458-5-aneesh.kumar@linux.ibm.com>
References: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com>
	<20181128143438.29458-5-aneesh.kumar@linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, 28 Nov 2018 20:04:37 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Some explanation of the motivation would be useful.

>  include/linux/hugetlb.h | 18 ++++++++++++++++++
>  mm/hugetlb.c            |  8 +++++---
>  2 files changed, 23 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 087fd5f48c91..e2a3b0c854eb 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -543,6 +543,24 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
>  	set_huge_pte_at(mm, addr, ptep, pte);
>  }
>  #endif
> +
> +#ifndef huge_ptep_modify_prot_start
> +static inline pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
> +						unsigned long addr, pte_t *ptep)
> +{
> +	return huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
> +}
> +#endif

#define huge_ptep_modify_prot_start huge_ptep_modify_prot_start

> +#ifndef huge_ptep_modify_prot_commit
> +static inline void huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
> +						unsigned long addr, pte_t *ptep,
> +						pte_t old_pte, pte_t pte)
> +{
> +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> +}
> +#endif

#define huge_ptep_modify_prot_commit huge_ptep_modify_prot_commit
