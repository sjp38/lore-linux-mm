Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DB4238D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:26:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2AA583EE0BC
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:26:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7BD245DE97
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:26:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB1E845DE94
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:26:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BBAB8E08003
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:26:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C2CB1DB803B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:26:29 +0900 (JST)
Message-ID: <4DD31221.3060205@jp.fujitsu.com>
Date: Wed, 18 May 2011 09:26:09 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-5-git-send-email-mgorman@suse.de> <4DCFAA80.7040109@jp.fujitsu.com> <1305519711.4806.7.camel@mulgrave.site> <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com> <20110516084558.GE5279@suse.de> <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com> <20110516102753.GF5279@suse.de>
In-Reply-To: <20110516102753.GF5279@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: minchan.kim@gmail.com, James.Bottomley@hansenpartnership.com, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

> Lets see;
>
> shrink_page_list() only applies if inactive pages were isolated
> 	which in turn may not happen if all_unreclaimable is set in
> 	shrink_zones(). If for whatver reason, all_unreclaimable is
> 	set on all zones, we can miss calling cond_resched().
>
> shrink_slab only applies if we are reclaiming slab pages. If the first
> 	shrinker returns -1, we do not call cond_resched(). If that
> 	first shrinker is dcache and __GFP_FS is not set, direct
> 	reclaimers will not shrink at all. However, if there are
> 	enough of them running or if one of the other shrinkers
> 	is running for a very long time, kswapd could be starved
> 	acquiring the shrinker_rwsem and never reaching the
> 	cond_resched().

OK.


>
> balance_pgdat() only calls cond_resched if the zones are not
> 	balanced. For a high-order allocation that is balanced, it
> 	checks order-0 again. During that window, order-0 might have
> 	become unbalanced so it loops again for order-0 and returns
> 	that was reclaiming for order-0 to kswapd(). It can then find
> 	that a caller has rewoken kswapd for a high-order and re-enters
> 	balance_pgdat() without ever have called cond_resched().

Then, Shouldn't balance_pgdat() call cond_resched() unconditionally?
The problem is NOT 100% cpu consumption. if kswapd will sleep, other
processes need to reclaim old pages. The problem is, kswapd doesn't
invoke context switch and other tasks hang-up.




> While it appears unlikely, there are bad conditions which can result
> in cond_resched() being avoided.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
