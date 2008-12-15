Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kvack.org (Postfix) with ESMTP id 7C7DA6B0074
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 05:32:07 -0500 (EST)
Date: Mon, 15 Dec 2008 10:34:26 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [BUGFIX][PATCH mmotm] memcg fix swap accounting leak (v3)
In-Reply-To: <20081215160751.b6a944be.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0812151033060.16370@blonde.anvils>
References: <20081212172930.282caa38.kamezawa.hiroyu@jp.fujitsu.com>
 <20081212184341.b62903a7.nishimura@mxp.nes.nec.co.jp>
 <46730.10.75.179.61.1229080565.squirrel@webmail-b.css.fujitsu.com>
 <20081213160310.e9501cd9.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0812130935220.3611@blonde.anvils>
 <4409.10.75.179.62.1229164064.squirrel@webmail-b.css.fujitsu.com>
 <20081215160751.b6a944be.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Dec 2008, KAMEZAWA Hiroyuki wrote:
> 
> Fix swapin charge operation of memcg.
> 
> @@ -1139,10 +1139,11 @@ void mem_cgroup_commit_charge_swapin(str
>  	/*
>  	 * Now swap is on-memory. This means this page may be
>  	 * counted both as mem and swap....double count.
> -	 * Fix it by uncharging from memsw. This SwapCache is stable
> -	 * because we're still under lock_page().
> +	 * Fix it by uncharging from memsw. Basically, this SwapCache is stable
> +	 * under lock_page(). But in do_swap_page()::memory.c, reuse_swap_page()
> +	 * may call delete_from_swap_cache() before reach here.
>  	 */
> -	if (do_swap_account) {
> +	if (do_swap_account && PageSwapCache(page)) {
>  		swp_entry_t ent = {.val = page_private(page)};
>  		struct mem_cgroup *memcg;
>  		memcg = swap_cgroup_record(ent, NULL);

Yes, that addition looks good to me.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
