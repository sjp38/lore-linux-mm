Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DFA568D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 06:03:09 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAQB35c8016822
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 26 Nov 2010 20:03:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC6A945DE59
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 20:03:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B476945DE55
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 20:03:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AABADE08003
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 20:03:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7716F1DB803B
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 20:03:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101125161238.GD26037@csn.ul.ie>
References: <20101125090328.GB14180@hostway.ca> <20101125161238.GD26037@csn.ul.ie>
Message-Id: <20101126195118.B6E7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 26 Nov 2010 20:03:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Simon Kirby <sim@hostway.ca>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Two points.

> @@ -2310,10 +2324,12 @@ loop_again:
>  				 * spectulatively avoid congestion waits
>  				 */
>  				zone_clear_flag(zone, ZONE_CONGESTED);
> +				if (i <= pgdat->high_zoneidx)
> +					any_zone_ok = 1;
>  			}
>  
>  		}
> -		if (all_zones_ok)
> +		if (all_zones_ok || (order && any_zone_ok))
>  			break;		/* kswapd: all done */
>  		/*
>  		 * OK, kswapd is getting into trouble.  Take a nap, then take
> @@ -2336,7 +2352,7 @@ loop_again:
>  			break;
>  	}
>  out:
> -	if (!all_zones_ok) {
> +	if (!(all_zones_ok || (order && any_zone_ok))) {

This doesn't work ;)
kswapd have to clear ZONE_CONGESTED flag before enter sleeping.
otherwise nobody can clear it.

Say, we have to fill below condition.
 - All zone are successing zone_watermark_ok(order-0)
 - At least one zone are successing zone_watermark_ok(high-order)



> @@ -2417,6 +2439,7 @@ static int kswapd(void *p)
>  		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  		new_order = pgdat->kswapd_max_order;
>  		pgdat->kswapd_max_order = 0;
> +		pgdat->high_zoneidx = MAX_ORDER;

I don't think MAX_ORDER is correct ;)

        high_zoneidx = pgdat->high_zoneidx;
        pgdat->high_zoneidx = pgdat->nr_zones - 1;

?


And, we have another kswapd_max_order reading place. (after kswapd_try_to_sleep)
We need it too.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
