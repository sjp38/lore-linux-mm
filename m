Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 622606B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 10:47:25 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id u190so77880847pfb.3
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 07:47:25 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0115.outbound.protection.outlook.com. [157.55.234.115])
        by mx.google.com with ESMTPS id u27si5570080pfi.159.2016.03.16.07.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 16 Mar 2016 07:47:24 -0700 (PDT)
Date: Wed, 16 Mar 2016 17:47:14 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160316144713.GB18142@esperanza>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
 <20160311083440.GI1946@esperanza>
 <20160316054157.GB11006@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160316054157.GB11006@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Mar 15, 2016 at 10:41:57PM -0700, Johannes Weiner wrote:
> On Fri, Mar 11, 2016 at 11:34:40AM +0300, Vladimir Davydov wrote:
> > On Thu, Mar 10, 2016 at 03:50:13PM -0500, Johannes Weiner wrote:
> > > When setting memory.high below usage, nothing happens until the next
> > > charge comes along, and then it will only reclaim its own charge and
> > > not the now potentially huge excess of the new memory.high. This can
> > > cause groups to stay in excess of their memory.high indefinitely.
> > > 
> > > To fix that, when shrinking memory.high, kick off a reclaim cycle that
> > > goes after the delta.
> > 
> > I agree that we should reclaim the high excess, but I don't think it's a
> > good idea to do it synchronously. Currently, memory.low and memory.high
> > knobs can be easily used by a single-threaded load manager implemented
> > in userspace, because it doesn't need to care about potential stalls
> > caused by writes to these files. After this change it might happen that
> > a write to memory.high would take long, seconds perhaps, so in order to
> > react quickly to changes in other cgroups, a load manager would have to
> > spawn a thread per each write to memory.high, which would complicate its
> > implementation significantly.
> 
> While I do expect memory.high to be adjusted every once in a while, I
> can't see anybody doing it by a significant fraction of the cgroup
> every couple of seconds - or tighter than the workingset; and dropping
> use-once cache is cheap. What kind of usecase would that be?

I agree that a load manager won't need to adjust memory.high by a
significant amount often, but there can be a lot of containers running,
so even if it takes 10 ms to adjust memory.high for one container, it
will take up to a second for 100 containers. I expect that a load
manager implementation will just blindly spawn a thread per each
memory.high update to be sure it won't be stalled for too long.

> 
> But even if we're wrong about it and this becomes a scalability issue,
> the knob - even when reclaiming synchroneously - makes no guarantees
> about the target being met once the write finishes. It's a best effort
> mechanism. What would break if we made it async later on?

You're right of course - we wouldn't be able to change async to sync,
but not the other way round. However, I'm afraid that by making it sync
from the very beginning we effectively enforce userspace applications
that need to update memory.{low,high} often to use multi-threading. Not
sure if it's that bad though.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
