Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 5F1F36B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 08:32:54 -0500 (EST)
Date: Thu, 5 Jan 2012 13:32:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscam: check page order in isolating lru pages
Message-ID: <20120105133248.GH28031@suse.de>
References: <CAJd=RBBJG+hLLc3mR-WzByU1gZEcdFUAoZzyir+1A4a0tVnSmg@mail.gmail.com>
 <4EFCA4F9.7070703@gmail.com>
 <CAJd=RBCuh=zDLZ7J9sV_p_ghoXP-VX6PEAx01t8p_pziTimxnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBCuh=zDLZ7J9sV_p_ghoXP-VX6PEAx01t8p_pziTimxnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On Sat, Dec 31, 2011 at 10:55:22PM +0800, Hillf Danton wrote:
> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: vmscam: check page order in isolating lru pages
> 
> Before try to isolate physically contiguous pages, check for page order is
> added, and if it is not regular page, we should give up the attempt.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> ---
> 
> --- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
> +++ b/mm/vmscan.c	Sat Dec 31 22:44:16 2011
> @@ -1162,6 +1162,7 @@ static unsigned long isolate_lru_pages(u
>  		unsigned long end_pfn;
>  		unsigned long page_pfn;
>  		int zone_id;
> +		unsigned int isolated_pages = 1;
> 
>  		page = lru_to_page(src);
>  		prefetchw_prev_lru_page(page, src, flags);
> @@ -1172,7 +1173,7 @@ static unsigned long isolate_lru_pages(u
>  		case 0:
>  			mem_cgroup_lru_del(page);
>  			list_move(&page->lru, dst);
> -			nr_taken += hpage_nr_pages(page);
> +			isolated_pages = hpage_nr_pages(page);
>  			break;
> 
>  		case -EBUSY:
> @@ -1184,8 +1185,12 @@ static unsigned long isolate_lru_pages(u
>  			BUG();
>  		}
> 
> +		nr_taken += isolated_pages;
>  		if (!order)
>  			continue;
> +		/* try pfn-based isolation only for regular page */
> +		if (isolated_pages != 1)
> +			continue;
> 

Please put more detail in your changelogs explaining the intention
of your patch.  Judging from it, this is a marginal performance
improvement when THPs are being isolated from the LRU by bypassing
lumpy reclaim.

However, basing the check on "isolated_pages" is obscure and it also
disables lumpy reclaim for the cases where order > HPAGE_SHIFT . This
is very rare (might never even happen) but it's still broken. Minimally
the check should have been something like

if (!order || isolated_pages >= (1 << order))
	continue;

with a comment explaining that there is no point taking pages around
a naturally-aligned region if we just isolated a page larger than it.
This would look better, avoid reusing isolated_pages, be less obscure
and still work for cases where the requested order is larger than
a THP.

Nak to this version.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
