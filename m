Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 51EF76B0002
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:00:52 -0400 (EDT)
Date: Wed, 3 Apr 2013 16:00:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, x86: Do not zero hugetlbfs pages at boot. -v2
Message-ID: <20130403140049.GI16471@dhcp22.suse.cz>
References: <E1UDME8-00041J-B4@eag09.americas.sgi.com>
 <20130314085138.GA11636@dhcp22.suse.cz>
 <20130403024344.GA4384@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130403024344.GA4384@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, wli@holomorphy.com

On Tue 02-04-13 21:43:44, Robin Holt wrote:
[...]
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 2b0bcb0..b2e4027 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -705,12 +705,16 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
>  
>  void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
>  				unsigned long size, unsigned long align,
> -				unsigned long goal, unsigned long limit)
> +				unsigned long goal, unsigned long limit,
> +				int zeroed)
>  {
>  	void *ptr;
>  
>  	if (WARN_ON_ONCE(slab_is_available()))
> -		return kzalloc(size, GFP_NOWAIT);
> +		if (zeroed)
> +			return kzalloc(size, GFP_NOWAIT);
> +		else
> +			return kmalloc(size, GFP_NOWAIT);
>  again:
>  
>  	/* do not panic in alloc_bootmem_bdata() */

You need to update alloc_bootmem_bdata and alloc_bootmem_core as well.
Otherwise this is a no-op for early allocations when slab is not
available which is the case unless something is broken.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
