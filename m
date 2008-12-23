Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 38B3E6B005C
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 20:29:55 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBN1OuGt016296
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Dec 2008 10:24:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E98D45DD72
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:24:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 25C6545DD75
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:24:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A76DC1DB8043
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:24:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 559211DB803E
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:24:55 +0900 (JST)
Date: Tue, 23 Dec 2008 10:23:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: avoid reclaim_stat oops when disabled
Message-Id: <20081223102356.27faab7b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0812230116210.20371@blonde.anvils>
References: <Pine.LNX.4.64.0812230116210.20371@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Dec 2008 01:24:56 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> mem_cgroup_get_reclaim_stat_from_page() oopses in page_cgroup_zoneinfo()
> when you boot with cgroup_disabled=memory: it needs to check for that.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Oh, thanks.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> Follow memcg-add-zone_reclaim_stat-reclaim-stat-trivial-fixes.patch
> 
>  mm/memcontrol.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> --- mmotm/mm/memcontrol.c	2008-12-16 18:05:31.000000000 +0000
> +++ fixed/mm/memcontrol.c	2008-12-16 19:30:02.000000000 +0000
> @@ -496,9 +496,14 @@ struct zone_reclaim_stat *mem_cgroup_get
>  struct zone_reclaim_stat *
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  {
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
> +	struct page_cgroup *pc;
> +	struct mem_cgroup_per_zone *mz;
>  
> +	if (mem_cgroup_disabled())
> +		return NULL;
> +
> +	pc = lookup_page_cgroup(page);
> +	mz = page_cgroup_zoneinfo(pc);
>  	if (!mz)
>  		return NULL;
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
