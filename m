Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EEDF16B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 12:36:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u48so19511025wrc.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 09:36:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j33si7380720wre.332.2017.03.01.09.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 09:36:37 -0800 (PST)
Date: Wed, 1 Mar 2017 12:36:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/9] mm: don't avoid high-priority reclaim on memcg limit
 reclaim
Message-ID: <20170301173628.GA12664@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-7-hannes@cmpxchg.org>
 <20170301154027.GF11730@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301154027.GF11730@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Mar 01, 2017 at 04:40:27PM +0100, Michal Hocko wrote:
> On Tue 28-02-17 16:40:04, Johannes Weiner wrote:
> > 246e87a93934 ("memcg: fix get_scan_count() for small targets") sought
> > to avoid high reclaim priorities for memcg by forcing it to scan a
> > minimum amount of pages when lru_pages >> priority yielded nothing.
> > This was done at a time when reclaim decisions like dirty throttling
> > were tied to the priority level.
> > 
> > Nowadays, the only meaningful thing still tied to priority dropping
> > below DEF_PRIORITY - 2 is gating whether laptop_mode=1 is generally
> > allowed to write. But that is from an era where direct reclaim was
> > still allowed to call ->writepage, and kswapd nowadays avoids writes
> > until it's scanned every clean page in the system. Potential changes
> > to how quick sc->may_writepage could trigger are of little concern.
> > 
> > Remove the force_scan stuff, as well as the ugly multi-pass target
> > calculation that it necessitated.
> 
> I _really_ like this, I hated the multi-pass part. One thig that I am
> worried about and changelog doesn't mention it is what we are going to
> do about small (<16MB) memcgs. On one hand they were already ignored in
> the global reclaim so this is nothing really new but maybe we want to
> preserve the behavior for the memcg reclaim at least which would reduce
> side effect of this patch which is a great cleanup otherwise. Or at
> least be explicit about this in the changelog.

<16MB groups are a legitimate concern during global reclaim, but we
have done it this way for a long time and it never seemed to have
mattered in practice.

And for limit reclaim, this should be much less of a concern. It just
means we no longer scan these groups at DEF_PRIORITY and will have to
increase the scan window. I don't see a problem with that. And that
consequence of higher priorities is right in the patch subject.

> Btw. why cannot we simply force scan at least SWAP_CLUSTER_MAX
> unconditionally?
> 
> > +		/*
> > +		 * If the cgroup's already been deleted, make sure to
> > +		 * scrape out the remaining cache.
> 		   Also make sure that small memcgs will not get
> 		   unnoticed during the memcg reclaim
> 
> > +		 */
> > +		if (!scan && !mem_cgroup_online(memcg))
> 
> 		if (!scan && (!mem_cgroup_online(memcg) || !global_reclaim(sc)))

With this I'd be worried about regressing the setups pointed out in
6f04f48dc9c0 ("mm: only force scan in reclaim when none of the LRUs
are big enough.").

Granted, that patch is a little dubious. IMO, we should be steering
the LRU balance through references and, in that case in particular,
with swappiness. Using the default 60 for zswap is too low.

Plus, I would expect the refault detection code that was introduced
around the same time as this patch to counter-act the hot file
thrashing that is mentioned in that patch's changelog.

Nevertheless, it seems a bit gratuitous to go against that change so
directly when global reclaim hasn't historically been a problem with
groups <16MB. Limit reclaim should be fine too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
