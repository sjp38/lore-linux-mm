Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CB3DF900123
	for <linux-mm@kvack.org>; Mon,  2 May 2011 10:57:39 -0400 (EDT)
Message-ID: <4DBEC65B.4010201@redhat.com>
Date: Mon, 02 May 2011 10:57:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Filter unevictable page out in deactivate_page
References: <cover.1304261567.git.minchan.kim@gmail.com> <dc54a5771cf1f580a91d16816100d4a2bcf2cdf5.1304261567.git.minchan.kim@gmail.com>
In-Reply-To: <dc54a5771cf1f580a91d16816100d4a2bcf2cdf5.1304261567.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>

On 05/01/2011 11:03 AM, Minchan Kim wrote:
> It's pointless that deactive_page's pagevec operation about
> unevictable page as it's nop.
> This patch removes unnecessary overhead which might be a bit problem
> in case that there are many unevictable page in system(ex, mprotect workload)
>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
> ---
>   mm/swap.c |    9 +++++++++
>   1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 2e9656d..b707694 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -511,6 +511,15 @@ static void drain_cpu_pagevecs(int cpu)
>    */
>   void deactivate_page(struct page *page)
>   {
> +
> +	/*
> +	 * In workload which system has many unevictable page(ex, mprotect),
> +	 * unevictalge page deactivation for accelerating reclaim

Typo.

> +	 * is pointless.
> +	 */
> +	if (PageUnevictable(page))
> +		return;
> +
>   	if (likely(get_page_unless_zero(page))) {
>   		struct pagevec *pvec =&get_cpu_var(lru_deactivate_pvecs);
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
