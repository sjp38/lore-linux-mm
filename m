Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6AD9F6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 23:25:47 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F3Piej009860
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 12:25:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E568445DE53
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:25:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BCE5E45DE52
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:25:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 920E91DB801D
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:25:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 429131DB8018
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:25:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100414012700.GA10450@sli10-desk.sh.intel.com>
References: <20100413175414.D110.A69D9226@jp.fujitsu.com> <20100414012700.GA10450@sli10-desk.sh.intel.com>
Message-Id: <20100414104434.D135.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 12:25:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

sorry for the delay.

> > After solving streaming io issue, I'll put it to mainline.
> if the streaming io issue is popular, how about below patch against my last one?
> we take priority == DEF_PRIORITY an exception.

Your patch seems works. but it is obviously ugly and bandaid patch.
So, I like single your previous patch rather than combinate this one.
Even though both dropping makes sense rather than both merge.

Please consider attack root cause.



> Index: linux/mm/vmscan.c
> ===================================================================
> --- linux.orig/mm/vmscan.c	2010-04-14 09:03:28.000000000 +0800
> +++ linux/mm/vmscan.c	2010-04-14 09:19:56.000000000 +0800
> @@ -1629,6 +1629,22 @@ static void get_scan_count(struct zone *
>  	fraction[0] = ap;
>  	fraction[1] = fp;
>  	denominator = ap + fp + 1;
> +
> +	/*
> +	 * memory pressure isn't high, we allow percentage underflow. This
> +	 * avoids swap in stream io case.
> +	 */
> +	if (priority == DEF_PRIORITY) {
> +		if (fraction[0] * 99 < fraction[1]) {
> +			fraction[0] = 0;
> +			fraction[1] = 1;
> +			denominator = 1;
> +		} else if (fraction[1] * 99 < fraction[0]) {
> +			fraction[0] = 1;
> +			fraction[1] = 0;
> +			denominator = 1;
> +		}
> +	}
>  out:
>  	for_each_evictable_lru(l) {
>  		int file = is_file_lru(l);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
