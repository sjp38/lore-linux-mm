Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E74986B6C11
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 03:00:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g29-v6so1054244edb.1
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 00:00:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24-v6si1768201edq.93.2018.09.04.00.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 00:00:07 -0700 (PDT)
Date: Tue, 4 Sep 2018 09:00:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: slowly shrink slabs with a relatively small number
 of objects
Message-ID: <20180904070005.GG14951@dhcp22.suse.cz>
References: <20180831203450.2536-1-guro@fb.com>
 <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
 <20180831213138.GA9159@tower.DHCP.thefacebook.com>
 <20180903182956.GE15074@dhcp22.suse.cz>
 <20180903202803.GA6227@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180903202803.GA6227@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon 03-09-18 13:28:06, Roman Gushchin wrote:
> On Mon, Sep 03, 2018 at 08:29:56PM +0200, Michal Hocko wrote:
> > On Fri 31-08-18 14:31:41, Roman Gushchin wrote:
> > > On Fri, Aug 31, 2018 at 05:15:39PM -0400, Rik van Riel wrote:
> > > > On Fri, 2018-08-31 at 13:34 -0700, Roman Gushchin wrote:
> > > > 
> > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > index fa2c150ab7b9..c910cf6bf606 100644
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > > > @@ -476,6 +476,10 @@ static unsigned long do_shrink_slab(struct
> > > > > shrink_control *shrinkctl,
> > > > >  	delta = freeable >> priority;
> > > > >  	delta *= 4;
> > > > >  	do_div(delta, shrinker->seeks);
> > > > > +
> > > > > +	if (delta == 0 && freeable > 0)
> > > > > +		delta = min(freeable, batch_size);
> > > > > +
> > > > >  	total_scan += delta;
> > > > >  	if (total_scan < 0) {
> > > > >  		pr_err("shrink_slab: %pF negative objects to delete
> > > > > nr=%ld\n",
> > > > 
> > > > I agree that we need to shrink slabs with fewer than
> > > > 4096 objects, but do we want to put more pressure on
> > > > a slab the moment it drops below 4096 than we applied
> > > > when it had just over 4096 objects on it?
> > > > 
> > > > With this patch, a slab with 5000 objects on it will
> > > > get 1 item scanned, while a slab with 4000 objects on
> > > > it will see shrinker->batch or SHRINK_BATCH objects
> > > > scanned every time.
> > > > 
> > > > I don't know if this would cause any issues, just
> > > > something to ponder.
> > > 
> > > Hm, fair enough. So, basically we can always do
> > > 
> > >     delta = max(delta, min(freeable, batch_size));
> > > 
> > > Does it look better?
> > 
> > Why don't you use the same heuristic we use for the normal LRU raclaim?
> 
> Because we do reparent kmem lru lists on offlining.
> Take a look at memcg_offline_kmem().

Then I must be missing something. Why are we growing the number of dead
cgroups then?
-- 
Michal Hocko
SUSE Labs
