Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 551406B008C
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 19:05:52 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id ED00E3EE0BC
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:05:49 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D0DBD45DE55
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:05:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B664E45DE4D
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:05:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A5ED11DB803F
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:05:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 716921DB8037
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:05:49 +0900 (JST)
Date: Thu, 24 Nov 2011 09:04:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 5/8] mm: memcg: remove unneeded checks from
 newpage_charge()
Message-Id: <20111124090443.d3f720c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322062951-1756-6-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-6-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Nov 2011 16:42:28 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Johannes Weiner <jweiner@redhat.com>
> 
> All callsites pass in freshly allocated pages and a valid mm.  As a
> result, all checks pertaining the page's mapcount, page->mapping or
> the fallback to init_mm are unneeded.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Hmm, it's true now. But for making clear our assumption to all readers of code,

could you add
VM_BUG_ON(!mm || page_mapped(page) || (page->mapping && !PageAnon(page)) ?

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |   13 +------------
>  1 files changed, 1 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d4d139a..0d10be4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2679,19 +2679,8 @@ int mem_cgroup_newpage_charge(struct page *page,
>  {
>  	if (mem_cgroup_disabled())
>  		return 0;
> -	/*
> -	 * If already mapped, we don't have to account.
> -	 * If page cache, page->mapping has address_space.
> -	 * But page->mapping may have out-of-use anon_vma pointer,
> -	 * detecit it by PageAnon() check. newly-mapped-anon's page->mapping
> -	 * is NULL.
> -  	 */
> -	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
> -		return 0;
> -	if (unlikely(!mm))
> -		mm = &init_mm;
>  	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +					MEM_CGROUP_CHARGE_TYPE_MAPPED);
>  }
>  
>  static void
> -- 
> 1.7.6.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
