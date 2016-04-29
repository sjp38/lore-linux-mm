Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE9096B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:28:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so14571435wmw.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:28:37 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id m6si16351431wjz.36.2016.04.29.02.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 02:28:36 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id a17so26306267wme.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:28:36 -0700 (PDT)
Date: Fri, 29 Apr 2016 11:28:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/14] mm: use compaction feedback for thp backoff
 conditions
Message-ID: <20160429092835.GD21977@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-10-git-send-email-mhocko@kernel.org>
 <5721CF7E.9020106@suse.cz>
 <20160428123545.GG31489@dhcp22.suse.cz>
 <5723267C.1050903@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5723267C.1050903@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On Fri 29-04-16 11:16:44, Vlastimil Babka wrote:
> On 04/28/2016 02:35 PM, Michal Hocko wrote:
[...]
> >My main point was to simplify the code and get rid of as much compaction
> >specific hacks as possible. We might very well drop this later on but it
> >would be at least less code to grasp through. I do not have any problem
> >with dropping this but I think this shouldn't collide with other patches
> >much so reducing the number of lines is worth it.

Good point, I have completely missed this part.

> I just realized it also affects khugepaged, and not just THP page faults, so
> it may potentially cripple THP's completely. My main issue is that the
> reasons to bail out includes COMPACT_SKIPPED, and for a wrong reason (see
> the comment above). It also goes against the comment below the noretry
> label:
> 
>  * High-order allocations do not necessarily loop after direct reclaim
>  * and reclaim/compaction depends on compaction being called after
>  * reclaim so call directly if necessary.
> 
> Given that THP's are large, I expect reclaim would indeed be quite often
> necessary before compaction, and the first optimistic async compaction
> attempt will just return SKIPPED. After this patch, there will be no more
> reclaim/compaction attempts for THP's, including khugepaged. And given the
> change of THP page fault defaults, even crippling that path should no longer
> be necessary.
> 
> So I would just drop this for now indeed.

Agreed, thanks for catching this. Andrew, could you drop this patch
please? It was supposed to be a mere clean up without any effect on the
oom detection.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
