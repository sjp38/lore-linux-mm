Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 67F686B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 05:51:00 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d65so172591238ith.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 02:51:00 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0138.outbound.protection.outlook.com. [104.47.2.138])
        by mx.google.com with ESMTPS id y6si4003489otd.129.2016.08.03.02.50.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 02:50:59 -0700 (PDT)
Date: Wed, 3 Aug 2016 12:50:49 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160803095049.GG13263@esperanza>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160802160025.GB28900@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 06:00:26PM +0200, Michal Hocko wrote:
> On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
...
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 3be791afd372..4ae12effe347 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4036,6 +4036,24 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
> >  	atomic_inc(&memcg->id.ref);
> >  }
> >  
> > +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> > +{
> > +	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> > +		/*
> > +		 * The root cgroup cannot be destroyed, so it's refcount must
> > +		 * always be >= 1.
> > +		 */
> > +		if (memcg == root_mem_cgroup) {
> > +			VM_BUG_ON(1);
> > +			break;
> > +		}
> 
> why not simply VM_BUG_ON(memcg == root_mem_cgroup)?

Because with DEBUG_VM disabled we could wind up looping forever here if
the refcount of the root_mem_cgroup got screwed up. On production
kernels, it's better to break the loop and carry on closing eyes on
diverging counters rather than getting a lockup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
