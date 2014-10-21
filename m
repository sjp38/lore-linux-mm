Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABBA6B006C
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 21:08:22 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so217962pad.19
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:08:22 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id qd9si9268261pdb.221.2014.10.20.18.08.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 18:08:21 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4EF483EE0C1
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:08:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 5DE48AC06F0
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:08:19 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02B431DB8038
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:08:19 +0900 (JST)
Message-ID: <5445B1E8.1010100@jp.fujitsu.com>
Date: Tue, 21 Oct 2014 10:07:52 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 1/4] mm: memcontrol: uncharge pages on swapout
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org> <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2014/10/21 0:22), Johannes Weiner wrote:
> mem_cgroup_swapout() is called with exclusive access to the page at
> the end of the page's lifetime.  Instead of clearing the PCG_MEMSW
> flag and deferring the uncharge, just do it right away.  This allows
> follow-up patches to simplify the uncharge code.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   mm/memcontrol.c | 17 +++++++++++++----
>   1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bea3fddb3372..7709f17347f3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5799,6 +5799,7 @@ static void __init enable_swap_cgroup(void)
>    */
>   void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>   {
> +	struct mem_cgroup *memcg;
>   	struct page_cgroup *pc;
>   	unsigned short oldid;
>   
> @@ -5815,13 +5816,21 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>   		return;
>   
>   	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
shouldn't be removed ?


> +	memcg = pc->mem_cgroup;
>   
> -	oldid = swap_cgroup_record(entry, mem_cgroup_id(pc->mem_cgroup));
> +	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
>   	VM_BUG_ON_PAGE(oldid, page);
> +	mem_cgroup_swap_statistics(memcg, true);
>   
> -	pc->flags &= ~PCG_MEMSW;
> -	css_get(&pc->mem_cgroup->css);
> -	mem_cgroup_swap_statistics(pc->mem_cgroup, true);
> +	pc->flags = 0;
> +
> +	if (!mem_cgroup_is_root(memcg))
> +		page_counter_uncharge(&memcg->memory, 1);
> +
> +	local_irq_disable();
> +	mem_cgroup_charge_statistics(memcg, page, -1);
> +	memcg_check_events(memcg, page);
> +	local_irq_enable();
>   }
>   

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
