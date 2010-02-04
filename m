Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 38C6A6B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 22:31:46 -0500 (EST)
Date: Wed, 3 Feb 2010 19:31:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-Id: <20100203193127.fe5efa17.akpm@linux-foundation.org>
In-Reply-To: <20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:38:16 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

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
>
> ...
>
> +		else if (is_swap_pte(ptent)) {

is_swap_pte() isn't implemented for CONFIG_MMU=n, so the build breaks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
