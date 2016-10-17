Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EEE56B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:16:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so201649167pfa.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:16:45 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id ul9si26433538pab.38.2016.10.17.10.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 10:16:44 -0700 (PDT)
Date: Mon, 17 Oct 2016 10:16:20 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] vmscan: set correct defer count for shrinker
Message-ID: <20161017171619.GA28818@shli-mbp.local>
References: <2414be961b5d25892060315fbb56bb19d81d0c07.1476227351.git.shli@fb.com>
 <20161013065327.GE21678@dhcp22.suse.cz>
 <20161015204812.GB2241@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161015204812.GB2241@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Oct 15, 2016 at 11:48:13PM +0300, Vladimir Davydov wrote:
> On Thu, Oct 13, 2016 at 08:53:28AM +0200, Michal Hocko wrote:
> > On Wed 12-10-16 09:09:49, Shaohua Li wrote:
> > > Our system uses significantly more slab memory with memcg enabled with
> > > latest kernel. With 3.10 kernel, slab uses 2G memory, while with 4.6
> > > kernel, 6G memory is used. Looks the shrinker has problem. Let's see we
> > > have two memcg for one shrinker. In do_shrink_slab:
> > > 
> > > 1. Check cg1. nr_deferred = 0, assume total_scan = 700. batch size is 1024,
> > > then no memory is freed. nr_deferred = 700
> > > 2. Check cg2. nr_deferred = 700. Assume freeable = 20, then total_scan = 10
> > > or 40. Let's assume it's 10. No memory is freed. nr_deferred = 10.
> > > 
> > > The deferred share of cg1 is lost in this case. kswapd will free no
> > > memory even run above steps again and again.
> 
> I agree this is possible. IMO the ideal way to fix this problem would be
> making deferred counters per memory cgroup. That would also resolve
> possible fairness issues when objects deferred by one cgroup are
> reclaimed from another. However, it's unclear to me how to implement it
> w/o bringing in a lot of awkward code. So I guess your patch is
> reasonable for now. Apart from a couple nitpicks (below), it looks good
> to me:
> 
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> 
> > > @@ -312,7 +313,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > >  		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
> > >  		       shrinker->scan_objects, total_scan);
> > >  		total_scan = freeable;
> > > -	}
> > > +		next_deferred = nr;
> > > +	} else
> > > +		next_deferred = total_scan;
> 
> nitpick: Why do we want to handle this what-the-heck-is-going-on case in
> a special way? Why not just always assign total_scan to next_deferred
> here? I don't see how it could make things worse when total_scan gets
> screwed up.

I have no idea when this special case will hapen. I'd like to make it
conservative. Somebody knowing this code probably could help clean up.
 
> > >  
> > >  	/*
> > >  	 * We need to avoid excessive windup on filesystem shrinkers
> > > @@ -369,17 +372,22 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > >  
> > >  		count_vm_events(SLABS_SCANNED, nr_to_scan);
> > >  		total_scan -= nr_to_scan;
> > > +		scanned += nr_to_scan;
> 
> nitpick: We could get along w/o 'scanned' here:
> 
>                 next_deferred -= nr_to_scan;

In that special case the next_deferred could be smaller than total_scan. That
said, if we don't have the special case, your suggestion is good. I'm totally
open here.

> > >  
> > >  		cond_resched();
> > >  	}
> > >  
> > > +	if (next_deferred >= scanned)
> > > +		next_deferred -= scanned;
> > > +	else
> > > +		next_deferred = 0;
> 
> ... and this chunk wouldn't be needed then.

Ditto.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
