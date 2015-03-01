Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 570566B0038
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 15:44:23 -0500 (EST)
Received: by widem10 with SMTP id em10so10102070wid.0
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 12:44:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bq15si15331542wib.47.2015.03.01.12.44.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Mar 2015 12:44:21 -0800 (PST)
Date: Sun, 1 Mar 2015 15:44:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150301204412.GA8497@phnom.home.cmpxchg.org>
References: <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150228162943.GA17989@phnom.home.cmpxchg.org>
 <20150228164158.GE5404@thunk.org>
 <20150228221558.GA23028@phnom.home.cmpxchg.org>
 <20150301134322.GA3287@thunk.org>
 <20150301161506.GA1854@phnom.home.cmpxchg.org>
 <20150301193635.GB3287@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150301193635.GB3287@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sun, Mar 01, 2015 at 02:36:35PM -0500, Theodore Ts'o wrote:
> On Sun, Mar 01, 2015 at 11:15:06AM -0500, Johannes Weiner wrote:
> > 
> > We had these lockups in cgroups with just a handful of threads, which
> > all got stuck in the allocator and there was nobody left to volunteer
> > unreclaimable memory.  When this was being addressed, we knew that the
> > same can theoretically happen on the system-level but weren't aware of
> > any reports.  Well now, here we are.
> 
> I think the "few threads in a small" cgroup problem is a little
> difference, because in those cases very often the global system has
> enough memory, and there is always the possibility that we might relax
> the memory cgroup guarantees a little in order to allow forward
> progress.

That's exactly how we fixed it.  __GFP_NOFAIL are allowed to simply
bypass the cgroup memory limits when reclaim within the group fails to
make room for the allocation.  I'm just mentioning that because the
global case doesn't have the same out, but is susceptible to the same
deadlock situation when there are no other threads volunteering pages.

If your machines are loaded with hundreds or thousands of threads, the
chances that a thread stuck in the allocator will be bailed out by the
other threads in the system is likely (or that you run into CPU limits
first), but if you have only a handful of memory-intensive tasks, this
might not be the case.  The cgroup problem was closer to that second
scenario, where few threads split all available memory between them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
