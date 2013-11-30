Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 10CFD6B0035
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 10:55:51 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so4678253bkz.19
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 07:55:51 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id j3si16849119bki.133.2013.11.30.07.55.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 30 Nov 2013 07:55:50 -0800 (PST)
Date: Sat, 30 Nov 2013 10:55:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131130155542.GO3556@cmpxchg.org>
References: <20131127233353.GH3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com>
 <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com>
 <20131128031313.GK3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com>
 <20131128035218.GM3556@cmpxchg.org>
 <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
 <20131130033536.GL22729@cmpxchg.org>
 <alpine.DEB.2.02.1311300226070.29602@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311300226070.29602@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Nov 30, 2013 at 02:32:43AM -0800, David Rientjes wrote:
> On Fri, 29 Nov 2013, Johannes Weiner wrote:
> 
> > > You said you have informed stable to not merge these patches until further 
> > > notice, I'd suggest simply avoid ever merging the whole series into a 
> > > stable kernel since the problem isn't serious enough.  Marking changes 
> > > that do "goto nomem" seem fine to mark for stable, though.
> > 
> > These are followup fixes for the series that is upstream but didn't go
> > to stable.  I truly have no idea what you are talking about.
> > 
> 
> I'm responding to your comments[*] that indicate you were going to 
> eventually be sending it to stable.
> 
> > > On the scale that we run memcg, we would see it daily in automated testing 
> > > primarily because we panic the machine for memcg oom conditions where 
> > > there are no killable processes.  It would typically manifest by two 
> > > processes that are allocating memory in a memcg; one is oom killed, is 
> > > allowed to allocate, handles its SIGKILL, exits and frees its memory and 
> > > the second process which is oom disabled races with the uncharge and is 
> > > oom disabled so the machine panics.
> > 
> > So why don't you implement proper synchronization instead of putting
> > these random checks all over the map to make the race window just
> > small enough to not matter most of the time?
> > 
> 
> The oom killer can be quite expensive, so we have found that is 
> advantageous after doing all that work that the memcg is still oom for 
> the charge order before needlessly killing a process.  I am not suggesting 
> that we add synchronization to the uncharge path for such a race, but 
> merely a simple check as illustrated as due diligence.  I think a simple 
> conditional in the oom killer to avoid needlessly killing a user job is 
> beneficial and avoids questions from customers who have a kernel log 
> showing an oom kill occurring in a memcg that is not oom.  We could even 
> do the check in oom_kill_process() after dump_header() if you want to 
> reduce any chance of that to avoid getting bug reports about such cases.

I asked about quantified data of this last-minute check, you replied
with a race condition between an OOM kill victim and a subsequent OOM
kill invocation.

> > If you are really bothered by this race, then please have OOM kill
> > invocations wait for any outstanding TIF_MEMDIE tasks in the same
> > context.
> > 
> 
> The oom killer requires a tasklist scan, or an iteration over the set of 
> processes attached to the memcg for the memcg case, to find a victim.  It 
> already defers if it finds eligible threads with TIF_MEMDIE set.

And now you say that this race does not really exist and repeat the
same ramblings about last-minute checks to avoid unnecessary kills
again.  And again without any supporting data that I already asked
for.

The more I talk to you, the less sense this all makes.  Why do you
insist we merge this patch when you have apparently no idea why and
how it works, and can't demonstrate that it works in the first place?

I only followed you around in circles because I'm afraid that my
shutting up would be interpreted as agreement again and Andrew would
merge this anyway.  But this is unsustainable, the burden of proof
should be on you, not me.  I'm going to stop replying until you
provide the information I asked for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
