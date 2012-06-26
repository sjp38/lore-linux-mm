Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 699B46B0113
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 09:38:48 -0400 (EDT)
Received: by qcsp15 with SMTP id p15so3330664qcs.30
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 06:38:47 -0700 (PDT)
Date: Tue, 26 Jun 2012 15:38:41 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 11/11] protect architectures where THREAD_SIZE >=
 PAGE_SIZE against fork bombs
Message-ID: <20120626133838.GA11519@somewhere.redhat.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
 <1340633728-12785-12-git-send-email-glommer@parallels.com>
 <4FE89807.50708@redhat.com>
 <20120625183818.GH3869@google.com>
 <4FE9AF88.5070803@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE9AF88.5070803@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@redhat.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, Jun 26, 2012 at 04:48:08PM +0400, Glauber Costa wrote:
> On 06/25/2012 10:38 PM, Tejun Heo wrote:
> >On Mon, Jun 25, 2012 at 06:55:35PM +0200, Frederic Weisbecker wrote:
> >>On 06/25/2012 04:15 PM, Glauber Costa wrote:
> >>
> >>>Because those architectures will draw their stacks directly from
> >>>the page allocator, rather than the slab cache, we can directly
> >>>pass __GFP_KMEMCG flag, and issue the corresponding free_pages.
> >>>
> >>>This code path is taken when the architecture doesn't define
> >>>CONFIG_ARCH_THREAD_INFO_ALLOCATOR (only ia64 seems to), and has
> >>>THREAD_SIZE >= PAGE_SIZE. Luckily, most - if not all - of the
> >>>remaining architectures fall in this category.
> >>>
> >>>This will guarantee that every stack page is accounted to the memcg
> >>>the process currently lives on, and will have the allocations to fail
> >>>if they go over limit.
> >>>
> >>>For the time being, I am defining a new variant of THREADINFO_GFP, not
> >>>to mess with the other path. Once the slab is also tracked by memcg,
> >>>we can get rid of that flag.
> >>>
> >>>Tested to successfully protect against :(){ :|:& };:
> >>>
> >>>Signed-off-by: Glauber Costa <glommer@parallels.com>
> >>>CC: Christoph Lameter <cl@linux.com>
> >>>CC: Pekka Enberg <penberg@cs.helsinki.fi>
> >>>CC: Michal Hocko <mhocko@suse.cz>
> >>>CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>>CC: Johannes Weiner <hannes@cmpxchg.org>
> >>>CC: Suleiman Souhlal <suleiman@google.com>
> >>
> >>
> >>Acked-by: Frederic Weisbecker <fweisbec@redhat.com>
> >
> >Frederic, does this (with proper slab accounting added later) achieve
> >what you wanted with the task counter?
> >
> 
> A note: Frederic may confirm, but I think he doesn't even need
> the slab accounting to follow to achieve that goal.

Limiting is enough. But that requires internal accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
