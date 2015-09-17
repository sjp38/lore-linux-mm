Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4E66B0254
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 09:04:32 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so22882017wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 06:04:31 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id p10si3970902wiv.26.2015.09.17.06.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 06:04:31 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so26421082wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 06:04:30 -0700 (PDT)
Date: Thu, 17 Sep 2015 15:04:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix order calculation in try_charge()
Message-ID: <20150917130427.GA25740@dhcp22.suse.cz>
References: <1442318757-7141-1-git-send-email-jmarchan@redhat.com>
 <20150915135623.GA26649@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915135623.GA26649@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

[CC Andrew - the patch was posted here
http://lkml.kernel.org/r/1442318757-7141-1-git-send-email-jmarchan%40redhat.com]

On Tue 15-09-15 15:56:23, Michal Hocko wrote:
> On Tue 15-09-15 14:05:57, Jerome Marchand wrote:
> > Since commit <6539cc05386> (mm: memcontrol: fold mem_cgroup_do_charge()),
> > the order to pass to mem_cgroup_oom() is calculated by passing the number
> > of pages to get_order() instead of the expected  size in bytes. AFAICT,
> > it only affects the value displayed in the oom warning message.
> > This patch fix this.
> 
> We haven't noticed that just because the OOM is enabled only for page
> faults of order-0 (single page) and get_order work just fine. Thanks for
> noticing this. If we ever start triggering OOM on different orders this
> would be broken.
>  
> > Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Btw. a quick git grep shows that at least gart_iommu_init is using
> number of pages as well. I haven't checked it does that intentionally,
> though.
> 
> Thanks!
> 
> > ---
> >  mm/memcontrol.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 1742a2d..91bf094 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2032,7 +2032,8 @@ retry:
> >  
> >  	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
> >  
> > -	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(nr_pages));
> > +	mem_cgroup_oom(mem_over_limit, gfp_mask,
> > +		       get_order(nr_pages * PAGE_SIZE));
> >  nomem:
> >  	if (!(gfp_mask & __GFP_NOFAIL))
> >  		return -ENOMEM;
> > -- 
> > 1.9.3
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
