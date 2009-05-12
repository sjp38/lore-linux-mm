Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA3F6B005D
	for <linux-mm@kvack.org>; Tue, 12 May 2009 00:36:04 -0400 (EDT)
Date: Tue, 12 May 2009 13:32:38 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/3] fix swap cache account leak at swapin-readahead
Message-Id: <20090512133238.0fb41722.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090512104603.ac4ca1f4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512104603.ac4ca1f4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009 10:46:03 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In general, Linux's swp_entry handling is done by combination of lazy techniques
> and global LRU. It works well but when we use mem+swap controller, some more
> strict control is appropriate. Otherwise, swp_entry used by a cgroup will be
> never freed until global LRU works. In a system where memcg is well-configured,
> global LRU doesn't work frequently.
> 
>   Example) Assume swapin-readahead.
> 	      CPU0			      CPU1
> 	   zap_pte()			  read_swap_cache_async()
> 					  swap_duplicate().
>            swap_entry_free() = 1
> 	   find_get_page()=> NULL.
> 					  add_to_swap_cache().
> 					  issue swap I/O. 
> 
> There are many patterns of this kind of race (but no problems).
> 
> free_swap_and_cache() is called for freeing swp_entry. But it is a best-effort
> function. If the swp_entry/page seems busy, swp_entry is not freed.
> This is not a problem because global-LRU will find SwapCache at page reclaim.
> 
> If memcg is used, on the other hand, global LRU may not work. Then, above
> unused SwapCache will not be freed.
> (unmapped SwapCache occupy swp_entry but never be freed if not on memcg's LRU)
> 
> So, even if there are no tasks in a cgroup, swp_entry usage still remains.
> In bad case, OOM by mem+swap controller is triggered by this "leak" of
> swp_entry as Nishimura reported.
> 
> Considering this issue, swapin-readahead itself is not very good for memcg.
> It read swap cache which will not be used. (and _unused_ swapcache will
> not be accounted.) Even if we account swap cache at add_to_swap_cache(),
> we need to account page to several _unrelated_ memcg. This is bad.
> 
> This patch tries to fix racy case of free_swap_and_cache() and page status.
> 
> After this patch applied, following test works well.
> 
>   # echo 1-2M > ../memory.limit_in_bytes
>   # run tasks under memcg.
>   # kill all tasks and make memory.tasks empty
>   # check memory.memsw.usage_in_bytes == memory.usage_in_bytes and
>     there is no _used_ swp_entry.
> 
> What this patch does is
>  - avoid swapin-readahead when memcg is activated.
> 
> Changelog: v6 -> v7
>  - just handle races in readahead.
>  - races in writeback is handled in the next patch.
> 
> Changelog: v5 -> v6
>  - works only when memcg is activated.
>  - check after I/O works only after writeback.
>  - avoid swapin-readahead when memcg is activated.
>  - fixed page refcnt issue.
> Changelog: v4->v5
>  - completely new design.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good to me.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
