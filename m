Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE566B003A
	for <linux-mm@kvack.org>; Tue, 27 May 2014 03:44:13 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so8717547pbb.8
        for <linux-mm@kvack.org>; Tue, 27 May 2014 00:44:13 -0700 (PDT)
Received: from fgwmail2.fujitsu.co.jp (fgwmail2.fujitsu.co.jp. [164.71.1.135])
        by mx.google.com with ESMTPS id bh4si17772571pad.219.2014.05.27.00.44.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 27 May 2014 00:44:12 -0700 (PDT)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail2.fujitsu.co.jp (Postfix) with ESMTP id E24C344DD87
	for <linux-mm@kvack.org>; Tue, 27 May 2014 16:44:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id F1B96AC0C06
	for <linux-mm@kvack.org>; Tue, 27 May 2014 16:44:09 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 912CA1DB803C
	for <linux-mm@kvack.org>; Tue, 27 May 2014 16:44:09 +0900 (JST)
Message-ID: <53844220.5040507@jp.fujitsu.com>
Date: Tue, 27 May 2014 16:43:28 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 9/9] mm: memcontrol: rewrite uncharge API
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org> <1398889543-23671-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1398889543-23671-10-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2014/05/01 5:25), Johannes Weiner wrote:
> The memcg uncharging code that is involved towards the end of a page's
> lifetime - truncation, reclaim, swapout, migration - is impressively
> complicated and fragile.
> 
> Because anonymous and file pages were always charged before they had
> their page->mapping established, uncharges had to happen when the page
> type could be known from the context, as in unmap for anonymous, page
> cache removal for file and shmem pages, and swap cache truncation for
> swap pages.  However, these operations also happen well before the
> page is actually freed, and so a lot of synchronization is necessary:
> 
> - On page migration, the old page might be unmapped but then reused,
>    so memcg code has to prevent an untimely uncharge in that case.
>    Because this code - which should be a simple charge transfer - is so
>    special-cased, it is not reusable for replace_page_cache().
> 
> - Swap cache truncation happens during both swap-in and swap-out, and
>    possibly repeatedly before the page is actually freed.  This means
>    that the memcg swapout code is called from many contexts that make
>    no sense and it has to figure out the direction from page state to
>    make sure memory and memory+swap are always correctly charged.
> 
> But now that charged pages always have a page->mapping, introduce
> mem_cgroup_uncharge(), which is called after the final put_page(),
> when we know for sure that nobody is looking at the page anymore.
> 
> For page migration, introduce mem_cgroup_migrate(), which is called
> after the migration is successful and the new page is fully rmapped.
> Because the old page is no longer uncharged after migration, prevent
> double charges by decoupling the page's memcg association (PCG_USED
> and pc->mem_cgroup) from the page holding an actual charge.  The new
> bits PCG_MEM and PCG_MEMSW represent the respective charges and are
> transferred to the new page during migration.
> 
> mem_cgroup_migrate() is suitable for replace_page_cache() as well.
> 
> Swap accounting is massively simplified: because the page is no longer
> uncharged as early as swap cache deletion, a new mem_cgroup_swapout()
> can transfer the page's memory+swap charge (PCG_MEMSW) to the swap
> entry before the final put_page() in page reclaim.
> 
> Finally, because pages are now charged under proper serialization
> (anon: exclusive; cache: page lock; swapin: page lock; migration: page
> lock), and uncharged under full exclusion, they can not race with
> themselves.  Because they are also off-LRU during charge/uncharge,
> charge migration can not race, with that, either.  Remove the crazily
> expensive the page_cgroup lock and set pc->flags non-atomically.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

The whole series seems wonderful to me. Thank you.
I'm not sure whether I have enough good eyes now but this seems good.

One thing in my mind is batched uncharge rework.

Because uncharge() is done in final put_page() path, 
mem_cgroup_uncharge_start()/mem_cgroup_uncharge_end() placement may not be good enough.

swap.c::release_pages() may be good to have mem_cgroup_uncharge_start()/end().
(and you may be able to remove unnecessary calls of mem_cgroup_uncharge_start/end())

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
