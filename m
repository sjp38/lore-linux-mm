Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id E35156B0039
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 15:50:13 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so4919158yho.24
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 12:50:13 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id g65si16524018yhc.5.2013.12.17.12.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 12:50:12 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so4992611yha.12
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 12:50:12 -0800 (PST)
Date: Tue, 17 Dec 2013 12:50:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131217162342.GG28991@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com>
References: <20131204111318.GE8410@dhcp22.suse.cz> <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com> <20131209124840.GC3597@dhcp22.suse.cz> <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com> <20131210103827.GB20242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com> <20131211095549.GA18741@dhcp22.suse.cz> <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com> <20131212103159.GB2630@dhcp22.suse.cz> <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
 <20131217162342.GG28991@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 17 Dec 2013, Michal Hocko wrote:

> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index c72b03bf9679..fee25c5934d2 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2692,7 +2693,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  	 * MEMDIE process.
> > >  	 */
> > >  	if (unlikely(test_thread_flag(TIF_MEMDIE)
> > > -		     || fatal_signal_pending(current)))
> > > +		     || fatal_signal_pending(current))
> > > +		     || current->flags & PF_EXITING)
> > >  		goto bypass;
> > >  
> > >  	if (unlikely(task_in_memcg_oom(current)))
> > > 
> > > rather than the later checks down the oom_synchronize paths. The comment
> > > already mentions dying process...
> > > 
> > 
> > This is scary because it doesn't even try to reclaim memcg memory before 
> > allowing the allocation to succeed.
> 
> Why should it reclaim in the first place when it simply is on the way to
> release memory. In other words why should it increase the memory
> pressure when it is in fact releasing it?
> 

(Answering about removing the fatal_signal_pending() check as well here.)

For memory isolation, we'd only want to bypass memcg charges when 
absolutely necessary and it seems like TIF_MEMDIE is the only case where 
that's required.  We don't give processes with pending SIGKILLs or those 
in the exit() path access to memory reserves in the page allocator without 
first determining that reclaim can't make any progress for the same reason 
and then we only do so by setting TIF_MEMDIE when calling the oom killer.  

> I am really puzzled here. On one hand you are strongly arguing for not
> notifying when we know we can prevent from OOM action and on the other
> hand you are ok to get vmpressure/thresholds notification when an
> exiting task triggers reclaim.
> 
> So I am really lost in what you are trying to achieve here. It sounds a
> bit arbirtrary.
> 

It's not arbitrary to define when memcg bypass is allowed and, in my 
opinion, it should only be done in situations where it is unavoidable and 
therefore breaking memory isolation is required.

(We wouldn't expect a 128MB memcg to be oom [and perhaps with a userspace 
oom handler attached] when it has 100 children each 1MB in size just 
because they all happen to be oom at the same time.  We set up the excess 
memory in the parent specifically for the memcg with the oom handler 
attached.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
