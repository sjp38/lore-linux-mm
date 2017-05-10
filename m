Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97A1A2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 09:09:40 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l9so8851768wre.12
        for <linux-mm@kvack.org>; Wed, 10 May 2017 06:09:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si3015243wra.196.2017.05.10.06.09.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 06:09:39 -0700 (PDT)
Subject: Re: [PATCH] mm/khugepaged: Add missed tracepoint for
 collapse_huge_page_swapin
References: <20170507101813.30187-1-sj38.park@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b478e564-fa10-79de-f9df-5b55b211e85d@suse.cz>
Date: Wed, 10 May 2017 15:09:37 +0200
MIME-Version: 1.0
In-Reply-To: <20170507101813.30187-1-sj38.park@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/07/2017 12:18 PM, SeongJae Park wrote:
> One return case of `__collapse_huge_page_swapin()` does not invoke
> tracepoint while every other return case does.  This commit adds a
> tracepoint invocation for the case.
> 
> Signed-off-by: SeongJae Park <sj38.park@gmail.com>

Right. But extra points by turning all of the "trace+return false"
instances into some kind of "goto out".

> ---
>  mm/khugepaged.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index ba40b7f673f4..9aad377c67a8 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -909,8 +909,10 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
>  				return false;
>  			}
>  			/* check if the pmd is still valid */
> -			if (mm_find_pmd(mm, address) != pmd)
> +			if (mm_find_pmd(mm, address) != pmd) {
> +				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
>  				return false;
> +			}
>  		}
>  		if (ret & VM_FAULT_ERROR) {
>  			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
