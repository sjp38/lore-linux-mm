Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD756B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:19:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so6365452wme.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:19:24 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id b7si11538949wjj.94.2016.04.28.08.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:19:23 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id a17so71183653wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:19:23 -0700 (PDT)
Date: Thu, 28 Apr 2016 17:19:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160428151921.GL31489@dhcp22.suse.cz>
References: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Wed 27-04-16 14:17:20, Andrew Morton wrote:
[...]
> @@ -2484,7 +2485,14 @@ static void collapse_huge_page(struct mm
>  		goto out;
>  	}
>  
> -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> +	swap = get_mm_counter(mm, MM_SWAPENTS);
> +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> +	/*
> +	 * When system under pressure, don't swapin readahead.
> +	 * So that avoid unnecessary resource consuming.
> +	 */
> +	if (allocstall == curr_allocstall && swap != 0)
> +		__collapse_huge_page_swapin(mm, vma, address, pmd);
>  
>  	anon_vma_lock_write(vma->anon_vma);
>  

I have mentioned that before already but this seems like a rather weak
heuristic. Don't we really rather teach __collapse_huge_page_swapin
(resp. do_swap_page) do to an optimistic GFP_NOWAIT allocations and
back off under the memory pressure?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
