Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 860B06B0098
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 17:16:10 -0500 (EST)
Received: by wesq59 with SMTP id q59so26645457wes.1
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 14:16:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lf5si191850wjb.111.2015.02.28.14.16.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Feb 2015 14:16:08 -0800 (PST)
Date: Sat, 28 Feb 2015 17:15:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150228221558.GA23028@phnom.home.cmpxchg.org>
References: <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150228162943.GA17989@phnom.home.cmpxchg.org>
 <20150228164158.GE5404@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150228164158.GE5404@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sat, Feb 28, 2015 at 11:41:58AM -0500, Theodore Ts'o wrote:
> On Sat, Feb 28, 2015 at 11:29:43AM -0500, Johannes Weiner wrote:
> > 
> > I'm trying to figure out if the current nofail allocators can get
> > their memory needs figured out beforehand.  And reliably so - what
> > good are estimates that are right 90% of the time, when failing the
> > allocation means corrupting user data?  What is the contingency plan?
> 
> In the ideal world, we can figure out the exact memory needs
> beforehand.  But we live in an imperfect world, and given that block
> devices *also* need memory, the answer is "of course not".  We can't
> be perfect.  But we can least give some kind of hint, and we can offer
> to wait before we get into a situation where we need to loop in
> GFP_NOWAIT --- which is the contingency/fallback plan.

Overestimating should be fine, the result would a bit of false memory
pressure.  But underestimating and looping can't be an option or the
original lockups will still be there.  We need to guarantee forward
progress or the problem is somewhat mitigated at best - only now with
quite a bit more complexity in the allocator and the filesystems.

The block code would have to be looked at separately, but doesn't it
already use mempools etc. to guarantee progress?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
