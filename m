Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C85F46B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 07:01:42 -0400 (EDT)
Received: by wefh52 with SMTP id h52so4680155wef.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 04:01:41 -0700 (PDT)
Date: Wed, 30 May 2012 13:01:37 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v3 12/28] slab: pass memcg parameter to kmem_cache_create
Message-ID: <20120530110134.GA25094@somewhere.redhat.com>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com>
 <1337951028-3427-13-git-send-email-glommer@parallels.com>
 <alpine.DEB.2.00.1205290922340.4666@router.home>
 <4FC4F04F.1070401@parallels.com>
 <alpine.DEB.2.00.1205291131590.6723@router.home>
 <4FC4FAF6.8060900@parallels.com>
 <alpine.DEB.2.00.1205291149280.8406@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205291149280.8406@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, May 29, 2012 at 11:52:55AM -0500, Christoph Lameter wrote:
> On Tue, 29 May 2012, Glauber Costa wrote:
> 
> > > How do you detect that someone is touching it?
> >
> > kmem_alloc_cache will create mem_cgroup_get_kmem_cache.
> > (protected by static_branches, so won't happen if you don't have at least
> > non-root memcg using it)
> >
> > * Then it detects which memcg the calling process belongs to,
> > * if it is the root memcg, go back to the allocation as quickly as we
> >   can
> > * otherwise, in the creation process, you will notice that each cache
> >   has an index. memcg will store pointers to the copies and find them by
> >   the index.
> >
> > From this point on, all the code of the caches is reused (except for
> > accounting the page)
> 
> Well kmem_cache_alloc cache is the performance critical hotpath.
> 
> If you are already there and doing all of that then would it not be better
> to simply count the objects allocated and freed per cgroup? Directly
> increment and decrement counters in a cgroup? You do not really need to
> duplicate the kmem_cache structure and do not need to modify allocators if
> you are willing to take that kind of a performance hit. Put a wrapper
> around kmem_cache_alloc/free and count things.

I believe one of the issues is also that a task can migrate to another cgroup
anytime. But an object that has been charged to a cgroup must be later uncharged
to the same, unless you move the charge as you move the task. But then it means
you need to keep track of the allocations per task, and you also need to be able
to do that reverse mapping (object -> allocating task) because your object can
be allocated by task A but later freed by task B. Then when you do the uncharge
it must happen to the cgroup of A, not the one of B.

That all would be much more complicated and performance sensitive than what this
patchset does. Dealing with duplicate caches for accounting seem to me a good tradeoff
between allocation performance hot path and maintaining cgroups semantics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
