Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFFE66B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 02:02:16 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so36838835wjc.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:02:16 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z84si10830823wmg.75.2016.11.30.23.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 23:02:15 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id a20so32727779wme.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:02:15 -0800 (PST)
Date: Thu, 1 Dec 2016 08:02:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 189181] New: BUG: unable to handle kernel NULL pointer
 dereference in mem_cgroup_node_nr_lru_pages
Message-ID: <20161201070213.GA18272@dhcp22.suse.cz>
References: <bug-189181-27@https.bugzilla.kernel.org/>
 <20161129145654.c48bebbd684edcd6f64a03fe@linux-foundation.org>
 <20161130170040.GJ18432@dhcp22.suse.cz>
 <20161130181653.GA30558@cmpxchg.org>
 <20161130183016.GO18432@dhcp22.suse.cz>
 <20161201022454.GB21693@mail-personal>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161201022454.GB21693@mail-personal>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek =?iso-8859-1?Q?Marczykowski-G=F3recki?= <marmarek@mimuw.edu.pl>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 01-12-16 03:24:54, Marek Marczykowski-Gorecki wrote:
> On Wed, Nov 30, 2016 at 07:30:17PM +0100, Michal Hocko wrote:
> > On Wed 30-11-16 13:16:53, Johannes Weiner wrote:
> > > Hi Michael,
> > > 
> > > On Wed, Nov 30, 2016 at 06:00:40PM +0100, Michal Hocko wrote:
> > [...]
> > > > diff --git a/mm/workingset.c b/mm/workingset.c
> > > > index 617475f529f4..0f07522c5c0e 100644
> > > > --- a/mm/workingset.c
> > > > +++ b/mm/workingset.c
> > > > @@ -348,7 +348,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> > > >  	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
> > > >  	local_irq_enable();
> > > >  
> > > > -	if (memcg_kmem_enabled()) {
> > > > +	if (memcg_kmem_enabled() && sc->memcg) {
> > > >  		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
> > > >  						     LRU_ALL_FILE);
> > > >  	} else {
> > > 
> > > If we do that, I'd remove the racy memcg_kmem_enabled() check
> > > altogether and just check for whether we have a memcg or not.
> > 
> > But that would make this a memcg aware shrinker even when kmem is not
> > enabled...
> > 
> > But now that I am looking into the code
> > shrink_slab:
> > 		if (memcg_kmem_enabled() &&
> > 		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> > 			continue;
> > 
> > this should be taken care of already. So sc->memcg should be indeed
> > sufficient. So unless I am missing something I will respin my local
> > patch and post it later after the reporter has some time to test the
> > current one.
> 
> The above patch seems to help. At least the problem haven't occurred for
> the last ~40 VM startups.

I will consider this as
Tested-by: Marek Marczykowski-Gorecki <marmarek@mimuw.edu.pl>

OK? Thanks for the report and testing!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
