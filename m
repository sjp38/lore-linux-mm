Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 7DCD86B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 02:48:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8A0B43EE0C2
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:48:32 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 704FA45DE53
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:48:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 506D845DE4F
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:48:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 39C2A1DB8040
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:48:32 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC17F1DB8037
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:48:31 +0900 (JST)
Message-ID: <51650B1F.1060607@jp.fujitsu.com>
Date: Wed, 10 Apr 2013 15:47:59 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1365505625-9460-1-git-send-email-mgorman@suse.de> <1365505625-9460-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(2013/04/09 20:06), Mel Gorman wrote:
> The number of pages kswapd can reclaim is bound by the number of pages it
> scans which is related to the size of the zone and the scanning priority. In
> many cases the priority remains low because it's reset every SWAP_CLUSTER_MAX
> reclaimed pages but in the event kswapd scans a large number of pages it
> cannot reclaim, it will raise the priority and potentially discard a large
> percentage of the zone as sc->nr_to_reclaim is ULONG_MAX. The user-visible
> effect is a reclaim "spike" where a large percentage of memory is suddenly
> freed. It would be bad enough if this was just unused memory but because
> of how anon/file pages are balanced it is possible that applications get
> pushed to swap unnecessarily.
> 
> This patch limits the number of pages kswapd will reclaim to the high
> watermark. Reclaim will still overshoot due to it not being a hard limit as
> shrink_lruvec() will ignore the sc.nr_to_reclaim at DEF_PRIORITY but it
> prevents kswapd reclaiming the world at higher priorities. The number of
> pages it reclaims is not adjusted for high-order allocations as kswapd will
> reclaim excessively if it is to balance zones for high-order allocations.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
