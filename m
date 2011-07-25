Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDA86B00EE
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 21:28:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DA9543EE0BB
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:25:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C1F4145DE56
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:25:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA9A845DE55
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:25:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C2871DB8048
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:25:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6917D1DB8045
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:25:51 +0900 (JST)
Date: Mon, 25 Jul 2011 10:18:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] memcg: get rid of percpu_charge_mutex lock
Message-Id: <20110725101840.f2796524.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
	<a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, 22 Jul 2011 13:20:25 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> percpu_charge_mutex protects from multiple simultaneous per-cpu charge
> caches draining because we might end up having too many work items.
> At least this was the case until 26fe6168 (memcg: fix percpu cached
> charge draining frequency) when we introduced a more targeted draining
> for async mode.
> Now that also sync draining is targeted we can safely remove mutex
> because we will not send more work than the current number of CPUs.
> FLUSHING_CACHED_CHARGE protects from sending the same work multiple
> times and stock->nr_pages == 0 protects from pointless sending a work
> if there is obviously nothing to be done. This is of course racy but we
> can live with it as the race window is really small (we would have to
> see FLUSHING_CACHED_CHARGE cleared while nr_pages would be still
> non-zero).
> The only remaining place where we can race is synchronous mode when we
> rely on FLUSHING_CACHED_CHARGE test which might have been set by other
> drainer on the same group but we should wait in that case as well.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
