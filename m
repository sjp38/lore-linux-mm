Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A53C36B02B4
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 13:54:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v104so2964987wrb.6
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 10:54:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e9si32979058edd.17.2017.06.05.10.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Jun 2017 10:54:02 -0700 (PDT)
Date: Mon, 5 Jun 2017 13:53:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] mm: memcontrol: per-lruvec stats infrastructure
Message-ID: <20170605175354.GB8547@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-6-hannes@cmpxchg.org>
 <20170603175002.GE15130@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170603175002.GE15130@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Jun 03, 2017 at 08:50:02PM +0300, Vladimir Davydov wrote:
> On Tue, May 30, 2017 at 02:17:23PM -0400, Johannes Weiner wrote:
> > lruvecs are at the intersection of the NUMA node and memcg, which is
> > the scope for most paging activity.
> > 
> > Introduce a convenient accounting infrastructure that maintains
> > statistics per node, per memcg, and the lruvec itself.
> > 
> > Then convert over accounting sites for statistics that are already
> > tracked in both nodes and memcgs and can be easily switched.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  include/linux/memcontrol.h | 238 +++++++++++++++++++++++++++++++++++++++------
> >  include/linux/vmstat.h     |   1 -
> >  mm/memcontrol.c            |   6 ++
> >  mm/page-writeback.c        |  15 +--
> >  mm/rmap.c                  |   8 +-
> >  mm/workingset.c            |   9 +-
> >  6 files changed, 225 insertions(+), 52 deletions(-)
> > 
> ...
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 9c68a40c83e3..e37908606c0f 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4122,6 +4122,12 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
> >  	if (!pn)
> >  		return 1;
> >  
> > +	pn->lruvec_stat = alloc_percpu(struct lruvec_stat);
> > +	if (!pn->lruvec_stat) {
> > +		kfree(pn);
> > +		return 1;
> > +	}
> > +
> >  	lruvec_init(&pn->lruvec);
> >  	pn->usage_in_excess = 0;
> >  	pn->on_tree = false;
> 
> I don't see the matching free_percpu() anywhere, forget to patch
> free_mem_cgroup_per_node_info()?

Yes, I missed that.

---
