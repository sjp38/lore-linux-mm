Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 25C016B005D
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 21:50:06 -0500 (EST)
Date: Fri, 21 Dec 2012 13:50:01 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
Message-ID: <20121221025001.GC15182@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <50D2FA58.9030605@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50D2FA58.9030605@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Thu, Dec 20, 2012 at 03:45:28PM +0400, Glauber Costa wrote:
> On 11/28/2012 03:14 AM, Dave Chinner wrote:
> > Hi Glauber,
> > 
> > Here's a working version of my patchset for generic LRU lists and
> > NUMA-aware shrinkers.
.....
> > There's still a bunch of cleanup work needed. e.g. the LRU list
> > walk/isolation code needs to use enums for the isolate callback
> > return code, there needs to be a generic list_lru_for_each() style
> > function for walking all the objects in the cache (which will allow
> > the list_lru structures to be used for things like the per-sb inode
> > list). Indeed, even the name "list_lru" is probably something that
> > should be changed - I think the list has become more of a general
> > per-node list than it's initial functionality as a scalable LRU list
> > implementation and I can see uses for it outside of LRUs...
> > 
> > Comments, thoughts and flames all welcome.
> > 
> 
> I like the general idea, and after a small PoC on my side, I can say it
> can at least provide us with a good and sound route to solve the
> targetted memcg shrinking problem.
> 
> I've already provided you some small feedback about the interface in the
> specific patches.

*nod*

> But on a broader sense: The only thing that still bothers me personally
> (meaning: it created particular pain points), is the very loose coupling
> between all the elements involved in the shrinking process:
> 
> 1) the shrinker, always present
> 2) the lru, usually present
> 3) the cache, usually present, specially when there is an LRU.
> 
> I of course understand that they are not always present, and when they
> are, they are not in a 1:1 relation.
> 
> But still, it would be nice to be able to register them to one another,
> so that we can easily answer things like:
> 
> "Given a set of caches, what is the set of shrinkers that will shrink them?"
> 
> "What are the lrus that are driven by this shrinker?"
> 
> This would allow me to do things like this:
> 
> * When a per-memcg cache is created (not all of the caches are
> replicated), find the shrinkers that can shrink them.
> 
> * For each shrinker, also replicate the LRUs that are driven by them.
> 
> Does that make any sense to you ?

It certainly does, though I see that as a separate problem to the
one that this patch set solves. i.e. this is an issue related to the
scope and context of a shrinker/LRU couplet, rather than the
implementation of a shrinker/LRU couplet. This patchset addresses
the latter of the two, and I'm pretty sure that I mentioned that the
former was not a problem I am trying to solve yet....

As it is, right now we embed the struct shrinker into the owner
context, and that's how we find the LRU/cache instances that the
shrinker operates on. In the case of per-memcg shrinker
instantiation that fixed relationship does not work.

Further, the struct shrinker has context specific information in it,
like the defered scan count that it carries from one invocation to
the next, so what we end up with is a tightly coupled owner/shrinker
relationship.  That is, a shrinker is really made up of four things:

	- a shrinker definition (set of methods and configuration
	  data)
	- a non-volatile set of data
	- the owner context
	- the LRU/cache to be shrunk

I suspect that a shrinker instance would look something like this:

shrinker_instance {
	non-volatile set of data
	LRU/cache to be shrunk
	pointer to the owner context
	pointer to the shrinker definition
}

But I'm not really sure how to group them sanely, how to know what
shrinkers would need multiple instantiation and when you'd do that
instantiation, or even how an owner context would then do global
operations (e.g empty caches prior to unmount).

I simply don't know what the requirements for such infrastructure
is, so I can't really say much more than this. Hence I think the
first thing to do here is work out and document what such
instantiation, tracking and grouping needs to be able to do before
anything else...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
