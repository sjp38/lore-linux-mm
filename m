Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id CAAB3280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 05:28:16 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id pv20so4091310lab.11
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 02:28:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wh3si15702630lbb.118.2014.10.31.02.28.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 02:28:14 -0700 (PDT)
Date: Fri, 31 Oct 2014 10:28:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC patch] mm: hugetlb: fix __unmap_hugepage_range
Message-ID: <20141031092812.GB16840@dhcp22.suse.cz>
References: <028701cff4c2$3e9e2ca0$bbda85e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <028701cff4c2$3e9e2ca0$bbda85e0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

[CCing people involved in 24669e58477e2]

On Fri 31-10-14 12:22:12, Hillf Danton wrote:
> First, after flushing TLB, we have no need to scan pte from start again.
> Second, before bail out loop, the address is forwarded one step.

I can imagine a more comprehensive wording here. It is not immediately
clear whether this is just an optimization or a bug fix as well
(especially the second part).

Anyway the optimization looks good to me.

> Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
> --- a/mm/hugetlb.c	Fri Oct 31 11:47:25 2014
> +++ b/mm/hugetlb.c	Fri Oct 31 11:52:42 2014
> @@ -2641,8 +2641,9 @@ void __unmap_hugepage_range(struct mmu_g
>  
>  	tlb_start_vma(tlb, vma);
>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> +	address = start;
>  again:
> -	for (address = start; address < end; address += sz) {
> +	for (; address < end; address += sz) {
>  		ptep = huge_pte_offset(mm, address);
>  		if (!ptep)
>  			continue;
> @@ -2689,6 +2690,7 @@ again:
>  		page_remove_rmap(page);
>  		force_flush = !__tlb_remove_page(tlb, page);
>  		if (force_flush) {
> +			address += sz;
>  			spin_unlock(ptl);
>  			break;
>  		}
> --
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
