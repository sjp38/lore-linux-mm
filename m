Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 033166B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 13:20:54 -0500 (EST)
Message-ID: <50F84118.7030608@parallels.com>
Date: Thu, 17 Jan 2013 10:21:12 -0800
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-10-git-send-email-david@fromorbit.com> <50F6FDC8.5020909@parallels.com> <20130116225521.GF2498@dastard> <50F7475F.90609@parallels.com> <20130117042245.GG2498@dastard>
In-Reply-To: <20130117042245.GG2498@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>


>> Deepest fears:
>>
>> 1) snakes.
> 
> Snakes are merely poisonous. Drop Bears are far more dangerous :P
> 

fears are irrational anyway...

>> 2) It won't surprise you to know that I am adapting your work, which
>> provides a very sane and helpful API, to memcg shrinking.
>>
>> The dumb and simple approach in there is to copy all lrus that are
>> marked memcg aware at memcg creation time. The API is kept the same,
>> but when you do something like list_lru_add(lru, obj), for instance, we
>> derive the memcg context from obj and relay it to the right list.
> 
> At which point, you don't want the overhead of per-node lists.
> 

This is one of the assumptions we may have to end up doing here.

> The problem I see here is that someone might still need the
> scalability of the per-node lists. If someone runs a large memcg in terms
> of CPU and memory, then we most definitely are going to need to
> retain per-node lists regardless of the fact that the workload is
> running in a constrained environment. And if you are running a mix
> of large and small containers, then one static solution is not going
> to cut it for some workload.
> 

Yes, this is spot on. As a first approach, I think single-node lists
will do.

> This is a problem that superblock contexts don't care about - they
> are global by their very nature. Hence I'm wondering if trying to
> fit these two very different behaviours into the one LRU list is
> the wrong approach.
> 

I am not that much concerned about that, honestly. I like the API, and I
like the fact that it allow me to have the subsystems using it
transparently, just by referring to the "master" lru (the dentry, inode,
etc). It reduces complexity to reuse the data structures, but that is
not paramount.

However, a more flexible data structure in which we could select at
least at creation time if we want per-node lists or not, would be quite
helpful.

And it seems it would be at least moderately helpful to you as well for
usually-small filesystems, so I think it would be a good addition to
next version.

> Consider this: these patches give us a generic LRU list structure.
> It currently uses a list_head in each object for indexing, and we
> are talking about single LRU lists because of this limitation and
> trying to build infrastructure that can support this indexing
> mechanism.
> 
> I think that all of thses problems go away if we replace the
> list_head index in the object with a "struct lru_item" index. To
> start with, it's just a s/list_head/lru_item/ changeover, but from
> there we can expand.
> 
> What I'm getting at is that we want to have multiple axis of
> tracking and reclaim, but we only have a single axis for tracking.
> If the lru_item grew a second list_head called "memcg_lru", then
> suddenly the memcg LRUs can be maintained separately to the global
> (per-superblock) LRU. i.e.:
> 
> struct lru_item {
> 	struct list_head global_list;
> 	struct list_head memcg_list;
> }
> 

I may be misunderstanding you, but that is not how I see it. Your global
list AFAIU, is more like a hook to keep the lists together. The actual
accesses to it are controlled by a parent structure, like the
super-block, which in turns, embeds a shrinker.

So we get (in the sb case), from shrinker to sb, and from sb to dentry
list (or inode). We never care about the global list head.

>From this point on, we "entered" the LRU, but we still don't know which
list to reclaim from: there is one list per node, and we need to figure
out which is our target, based on the flags.

This list selection mechanism is where I am usually hooking memcg: and
for the same way you are using an array - given a node, you want fast
access to the underlying list - so am I. Given the memcg context, I want
to get to the corresponding memcg list.

Now, in my earliest implementations, the memcg would still take me to a
node-wide array, and an extra level would be required. We seem to agree
that (at least as a starting point) getting rid of this extra level, so
the memcg colapses all objects in the same list would provide decent
behavior in most cases, while still keeping the footprint manageable. So
that is what I am pursuing at the moment.


> And then you can use whatever tracking structure you want for a
> memcg LRU list. Indeed, this would allow per-node lists for the
> global LRU, and whatever LRU type is appropriate for the memcg using
> the object (e.g. single list for small memcgs, per-node for large
> memcgs)....
> 

Yes. You can have either a small number of big memcgs or a big number of
small memcgs. So if we adopt selectively per-node scalability, our
memory usage is always bounded by #memcgs x avg_size. It works perfectly.

> i.e. rather than trying to make the infrastructure jump through hoops
> to only have one LRU index per object, have a second index that
> allows memcg's to have a separate LRU index and a method for the
> global LRU structure to find them. This woul dallow memcg specific
> shrinker callouts switch to the memcg LRU rather than the global LRU
> and operate on that. That way we still only instantiate a single
> LRU/shrinker pair per cache context, but the memcg code doesn't need
> to duplicate the entire LRU infrastructure into every memcg that
> contains that type of object for that cache context....
> 
> /me stops rambling....
> 

>> Your current suggestion of going per-node only in the performance
>> critical filesystems could also possibly work, provided this count is
>> expected to be small.
> 
> The problem is deciding on a per filesystem basis. I was thinking
> that all filesytsems of a specific type would use a particular type
> of structure, not that specific instances of a filesystem could use
> different types....
> 

Yes, I referred to "critical" as an attribute of the fs class as well.
Most of the disk filesystems (if not all) would use per-node lists, and
I would guess most of the pseudo fs would do fine with a single-node.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
