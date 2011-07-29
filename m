Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8BB6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 02:28:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A47E43EE0AE
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 15:28:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A7C645DE86
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 15:28:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70C9145DE81
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 15:28:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62F271DB8042
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 15:28:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3063B1DB803F
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 15:28:05 +0900 (JST)
Message-ID: <4E3252E2.1030101@jp.fujitsu.com>
Date: Fri, 29 Jul 2011 15:27:46 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: Remove if statement that will never trigger
References: <alpine.LNX.2.00.1107282302580.20477@swampdragon.chaosbits.net>
In-Reply-To: <alpine.LNX.2.00.1107282302580.20477@swampdragon.chaosbits.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jj@chaosbits.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, minchan.kim@gmail.com, mgorman@suse.de, akpm@linux-foundation.org, kanoj@sgi.com, sct@redhat.com

(2011/07/29 6:05), Jesper Juhl wrote:
> We have this code in mm/vmscan.c:shrink_slab() :
> ...
> 		if (total_scan < 0) {
> 			printk(KERN_ERR "shrink_slab: %pF negative objects to "
> 			       "delete nr=%ld\n",
> 			       shrinker->shrink, total_scan);
> 			total_scan = max_pass;
> 		}
> ...
> but since 'total_scan' is of type 'unsigned long' it will never be
> less than zero, so there is no way we'll ever enter the true branch of
> this if statement - so let's just remove it.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  mm/vmscan.c |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)
> 
> 	Compile tested only.
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7ef6912..c07d9b1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -271,12 +271,6 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		delta *= max_pass;
>  		do_div(delta, lru_pages + 1);
>  		total_scan += delta;
> -		if (total_scan < 0) {
> -			printk(KERN_ERR "shrink_slab: %pF negative objects to "
> -			       "delete nr=%ld\n",
> -			       shrinker->shrink, total_scan);
> -			total_scan = max_pass;
> -		}
>  
>  		/*
>  		 * We need to avoid excessive windup on filesystem shrinkers

Good catch.

However this seems intended to catch a overflow. So, I'd suggest to make proper
overflow check instead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
