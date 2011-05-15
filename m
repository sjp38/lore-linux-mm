Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 23805900001
	for <linux-mm@kvack.org>; Sun, 15 May 2011 06:26:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A12AE3EE0AE
	for <linux-mm@kvack.org>; Sun, 15 May 2011 19:26:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8787045DF5A
	for <linux-mm@kvack.org>; Sun, 15 May 2011 19:26:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67E0F45DF54
	for <linux-mm@kvack.org>; Sun, 15 May 2011 19:26:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 58565E08005
	for <linux-mm@kvack.org>; Sun, 15 May 2011 19:26:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 22B49E08002
	for <linux-mm@kvack.org>; Sun, 15 May 2011 19:26:01 +0900 (JST)
Message-ID: <4DCFAA80.7040109@jp.fujitsu.com>
Date: Sun, 15 May 2011 19:27:12 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1305295404-12129-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, James.Bottomley@HansenPartnership.com, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

(2011/05/13 23:03), Mel Gorman wrote:
> Under constant allocation pressure, kswapd can be in the situation where
> sleeping_prematurely() will always return true even if kswapd has been
> running a long time. Check if kswapd needs to be scheduled.
> 
> Signed-off-by: Mel Gorman<mgorman@suse.de>
> ---
>   mm/vmscan.c |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index af24d1e..4d24828 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
>   	unsigned long balanced = 0;
>   	bool all_zones_ok = true;
> 
> +	/* If kswapd has been running too long, just sleep */
> +	if (need_resched())
> +		return false;
> +

Hmm... I don't like this patch so much. because this code does

- don't sleep if kswapd got context switch at shrink_inactive_list
- sleep if kswapd didn't

It seems to be semi random behavior.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
