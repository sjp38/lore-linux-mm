Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id E7C2C6B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 11:43:40 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so18364535lbc.3
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 08:43:40 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y191si2719143lfd.174.2015.10.20.08.43.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 08:43:39 -0700 (PDT)
Date: Tue, 20 Oct 2015 18:43:25 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: vmscan: count slab shrinking results after each
 shrink_slab()
Message-ID: <20151020154325.GI18351@esperanza>
References: <1445278415-21138-1-git-send-email-hannes@cmpxchg.org>
 <20151020121920.GE18351@esperanza>
 <20151020135606.GB22383@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151020135606.GB22383@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 20, 2015 at 09:56:06AM -0400, Johannes Weiner wrote:
> On Tue, Oct 20, 2015 at 03:19:20PM +0300, Vladimir Davydov wrote:
> > On Mon, Oct 19, 2015 at 02:13:35PM -0400, Johannes Weiner wrote:
> > > cb731d6 ("vmscan: per memory cgroup slab shrinkers") sought to
> > > optimize accumulating slab reclaim results in sc->nr_reclaimed only
> > > once per zone, but the memcg hierarchy walk itself uses
> > > sc->nr_reclaimed as an exit condition. This can lead to overreclaim.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  mm/vmscan.c | 19 ++++++++++++++-----
> > >  1 file changed, 14 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 27d580b..a02654e 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2441,11 +2441,18 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> > >  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
> > >  			zone_lru_pages += lru_pages;
> > >  
> > > -			if (memcg && is_classzone)
> > > +			if (memcg && is_classzone) {
> > >  				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
> > >  					    memcg, sc->nr_scanned - scanned,
> > >  					    lru_pages);
> > >  
> > > +				if (reclaim_state) {
> > 
> > current->reclaim_state is only set on global reclaim, so when performing
> > memcg reclaim we'll never get here. Hence, since we check nr_reclaimed
> > in the loop only on memcg reclaim, this patch doesn't change anything.
> > 
> > Setting current->reclaim_state on memcg reclaim doesn't seem to be an
> > option, because it accounts objects freed by any cgroup (e.g. via RCU
> > callback) - see https://lkml.org/lkml/2015/1/20/91
> 
> Ah, I was not aware of that. Thanks for clarifying. Scratch this patch
> then.
> 
> Do you think it would make sense to take the shrink_slab() return
> value into account? Or are most objects expected to be RCU-freed
> anyway so it wouldn't make a difference?

On memcg pressure we don't shrink anything except inodes/dentries, which
are usually RCU-freed - e.g. see dentry_free, destroy_inode,
ext4_destroy_inode, xfs_fs_destroy_inode. So I don't think the number of
objects shrunk would tell us much.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
