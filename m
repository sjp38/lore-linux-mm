Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A20F16B0253
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 05:25:23 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id t20so13658739wju.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 02:25:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si9805720wme.149.2017.01.09.02.25.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 02:25:22 -0800 (PST)
Date: Mon, 9 Jan 2017 11:25:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: hugetlb: reservation race leading to under provisioning
Message-ID: <20170109102520.GG7495@dhcp22.suse.cz>
References: <20170105151540.GT21618@dhcp22.suse.cz>
 <a46ad76e-2d73-1138-b871-fc110cc9d596@oracle.com>
 <20170106085808.GE5556@dhcp22.suse.cz>
 <alpine.LNX.2.00.1701061128390.9628@rueplumet.us.cray.com>
 <f6f7338c-2afe-885b-4c72-44b7daba07d8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6f7338c-2afe-885b-4c72-44b7daba07d8@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Paul Cassella <cassella@cray.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Sun 08-01-17 11:08:30, Mike Kravetz wrote:
[...]
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3edb759..221abdc 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1783,12 +1783,9 @@ static void return_unused_surplus_pages(struct hstate *h,
>  {
>  	unsigned long nr_pages;
>  
> -	/* Uncommit the reservation */
> -	h->resv_huge_pages -= unused_resv_pages;
> -
>  	/* Cannot return gigantic pages currently */
>  	if (hstate_is_gigantic(h))
> -		return;
> +		goto out;
>  
>  	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
>  
> @@ -1801,10 +1798,16 @@ static void return_unused_surplus_pages(struct hstate *h,
>  	 * on-line nodes with memory and will handle the hstate accounting.
>  	 */
>  	while (nr_pages--) {
> +		h->resv_huge_pages--;
> +		unused_resv_pages--;
>  		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
> -			break;
> +			goto out;
>  		cond_resched_lock(&hugetlb_lock);
>  	}
> +
> +out:
> +	/* Fully uncommit the reservation */
> +	h->resv_huge_pages -= unused_resv_pages;
>  }

OK, this would handle the case I was wondering about. It really deserves
a big fat comment explaining when this can happen.

Other than that this looks OK and safe enough for the stable after
second look into the code.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
