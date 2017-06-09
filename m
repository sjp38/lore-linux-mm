Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D85436B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 18:46:41 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k26so23274213iti.5
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 15:46:41 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y64si2366025ioy.15.2017.06.09.15.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 15:46:41 -0700 (PDT)
Subject: Re: [patch v2 -mm] mm, hugetlb: schedule when potentially allocating
 many hugepages
References: <alpine.DEB.2.10.1706072102560.29060@chino.kir.corp.google.com>
 <52ee0233-c3cd-d33a-a33b-50d49e050d5c@oracle.com>
 <alpine.DEB.2.10.1706091534580.66176@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1706091535300.66176@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f8117b6d-b122-2a8a-eece-3c3fe44a0b13@oracle.com>
Date: Fri, 9 Jun 2017 15:43:36 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1706091535300.66176@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/09/2017 03:36 PM, David Rientjes wrote:
> A few hugetlb allocators loop while calling the page allocator and can
> potentially prevent rescheduling if the page allocator slowpath is not
> utilized.
> 
> Conditionally schedule when large numbers of hugepages can be allocated.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Thanks for doing this.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> ---
>  Based on -mm only to prevent merge conflicts with
>  "mm/hugetlb.c: warn the user when issues arise on boot due to hugepages"
> 
>  v2: removed redundant cond_resched() per Mike
> 
>  mm/hugetlb.c | 2 ++
>  1 file changed, 2 insertions(+)
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
