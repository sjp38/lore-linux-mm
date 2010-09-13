Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 34A0D6B0047
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 17:08:43 -0400 (EDT)
Date: Mon, 13 Sep 2010 14:08:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX][PATCH] memcg: fix race in file_mapped accouting flag
 management
Message-Id: <20100913140803.b83d3fe1.akpm@linux-foundation.org>
In-Reply-To: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Sep 2010 16:08:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> I think this small race is not very critical but it's bug.
> We have this race since 2.6.34. 
> =
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now. memory cgroup accounts file-mapped by counter and flag.
> counter is working in the same way with zone_stat but FileMapped flag only
> exists in memcg (for helping move_account).
> 
> This flag can be updated wrongly in a case. Assume CPU0 and CPU1
> and a thread mapping a page on CPU0, another thread unmapping it on CPU1.
> 
>     CPU0                   		CPU1
> 				rmv rmap (mapcount 1->0)
>    add rmap (mapcount 0->1)
>    lock_page_cgroup()
>    memcg counter+1		(some delay)
>    set MAPPED FLAG.
>    unlock_page_cgroup()
> 				lock_page_cgroup()
> 				memcg counter-1
> 				clear MAPPED flag
> 
> In above sequence, counter is properly updated but FLAG is not.
> This means that representing a state by a flag which is maintained by
> counter needs some specail care.
> 
> To handle this, at claering a flag, this patch check mapcount directly and
> clear the flag only when mapcount == 0. (if mapcount >0, someone will make
> it to zero later and flag will be cleared.)
> 
> Reverse case, dec-after-inc cannot be a problem because page_table_lock()
> works well for it. (IOW, to make above sequence, 2 processes should touch
> the same page at once with map/unmap.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: lockless-update/mm/memcontrol.c
> ===================================================================
> --- lockless-update.orig/mm/memcontrol.c
> +++ lockless-update/mm/memcontrol.c
> @@ -1485,7 +1485,8 @@ void mem_cgroup_update_file_mapped(struc
>  		SetPageCgroupFileMapped(pc);
>  	} else {
>  		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		ClearPageCgroupFileMapped(pc);
> +		if (page_mapped(page)) /* for race between dec->inc counter */
> +			ClearPageCgroupFileMapped(pc);
>  	}

This should be !page_mapped(), shouldn't it?

And your second patch _does_ have !page_mapped() here, which is why the
second patch didn't apply.

I tried to fix things up.  Please check.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
