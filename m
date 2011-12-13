Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 23FFF6B020F
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 03:04:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 69B023EE0C3
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:04:12 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5036645DE6D
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:04:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 35B6E45DE68
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:04:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 282901DB804C
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:04:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D72951DB804A
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:04:11 +0900 (JST)
Date: Tue, 13 Dec 2011 17:02:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX] memcg: fix memsw uncharged twice in do_swap_page
Message-Id: <20111213170259.6c625cfb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323762925-14695-1-git-send-email-lliubbo@gmail.com>
References: <1323762925-14695-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, hannes@cmpxchg.org, bsingharora@gmail.com

On Tue, 13 Dec 2011 15:55:25 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> As the document memcg_test.txt said:
> In do_swap_page(), following events occur when pte is unchanged.
> 	(1) the page (SwapCache) is looked up.
> 	(2) lock_page()
> 	(3) try_charge_swapin()
> 	(4) reuse_swap_page() (may call delete_swap_cache())
> 	(5) commit_charge_swapin()
> 	(6) swap_free().
> 
> And below situation:
> (C) The page has been charged before (2) and reuse_swap_page() doesn't
> 	call delete_from_swap_cache().
> 
> In this case, __mem_cgroup_commit_charge_swapin() may uncharge memsw twice.
> See below two uncharge place:
> 
> __mem_cgroup_commit_charge_swapin {
> 	=> __mem_cgroup_commit_charge_lrucare
> 		=> __mem_cgroup_commit_charge()    <== PageCgroupUsed
> 			=> __mem_cgroup_cancel_charge()
> 						<== 1.uncharge memsw here
> 
> 	if (do_swap_account && PageSwapCache(page)) {
> 		if (swap_memcg) {
> 			if (!mem_cgroup_is_root(swap_memcg))
> 				res_counter_uncharge(&swap_memcg->memsw,
> 						PAGE_SIZE);
> 						<== 2.uncharged memsw again here
> 
> 			mem_cgroup_swap_statistics(swap_memcg, false);
> 			mem_cgroup_put(swap_memcg);
> 		}
> 	}
> }


How this happens ?

1. all swap-cache handling is serialized by lock_page().
2. If the page_cgroup is marked as PCG_USED, record in swap_cgroup must be cleared.
   and swap_memcg never be found.

There is no real bug. If you want to add VM_BUG_ON() as

  commit_charge() decreases memsw count but swap_cgroup is found.

ok, please write a patch.

Nack to this patch. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
