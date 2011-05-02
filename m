Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 75AF390010C
	for <linux-mm@kvack.org>; Mon,  2 May 2011 06:37:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 744013EE0B5
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:37:31 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CA8E45DE93
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:37:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44C7745DE77
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:37:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 382FAE08001
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:37:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 012761DB8037
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:37:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Filter unevictable page out in deactivate_page
In-Reply-To: <dc54a5771cf1f580a91d16816100d4a2bcf2cdf5.1304261567.git.minchan.kim@gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com> <dc54a5771cf1f580a91d16816100d4a2bcf2cdf5.1304261567.git.minchan.kim@gmail.com>
Message-Id: <20110502193820.2D60.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 May 2011 19:37:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>

> It's pointless that deactive_page's pagevec operation about
> unevictable page as it's nop.
> This patch removes unnecessary overhead which might be a bit problem
> in case that there are many unevictable page in system(ex, mprotect workload)
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/swap.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 2e9656d..b707694 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -511,6 +511,15 @@ static void drain_cpu_pagevecs(int cpu)
>   */
>  void deactivate_page(struct page *page)
>  {
> +
> +	/*
> +	 * In workload which system has many unevictable page(ex, mprotect),
> +	 * unevictalge page deactivation for accelerating reclaim
> +	 * is pointless.
> +	 */
> +	if (PageUnevictable(page))
> +		return;
> +

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


btw, I think we should check PageLRU too.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
