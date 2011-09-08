Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 27D3A900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 04:31:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 613AB3EE0BB
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 17:31:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4842145DEAD
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 17:31:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2746145DE9E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 17:31:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 171E51DB803C
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 17:31:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C4F561DB8037
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 17:31:24 +0900 (JST)
Date: Thu, 8 Sep 2011 17:30:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: memcg: close race between charge and putback
Message-Id: <20110908173042.4a6f8ac0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315467622-9520-1-git-send-email-jweiner@redhat.com>
References: <1315467622-9520-1-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  8 Sep 2011 09:40:22 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> There is a potential race between a thread charging a page and another
> thread putting it back to the LRU list:
> 
> charge:                         putback:
> SetPageCgroupUsed               SetPageLRU
> PageLRU && add to memcg LRU     PageCgroupUsed && add to memcg LRU
> 

I assumed that all pages are charged before added to LRU.
(i.e. event happens in charge->lru_lock->putback order.)

But hmm, this assumption may be bad for maintainance.
Do you find a code which adds pages to LRU before charge ?

Hmm, if there are codes which recharge the page to other memcg,
it will cause bug and my assumption may be harmful.

> The order of setting one flag and checking the other is crucial,
> otherwise the charge may observe !PageLRU while the putback observes
> !PageCgroupUsed and the page is not linked to the memcg LRU at all.
> 
> Global memory pressure may fix this by trying to isolate and putback
> the page for reclaim, where that putback would link it to the memcg
> LRU again.  Without that, the memory cgroup is undeletable due to a
> charge whose physical page can not be found and moved out.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/memcontrol.c |   21 ++++++++++++++++++++-
>  1 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d63dfb2..17708e1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -990,6 +990,16 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
>  		return;
>  	pc = lookup_page_cgroup(page);
>  	VM_BUG_ON(PageCgroupAcctLRU(pc));
> +	/*
> +	 * putback:				charge:
> +	 * SetPageLRU				SetPageCgroupUsed
> +	 * smp_mb				smp_mb
> +	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
> +	 *
> +	 * Ensure that one of the two sides adds the page to the memcg
> +	 * LRU during a race.
> +	 */
> +	smp_mb();
>  	if (!PageCgroupUsed(pc))
>  		return;
>  	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> @@ -1041,7 +1051,16 @@ static void mem_cgroup_lru_add_after_commit(struct page *page)
>  	unsigned long flags;
>  	struct zone *zone = page_zone(page);
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> -
> +	/*
> +	 * putback:				charge:
> +	 * SetPageLRU				SetPageCgroupUsed
> +	 * smp_mb				smp_mb
> +	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
> +	 *
> +	 * Ensure that one of the two sides adds the page to the memcg
> +	 * LRU during a race.
> +	 */
> +	smp_mb();
>  	/* taking care of that the page is added to LRU while we commit it */
>  	if (likely(!PageLRU(page)))
>  		return;
> -- 
> 1.7.6
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
