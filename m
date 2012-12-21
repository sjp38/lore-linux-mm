Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id A8A026B006C
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 05:41:11 -0500 (EST)
Message-ID: <50D43CCA.5050703@parallels.com>
Date: Fri, 21 Dec 2012 14:41:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <50D2FA58.9030605@parallels.com> <20121221025001.GC15182@dastard>
In-Reply-To: <20121221025001.GC15182@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

Hey Dave,

On 12/21/2012 06:50 AM, Dave Chinner wrote:
>> But on a broader sense: The only thing that still bothers me personally
>> > (meaning: it created particular pain points), is the very loose coupling
>> > between all the elements involved in the shrinking process:
>> > 
>> > 1) the shrinker, always present
>> > 2) the lru, usually present
>> > 3) the cache, usually present, specially when there is an LRU.
>> > 
>> > I of course understand that they are not always present, and when they
>> > are, they are not in a 1:1 relation.
>> > 
>> > But still, it would be nice to be able to register them to one another,
>> > so that we can easily answer things like:
>> > 
>> > "Given a set of caches, what is the set of shrinkers that will shrink them?"
>> > 
>> > "What are the lrus that are driven by this shrinker?"
>> > 
>> > This would allow me to do things like this:
>> > 
>> > * When a per-memcg cache is created (not all of the caches are
>> > replicated), find the shrinkers that can shrink them.
>> > 
>> > * For each shrinker, also replicate the LRUs that are driven by them.
>> > 
>> > Does that make any sense to you ?
> It certainly does, though I see that as a separate problem to the
> one that this patch set solves. i.e. this is an issue related to the
> scope and context of a shrinker/LRU couplet, rather than the
> implementation of a shrinker/LRU couplet. This patchset addresses
> the latter of the two, and I'm pretty sure that I mentioned that the
> former was not a problem I am trying to solve yet....

Yes. And now I am pretty sure that I mentioned that this is actually a
problem!

Really, the only major change I would like to see made in this patchset
is the provision of more context to the lru functions. It is fine if it
is a lru-specific context.

All the rest is details.

> 
> As it is, right now we embed the struct shrinker into the owner
> context, and that's how we find the LRU/cache instances that the
> shrinker operates on. In the case of per-memcg shrinker
> instantiation that fixed relationship does not work.

Yes, and there is also another problem that arises from it:

the superblock is the owner, but superblocks are no memcg's business. It
is caches that we track, so it would be good to determine which
shrinkers are responsible for each caches -> a n:m relationship.

Those are the ones we need to run per-memcg. Otherwise, we need to go
mess with them all.

> 
> Further, the struct shrinker has context specific information in it,
> like the defered scan count that it carries from one invocation to
> the next, so what we end up with is a tightly coupled owner/shrinker
> relationship.  That is, a shrinker is really made up of four things:
> 
> 	- a shrinker definition (set of methods and configuration
> 	  data)
> 	- a non-volatile set of data
> 	- the owner context
> 	- the LRU/cache to be shrunk
> 
> I suspect that a shrinker instance would look something like this:
> 
> shrinker_instance {
> 	non-volatile set of data
> 	LRU/cache to be shrunk
> 	pointer to the owner context
> 	pointer to the shrinker definition
> }
> 
> But I'm not really sure how to group them sanely, how to know what
> shrinkers would need multiple instantiation and when you'd do that
> instantiation, or even how an owner context would then do global
> operations (e.g empty caches prior to unmount).

Ok, so right now, what my PoC does, is to leave the shrinkers mostly
alone (I just have a static flag to indicate that this is a possible
per-memcg candidate).

The LRUs are all copied over (a bit of a waste, but this is still a
PoC), and whenever the shrinker is called, we trust that the LRUs will
be available, and then using the memcg pointer, derive the
memcg-specific LRUs from the global, original LRUs.

It is still unsolved for the non-volatile set of data belonging to the
shrinker.

So the full solution, would be to create a isolated copy of all that.

"Which shrinkers to copy" is just an item in the wishlist. We don't
replicate all caches because some of them will truly never be used
in a typical container, but most of the shrinkers are fs-related anyway,
and we'll always touch the filesystems. However, we will likely not
touch *all* the filesystems, so a lot of them will just be there,
hanging around and wasting memory.


> 
> I simply don't know what the requirements for such infrastructure
> is, so I can't really say much more than this. Hence I think the
> first thing to do here is work out and document what such
> instantiation, tracking and grouping needs to be able to do before
> anything else...
> 
Yes, let's do it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
