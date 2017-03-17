Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7A66B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:45:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u9so4947932wme.6
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:45:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si12220387wrj.37.2017.03.17.11.45.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 11:45:31 -0700 (PDT)
Date: Fri, 17 Mar 2017 19:45:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
Message-ID: <20170317184527.GC23957@dhcp22.suse.cz>
References: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
 <20170317183928.GA12281@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317183928.GA12281@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

On Fri 17-03-17 14:39:28, Johannes Weiner wrote:
> On Wed, Mar 15, 2017 at 07:36:48PM +0800, Yisheng Xie wrote:
> > @@ -100,6 +100,9 @@ struct scan_control {
> >  	/* Can cgroups be reclaimed below their normal consumption range? */
> >  	unsigned int may_thrash:1;
> >  
> > +	/* Did we have any memcg protected by the low limit */
> > +	unsigned int memcg_low_protection:1;
> 
> These are both bad names. How about the following pair?
> 
> 	/*
> 	 * Cgroups are not reclaimed below their configured memory.low,
> 	 * unless we threaten to OOM. If any cgroups are skipped due to
> 	 * memory.low and nothing was reclaimed, go back for memory.low.
> 	 */
> 	unsigned int memcg_low_skipped:1
> 	unsigned int memcg_low_reclaim:1;

yes this is much better

> 
> > @@ -2557,6 +2560,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >  			unsigned long scanned;
> >  
> >  			if (mem_cgroup_low(root, memcg)) {
> > +				sc->memcg_low_protection = 1;
> > +
> >  				if (!sc->may_thrash)
> >  					continue;
> 
> 				if (!sc->memcg_low_reclaim) {
> 					sc->memcg_low_skipped = 1;
> 					continue;
> 				}
> 
> >  				mem_cgroup_events(memcg, MEMCG_LOW, 1);
> > @@ -2808,7 +2813,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> >  		return 1;
> >  
> >  	/* Untapped cgroup reserves?  Don't OOM, retry. */
> > -	if (!sc->may_thrash) {
> > +	if (sc->memcg_low_protection && !sc->may_thrash) {
> 
> 	if (sc->memcg_low_skipped) {
> 		[...]
> 		sc->memcg_low_reclaim = 1;

you need to set memcg_low_skipped = 0 here, right? Otherwise we do not
have break out of the loop. Or am I missing something?

> 		goto retry;
> 	}

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
