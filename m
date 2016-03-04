Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 411BC6B0253
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 03:48:50 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so10673644wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 00:48:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j187si2850114wma.69.2016.03.04.00.48.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 00:48:49 -0800 (PST)
Subject: Re: [PATCH RFC 1/2] mm: meminit: initialise more memory for
 inode/dentry hash tables in early boot
References: <1456988501-29046-1-git-send-email-zhlcindy@gmail.com>
 <1456988501-29046-2-git-send-email-zhlcindy@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D94BEE.1080506@suse.cz>
Date: Fri, 4 Mar 2016 09:48:46 +0100
MIME-Version: 1.0
In-Reply-To: <1456988501-29046-2-git-send-email-zhlcindy@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhang <zhlcindy@gmail.com>, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, mgorman@techsingularity.net
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On 03/03/2016 08:01 AM, Li Zhang wrote:
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -293,13 +293,20 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  				unsigned long pfn, unsigned long zone_end,
>  				unsigned long *nr_initialised)
>  {
> +	unsigned long max_initialise;
> +
>  	/* Always populate low zones for address-contrained allocations */
>  	if (zone_end < pgdat_end_pfn(pgdat))
>  		return true;
> +	/*
> +	* Initialise at least 2G of a node but also take into account that
> +	* two large system hashes that can take up 1GB for 0.25TB/node.
> +	*/

The indentation is wrong here.

> +	max_initialise = max(2UL << (30 - PAGE_SHIFT),
> +		(pgdat->node_spanned_pages >> 8));
>  
> -	/* Initialise at least 2G of the highest zone */
>  	(*nr_initialised)++;
> -	if (*nr_initialised > (2UL << (30 - PAGE_SHIFT)) &&
> +	if ((*nr_initialised > max_initialise) &&
>  	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
>  		pgdat->first_deferred_pfn = pfn;
>  		return false;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
