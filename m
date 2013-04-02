Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C3EC46B0027
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 03:54:46 -0400 (EDT)
Message-ID: <515A8EE3.70702@parallels.com>
Date: Tue, 2 Apr 2013 11:55:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/28] memcg-aware slab shrinking
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <20130401123843.GC5217@sergelap> <20130402045842.GO6369@dastard>
In-Reply-To: <20130402045842.GO6369@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Serge Hallyn <serge.hallyn@ubuntu.com>, linux-mm@kvack.org, hughd@google.com, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 04/02/2013 08:58 AM, Dave Chinner wrote:
> On Mon, Apr 01, 2013 at 07:38:43AM -0500, Serge Hallyn wrote:
>> Quoting Glauber Costa (glommer@parallels.com):
>>> Hi,
>>>
>>> Notes:
>>> ======
>>>
>>> This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
>>> and it behaves well, at least from the isolation point of view. However,
>>> I feel some more testing is needed before we commit to it. Still, this is
>>> doing the job fairly well. Comments welcome.
>>
>> Do you have any performance tests (preferably with enough runs with and
>> without this patchset to show 95% confidence interval) to show the
>> impact this has?  Certainly the feature sounds worthwhile, but I'm
>> curious about the cost of maintaining this extra state.
> 
> The reason for the node-aware LRUs in the first place is
> performance. i.e. to remove the global LRU locks from the shrinkers
> and LRU list operations. For XFS (at least) the VFS LRU operations
> are significant sources of contention at 16p, and at high CPU counts
> they can basically cause spinlock meltdown.
> 
> I've done performance testing on them on 16p machines with
> fake-numa=4 under such contention generating workloads (e.g. 16-way
> concurrent fsmark workloads) and seen that the LRU locks disappear
> from the profiles. Performance improvement at this size of machine
> under these workloads is still within the run-to-run variance of the
> benchmarks I've run, but the fact the lock is no longer in the
> profiles at all suggest that scalability for larger machines will be
> significantly improved.
> 
> As for the memcg side of things, I'll leave that to Glauber....
> 

I will chime in here about the per-node thing on the memcg side, because
I believe this is the most important design point, and one I'd like to
reach quick agreement on.

>From the memcg PoV, all pressure is global, and the LRU does not buy us
nothing. This is because the nature of memcg: all we care about, is
being over or below a certain soft or hard limit. Where the memory is
located is the concern of other subsystems (like cpuset) and has no
place in memcg interests.

As far as the underlying LRU, I fully trust Dave in what he says: We may
not be able to detect it in our mortal setups, but less lock contention
is very likely to be a clear win in big contended, multi-node scenarios.
By design, you may want as well to shrink per-node, so not disposing
objects in other nodes is also a qualitative win.

In memcg, there are two options: We either stuck a new list_lru in the
objects (dentry and inodes), or we keep it per-node as well. The first
one would allow us to keep global LRU order for global pressure walks,
and memcg LRU order for memcg walks.

Two lists seems simpler at first, but it also have an interesting
effect: on global reclaim, we will break fairness among memcgs. Old
memcgs are likely to be penalized regardless of any other
considerations. Being memcg concerned heavily about isolation between
workloads, it would be preferable to spread global reclaim among them.

The other reason I am keeping per-node memcg, is memory footprint. I
have 24 bytes per-LRU, which are constant and likely to exist in any
scenario (the list head for child lrus (16b) and a memcg pointer(8b))

Then we have a 32-byte structure that represents the LRU itself (If I
got the math correctly for the spinlock usual, non-debug size)

That will be per-node, and each LRU will have one copy of that
per-memcg. So the extra size is 32 * nodes * lrus * memcgs.

Keeping extra state in the object, means an extra list_head per-object.
This is 16 * # objects.

It starts to be a win in favor of the memcg-per-lru when we reach a
number of objects o = 2 * nodes * lrus * memcgs

Using some numbers, nodes = 4, lrus = 100, memcgs = 100, (and this can
already be considered damn big), we have 4000 objects as the threshold
point. My fedora laptop doing nothing other than April fool's jokes and
answering your e-mails, have 26k dentries stored in the slab.

This means aside from the more isolated behavior, our memory footprint
is way, way smaller by keeping the memcgs per-lru.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
