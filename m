Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3436E6B01B6
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 00:19:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2T4JjwV023062
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Mar 2010 13:19:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C38A445DE51
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:19:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8657D45DE3E
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:19:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49777EF8026
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:19:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E52ADE78002
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 13:19:43 +0900 (JST)
Date: Mon, 29 Mar 2010 13:15:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/2] memcg move charge of file cache at task
 migration
Message-Id: <20100329131541.7cdc1744.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100329120321.bb6e65fe.nishimura@mxp.nes.nec.co.jp>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120321.bb6e65fe.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010 12:03:21 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch adds support for moving charge of file cache. It's enabled by setting
> bit 1 of <target cgroup>/memory.move_charge_at_immigrate.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  Documentation/cgroups/memory.txt |    6 ++++--
>  mm/memcontrol.c                  |   14 +++++++++++---
>  2 files changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 1b5bd04..f53d220 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -461,10 +461,12 @@ charges should be moved.
>     0  | A charge of an anonymous page(or swap of it) used by the target task.
>        | Those pages and swaps must be used only by the target task. You must
>        | enable Swap Extension(see 2.4) to enable move of swap charges.
> + -----+------------------------------------------------------------------------
> +   1  | A charge of file cache mmap'ed by the target task. Those pages must be
> +      | mmap'ed only by the target task.

Hmm..my English is not good but..
==
A charge of a page cache mapped by the target task. Pages mapped by multiple processes
will not be moved. This "page cache" doesn't include tmpfs.
==

Hmm, "a page mapped only by target task but belongs to other cgroup" will be moved ?
The answer is "NO.".

The code itself seems to work well. So, could you update Documentation ?

Thanks,
-Kame

>  
>  Note: Those pages and swaps must be charged to the old cgroup.
> -Note: More type of pages(e.g. file cache, shmem,) will be supported by other
> -      bits in future.
> +Note: More type of pages(e.g. shmem) will be supported by other bits in future.
>  
>  8.3 TODO
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f6c9d42..66d2704 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -250,6 +250,7 @@ struct mem_cgroup {
>   */
>  enum move_type {
>  	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
> +	MOVE_CHARGE_TYPE_FILE,	/* private file caches */
>  	NR_MOVE_TYPE,
>  };
>  
> @@ -4192,6 +4193,8 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  	int usage_count = 0;
>  	bool move_anon = test_bit(MOVE_CHARGE_TYPE_ANON,
>  					&mc.to->move_charge_at_immigrate);
> +	bool move_file = test_bit(MOVE_CHARGE_TYPE_FILE,
> +					&mc.to->move_charge_at_immigrate);
>  
>  	if (!pte_present(ptent)) {
>  		/* TODO: handle swap of shmes/tmpfs */
> @@ -4208,10 +4211,15 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  		if (!page || !page_mapped(page))
>  			return 0;
>  		/*
> -		 * TODO: We don't move charges of file(including shmem/tmpfs)
> -		 * pages for now.
> +		 * TODO: We don't move charges of shmem/tmpfs pages for now.
>  		 */
> -		if (!move_anon || !PageAnon(page))
> +		if (PageAnon(page)) {
> +			if (!move_anon)
> +				return 0;
> +		} else if (page_is_file_cache(page)) {
> +			if (!move_file)
> +				return 0;
> +		} else
>  			return 0;
>  		if (!get_page_unless_zero(page))
>  			return 0;
> -- 
> 1.6.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
