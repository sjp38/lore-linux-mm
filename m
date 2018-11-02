Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4556C6B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 08:33:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u6-v6so1103424eds.10
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 05:33:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j15-v6si1328280eds.376.2018.11.02.05.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 05:33:46 -0700 (PDT)
Date: Fri, 2 Nov 2018 13:32:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hotplug: Optimize clear_hwpoisoned_pages
Message-ID: <20181102120856.GC28039@dhcp22.suse.cz>
References: <20181102120001.4526-1-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102120001.4526-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 02-11-18 23:00:01, Balbir Singh wrote:
> In hot remove, we try to clear poisoned pages, but
> a small optimization to check if num_poisoned_pages
> is 0 helps remove the iteration through nr_pages.
> 
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>

Makes sense to me. It would be great to actually have some number but
the optimization for the normal case is quite obvious.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/sparse.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 33307fc05c4d..16219c7ddb5f 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -724,6 +724,16 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	if (!memmap)
>  		return;
>  
> +	/*
> +	 * A further optimization is to have per section
> +	 * ref counted num_poisoned_pages, but that is going
> +	 * to need more space per memmap, for now just do
> +	 * a quick global check, this should speed up this
> +	 * routine in the absence of bad pages.
> +	 */
> +	if (atomic_long_read(&num_poisoned_pages) == 0)
> +		return;
> +
>  	for (i = 0; i < nr_pages; i++) {
>  		if (PageHWPoison(&memmap[i])) {
>  			atomic_long_sub(1, &num_poisoned_pages);
> -- 
> 2.17.1
> 

-- 
Michal Hocko
SUSE Labs
