Date: Mon, 3 Oct 2005 08:34:08 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH]: Clean up of __alloc_pages
In-Reply-To: <20051001120023.A10250@unix-os.sc.intel.com>
Message-ID: <Pine.LNX.4.62.0510030828400.7812@schroedinger.engr.sgi.com>
References: <20051001120023.A10250@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Oct 2005, Seth, Rohit wrote:

> -				goto zone_reclaim_retry;
> -			}
> +	if (order == 0) {
> +		for (i = 0; (z = zones[i]) != NULL; i++) {
> +			page = buffered_rmqueue(z, 0, gfp_mask, 0);
> +			if (page) 
> +				goto got_pg;
>  		}
> -

This is checking all zones for pages on the pcp before going the more 
expensive route?

Seems that this removes the logic intended to prefer local 
allocations over remote pages present in the existing alloc_pages? There 
is the danger that this modification will lead to the allocation of remote 
pages even if local pages are available. Thus reducing performance.

I would suggest to just check the first zone's pcp instead of all zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
