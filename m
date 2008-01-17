Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m0HAJcjY032363
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 21:19:38 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0HAJkuE2818290
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 21:19:46 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0HAJka2017723
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 21:19:46 +1100
Date: Thu, 17 Jan 2008 15:49:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] shared page table for hugetlbpage memory causing leak.
Message-ID: <20080117101946.GJ11384@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <478E3DFA.9050900@redhat.com> <1200509668.3296.204.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1200509668.3296.204.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Adam Litke <agl@us.ibm.com> [2008-01-16 12:54:28]:

> Since we know we are dealing with a hugetlb VMA, how about the
> following, simpler, _untested_ patch:
> 
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6f97821..75b0e4f 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -644,6 +644,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  		dst_pte = huge_pte_alloc(dst, addr);
>  		if (!dst_pte)
>  			goto nomem;
> +
> +		/* If page table is shared do not copy or take references */
> +		if (src_pte == dst_pte)
> +			continue;
> +

Shouldn't you be checking the PTE contents rather than the pointers?
Shouldn't the check be

                if (unlikely(pte_same(*src_pte, *dst_pte))
                        continue;


>  		spin_lock(&dst->page_table_lock);
>  		spin_lock(&src->page_table_lock);
>  		if (!pte_none(*src_pte)) {
> 

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
