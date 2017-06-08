Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 041956B0365
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 00:41:53 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 67so9238623itx.11
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 21:41:52 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w204si4064424iow.197.2017.06.07.21.41.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 21:41:52 -0700 (PDT)
Subject: Re: [patch -mm] mm, hugetlb: schedule when potentially allocating
 many hugepages
References: <alpine.DEB.2.10.1706072102560.29060@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <52ee0233-c3cd-d33a-a33b-50d49e050d5c@oracle.com>
Date: Wed, 7 Jun 2017 21:31:57 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1706072102560.29060@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/07/2017 09:03 PM, David Rientjes wrote:
> A few hugetlb allocators loop while calling the page allocator and can
> potentially prevent rescheduling if the page allocator slowpath is not
> utilized.
> 
> Conditionally schedule when large numbers of hugepages can be allocated.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Based on -mm only to prevent merge conflicts with
>  "mm/hugetlb.c: warn the user when issues arise on boot due to hugepages"
> 
>  mm/hugetlb.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1754,6 +1754,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
>  			break;
>  		}
>  		list_add(&page->lru, &surplus_list);
> +		cond_resched();
>  	}
>  	allocated += i;
>  
> @@ -2222,6 +2223,7 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
>  		} else if (!alloc_fresh_huge_page(h,
>  					 &node_states[N_MEMORY]))
>  			break;
> +		cond_resched();
>  	}
>  	if (i < h->max_huge_pages) {
>  		char buf[32];
> @@ -2364,6 +2366,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
>  		else
>  			ret = alloc_fresh_huge_page(h, nodes_allowed);
> +		cond_resched();

Are not the following lines immediately before the above huge page allocation
in set_max_huge_pages, or am I looking at an incorrect version of the file?

		/* yield cpu to avoid soft lockup */
		cond_resched();

-- 
Mike Kravetz

>  		spin_lock(&hugetlb_lock);
>  		if (!ret)
>  			goto out;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
