Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 7C9736B004D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 06:04:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AA9673EE0B5
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 20:04:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9283145DE4E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 20:04:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B9ED45DE4D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 20:04:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DC5D1DB8037
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 20:04:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28B801DB802F
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 20:04:27 +0900 (JST)
Date: Wed, 7 Dec 2011 20:03:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: drop type MEM_CGROUP_CHARGE_TYPE_DROP
Message-Id: <20111207200315.0bb99400.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323253846-21245-1-git-send-email-lliubbo@gmail.com>
References: <1323253846-21245-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, jweiner@redhat.com, mhocko@suse.cz

On Wed, 7 Dec 2011 18:30:46 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> uncharge will happen only when !page_mapped(page) no matter MEM_CGROUP_CHARGE_TYPE_DROP
> or MEM_CGROUP_CHARGE_TYPE_SWAPOUT when called from mem_cgroup_uncharge_swapcache().
> i think it's no difference, so drop it.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

I think you didn't test at all.

> ---
>  mm/memcontrol.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6aff93c..02a2988 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -339,7 +339,6 @@ enum charge_type {
>  	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
>  	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
>  	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
> -	MEM_CGROUP_CHARGE_TYPE_DROP,	/* a page was unused swap cache */
>  	NR_CHARGE_TYPE,
>  };
>  
> @@ -3000,7 +2999,6 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  
>  	switch (ctype) {
>  	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> -	case MEM_CGROUP_CHARGE_TYPE_DROP:
>  		/* See mem_cgroup_prepare_migration() */
>  		if (page_mapped(page) || PageCgroupMigration(pc))
>  			goto unlock_out;
> @@ -3121,9 +3119,6 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  	struct mem_cgroup *memcg;
>  	int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
>  
> -	if (!swapout) /* this was a swap cache but the swap is unused ! */
> -		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
> -

Then, here , what ctype must be if !swapout ?

Nack.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
