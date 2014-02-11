Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id F2ECF6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 15:20:20 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e53so3843788eek.41
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:20:20 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id s6si34270866eel.140.2014.02.11.12.20.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 12:20:17 -0800 (PST)
Date: Tue, 11 Feb 2014 15:19:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm v15 00/13] kmemcg shrinkers
Message-ID: <20140211201946.GI4407@cmpxchg.org>
References: <cover.1391624021.git.vdavydov@parallels.com>
 <52FA3E8E.2080601@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52FA3E8E.2080601@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Tue, Feb 11, 2014 at 07:15:26PM +0400, Vladimir Davydov wrote:
> Hi Michal, Johannes, David,
> 
> Could you please take a look at this if you have time? Without your
> review, it'll never get committed.

There is simply no review bandwidth for new features as long as we are
fixing fundamental bugs in memcg.

> On 02/05/2014 10:39 PM, Vladimir Davydov wrote:
> > Hi,
> >
> > This is the 15th iteration of Glauber Costa's patch-set implementing slab
> > shrinking on memcg pressure. The main idea is to make the list_lru structure
> > used by most FS shrinkers per-memcg. When adding or removing an element from a
> > list_lru, we use the page information to figure out which memcg it belongs to
> > and relay it to the appropriate list. This allows scanning kmem objects
> > accounted to different memcgs independently.
> >
> > Please note that this patch-set implements slab shrinking only when we hit the
> > user memory limit so that kmem allocations will still fail if we are below the
> > user memory limit, but close to the kmem limit. I am going to fix this in a
> > separate patch-set, but currently it is only worthwhile setting the kmem limit
> > to be greater than the user mem limit just to enable per-memcg slab accounting
> > and reclaim.
> >
> > The patch-set is based on top of v3.14-rc1-mmots-2014-02-04-16-48 (there are
> > some vmscan cleanups that I need committed there) and organized as follows:
> >  - patches 1-4 introduce some minor changes to memcg needed for this set;
> >  - patches 5-7 prepare fs for per-memcg list_lru;
> >  - patch 8 implement kmemcg reclaim core;
> >  - patch 9 make list_lru per-memcg and patch 10 marks sb shrinker memcg-aware;
> >  - patch 10 is trivial - it issues shrinkers on memcg destruction;
> >  - patches 12 and 13 introduce shrinking of dead kmem caches to facilitate
> >    memcg destruction.

In the context of the ongoing discussions about charge reparenting I
was curious how you deal with charges becoming unreclaimable after a
memcg has been offlined.

Patch #11 drops all charged objects at offlining by just invoking
shrink_slab() in a loop until "only a few" (10) objects are remaining.
How long is this going to take?  And why is it okay to destroy these
caches when somebody else might still be using them?

That still leaves you with the free objects that slab caches retain
for allocation efficiency, so now you put all dead memcgs in the
system on a global list, and on a vmpressure event on root_mem_cgroup
you walk the global list and drain the freelist of all remaining
caches.

This is a lot of complexity and scalability problems for less than
desirable behavior.

Please think about how we can properly reparent kmemcg charges during
memcg teardown.  That would simplify your code immensely and help
clean up this unholy mess of css pinning.

Slab caches are already collected in the memcg and on destruction
could be reassigned to the parent.  Kmemcg uncharge from slab freeing
would have to be updated to use the memcg from the cache, not from the
individual page, but I don't see why this wouldn't work right now.

Charged thread stack pages could be reassigned when the task itself is
migrated out of a cgroup.

It would mean that you can't simply use __GFP_KMEMCG and just pin the
css until you can be bothered to return it.  There must be a way for
any memcg charge to be reparented on demand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
