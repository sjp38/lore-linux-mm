Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54B986B02B4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 08:55:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v2so2201812wmd.11
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 05:55:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si4465977wre.276.2017.08.30.05.55.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 05:55:45 -0700 (PDT)
Date: Wed, 30 Aug 2017 14:55:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory
 uncharging
Message-ID: <20170830125543.um72yjhzps4lbj4t@dhcp22.suse.cz>
References: <20170829100150.4580-1-guro@fb.com>
 <20170830123655.6kce7yfkrhrhwubu@dhcp22.suse.cz>
 <20170830124459.GA10438@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830124459.GA10438@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed 30-08-17 13:44:59, Roman Gushchin wrote:
> On Wed, Aug 30, 2017 at 02:36:55PM +0200, Michal Hocko wrote:
> > On Tue 29-08-17 11:01:50, Roman Gushchin wrote:
> > [...]
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index b9cf3cf4a3d0..a69d23082abf 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1792,6 +1792,9 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
> > >  	}
> > >  	stock->nr_pages += nr_pages;
> > >  
> > > +	if (stock->nr_pages > CHARGE_BATCH)
> > > +		drain_stock(stock);
> > > +
> > >  	local_irq_restore(flags);
> > >  }
> > 
> > Why do we need this? In other words, why cannot we rely on draining we
> > already do?
> 
> The existing draining depends on memory pressure, so to keep
> the accounting (which we expose to a user) reasonable accurate
> even without memory pressure, we need to limit the size of per-cpu stocks.

Why don't we need this for regular page charges? Or maybe we do but that
sounds like a seprate and an unrealted fix to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
