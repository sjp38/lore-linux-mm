Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0053C6B6941
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 14:30:09 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so618938pfn.3
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 11:30:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n24-v6si18203097pgj.14.2018.09.03.11.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 11:30:08 -0700 (PDT)
Date: Mon, 3 Sep 2018 20:29:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: slowly shrink slabs with a relatively small number
 of objects
Message-ID: <20180903182956.GE15074@dhcp22.suse.cz>
References: <20180831203450.2536-1-guro@fb.com>
 <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
 <20180831213138.GA9159@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180831213138.GA9159@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri 31-08-18 14:31:41, Roman Gushchin wrote:
> On Fri, Aug 31, 2018 at 05:15:39PM -0400, Rik van Riel wrote:
> > On Fri, 2018-08-31 at 13:34 -0700, Roman Gushchin wrote:
> > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index fa2c150ab7b9..c910cf6bf606 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -476,6 +476,10 @@ static unsigned long do_shrink_slab(struct
> > > shrink_control *shrinkctl,
> > >  	delta = freeable >> priority;
> > >  	delta *= 4;
> > >  	do_div(delta, shrinker->seeks);
> > > +
> > > +	if (delta == 0 && freeable > 0)
> > > +		delta = min(freeable, batch_size);
> > > +
> > >  	total_scan += delta;
> > >  	if (total_scan < 0) {
> > >  		pr_err("shrink_slab: %pF negative objects to delete
> > > nr=%ld\n",
> > 
> > I agree that we need to shrink slabs with fewer than
> > 4096 objects, but do we want to put more pressure on
> > a slab the moment it drops below 4096 than we applied
> > when it had just over 4096 objects on it?
> > 
> > With this patch, a slab with 5000 objects on it will
> > get 1 item scanned, while a slab with 4000 objects on
> > it will see shrinker->batch or SHRINK_BATCH objects
> > scanned every time.
> > 
> > I don't know if this would cause any issues, just
> > something to ponder.
> 
> Hm, fair enough. So, basically we can always do
> 
>     delta = max(delta, min(freeable, batch_size));
> 
> Does it look better?

Why don't you use the same heuristic we use for the normal LRU raclaim?

		/*
		 * If the cgroup's already been deleted, make sure to
		 * scrape out the remaining cache.
		 */
		if (!scan && !mem_cgroup_online(memcg))
			scan = min(size, SWAP_CLUSTER_MAX);

-- 
Michal Hocko
SUSE Labs
