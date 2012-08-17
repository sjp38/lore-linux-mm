Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 0D2286B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 15:18:33 -0400 (EDT)
Received: by lbon3 with SMTP id n3so2769399lbo.14
        for <linux-mm@kvack.org>; Fri, 17 Aug 2012 12:18:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502E1648.9040907@parallels.com>
References: <1345150417-30856-1-git-send-email-yinghan@google.com>
	<502D61E1.8040704@redhat.com>
	<20120816234157.GB2776@devil.redhat.com>
	<502DD35F.7080009@parallels.com>
	<20120817075440.GD2776@devil.redhat.com>
	<502E1648.9040907@parallels.com>
Date: Fri, 17 Aug 2012 12:18:31 -0700
Message-ID: <CALWz4iw3zNgvy+NUrw9Gb2pEMbkFAmo2y+qh=kAA3VWf6zKu-w@mail.gmail.com>
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Fri, Aug 17, 2012 at 3:00 AM, Glauber Costa <glommer@parallels.com> wrote:
>
>>>> Also how do yo propose to solve the problem of inodes and dentries
>>>> shared across multiple memcgs?  They can only be tracked in one LRU,
>>>> but the caches are global and are globally accessed.
>>>
>>> I think the proposal is to not solve this problem. Because at first it
>>> sounds a bit weird, let me explain myself:
>>>
>>> 1) Not all processes in the system will sit on a memcg.
>>> Technically they will, but the root cgroup is never accounted, so a big
>>> part of the workload can be considered "global" and will have no
>>> attached memcg information whatsoever.
>>>
>>> 2) Not all child memcgs will have associated vfs objects, or kernel
>>> objects at all, for that matter. This happens only when specifically
>>> requested by the user.
>>>
>>> Due to that, I believe that although sharing is obviously a reality
>>> within the VFS, but the workloads associated to this will tend to be
>>> fairly local.
>>
>> I have my doubts about that - I've heard it said many times but no
>> data has been provided to prove the assertion....
>>
>
> First let me stress this point again, which is never enough: Sitting on
> a memcg will not automatically start tracking kmem for you. So it is
> possible to have the craziest possible memcg use case, and still have
> kmem not tracked. Since kmem is naturally a shared resource, one can
> only expect that people turning this on will be aware of that.
>
> It is of course hard for me to argue or come up with data for about that
> for every possible use of memcg. If you have anything specific in mind,
> I can get a test running. But I can talk about the things we do.
>
> Since we run a full-userspace container, our main use case is to mount
> a directory structure somewhere - so this already gets the whole chain
> cached, then we chroot to it, and move the tasks to the cgroup. There
> seems to be nothing unreasonable about assuming that the vast majority
> of the dentries accessed from that point on will tend to be fairly local.
>
> Even if you have a remote NFS mount that is only yours, that is also
> fine, because you get accounted as you touch the dentries. The
> complications arise when more than one group is accessing it. But then,
> as I said, There is WIP to predictably determine which group you will
> end up at, and at this point, it becomes policy.
>
> Maybe Ying Han can tell us more about what they are doing to add to the
> pool, but I can only assume that if sharing was a deal-breaker for them,
> they would not be pursuing this path at all.

Similar discussion happens on "per-memcg dirty limit & writeback"
patch, where we faced similar issue of
how to tag a inode if it is shared between two memcgs. The answer
remains that it is a rare case in our
production environment.


