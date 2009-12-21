Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 93B266B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 02:07:56 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL77rWO018699
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 16:07:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CB94945DE6D
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:07:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C706B45DE55
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:07:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A99FD1DB803E
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:07:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D74C1DB8065
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:07:39 +0900 (JST)
Date: Mon, 21 Dec 2009 16:04:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-Id: <20091221160434.8388f588.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:38:16 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch is another core part of this move-charge-at-task-migration feature.
> It enables moving charges of anonymous swaps.
> 
> To move the charge of swap, we need to exchange swap_cgroup's record.
> 
> In current implementation, swap_cgroup's record is protected by:
> 
>   - page lock: if the entry is on swap cache.
>   - swap_lock: if the entry is not on swap cache.
> 
> This works well in usual swap-in/out activity.
> 
> But this behavior make the feature of moving swap charge check many conditions
> to exchange swap_cgroup's record safely.
> 
> So I changed modification of swap_cgroup's recored(swap_cgroup_record())
> to use xchg, and define a new function to cmpxchg swap_cgroup's record.
> 
> This patch also enables moving charge of non pte_present but not uncharged swap
> caches, which can be exist on swap-out path, by getting the target pages via
> find_get_page() as do_mincore() does.
> 
> Changelog: 2009/12/21
> - move css_put(&to->css) from mem_cgroup_move_charge_pte_range() to
>   mem_cgroup_move_swap_account().
> Changelog: 2009/12/04
> - minor changes in comments and valuable names.
> Changelog: 2009/11/19
> - in can_attach(), instead of parsing the page table, make use of per process
>   mm_counter(swap_usage).
> Changelog: 2009/11/06
> - drop support for shmem's swap(revisit in future).
> - add mem_cgroup_count_swap_user() to prevent moving charges of swaps used by
>   multiple processes(revisit in future).
> Changelog: 2009/09/24
> - do no swap-in in moving swap account any more.
> - add support for shmem's swap.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
