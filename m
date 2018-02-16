Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBA56B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:59:43 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id k82so2175815wmd.1
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:59:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si12899280wrc.412.2018.02.16.05.59.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Feb 2018 05:59:42 -0800 (PST)
Date: Fri, 16 Feb 2018 14:59:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't defer struct page initialization for Xen pv
 guests
Message-ID: <20180216135940.GQ7275@dhcp22.suse.cz>
References: <20180216133726.30813-1-jgross@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180216133726.30813-1-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, akpm@linux-foundation.org, stable@vger.kernel.org, Pavel Tatashin <pasha.tatashin@oracle.com>

[CC Pavel]

On Fri 16-02-18 14:37:26, Juergen Gross wrote:
> Commit f7f99100d8d95dbcf09e0216a143211e79418b9f ("mm: stop zeroing
> memory during allocation in vmemmap") broke Xen pv domains in some
> configurations, as the "Pinned" information in struct page of early
> page tables could get lost.

Could you be more specific please?

> Avoid this problem by not deferring struct page initialization when
> running as Xen pv guest.
> 
> Cc: <stable@vger.kernel.org> #4.15
Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")

please

> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 81e18ceef579..681d504b9a40 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -347,6 +347,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  	/* Always populate low zones for address-constrained allocations */
>  	if (zone_end < pgdat_end_pfn(pgdat))
>  		return true;
> +	/* Xen PV domains need page structures early */
> +	if (xen_pv_domain())
> +		return true;
>  	(*nr_initialised)++;
>  	if ((*nr_initialised > pgdat->static_init_pgcnt) &&
>  	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
> -- 
> 2.13.6

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
