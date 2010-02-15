Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 08C476B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 03:29:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F8TVL6021344
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Feb 2010 17:29:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F8C845DE53
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:29:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4425A45DE4D
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:29:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 071041DB803C
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:29:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B46531DB803F
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:29:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 6/7 -mm] oom: avoid oom killer for lowmem allocations
In-Reply-To: <alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com>
Message-Id: <20100215172530.72A1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Feb 2010 17:29:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If memory has been depleted in lowmem zones even with the protection
> afforded to it by /proc/sys/vm/lowmem_reserve_ratio, it is unlikely that
> killing current users will help.  The memory is either reclaimable (or
> migratable) already, in which case we should not invoke the oom killer at
> all, or it is pinned by an application for I/O.  Killing such an
> application may leave the hardware in an unspecified state and there is
> no guarantee that it will be able to make a timely exit.
> 
> Lowmem allocations are now failed in oom conditions so that the task can
> perhaps recover or try again later.  Killing current is an unnecessary
> result for simply making a GFP_DMA or GFP_DMA32 page allocation and no
> lowmem allocations use the now-deprecated __GFP_NOFAIL bit so retrying is
> unnecessary.
> 
> Previously, the heuristic provided some protection for those tasks with 
> CAP_SYS_RAWIO, but this is no longer necessary since we will not be
> killing tasks for the purposes of ISA allocations.

The main difference of Kamezawasan's patch is, his patch treated DMA
zone is filled by mlocked page too.
but I personally think such case should be solved auto page migration
mechanism. (probably, mel's memory compaction patch provide its base
infrastructure). So this patch seems enough and proper.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1914,6 +1914,9 @@ rebalance:
>  	 * running out of options and have to consider going OOM
>  	 */
>  	if (!did_some_progress) {
> +		/* The oom killer won't necessarily free lowmem */
> +		if (high_zoneidx < ZONE_NORMAL)
> +			goto nopage;
>  		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
>  			if (oom_killer_disabled)
>  				goto nopage;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
