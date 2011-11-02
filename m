Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD1B6B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 13:54:43 -0400 (EDT)
Message-ID: <4EB183CF.6050300@jp.fujitsu.com>
Date: Wed, 02 Nov 2011 10:54:23 -0700
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [rfc 1/3] mm: vmscan: never swap under low memory pressure
References: <20110808110658.31053.55013.stgit@localhost6> <CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com> <4E3FD403.6000400@parallels.com> <20111102163056.GG19965@redhat.com> <20111102163141.GH19965@redhat.com>
In-Reply-To: <20111102163141.GH19965@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jweiner@redhat.com
Cc: khlebnikov@parallels.com, penberg@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, riel@redhat.com, mel@csn.ul.ie, minchan.kim@gmail.com, gene.heskett@gmail.com

> ---
>  mm/vmscan.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a90c603..39d3da3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -831,6 +831,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * Try to allocate it some swap space here.l
>  		 */
>  		if (PageAnon(page) && !PageSwapCache(page)) {
> +			if (priority >= DEF_PRIORITY - 2)
> +				goto keep_locked;
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
>  			if (!add_to_swap(page))

Hehe, i tried very similar way very long time ago. Unfortunately, it doesn't work.
"DEF_PRIORITY - 2" is really poor indicator for reclaim pressure. example, if the
machine have 1TB memory, DEF_PRIORITY-2 mean 1TB>>10 = 1GB. It't too big.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
