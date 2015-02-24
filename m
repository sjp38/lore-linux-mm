Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5B48A6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:03:14 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so36024254pdb.11
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:03:14 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id dn8si7068880pdb.92.2015.02.24.13.03.10
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 13:03:11 -0800 (PST)
Date: Wed, 25 Feb 2015 08:02:44 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150224210244.GA13666@dastard>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
 <20150216154201.GA27295@phnom.home.cmpxchg.org>
 <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1502231347510.21127@chino.kir.corp.google.com>
 <201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
 <20150224152033.GA3782@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224152033.GA3782@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

On Tue, Feb 24, 2015 at 10:20:33AM -0500, Theodore Ts'o wrote:
> On Tue, Feb 24, 2015 at 08:20:11PM +0900, Tetsuo Handa wrote:
> > > In a timeout based solution, this would be detected and another thread 
> > > would be chosen for oom kill.  There's currently no way for the oom killer 
> > > to select a process that isn't waiting for that same mutex, however.  If 
> > > it does, then the process has been killed needlessly since it cannot make 
> > > forward progress itself without grabbing the mutex.
> > 
> > Right. The OOM killer cannot understand that there is such lock dependency....
> 
> > The memory reserves are something like a balloon. To guarantee forward
> > progress, the balloon must not become empty. All memory managing techniques
> > except the OOM killer are trying to control "deflator of the balloon" via
> > various throttling heuristics. On the other hand, the OOM killer is the only
> > memory managing technique which is trying to control "inflator of the balloon"
> > via several throttling heuristics.....
> 
> The mm developers have suggested in the past whether we could solve
> problems by preallocating memory in advance.  Sometimes this is very
> hard to do because we don't know exactly how much or if we need
> memory, or in order to do this, we would need to completely
> restructure the code because the memory allocation is happening deep
> in the call stack, potentially in some other subsystem.
> 
> So I wonder if we can solve the problem by having a subsystem
> reserving memory in advance of taking the mutexes.  We do something
> like this in ext3/ext4 --- when we allocate a (sub-)transaction
> handle, we give a worst case estimate of how many blocks we might need
> to dirty under that handle, and if there isn't enough space in the
> journal, we block in the start_handle() call while the current
> transaction is closed, and the transaction handle will be attached to
> the next transaction.

This exact discussion is already underway.

My initial proposal:

http://oss.sgi.com/archives/xfs/2015-02/msg00314.html

Why mempools don't work but transaction based reservations will:

http://oss.sgi.com/archives/xfs/2015-02/msg00339.html

Reservation needs to be an accounting mechanisms, not preallocation:

http://oss.sgi.com/archives/xfs/2015-02/msg00456.html
http://oss.sgi.com/archives/xfs/2015-02/msg00457.html
http://oss.sgi.com/archives/xfs/2015-02/msg00458.html

And that's where the discussion currently sits.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
