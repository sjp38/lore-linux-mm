Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 810AF828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:40:36 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so285389389wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:40:36 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id g125si2935526wmg.87.2016.01.13.01.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 01:40:35 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id l65so285388884wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:40:35 -0800 (PST)
Date: Wed, 13 Jan 2016 10:40:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 3/3] oom: Do not try to sacrifice small children
Message-ID: <20160113094034.GC28942@dhcp22.suse.cz>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
 <1452632425-20191-4-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601121646410.28831@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601121646410.28831@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Tue 12-01-16 16:51:43, David Rientjes wrote:
> On Tue, 12 Jan 2016, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 8bca0b1e97f7..b5c0021c6462 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -721,8 +721,16 @@ try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
> >  	if (!child_victim)
> >  		goto out;
> >  
> > -	put_task_struct(victim);
> > -	victim = child_victim;
> > +	/*
> > +	 * Protecting the parent makes sense only if killing the child
> > +	 * would release at least some memory (at least 1MB).
> > +	 */
> > +	if (K(victim_points) >= 1024) {
> > +		put_task_struct(victim);
> > +		victim = child_victim;
> > +	} else {
> > +		put_task_struct(child_victim);
> > +	}
> >  
> >  out:
> >  	return victim;
> 
> The purpose of sacrificing a child has always been to prevent a process 
> that has been running with a substantial amount of work done from being 
> terminated and losing all that work if it can be avoided.  This happens a 
> lot: imagine a long-living front end client forking a child which simply 
> collects stats and malloc information at a regular intervals and writes 
> them out to disk or over the network.  These processes may be quite small, 
> and we're willing to happily sacrifice them if it will save the parent.  
> This was, and still is, the intent of the sacrifice in the first place.

Yes I understand the intention of the heuristic. I am just contemplating
about what is way too small to sacrifice because it clearly doesn't make
much sense to kill a task which is sitting on basically no memory (well
just few pages backing page tables and stack) because this would just
prolong the OOM agony.

> We must be able to deal with oom victims that are very small, since 
> userspace has complete control in prioritizing these processes in the 
> first place.

Sure the patch is not great but I would like to come up with some
threshold when children are way too small to be worthwhile considering.
Or maybe there is other measure we can use.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
