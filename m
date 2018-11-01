Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47AF96B0010
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 13:09:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 134-v6so14877762pga.1
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 10:09:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14-v6si9912745pga.422.2018.11.01.10.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 10:09:53 -0700 (PDT)
Date: Thu, 1 Nov 2018 18:09:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm/page_owner: clamp read count to PAGE_SIZE
Message-ID: <20181101170948.GN23921@dhcp22.suse.cz>
References: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miles.chen@mediatek.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Fri 02-11-18 01:00:07, miles.chen@mediatek.com wrote:
> From: Miles Chen <miles.chen@mediatek.com>
> 
> The page owner read might allocate a large size of memory with
> a large read count. Allocation fails can easily occur when doing
> high order allocations.
> 
> Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation
> and avoid allocation fails due to high order allocation.

It is good to mention that interface is root only so the harm due to
unbounded allocation request is somehow reduced.

I believe we want to use seq_file infrastructure in the long term
solution.
 
> Change since v3:
>   - remove the change in kvmalloc
>   - keep kmalloc in page_owner.c
> 
> Change since v2:
>   - improve kvmalloc, allow sub page allocations fallback to
>     vmalloc when CONFIG_HIGHMEM=y
> 
> Change since v1:
>   - use kvmalloc()
>   - clamp buffer size to PAGE_SIZE
> 
> Signed-off-by: Miles Chen <miles.chen@mediatek.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/page_owner.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 87bc0dfdb52b..b83f295e4eca 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -351,6 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  		.skip = 0
>  	};
>  
> +	count = count > PAGE_SIZE ? PAGE_SIZE : count;
>  	kbuf = kmalloc(count, GFP_KERNEL);
>  	if (!kbuf)
>  		return -ENOMEM;
> -- 
> 2.18.0
> 

-- 
Michal Hocko
SUSE Labs
