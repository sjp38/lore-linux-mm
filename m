Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1916B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 16:48:23 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b81so79145794lfe.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 13:48:23 -0700 (PDT)
Received: from smtp50.i.mail.ru (smtp50.i.mail.ru. [94.100.177.110])
        by mx.google.com with ESMTPS id 75si14400620lfq.347.2016.10.15.13.48.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 15 Oct 2016 13:48:21 -0700 (PDT)
Date: Sat, 15 Oct 2016 23:48:13 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH] vmscan: set correct defer count for shrinker
Message-ID: <20161015204812.GB2241@esperanza>
References: <2414be961b5d25892060315fbb56bb19d81d0c07.1476227351.git.shli@fb.com>
 <20161013065327.GE21678@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013065327.GE21678@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 13, 2016 at 08:53:28AM +0200, Michal Hocko wrote:
> On Wed 12-10-16 09:09:49, Shaohua Li wrote:
> > Our system uses significantly more slab memory with memcg enabled with
> > latest kernel. With 3.10 kernel, slab uses 2G memory, while with 4.6
> > kernel, 6G memory is used. Looks the shrinker has problem. Let's see we
> > have two memcg for one shrinker. In do_shrink_slab:
> > 
> > 1. Check cg1. nr_deferred = 0, assume total_scan = 700. batch size is 1024,
> > then no memory is freed. nr_deferred = 700
> > 2. Check cg2. nr_deferred = 700. Assume freeable = 20, then total_scan = 10
> > or 40. Let's assume it's 10. No memory is freed. nr_deferred = 10.
> > 
> > The deferred share of cg1 is lost in this case. kswapd will free no
> > memory even run above steps again and again.

I agree this is possible. IMO the ideal way to fix this problem would be
making deferred counters per memory cgroup. That would also resolve
possible fairness issues when objects deferred by one cgroup are
reclaimed from another. However, it's unclear to me how to implement it
w/o bringing in a lot of awkward code. So I guess your patch is
reasonable for now. Apart from a couple nitpicks (below), it looks good
to me:

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

> > @@ -312,7 +313,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> >  		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
> >  		       shrinker->scan_objects, total_scan);
> >  		total_scan = freeable;
> > -	}
> > +		next_deferred = nr;
> > +	} else
> > +		next_deferred = total_scan;

nitpick: Why do we want to handle this what-the-heck-is-going-on case in
a special way? Why not just always assign total_scan to next_deferred
here? I don't see how it could make things worse when total_scan gets
screwed up.

> >  
> >  	/*
> >  	 * We need to avoid excessive windup on filesystem shrinkers
> > @@ -369,17 +372,22 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> >  
> >  		count_vm_events(SLABS_SCANNED, nr_to_scan);
> >  		total_scan -= nr_to_scan;
> > +		scanned += nr_to_scan;

nitpick: We could get along w/o 'scanned' here:

                next_deferred -= nr_to_scan;

> >  
> >  		cond_resched();
> >  	}
> >  
> > +	if (next_deferred >= scanned)
> > +		next_deferred -= scanned;
> > +	else
> > +		next_deferred = 0;

... and this chunk wouldn't be needed then.

> >  	/*
> >  	 * move the unused scan count back into the shrinker in a
> >  	 * manner that handles concurrent updates. If we exhausted the
> >  	 * scan, there is no need to do an update.
> >  	 */
> > -	if (total_scan > 0)
> > -		new_nr = atomic_long_add_return(total_scan,
> > +	if (next_deferred > 0)
> > +		new_nr = atomic_long_add_return(next_deferred,
> >  						&shrinker->nr_deferred[nid]);
> >  	else
> >  		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
