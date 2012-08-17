Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A8D6C6B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:18:22 -0400 (EDT)
Message-ID: <502DD35F.7080009@parallels.com>
Date: Fri, 17 Aug 2012 09:15:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
References: <1345150417-30856-1-git-send-email-yinghan@google.com> <502D61E1.8040704@redhat.com> <20120816234157.GB2776@devil.redhat.com>
In-Reply-To: <20120816234157.GB2776@devil.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 03:41 AM, Dave Chinner wrote:
> On Thu, Aug 16, 2012 at 05:10:57PM -0400, Rik van Riel wrote:
>> On 08/16/2012 04:53 PM, Ying Han wrote:
>>> The patchset adds the functionality of isolating the vfs slab objects per-memcg
>>> under reclaim. This feature is a *must-have* after the kernel slab memory
>>> accounting which starts charging the slab objects into individual memcgs. The
>>> existing per-superblock shrinker doesn't work since it will end up reclaiming
>>> slabs being charged to other memcgs.
> 
> What list was this posted to?

This what? per-memcg slab accounting ? linux-mm and cgroups, and at
least once to lkml.

You can also find the up2date version in my git tree:

  git://github.com/glommer/linux.git memcg-3.5/kmemcg-slab

But then you mainly lose the discussion. You can find the thread at
http://lwn.net/Articles/508087/, and if you scan recent messages to
linux-mm, there is a lot there too.

> The per-sb shrinkers are not intended for memcg granularity - they
> are for scalability in that they allow the removal of the global
> inode and dcache LRU locks and allow significant flexibility in
> cache relcaim strategies for filesystems. Hint: reclaiming
> the VFS inode cache doesn't free any memory on an XFS filesystem -
> it's the XFS inode cache shrinker that is integrated into the per-sb
> shrinker infrastructure that frees all the memory. It doesn't work
> without the per-sb shrinker functionality and it's an extremely
> performance critical balancing act. Hence any changes to this
> shrinker infrastructure need a lot of consideration and testing,
> most especially to ensure that the balance of the system has not
> been disturbed.
> 

I was actually wondering where the balance would stand between hooking
this into the current shrinking mechanism, and having something totally
separate for memcg. It is tempting to believe that we could get away
with something that works well for memcg-only, but this already proved
to be not true for the user pages lru list...


> Also how do yo propose to solve the problem of inodes and dentries
> shared across multiple memcgs?  They can only be tracked in one LRU,
> but the caches are global and are globally accessed. 

I think the proposal is to not solve this problem. Because at first it
sounds a bit weird, let me explain myself:

1) Not all processes in the system will sit on a memcg.
Technically they will, but the root cgroup is never accounted, so a big
part of the workload can be considered "global" and will have no
attached memcg information whatsoever.

2) Not all child memcgs will have associated vfs objects, or kernel
objects at all, for that matter. This happens only when specifically
requested by the user.

Due to that, I believe that although sharing is obviously a reality
within the VFS, but the workloads associated to this will tend to be
fairly local. When sharing does happen, we currently account to the
first process to ever touch the object. This is also how memcg treats
shared memory users for userspace pages and it is working well so far.
It doesn't *always* give you good behavior, but I guess those fall in
the list of "workloads memcg is not good for".

Do we want to extend this list of use cases? Sure. There is also
discussion going on about how to improve this in the future. That would
allow a policy to specify which memcg is to be "responsible" for the
shared objects, be them kernel memory or shared memory regions. Even
then, we'll always have one of the two scenarios:

1) There is a memcg that is responsible for accounting that object, and
then is clear we should reclaim from that memcg.

2) There is no memcg associated with the object, and then we should not
bother with that object at all.

I fully understand your concern, specifically because we talked about
that in details in the past. But I believe most of the cases that would
justify it would fall in 2).

Another thing to keep in mind is that we don't actually track objects.
We track pages, and try to make sure that objects in the same page
belong to the same memcg. (That could be important for your analysis or
not...)

> Having mem
> pressure in a single memcg that causes globally accessed dentries
> and inodes to be tossed from memory will simply cause cache
> thrashing and performance across the system will tank.
> 

As said above. I don't consider global accessed dentries to be
representative of the current use cases for memcg.

>>> The patch now is only handling dentry cache by given the nature dentry pinned
>>> inode. Based on the data we've collected, that contributes the main factor of
>>> the reclaimable slab objects. We also could make a generic infrastructure for
>>> all the shrinkers (if needed).
>>
>> Dave Chinner has some prototype code for that.
> 
> The patchset I have makes the dcache lru locks per-sb as the first
> step to introducing generic per-sb LRU lists, and then builds on
> that to provide generic kernel-wide LRU lists with integrated
> shrinkers, and builds on that to introduce node-awareness (i.e. NUMA
> scalability) into the LRU list so everyone gets scalable shrinkers.
> 

If you are building a generic infrastructure for shrinkers, what is the
big point about per-sb? I'll give you that most of the memory will come
from the VFS, but other objects are shrinkable too, that bears no
relationship with the vfs.

> I've looked at memcg awareness in the past, but the problem is the
> overhead - the explosion of LRUs because of the per-sb X per-node X
> per-memcg object tracking matrix.  It's a huge amount of overhead
> and complexity, and unless there's a way of efficiently tracking
> objects both per-node and per-memcg simulatneously then I'm of the
> opinion that memcg awareness is simply too much trouble, complexity
> and overhead to bother with.
> 
> So, convince me you can solve the various problems. ;)
> 

I believe we are open minded regarding a solution for that, and your
input is obviously top. So let me take a step back and restate the problem:

1) Some memcgs, not all, will have memory pressure regardless of the
memory pressure in the rest of the system
2) that memory pressure may or may not involve kernel objects.
3) if kernel objects are involved, we can assume the level of sharing is
low.
4) We then need to shrink memory from that memcg, affecting the others
the least we can.

Do you have any proposals for that, in any shape?

One thing that crossed my mind, was instead of having per-sb x per-node
objects, we could have per-"group" x per-node objects. The group would
then be either a memcg or a sb. Objects that doesn't belong to a memcg -
where we expect most of the globally accessed to fall, would be tied to
the sb. Global shrinkers, when called, would of course scan all groups.
Shrinking could also be triggered for the group. An object would of
course only live in one of them at a time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
