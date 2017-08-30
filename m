Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C72C6B02C3
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 08:45:25 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 85so1855533pge.9
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 05:45:25 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x124si4397119pfx.223.2017.08.30.05.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 05:45:24 -0700 (PDT)
Date: Wed, 30 Aug 2017 13:44:59 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory
 uncharging
Message-ID: <20170830124459.GA10438@castle.DHCP.thefacebook.com>
References: <20170829100150.4580-1-guro@fb.com>
 <20170830123655.6kce7yfkrhrhwubu@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170830123655.6kce7yfkrhrhwubu@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, Aug 30, 2017 at 02:36:55PM +0200, Michal Hocko wrote:
> On Tue 29-08-17 11:01:50, Roman Gushchin wrote:
> [...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index b9cf3cf4a3d0..a69d23082abf 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1792,6 +1792,9 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
> >  	}
> >  	stock->nr_pages += nr_pages;
> >  
> > +	if (stock->nr_pages > CHARGE_BATCH)
> > +		drain_stock(stock);
> > +
> >  	local_irq_restore(flags);
> >  }
> 
> Why do we need this? In other words, why cannot we rely on draining we
> already do?

The existing draining depends on memory pressure, so to keep
the accounting (which we expose to a user) reasonable accurate
even without memory pressure, we need to limit the size of per-cpu stocks.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
