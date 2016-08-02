Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4C06B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:36:17 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so98957200lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:36:17 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id aj2si3695911wjd.169.2016.08.02.10.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 10:36:16 -0700 (PDT)
Date: Tue, 2 Aug 2016 13:33:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160802173337.GD6637@cmpxchg.org>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160802160025.GB28900@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 06:00:26PM +0200, Michal Hocko wrote:
> On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
> > @@ -5767,15 +5785,20 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> >  	if (!memcg)
> >  		return;
> >  
> > -	mem_cgroup_id_get(memcg);
> > -	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> > +	swap_memcg = mem_cgroup_id_get_active(memcg);
> > +	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
> >  	VM_BUG_ON_PAGE(oldid, page);
> > -	mem_cgroup_swap_statistics(memcg, true);
> > +	mem_cgroup_swap_statistics(swap_memcg, true);
> >  
> >  	page->mem_cgroup = NULL;
> >  
> >  	if (!mem_cgroup_is_root(memcg))
> >  		page_counter_uncharge(&memcg->memory, 1);
> > +	if (memcg != swap_memcg) {
> > +		if (!mem_cgroup_is_root(swap_memcg))
> > +			page_counter_charge(&swap_memcg->memsw, 1);
> > +		page_counter_uncharge(&memcg->memsw, 1);
> > +	}
> >  
> >  	/*
> >  	 * Interrupts should be disabled here because the caller holds the
> 
> The resulting code is a weird mixture of memcg and swap_memcg usage
> which is really confusing and error prone. Do we really have to do
> uncharge on an already offline memcg?

The charge is recursive and includes swap_memcg, i.e. live groups, so
the uncharge is necessary. I don't think the code is too bad, though?
swap_memcg is the target that is being charged for swap, memcg is the
origin group from which we swap out. Seems pretty straightforward...?

But maybe a comment above the memcg != swap_memcg check would be nice:

/*
 * In case the memcg owning these pages has been offlined and doesn't
 * have an ID allocated to it anymore, charge the closest online
 * ancestor for the swap instead and transfer the memory+swap charge.
 */

Thinking about it, mem_cgroup_id_get_active() is a little strange; the
term we use throughout the cgroup code is "online". It might be good
to rename this mem_cgroup_id_get_online().

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
