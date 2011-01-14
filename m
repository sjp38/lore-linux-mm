Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 265356B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 07:14:14 -0500 (EST)
Date: Fri, 14 Jan 2011 13:14:03 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] [BUGFIX] fix memcgroup LRU stat with THP
Message-ID: <20110114121342.GQ23189@cmpxchg.org>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110114191042.dd145d22.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110114191042.dd145d22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2011 at 07:10:42PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> memroy cgroup's LRU stat should take care of size of pages because
> Transparent Hugepage inserts hugepage into LRU and zone counter
> is updeted based on the size of page.
> 
> If this value is the number wrong, memory reclaim will not work well.
> 
> Note: only head page of THP's huge page is linked into LRU.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> Index: mmotm-0107/mm/memcontrol.c
> ===================================================================
> --- mmotm-0107.orig/mm/memcontrol.c
> +++ mmotm-0107/mm/memcontrol.c
> @@ -815,7 +815,10 @@ void mem_cgroup_del_lru_list(struct page
>  	 * removed from global LRU.
>  	 */
>  	mz = page_cgroup_zoneinfo(pc);
> -	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> +	if (!PageTransHuge(page))
> +		MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> +	else
> +		MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);

compound_order() returns 0 for !PG_head pages, that should do the
right thing without checking PageTransHuge(), right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
