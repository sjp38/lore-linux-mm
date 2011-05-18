Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 977C08D004A
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:46:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B435E3EE0CB
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:46:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88F8245DE97
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:46:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64FAE45DE91
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:46:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55F58E08005
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:46:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DDE51DB803B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:46:16 +0900 (JST)
Message-ID: <4DD316C7.60003@jp.fujitsu.com>
Date: Wed, 18 May 2011 09:45:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: Correctly check if reclaimer should schedule
 during shrink_slab
References: <1305295404-12129-5-git-send-email-mgorman@suse.de> <4DCFAA80.7040109@jp.fujitsu.com> <1305519711.4806.7.camel@mulgrave.site> <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com> <20110516084558.GE5279@suse.de> <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com> <20110516102753.GF5279@suse.de> <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com> <20110517103840.GL5279@suse.de> <1305640239.2046.27.camel@lenovo> <20110517161508.GN5279@suse.de>
In-Reply-To: <20110517161508.GN5279@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, minchan.kim@gmail.com, colin.king@canonical.com, James.Bottomley@hansenpartnership.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

(2011/05/18 1:15), Mel Gorman wrote:
> It has been reported on some laptops that kswapd is consuming large
> amounts of CPU and not being scheduled when SLUB is enabled during
> large amounts of file copying. It is expected that this is due to
> kswapd missing every cond_resched() point because;
>
> shrink_page_list() calls cond_resched() if inactive pages were isolated
>          which in turn may not happen if all_unreclaimable is set in
>          shrink_zones(). If for whatver reason, all_unreclaimable is
>          set on all zones, we can miss calling cond_resched().
>
> balance_pgdat() only calls cond_resched if the zones are not
>          balanced. For a high-order allocation that is balanced, it
>          checks order-0 again. During that window, order-0 might have
>          become unbalanced so it loops again for order-0 and returns
>          that it was reclaiming for order-0 to kswapd(). It can then
>          find that a caller has rewoken kswapd for a high-order and
>          re-enters balance_pgdat() without ever calling cond_resched().
>
> shrink_slab only calls cond_resched() if we are reclaiming slab
> 	pages. If there are a large number of direct reclaimers, the
> 	shrinker_rwsem can be contended and prevent kswapd calling
> 	cond_resched().
>
> This patch modifies the shrink_slab() case. If the semaphore is
> contended, the caller will still check cond_resched(). After each
> successful call into a shrinker, the check for cond_resched() is
> still necessary in case one shrinker call is particularly slow.
>
> This patch replaces
> mm-vmscan-if-kswapd-has-been-running-too-long-allow-it-to-sleep.patch
> in -mm.
>
> [mgorman@suse.de: Preserve call to cond_resched after each call into shrinker]
> From: Minchan Kim<minchan.kim@gmail.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
