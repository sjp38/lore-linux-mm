Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3CDBE6B0263
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 17:22:34 -0500 (EST)
Received: by wmec201 with SMTP id c201so47624377wme.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 14:22:33 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 6si310846wmc.49.2015.11.17.14.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 14:22:32 -0800 (PST)
Date: Tue, 17 Nov 2015 17:22:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151117222217.GA20394@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
 <20151115135457.GM31308@esperanza>
 <20151116185316.GC32544@cmpxchg.org>
 <20151117201849.GQ31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151117201849.GQ31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Nov 17, 2015 at 11:18:50PM +0300, Vladimir Davydov wrote:
> AFAIK vmpressure was designed to allow userspace to tune hard limits of
> cgroups in accordance with their demands, in which case the way how
> vmpressure notifications work makes sense.

You can still do that when the reporting happens on the reclaim level,
it's easy to figure out where the pressure comes from once a group is
struggling to reclaim its LRU pages.

Reporting on the pressure level does nothing but destroy valuable
information that would be useful in scenarios other than tuning a
hierarchical memory limit.

> > But you guys were wary about the patch that changed it, and this
> 
> Changing vmpressure semantics as you proposed in v1 would result in
> userspace getting notifications even if cgroup does not hit its limit.
> May be it could be useful to someone (e.g. it could help tuning
> memory.low), but I am pretty sure this would also result in breakages
> for others.

Maybe. I'll look into a two-layer vmpressure recording/reporting model
that would give us reclaim-level events internally while retaining
pressure-level events for the existing userspace interface.

> > series has kicked up enough dust already, so I backed it out.
> > 
> > But this will still be useful. Yes, it won't help in rebalancing an
> > regularly working system, which would be cool, but it'll still help
> > contain a worklad that is growing beyond expectations, which is the
> > scenario that kickstarted this work.
> 
> I haven't looked through all the previous patches in the series, but
> AFAIU they should do the trick, no? Notifying sockets about vmpressure
> is rather needed to protect a workload from itself.

No, the only critical thing is to protect the system from OOM
conditions caused by what should be containerized processes.

That's a correctness issue.

How much we mitigate the consequences inside the container when the
workload screws up is secondary. But even that is already much better
in this series compared to memcg v1, while leaving us with all the
freedom to continue improving this internal mitigation in the future.

> And with this patch it will work this way, but only if sum limits <
> total ram, which is rather rare in practice. On tightly packed
> systems it does nothing.

That's not true, it's still useful when things go south inside a
cgroup, even with overcommitted limits. See above.

We can optimize the continuous global pressure rebalancing later on;
whether that'll be based on a modified vmpressure implementation, or
adding reclaim efficiency to the shrinker API or whatever.

> That said, I don't think we should commit this particular patch. Neither
> do I think socket accounting should be enabled by default in the unified
> hierarchy for now, since the implementation is still incomplete. IMHO.

I don't see a technical basis for either of those suggestions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
