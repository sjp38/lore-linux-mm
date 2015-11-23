Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 81E116B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:31:39 -0500 (EST)
Received: by wmec201 with SMTP id c201so119811564wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 11:31:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 9si21370477wml.3.2015.11.23.11.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 11:31:38 -0800 (PST)
Date: Mon, 23 Nov 2015 14:31:23 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151123193123.GG13000@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151120131033.GF31308@esperanza>
 <20151120192506.GD5623@cmpxchg.org>
 <20151123100059.GB29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123100059.GB29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 23, 2015 at 01:00:59PM +0300, Vladimir Davydov wrote:
> I've another question regarding this socket_work: its reclaim target
> always equals CHARGE_BATCH. Can't it result in a workload exceeding
> memory.high in case there are a lot of allocations coming from different
> cpus? In this case the work might not manage to complete before another
> allocation happens. May be, we should accumulate the number of pages to
> be reclaimed by the work, as we do in try_charge?

Actually, try_to_free_mem_cgroup_pages() rounds it up to 2MB anyway. I
would hate to add locking or more atomics to accumulate a reclaim goal
for the worker on spec, so let's wait to see if this is a real issue.

> > > BTW why do we need this work at all? Why is reclaim_high called from
> > > task_work not enough?
> > 
> > The problem lies in the memcg association: the random task that gets
> > interrupted by an arriving packet might not be in the same memcg as
> > the one owning receiving socket. And multiple interrupts could happen
> > while we're in the kernel already charging pages. We'd basically have
> > to maintain a list of memcgs that need to run reclaim_high associated
> > with current.
> > 
> 
> Right, I think this is worth placing in a comment to memcg->socket_work.

Okay, will do.

> I wonder if we could use it *instead* of task_work for handling every
> allocation, not only socket-related. Would it make any sense? May be, it
> could reduce the latency experienced by tasks in memory cgroups.

No, we *want* charging tasks to do reclaim work once memory.high is
breached, in order to match their speed to memory availability. That
needs to remain synchroneous.

What we could try is make memcg->socket_work purely about the receive
side when we're inside the softirq, and arm the per-task work when in
process context on the sending side. I'll look into that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
