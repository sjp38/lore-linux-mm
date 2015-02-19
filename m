Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 07AB96B0032
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 16:44:14 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so2736327pdb.4
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 13:44:13 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id zp4si3308752pac.23.2015.02.19.13.44.11
        for <linux-mm@kvack.org>;
        Thu, 19 Feb 2015 13:44:12 -0800 (PST)
Date: Fri, 20 Feb 2015 08:43:56 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150219214356.GW12722@dastard>
References: <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150218082502.GA4478@dhcp22.suse.cz>
 <20150218104859.GM12722@dastard>
 <20150218121602.GC4478@dhcp22.suse.cz>
 <20150219110124.GC15569@phnom.home.cmpxchg.org>
 <20150219122914.GH28427@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150219122914.GH28427@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Thu, Feb 19, 2015 at 01:29:14PM +0100, Michal Hocko wrote:
> On Thu 19-02-15 06:01:24, Johannes Weiner wrote:
> [...]
> > Preferrably, we'd get rid of all nofail allocations and replace them
> > with preallocated reserves.  But this is not going to happen anytime
> > soon, so what other option do we have than resolving this on the OOM
> > killer side?
> 
> As I've mentioned in other email, we might give GFP_NOFAIL allocator
> access to memory reserves (by giving it __GFP_HIGH).

Won't work when you have thousands of concurrent transactions
running in XFS and they are all doing GFP_NOFAIL allocations. That's
why I suggested the per-transaction reserve pool - we can use that
to throttle the number of concurent contexts demanding memory for
forwards progress, just the same was we throttle the number of
concurrent processes based on maximum log space requirements of the
transactions and the amount of unreserved log space available.

No log space, transaction reservations waits on an ordered queue for
space to become available. No memory available, transaction
reservation waits on an ordered queue for memory to become
available.

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
