Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0762F6B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 07:40:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so246193wrc.5
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 04:40:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b62si7290354wme.222.2017.08.07.04.40.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 04:40:45 -0700 (PDT)
Date: Mon, 7 Aug 2017 13:40:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmalloc: reduce half comparison during
 pcpu_get_vm_areas()
Message-ID: <20170807114043.GG32434@dhcp22.suse.cz>
References: <20170803063822.48702-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803063822.48702-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

[CC Tejun]

On Thu 03-08-17 14:38:22, Wei Yang wrote:
> In pcpu_get_vm_areas(), it checks each range is not overlapped. To make
> sure it is, only (N^2)/2 comparison is necessary, while current code does
> N^2 times. By starting from the next range, it achieves the goal and the
> continue could be removed.
> 
> At the mean time, other two work in this patch:
> *  the overlap check of two ranges could be done with one clause
> *  one typo in comment is fixed.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/vmalloc.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 8087451cb332..f33c8350fd83 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2457,7 +2457,7 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
>   * matching slot.  While scanning, if any of the areas overlaps with
>   * existing vmap_area, the base address is pulled down to fit the
>   * area.  Scanning is repeated till all the areas fit and then all
> - * necessary data structres are inserted and the result is returned.
> + * necessary data structures are inserted and the result is returned.
>   */
>  struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
>  				     const size_t *sizes, int nr_vms,
> @@ -2485,15 +2485,11 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
>  		if (start > offsets[last_area])
>  			last_area = area;
>  
> -		for (area2 = 0; area2 < nr_vms; area2++) {
> +		for (area2 = area + 1; area2 < nr_vms; area2++) {
>  			unsigned long start2 = offsets[area2];
>  			unsigned long end2 = start2 + sizes[area2];
>  
> -			if (area2 == area)
> -				continue;
> -
> -			BUG_ON(start2 >= start && start2 < end);
> -			BUG_ON(end2 <= end && end2 > start);
> +			BUG_ON(start2 < end && start < end2);
>  		}
>  	}
>  	last_end = offsets[last_area] + sizes[last_area];
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
