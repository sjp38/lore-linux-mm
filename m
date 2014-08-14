Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id BE3136B0072
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 12:12:47 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id b17so1351193lan.39
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 09:12:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c2si8709165lac.0.2014.08.14.09.12.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 09:12:46 -0700 (PDT)
Date: Thu, 14 Aug 2014 18:12:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/4] mm: memcontrol: reduce reclaim invocations for
 higher order requests
Message-ID: <20140814161244.GC19405@dhcp22.suse.cz>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-2-git-send-email-hannes@cmpxchg.org>
 <20140807130822.GB12730@dhcp22.suse.cz>
 <20140807153141.GD14734@cmpxchg.org>
 <20140808123258.GK4004@dhcp22.suse.cz>
 <20140808132635.GJ14734@cmpxchg.org>
 <20140813145904.GC2775@dhcp22.suse.cz>
 <20140813204134.GA20932@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140813204134.GA20932@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 13-08-14 16:41:34, Johannes Weiner wrote:
> On Wed, Aug 13, 2014 at 04:59:04PM +0200, Michal Hocko wrote:
[...]
> > I think this shows up that my concern about excessive reclaim and stalls
> > is real and it is worse when the memory is used sparsely. It is true it
> > might help when the whole THP section is used and so the additional cost
> > is amortized but the more sparsely each THP section is used the higher
> > overhead you are adding without userspace actually asking for it.
> 
> THP is expected to have some overhead in terms of initial fault cost

yes, but that overhead should be as small as possible. Direct reclaim
with such a big target will lead to all types of problems.

> and space efficiency, don't use it when you get little to no benefit
> from it. 

Do you really expect that all such users will use MADV_NOHUGEPAGE just
to prevent from reclaim stalls? This sounds unrealistic to me. Instead
we will end up with THP disabled globally. The same way we have seen it
when THP has been introduced and caused all kinds of reclaim issues.

> It can be argued that my patch moves that breakeven point a
> little bit, but the THP-positive end of the spectrum is much better
> off: THP coverage goes from 37% to 100%, while reclaim efficiency is
> significantly improved and system time significantly reduced.

I didn't see significantly improved reclaim efficiency the only
difference was that the reclaim happen less times.
The system time is reduced but the elapsed time is less than 1% improved
in the per-page walk but more than 3 times worse for the other extreme.

> You demonstrated a THP-workload that really benefits from my change,
> and another workload that shouldn't be using THP in the first place.

I do not think that the presented test case is appropriate for any
reclaim decision evaluation. Linear used-once walker usually benefits
from excessive reclaim in general.
The only point I wanted to raise is that the numbers look much worse
when the memory is used sparsely and thponly is the obvious worst case.

So if you want to increase THP charge success rate then back it by real
numbers from real loads and prove that the potential regressions are
unlikely and biased by the overall improvements. Until then NACK to this
patch from me. The change is too risky.

Besides that I do believe that you do not need this change for the high
limit as it can fail the charge for excessive THP charges same like the
hard limit. So you do not have the high limit escape problem.
As mentioned in other email, reclaiming the whole high limit excess as a
target is even more risky because heavy parallel load on many CPUs can
cause large excess and direct reclaim much more than 512 pages.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
