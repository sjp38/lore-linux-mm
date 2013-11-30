Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB286B0035
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 05:32:47 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so7264615yha.23
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 02:32:47 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id e33si32656433yhq.243.2013.11.30.02.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Nov 2013 02:32:46 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so7242373yha.26
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 02:32:46 -0800 (PST)
Date: Sat, 30 Nov 2013 02:32:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131130033536.GL22729@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311300226070.29602@chino.kir.corp.google.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org> <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com> <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com> <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com> <20131128031313.GK3556@cmpxchg.org> <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com> <20131128035218.GM3556@cmpxchg.org> <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
 <20131130033536.GL22729@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 29 Nov 2013, Johannes Weiner wrote:

> > You said you have informed stable to not merge these patches until further 
> > notice, I'd suggest simply avoid ever merging the whole series into a 
> > stable kernel since the problem isn't serious enough.  Marking changes 
> > that do "goto nomem" seem fine to mark for stable, though.
> 
> These are followup fixes for the series that is upstream but didn't go
> to stable.  I truly have no idea what you are talking about.
> 

I'm responding to your comments[*] that indicate you were going to 
eventually be sending it to stable.

> > On the scale that we run memcg, we would see it daily in automated testing 
> > primarily because we panic the machine for memcg oom conditions where 
> > there are no killable processes.  It would typically manifest by two 
> > processes that are allocating memory in a memcg; one is oom killed, is 
> > allowed to allocate, handles its SIGKILL, exits and frees its memory and 
> > the second process which is oom disabled races with the uncharge and is 
> > oom disabled so the machine panics.
> 
> So why don't you implement proper synchronization instead of putting
> these random checks all over the map to make the race window just
> small enough to not matter most of the time?
> 

The oom killer can be quite expensive, so we have found that is 
advantageous after doing all that work that the memcg is still oom for 
the charge order before needlessly killing a process.  I am not suggesting 
that we add synchronization to the uncharge path for such a race, but 
merely a simple check as illustrated as due diligence.  I think a simple 
conditional in the oom killer to avoid needlessly killing a user job is 
beneficial and avoids questions from customers who have a kernel log 
showing an oom kill occurring in a memcg that is not oom.  We could even 
do the check in oom_kill_process() after dump_header() if you want to 
reduce any chance of that to avoid getting bug reports about such cases.

> If you are really bothered by this race, then please have OOM kill
> invocations wait for any outstanding TIF_MEMDIE tasks in the same
> context.
> 

The oom killer requires a tasklist scan, or an iteration over the set of 
processes attached to the memcg for the memcg case, to find a victim.  It 
already defers if it finds eligible threads with TIF_MEMDIE set.

Thanks.

[*] http://marc.info/?l=linux-mm&m=138559524422298
    http://marc.info/?l=linux-kernel&m=138539243412073

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
