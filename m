Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BEDDF6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 06:07:00 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i64so178645259ith.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 03:07:00 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30133.outbound.protection.outlook.com. [40.107.3.133])
        by mx.google.com with ESMTPS id 67si4024274otj.110.2016.08.03.03.06.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 03:06:59 -0700 (PDT)
Date: Wed, 3 Aug 2016 13:06:47 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160803100647.GH13263@esperanza>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
 <20160802173337.GD6637@cmpxchg.org>
 <20160802203115.GA11239@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160802203115.GA11239@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 10:31:16PM +0200, Michal Hocko wrote:
> On Tue 02-08-16 13:33:37, Johannes Weiner wrote:
> > On Tue, Aug 02, 2016 at 06:00:26PM +0200, Michal Hocko wrote:
> > > On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
> > > > @@ -5767,15 +5785,20 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> > > >  	if (!memcg)
> > > >  		return;
> > > >  
> > > > -	mem_cgroup_id_get(memcg);
> > > > -	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> > > > +	swap_memcg = mem_cgroup_id_get_active(memcg);
> > > > +	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
> > > >  	VM_BUG_ON_PAGE(oldid, page);
> > > > -	mem_cgroup_swap_statistics(memcg, true);
> > > > +	mem_cgroup_swap_statistics(swap_memcg, true);
> > > >  
> > > >  	page->mem_cgroup = NULL;
> > > >  
> > > >  	if (!mem_cgroup_is_root(memcg))
> > > >  		page_counter_uncharge(&memcg->memory, 1);
> > > > +	if (memcg != swap_memcg) {
> > > > +		if (!mem_cgroup_is_root(swap_memcg))
> > > > +			page_counter_charge(&swap_memcg->memsw, 1);
> > > > +		page_counter_uncharge(&memcg->memsw, 1);
> > > > +	}
> > > >  
> > > >  	/*
> > > >  	 * Interrupts should be disabled here because the caller holds the
> > > 
> > > The resulting code is a weird mixture of memcg and swap_memcg usage
> > > which is really confusing and error prone. Do we really have to do
> > > uncharge on an already offline memcg?
> > 
> > The charge is recursive and includes swap_memcg, i.e. live groups, so
> > the uncharge is necessary.
> 
> Hmm, the charge is recursive, alraight, but then I see only see only
> small sympathy for
>                if (!mem_cgroup_is_root(swap_memcg))
>                        page_counter_charge(&swap_memcg->memsw, 1);
>                page_counter_uncharge(&memcg->memsw, 1);
> 
> we first charge up the hierarchy just to uncharge the same balance from
> the lower. So the end result should be same, right? The only reason
> would be that we uncharge the lower layer as well. I do not remember
> details, but I do not remember we would be checking counters being 0 on
> exit.

We don't, but I think it would be nice to check the counters on css
free, as it might be helpful for debugging.

I thought about introducing page_counter_uncharge_until() to make this
code look more straightforward, but finally decided to leave it as it is
now, because this code is doomed to die anyway once the unified
hierarchy has settled in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
