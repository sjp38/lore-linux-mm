Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 488C76B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 08:40:36 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id q58so964766wes.18
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 05:40:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg4si3333667wjb.102.2014.08.05.05.40.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 05:40:34 -0700 (PDT)
Date: Tue, 5 Aug 2014 14:40:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/4] mm: memcontrol: populate unified hierarchy interface
Message-ID: <20140805124033.GF15908@dhcp22.suse.cz>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 04-08-14 17:14:53, Johannes Weiner wrote:
> Hi,
> 
> the ongoing versioning of the cgroup user interface gives us a chance
> to clean up the memcg control interface and fix a lot of
> inconsistencies and ugliness that crept in over time.

The first patch doesn't fit into the series and should be posted
separately.

> This series adds a minimal set of control files to the new memcg
> interface to get basic memcg functionality going in unified hierarchy:

Hmm, I have posted RFC for new knobs quite some time ago and the
discussion died without some questions answered and now you are coming
with a new one. I cannot say I would be happy about that.

One of the concern was renaming knobs which represent the same
functionality as before. I have posted some concerns but haven't heard
back anything. This series doesn't give any rationale for renaming
either.
It is true we have a v2 but that doesn't necessarily mean we should put
everything upside down.

> - memory.current: a read-only file that shows current memory usage.

Even if we go with renaming existing knobs I really hate this name. The
old one was too long but this is not descriptive enough. Same applies to
max and high. I would expect at least limit in the name.

> - memory.high: a file that allows setting a high limit on the memory
>   usage.  This is an elastic limit, which is enforced via direct
>   reclaim, so allocators are throttled once it's reached, but it can
>   be exceeded and does not trigger OOM kills.  This should be a much
>   more suitable default upper boundary for the majority of use cases
>   that are better off with some elasticity than with sudden OOM kills.

I also thought you wanted to have all the new limits in the single
series. My series is sitting idle until we finally come to conclusion
which is the first set of exposed knobs. So I do not understand why are
you coming with it right now.

> - memory.max: a file that allows setting a maximum limit on memory
>   usage which is ultimately enforced by OOM killing tasks in the
>   group.  This is for setups that want strict isolation at the cost of
>   task death above a certain point.  However, even those can still
>   combine the max limit with the high limit to approach OOM situations
>   gracefully and with time to intervene.
> 
> - memory.vmstat: vmstat-style per-memcg statistics.  Very minimal for
>   now (lru stats, allocations and frees, faults), but fixing
>   fundamental issues of the old memory.stat file, including gross
>   misnomers like pgpgin/pgpgout for pages charged/uncharged etc.

I am definitely for exposing LRU stats and have a half baked patch
sitting and waiting for some polishing. So I agree with the vmstat part.
Putting it into stat file is not the greatest match so a separate file
is good here.

>  Documentation/cgroups/unified-hierarchy.txt |  18 +++
>  include/linux/res_counter.h                 |  29 +++++
>  include/linux/swap.h                        |   3 +-
>  kernel/res_counter.c                        |   3 +
>  mm/memcontrol.c                             | 177 +++++++++++++++++++++++++---
>  mm/vmscan.c                                 |   3 +-
>  6 files changed, 216 insertions(+), 17 deletions(-)
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
