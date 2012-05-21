Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 93BF66B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 06:28:07 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B52663EE0B6
	for <linux-mm@kvack.org>; Mon, 21 May 2012 19:28:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DDD845DE59
	for <linux-mm@kvack.org>; Mon, 21 May 2012 19:28:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87D9D45DE4D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 19:28:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A05CE08001
	for <linux-mm@kvack.org>; Mon, 21 May 2012 19:28:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3137C1DB803B
	for <linux-mm@kvack.org>; Mon, 21 May 2012 19:28:05 +0900 (JST)
Message-ID: <4FBA1841.40506@jp.fujitsu.com>
Date: Mon, 21 May 2012 19:26:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg,thp: fix res_counter:96 regression
References: <alpine.LSU.2.00.1205181116160.2082@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205181116160.2082@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/05/19 3:28), Hugh Dickins wrote:

> Occasionally, testing memcg's move_charge_at_immigrate on rc7 shows
> a flurry of hundreds of warnings at kernel/res_counter.c:96, where
> res_counter_uncharge_locked() does WARN_ON(counter->usage < val).
> 
> The first trace of each flurry implicates __mem_cgroup_cancel_charge()
> of mc.precharge, and an audit of mc.precharge handling points to
> mem_cgroup_move_charge_pte_range()'s THP handling in 12724850e806
> "memcg: avoid THP split in task migration".
> 
> Checking !mc.precharge is good everywhere else, when a single page is
> to be charged; but here the "mc.precharge -= HPAGE_PMD_NR" likely to
> follow, is liable to result in underflow (a lot can change since the
> precharge was estimated).
> 
> Simply check against HPAGE_PMD_NR: there's probably a better alternative,
> trying precharge for more, splitting if unsuccessful; but this one-liner
> is safer for now - no kernel/res_counter.c:96 warnings seen in 26 hours.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>


Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
