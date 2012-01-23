Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id C2D096B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 06:20:28 -0500 (EST)
Date: Mon, 23 Jan 2012 12:20:22 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: ensure reclaiming pages on the lru lists of
 zone
Message-ID: <20120123112022.GB1707@cmpxchg.org>
References: <CAJd=RBC8dCGgqXqP+yjW2+pVoSeFXwXfjx8DLHhMuY8goOadZw@mail.gmail.com>
 <CAJd=RBBqp3bMGwFc14BJ7+=KsfO0gLnrnXwbRdLDYOJDdvbptA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBqp3bMGwFc14BJ7+=KsfO0gLnrnXwbRdLDYOJDdvbptA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 23, 2012 at 12:47:34AM +0800, Hillf Danton wrote:
> Hi all
> 
> For easy review, it is re-prepared based on 3.3-rc1.
> 
> Thanks
> Hillf
> 
> ===cut please===
> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: vmscan: ensure reclaiming pages on the lru lists of zone
> 
> While iterating over memory cgroup hierarchy, pages are reclaimed from each
> mem cgroup, and reclaim terminates after a full round-trip. It is possible
> that no pages on the lru lists of given zone are reclaimed, as termination
> is checked after the reclaiming function.
> 
> Mem cgroup iteration is rearranged a bit to make sure that pages are reclaimed
> from both mem cgroups and zone.

It's not only possible, it's guaranteed: with the memory controller
enabled, the global per-zone lru lists are empty.

Pages used to be linked on the global per-zone AND the memcg per-zone
lru lists.  Nowadays, they only sit on the memcg per-zone lists, which
is why global reclaim does a hierarchy walk.

The global per-zone lists are just an artifact for when the memory
controller is not available.  The plan is to make root_mem_cgroup
available at all times, even without the memory controller.

So I'm afraid your patch only adds a round of scanning a known-to-be
empty lruvec.  NAK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
