Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B626F6B003D
	for <linux-mm@kvack.org>; Mon, 13 May 2013 03:59:15 -0400 (EDT)
Message-ID: <51909D84.7040800@parallels.com>
Date: Mon, 13 May 2013 12:00:04 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/31] kmemcg shrinkers
References: <1368382432-25462-1-git-send-email-glommer@openvz.org> <20130513071359.GM32675@dastard>
In-Reply-To: <20130513071359.GM32675@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org

On 05/13/2013 11:14 AM, Dave Chinner wrote:
> On Sun, May 12, 2013 at 10:13:21PM +0400, Glauber Costa wrote:
>> Initial notes:
>> ==============
>>
>> Mel, Dave, this is the last round of fixes I have for the series. The fixes are
>> few, and I was mostly interested in getting this out based on an up2date tree
>> so Dave can verify it. This should apply fine ontop of Friday's linux-next.
>> Alternatively, please grab from branch "kmemcg-lru-shrinker" at:
>>
>> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git
>>
>> Main changes from *v5:
>> * Rebased to linux-next, and fix the conflicts with the dcache.
>> * Make sure LRU_RETRY only retry once
>> * Prevent the bcache shrinker to scan the caches when disabled (by returning
>>   0 in the count function)
>> * Fix i915 return code when mutex cannot be acquired.
>> * Only scan less-than-batch objects in memcg scenarios
> 
> Ok, this is behaving a *lot* better than v5 in terms of initial
> balance and sustained behaviour under pure inode/dentry press
> workloads. The previous version was all over the place, not to
> mention unstable and prone to unrealted lockups in the block layer.
> 

Good to hear. About the problems you are seeing, if possible, I think
it would beneficial to do what Mel did, and run a test workload without
the upper half of the patches, IOW, excluding memcg. It should at least
give us an indication about whether or not the problem lies in the way
we are handling the LRU list, or in any memcg adaptation problem.

> However, I'm not sure that the LRUness of reclaim is working
> correctly at this point. When I switch from a write only workload to
> a read-only workload (i.e. fsmark finishes and find starts), I see
> this:
> 
>  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> 1923037 1807201  93%    1.12K  68729       28   2199328K xfs_inode
> 1914624 490812  25%    0.22K  53184       36    425472K xfs_ili
> 
> Note the xfs_ili slab capacity - there's half a million objects
> still in the cache, and they are only present on *dirty* inodes.

May a xfs-ignorant kernel hacker ask you what exactly xfs_ili is ?

> Now, the read-only workload is iterating through a cold-cache lookup
> workload of 50 million inodes - at roughly 150,000/s. It's a
> touch-once workload, so shoul dbe turning the cache over completely
> every 10 seconds. However, in the time it's taken for me to explain
> this:
> 
>  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
> 1954493 1764661  90%    1.12K  69831       28   2234592K xfs_inode
> 1643868 281962  17%    0.22K  45663       36    365304K xfs_ili   
> 
> Only 200k xfs_ili's have been freed. So the rate of reclaim of them
> is roughly 5k/s. Given the read-only nature of this workload, they
> should be gone from the cache in a few seconds. Another indication
> of problems here is the level of internal fragmentation of the
> xfs_ili slab. They should cycle out of the cache in LRU manner, just
> like inodes - the modify workload is a "touch once" workload as
> well, so there should be no internal fragmentation of the slab
> cache.
> 

Initial testing I have done indicates - although it does not undoubtly
prove  - that the problem may be with dentries, not inodes. This is from
attempted bisecting at the postmark benchmark, but as you said yourself,
that kind of workload is not that bad any more, so this is unconclusive.
In particular, the behavior of lru_walk mimics very well
the inode behavior, but for dentries, we have the following situation:

Before the patchset:
====================

relock:
while (!list_empty(&sb->s_dentry_lru)) {
        dentry = list_entry(sb->s_dentry_lru.prev,
                        struct dentry, d_lru);

        if (!spin_trylock(&dentry->d_lock)) {
                spin_unlock(&dcache_lru_lock);
                cpu_relax(); <== doesn't modify count
                goto relock;
        }

        if (dentry->d_flags & DCACHE_REFERENCED) {
                dentry->d_flags &= ~DCACHE_REFERENCED;
                list_move(&dentry->d_lru, &referenced);
                spin_unlock(&dentry->d_lock); <== doesn't modify count
        } else {
                list_move_tail(&dentry->d_lru, &tmp);
                dentry->d_flags |= DCACHE_SHRINK_LIST;
                spin_unlock(&dentry->d_lock);
                if (!--count)
                        break;
        }


The code we have in list_lru.c will decrement nr_to_walk in every
situation except for LRU_RETRY.

There is also another problem I have just spotted while looking at this:

Differently from the experimental patch I sent Mel, the actual version
of LRU_RETRY does not actually flip the flag, meaning the behavior is
not what I envisioned.

You are seeing problems in the inode behavior, but since the dentry
cache may pin them, I believe it is possible that the change in behavior
in the dentry cache may drive the change in behavior in the inode cache,
by keeping inodes that should be freed, pinned. (So far, just a theory)

Comments welcome.

> The stats I have of cache residency during the read-only part of the
> workload looks really bad. No steady state is reached, while on 3.9
> a perfect steady state is reached within seconds and maintained
> until the workload changes. Part way through the read-only workload,
> this happened:
> 
> [  562.673080] sh (5007): dropped kernel caches: 3
> [  629.617303] lowmemorykiller: send sigkill to 3953 (winbindd), adj 0, size 195
> [  629.625499] lowmemorykiller: send sigkill to 3439 (pmcd), adj 0, size 158
> 
> And when the read-only workload finishes it's walk, I then start
> another "touch once" workload that removes all the files. that
> triggered:
> 
> [ 1002.183604] lowmemorykiller: send sigkill to 5827 (winbindd), adj 0, size 246
> [ 1002.187822] lowmemorykiller: send sigkill to 3904 (winbindd), adj 0, size 134
> 
> Yeah, that stupid broken low memory killer is now kicking in,
> killing random processes - last run it killed two of the rm
> processes doing work, this time it killed winbindd and the PCP
> collection daemon that I use for remote stats monitoring.
> 
> So, yeah, there's still some broken stuff in this patchset that
> needs fixing.  The script that I'm running to trigger these problems
> is pretty basic - it's the same workload I've been using for the
> past 3 years for measuring metadata performance of filesystems:
> 
I will try to run them myself, and I appreciate your diligence as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
