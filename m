Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B3A116B0038
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:23:44 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so6163138wgg.28
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:23:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si30258eep.43.2013.12.17.08.23.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 08:23:43 -0800 (PST)
Date: Tue, 17 Dec 2013 17:23:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131217162342.GG28991@dhcp22.suse.cz>
References: <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
 <20131209124840.GC3597@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
 <20131210103827.GB20242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
 <20131211095549.GA18741@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
 <20131212103159.GB2630@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 13-12-13 15:55:44, David Rientjes wrote:
> On Thu, 12 Dec 2013, Michal Hocko wrote:
[...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c72b03bf9679..fee25c5934d2 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2692,7 +2693,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  	 * MEMDIE process.
> >  	 */
> >  	if (unlikely(test_thread_flag(TIF_MEMDIE)
> > -		     || fatal_signal_pending(current)))
> > +		     || fatal_signal_pending(current))
> > +		     || current->flags & PF_EXITING)
> >  		goto bypass;
> >  
> >  	if (unlikely(task_in_memcg_oom(current)))
> > 
> > rather than the later checks down the oom_synchronize paths. The comment
> > already mentions dying process...
> > 
> 
> This is scary because it doesn't even try to reclaim memcg memory before 
> allowing the allocation to succeed.

Why should it reclaim in the first place when it simply is on the way to
release memory. In other words why should it increase the memory
pressure when it is in fact releasing it?

I am really puzzled here. On one hand you are strongly arguing for not
notifying when we know we can prevent from OOM action and on the other
hand you are ok to get vmpressure/thresholds notification when an
exiting task triggers reclaim.

So I am really lost in what you are trying to achieve here. It sounds a
bit arbirtrary.

> I think we could even argue that we should move the
> fatal_signal_pending(current) check to later and the only condition we
> should really be bypassing here is TIF_MEMDIE since it will only get
> set when reclaim has already failed.

Any arguments?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
