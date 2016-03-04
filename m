Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 172F86B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 13:04:14 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so30638159wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 10:04:14 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ct1si5158058wjb.60.2016.03.04.10.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 10:04:12 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id l68so201716wml.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 10:04:12 -0800 (PST)
Date: Fri, 4 Mar 2016 19:04:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: memcontrol: drop unnecessary lru locking from
 mem_cgroup_migrate()
Message-ID: <20160304180411.GE24204@dhcp22.suse.cz>
References: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
 <1454616467-8994-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454616467-8994-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Mateusz Guzik <mguzik@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 04-02-16 15:07:47, Johannes Weiner wrote:
> Migration accounting in the memory controller used to have to handle
> both oldpage and newpage being on the LRU already; fuse's page cache
> replacement used to pass a recycled newpage that had been uncharged
> but not freed and removed from the LRU, and the memcg migration code
> used to uncharge oldpage to "pass on" the existing charge to newpage.
> 
> Nowadays, pages are no longer uncharged when truncated from the page
> cache, but rather only at free time, so if a LRU page is recycled in
> page cache replacement it'll also still be charged. And we bail out of
> the charge transfer altogether in that case. Tell commit_charge() that
> we know newpage is not on the LRU, to avoid taking the zone->lru_lock
> unnecessarily from the migration path.
> 
> But also, oldpage is no longer uncharged inside migration. We only use
> oldpage for its page->mem_cgroup and page size, so we don't care about
> its LRU state anymore either. Remove any mention from the kernel doc.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Suggested-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3e4199830456..42882c1e7fce 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5489,7 +5489,6 @@ void mem_cgroup_uncharge_list(struct list_head *page_list)
>   * be uncharged upon free.
>   *
>   * Both pages must be locked, @newpage->mapping must be set up.
> - * Either or both pages might be on the LRU already.
>   */
>  void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
>  {
> @@ -5524,7 +5523,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
>  		page_counter_charge(&memcg->memsw, nr_pages);
>  	css_get_many(&memcg->css, nr_pages);
>  
> -	commit_charge(newpage, memcg, true);
> +	commit_charge(newpage, memcg, false);
>  
>  	local_irq_disable();
>  	mem_cgroup_charge_statistics(memcg, newpage, compound, nr_pages);
> -- 
> 2.7.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