>
>>> When sharing does happen, we currently account to the
>>> first process to ever touch the object. This is also how memcg treats
>>> shared memory users for userspace pages and it is working well so far.
>>> It doesn't *always* give you good behavior, but I guess those fall in
>>> the list of "workloads memcg is not good for".
>>
>> And that list contains?
>
> I would say that anything that is first, not logically groupable
> (general case for cgroups), and for which is hard to come up with a
> immediate upper limit of memory.
>
> When kernel memory comes into play, you have to consider that you are
> accounting a shared resource, so you should have reasonable expectations
> to not be sharing those resources with everybody.
>
> We are also never implying that no sharing will happen. Just that we
> expect it to be in a low rate.
>
>>
>>> Do we want to extend this list of use cases?  Sure. There is also
>>> discussion going on about how to improve this in the future. That would
>>> allow a policy to specify which memcg is to be "responsible" for the
>>> shared objects, be them kernel memory or shared memory regions. Even
>>> then, we'll always have one of the two scenarios:
>>>
>>> 1) There is a memcg that is responsible for accounting that object, and
>>> then is clear we should reclaim from that memcg.
>>>
>>> 2) There is no memcg associated with the object, and then we should not
>>> bother with that object at all.
>>>
>>> I fully understand your concern, specifically because we talked about
>>> that in details in the past. But I believe most of the cases that would
>>> justify it would fall in 2).
>>
>> Which then leads to this: the no-memcg object case needs to scale.
>>
>
> Yes, and I trust you to do it! =)
>
>
>>> Another thing to keep in mind is that we don't actually track objects.
>>> We track pages, and try to make sure that objects in the same page
>>> belong to the same memcg. (That could be important for your analysis or
>>> not...)
>>
>> Hmmmm. So you're basically using the characteristics of internal
>> slab fragmentation to keep objects allocated to different memcg's
>> apart? That's .... devious. :)
>
> My first approach was to get the pages themselves, move pages around
> after cgroup destruction, etc. But that touched the slab heavily, and
> since we have 3 of them, and writing more seem to be a joyful hobby some
> people pursue, I am now actually reproducing the metadata and creating
> per-cgroup caches. It is about the same, but with a bit more wasted
> space that we're happily paying as the price for added simplicity.
>
> Instead of directing the allocation to a page, which requires knowledge
> of how the various slabs operate, we direct allocations to a different
> cache altogether, that hides it.
>
>
>>
>>>> Having mem
>>>> pressure in a single memcg that causes globally accessed dentries
>>>> and inodes to be tossed from memory will simply cause cache
>>>> thrashing and performance across the system will tank.
>>>>
>>>
>>> As said above. I don't consider global accessed dentries to be
>>> representative of the current use cases for memcg.
>>
>> But they have to co-exist, and I think that's our big problem. If
>> you have a workload in a memcg, and the underlying directory
>> structure is exported via NFS or CIFS, then there is still global
>> access to that "memcg local" dentry structure.
>>
>
> I am all for co-existing.
>
>>>>>> The patch now is only handling dentry cache by given the nature dentry pinned
>>>>>> inode. Based on the data we've collected, that contributes the main factor of
>>>>>> the reclaimable slab objects. We also could make a generic infrastructure for
>>>>>> all the shrinkers (if needed).
>>>>>
>>>>> Dave Chinner has some prototype code for that.
>>>>
>>>> The patchset I have makes the dcache lru locks per-sb as the first
>>>> step to introducing generic per-sb LRU lists, and then builds on
>>>> that to provide generic kernel-wide LRU lists with integrated
>>>> shrinkers, and builds on that to introduce node-awareness (i.e. NUMA
>>>> scalability) into the LRU list so everyone gets scalable shrinkers.
>>>>
>>>
>>> If you are building a generic infrastructure for shrinkers, what is the
>>> big point about per-sb? I'll give you that most of the memory will come
>>> from the VFS, but other objects are shrinkable too, that bears no
>>> relationship with the vfs.
>>
>> Without any more information, it's hard to understand what I'm
>> doing.
>
> With more information it's hard as well. =p
>
>>
>>>> I've looked at memcg awareness in the past, but the problem is the
>>>> overhead - the explosion of LRUs because of the per-sb X per-node X
>>>> per-memcg object tracking matrix.  It's a huge amount of overhead
>>>> and complexity, and unless there's a way of efficiently tracking
>>>> objects both per-node and per-memcg simulatneously then I'm of the
>>>> opinion that memcg awareness is simply too much trouble, complexity
>>>> and overhead to bother with.
>>>>
>>>> So, convince me you can solve the various problems. ;)
>>>
>>> I believe we are open minded regarding a solution for that, and your
>>> input is obviously top. So let me take a step back and restate the problem:
>>>
>>> 1) Some memcgs, not all, will have memory pressure regardless of the
>>> memory pressure in the rest of the system
>>> 2) that memory pressure may or may not involve kernel objects.
>>> 3) if kernel objects are involved, we can assume the level of sharing is
>>> low.
>>
>> I don't think you can make this assumption. You could simply have a
>> circle-thrash of a shared object where the first memcg reads it,
>> caches it, then reclaims it, then the second does the same thing,
>> then the third, and so on around the circle....
>>
>
> I think the best we can do here is a trade-off. We won't make shared
> resources become exclusive. What I tried to do, is by having to have one
> explicitly turning this on, confine its usage to scenarios where this
> assumption will mostly hold.
>
> "Mostly hold" basically means still have problems like the one you
> describe, but expecting them to be in a quantity small enough not to
> bother us. It is just like the case for processor caches...
>
>>> 4) We then need to shrink memory from that memcg, affecting the
>>> others the least we can.
>>>
>>> Do you have any proposals for that, in any shape?
>>>
>>> One thing that crossed my mind, was instead of having per-sb x
>>> per-node objects, we could have per-"group" x per-node objects.
>>> The group would then be either a memcg or a sb.
>>
>> Perhaps we've all been looking at the problem the wrong way.
>>
>> As I was writing this, it came to me that the problem is not that
>> "the object is owned either per-sb or per-memcg". The issue is how
>> to track the objects in a given context.
>
> Which is basically just a generalization of "per-group" as I said. The
> group can be anything, and I believe your generic LRU interface makes it
> quite clear.
>
>> The overall LRU manipulations
>> and ownership of the object is identical in both the global and
>> memcg cases - it's the LRU that the object is placed on that
>> matters! With a generic LRU+shrinker implementation, this detail is
>> completely confined to the internals of the LRU+shrinker subsystem.
>>
>
> Indeed.
>
>> IOWs, if you are tagging the object with memcg info at a slab page
>> level, the LRU and shrinker need to operate at the same level, not
>> at the per-object level.
>
> Not sure I fully parse. You do still track objects in the LRU, right?
>
>> The LRU implementation I have currently
>> selects the internal LRU list according to the node the object was
>> allocated on. i.e. by looking at the page:
>>
> [...]
>
>> There is no reason why we couldn't determine if an object was being
>> tracked by a memcg in the same way. Do we have a page_to_memcg()
>> function?
>
> Yes. We don't currently have, because we have no users.
> But that can easily be provided, and Ying Han's patches actually
> provides one.
>
>> If we've got that, then all we need to add to the struct
>> shrinker_lru is a method of dynamically adding and looking up the
>> memcg to get the appropriate struct shrinker_lru_node from the
>> memcg. The memcg would need a struct shrinker_lru_node per generic
>> LRU in use, and this probably means we need to uniquely identify
>> each struct shrinker_lru instance so the memcg code can kept a
>> dynamic list of them.
>
> Sounds like right.
>
>>
>> With that, we could track objects per memcg or globally on the
>> per-node lists.
>
> For userspace pages, we do per-memcg-per-zone. Can't we do the same
> here? Note that simple "per-memcg" is already a big thing for us, but
> you're not alone in your fight for scalability.
>
>> If we then add a memcg id to the struct
>> scan_control, the shrinker can then walk the related memcg LRU
>> rather than the per-node LRU.  That means that general per-node
>> reclaim won't find memcg related objects, and memcg related reclaim
>> won't scan the global per-node objects. This could be changed as
>> needed, though.
>>
>> What it does, though, is preserve the correct balance of related
>> caches in the memcg because they use exactly the same subsystem code
>> that defines the relationship for the global cache. It also
>> preserves the scalabilty of the non-memcg based processes, and
>> allows us to tune the global vs memcg LRU reclaim algorithm in a
>> single place.
>>
>> That, to me, sounds almost ideal - memcg tracking and reclaim works
>> with very little added complexity, it has no additional memory
>> overhead, and scalability is not compromised. What have I missed? :P

If I understand it, we are creating per-memcg per-zone lru for vfs
slabs? That sounds similar to how the user pages are handled today in
lruvec. As I have in the commit description, we thought about this at
the beginning but the complication of the code could turn into doesn't
gain us much. The complication mainly come from the race where memcg
comes and go, and we need to be careful of handing the separate lists.

The patch I have here works fine w/ us of the problem we are trying to
solve. By saying that, I need to read a bit more of understanding what
the generic shrinker buying us.

Thanks

--Ying


>
> So before I got to your e-mail, I actually coded a prototype for it.
> Due to the lack of funding for my crystal balls department, I didn't
> make use of your generic LRU, so a lot of it is still hard coded in
> place. I am attaching the ugly patch here so you can take a look.
>
> Note that I am basically using the same prune_dcache function, just with
> a different list. I am also not bothering with inodes, etc.
>
> Take a look. How do you think this would integrate with your idea?
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
