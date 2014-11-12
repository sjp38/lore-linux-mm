Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D5B9E6B00E6
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 14:35:00 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so15025805wgh.39
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 11:35:00 -0800 (PST)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id p8si28997061wia.96.2014.11.12.11.34.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 11:34:59 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id h11so5995001wiw.15
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 11:34:59 -0800 (PST)
Date: Wed, 12 Nov 2014 20:34:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm: page_isolation: check pfn validity before access
Message-ID: <20141112193450.GA18936@dhcp22.suse.cz>
References: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, mina86@mina86.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

On Thu 06-11-14 16:08:02, Weijie Yang wrote:
> In the undo path of start_isolate_page_range(), we need to check
> the pfn validity before access its page, or it will trigger an
> addressing exception if there is hole in the zone.

This looks a bit fishy to me. I am not familiar with the code much but
at least __offline_pages zone = page_zone(pfn_to_page(start_pfn)) so it
would blow up before we got here. Same applies to the other caller
alloc_contig_range. So either both need a fix and then
start_isolate_page_range doesn't need more checks or this is all
unnecessary.

Please do not make this code more obfuscated than it is already...

> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>  mm/page_isolation.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index d1473b2..3ddc8b3 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -137,8 +137,11 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  undo:
>  	for (pfn = start_pfn;
>  	     pfn < undo_pfn;
> -	     pfn += pageblock_nr_pages)
> -		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
> +	     pfn += pageblock_nr_pages) {
> +		page = __first_valid_page(pfn, pageblock_nr_pages);
> +		if (page)
> +			unset_migratetype_isolate(page, migratetype);
> +	}
>  
>  	return -EBUSY;
>  }
> -- 
> 1.7.0.4
> 
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
