Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2856B02A5
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 10:22:00 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o2so48328970wje.5
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 07:22:00 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id y9si18839215wjg.132.2016.12.19.07.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 07:21:59 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g23so19251863wme.1
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 07:21:58 -0800 (PST)
Date: Mon, 19 Dec 2016 16:21:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161219152156.GC5175@dhcp22.suse.cz>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 18-12-16 14:47:50, Wei Yang wrote:
> memblock_reserve() may fail in case there is not enough regions.

Have you seen this happenning in the real setups or this is a by-review
driven change?
[...]
>  again:
>  	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
>  					    nid, flags);
> -	if (alloc)
> +	if (alloc && !memblock_reserve(alloc, size))
>  		goto done;
>  
>  	if (nid != NUMA_NO_NODE) {
>  		alloc = memblock_find_in_range_node(size, align, min_addr,
>  						    max_addr, NUMA_NO_NODE,
>  						    flags);
> -		if (alloc)
> +		if (alloc && !memblock_reserve(alloc, size))
>  			goto done;
>  	}

This doesn't look right. You can end up leaking the first allocated
range.

>  
> @@ -1303,7 +1302,6 @@ static void * __init memblock_virt_alloc_internal(
>  
>  	return NULL;
>  done:
> -	memblock_reserve(alloc, size);
>  	ptr = phys_to_virt(alloc);
>  	memset(ptr, 0, size);


>  
> -- 
> 2.5.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
