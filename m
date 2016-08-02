Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBBD6B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 16:31:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so110919179wml.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 13:31:19 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id bq6si4358075wjc.14.2016.08.02.13.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 13:31:18 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so32837654wmg.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 13:31:18 -0700 (PDT)
Date: Tue, 2 Aug 2016 22:31:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160802203115.GA11239@dhcp22.suse.cz>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
 <20160802173337.GD6637@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160802173337.GD6637@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 02-08-16 13:33:37, Johannes Weiner wrote:
> On Tue, Aug 02, 2016 at 06:00:26PM +0200, Michal Hocko wrote:
> > On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
> > > @@ -5767,15 +5785,20 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> > >  	if (!memcg)
> > >  		return;
> > >  
> > > -	mem_cgroup_id_get(memcg);
> > > -	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> > > +	swap_memcg = mem_cgroup_id_get_active(memcg);
> > > +	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
> > >  	VM_BUG_ON_PAGE(oldid, page);
> > > -	mem_cgroup_swap_statistics(memcg, true);
> > > +	mem_cgroup_swap_statistics(swap_memcg, true);
> > >  
> > >  	page->mem_cgroup = NULL;
> > >  
> > >  	if (!mem_cgroup_is_root(memcg))
> > >  		page_counter_uncharge(&memcg->memory, 1);
> > > +	if (memcg != swap_memcg) {
> > > +		if (!mem_cgroup_is_root(swap_memcg))
> > > +			page_counter_charge(&swap_memcg->memsw, 1);
> > > +		page_counter_uncharge(&memcg->memsw, 1);
> > > +	}
> > >  
> > >  	/*
> > >  	 * Interrupts should be disabled here because the caller holds the
> > 
> > The resulting code is a weird mixture of memcg and swap_memcg usage
> > which is really confusing and error prone. Do we really have to do
> > uncharge on an already offline memcg?
> 
> The charge is recursive and includes swap_memcg, i.e. live groups, so
> the uncharge is necessary.

Hmm, the charge is recursive, alraight, but then I see only see only
small sympathy for
               if (!mem_cgroup_is_root(swap_memcg))
                       page_counter_charge(&swap_memcg->memsw, 1);
               page_counter_uncharge(&memcg->memsw, 1);

we first charge up the hierarchy just to uncharge the same balance from
the lower. So the end result should be same, right? The only reason
would be that we uncharge the lower layer as well. I do not remember
details, but I do not remember we would be checking counters being 0 on
exit.
But it is quite late and my brain is quite burnt so I might miss
something easily. So whatever small style issues, I think the patch
is correct and feel free to add

Acked-by: Michal Hocko <mhocko@suse.com>

I just think we can make this easier and more straightforward. See the
diff below (not even compile tested - just for an illustration).

> I don't think the code is too bad, though?
> swap_memcg is the target that is being charged for swap, memcg is the
> origin group from which we swap out. Seems pretty straightforward...?
> 
> But maybe a comment above the memcg != swap_memcg check would be nice:
> 
> /*
>  * In case the memcg owning these pages has been offlined and doesn't
>  * have an ID allocated to it anymore, charge the closest online
>  * ancestor for the swap instead and transfer the memory+swap charge.
>  */

comment would be definitely helpful.
 
> Thinking about it, mem_cgroup_id_get_active() is a little strange; the
> term we use throughout the cgroup code is "online". It might be good
> to rename this mem_cgroup_id_get_online().

yes, that would be better, imho

---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b6ac01d2b908..66868b2a4c8c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5819,6 +5819,14 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 	VM_BUG_ON_PAGE(page_count(page), page);
 
+	/*
+	 * Interrupts should be disabled here because the caller holds the
+	 * mapping->tree_lock lock which is taken with interrupts-off. It is
+	 * important here to have the interrupts disabled because it is the
+	 * only synchronisation we have for udpating the per-CPU variables.
+	 */
+	VM_BUG_ON(!irqs_disabled());
+
 	if (!do_memsw_account())
 		return;
 
@@ -5828,6 +5836,12 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return;
 
+	/*
+	 * In case the memcg owning these pages has been offlined and doesn't
+	 * have an ID allocated to it anymore, charge the closest online
+	 * ancestor for the swap instead. Hierarchical charges will be preserved
+	 * and the offlined one will not cry with some discrepances in statistics
+	 */
 	swap_memcg = mem_cgroup_id_get_active(memcg);
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
 	VM_BUG_ON_PAGE(oldid, page);
@@ -5837,21 +5851,11 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
-	if (memcg != swap_memcg) {
-		if (!mem_cgroup_is_root(swap_memcg))
-			page_counter_charge(&swap_memcg->memsw, 1);
-		page_counter_uncharge(&memcg->memsw, 1);
-	}
 
-	/*
-	 * Interrupts should be disabled here because the caller holds the
-	 * mapping->tree_lock lock which is taken with interrupts-off. It is
-	 * important here to have the interrupts disabled because it is the
-	 * only synchronisation we have for udpating the per-CPU variables.
-	 */
-	VM_BUG_ON(!irqs_disabled());
-	mem_cgroup_charge_statistics(memcg, page, false, -1);
-	memcg_check_events(memcg, page);
+	if (memcg == swap_memcg) {
+		mem_cgroup_charge_statistics(memcg, page, false, -1);
+		memcg_check_events(memcg, page);
+	}
 
 	if (!mem_cgroup_is_root(memcg))
 		css_put(&memcg->css);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
