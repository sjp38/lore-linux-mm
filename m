Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 47A0C6B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 04:33:32 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3944D3EE0C5
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 18:33:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B1C545DEF2
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 18:33:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F297545DEF1
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 18:33:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C753D1DB8043
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 18:33:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F2FC1DB8041
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 18:33:28 +0900 (JST)
Date: Thu, 1 Dec 2011 18:32:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: incorrect overflow check in shrink_slab()
Message-Id: <20111201183202.2e5bd872.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <0D9D9F79-204D-4460-8CE7-A583C5C38A1E@gmail.com>
References: <0D9D9F79-204D-4460-8CE7-A583C5C38A1E@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xi Wang <xi.wang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 1 Dec 2011 04:20:34 -0500
Xi Wang <xi.wang@gmail.com> wrote:

> total_scan is unsigned long, so the overflow check (total_scan < 0)
> didn't work.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Nice catch but.... the 'total_scan" shouldn't be long ?
Rather than type casting ?

Thanks,
-Kame
> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a1893c0..46a04e7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -270,7 +270,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		delta *= max_pass;
>  		do_div(delta, lru_pages + 1);
>  		total_scan += delta;
> -		if (total_scan < 0) {
> +		if ((long)total_scan < 0) {
>  			printk(KERN_ERR "shrink_slab: %pF negative objects to "
>  			       "delete nr=%ld\n",
>  			       shrinker->shrink, total_scan);
> -- 
> 1.7.5.4
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
