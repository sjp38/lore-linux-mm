Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id B7ED96B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 13:19:19 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p63so19782434wmp.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 10:19:19 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id f10si29386954wje.24.2016.01.30.10.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 10:19:18 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id r129so19834890wmr.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 10:19:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160125184559.GE29291@cmpxchg.org>
References: <20160125133357.GC23939@dhcp22.suse.cz> <20160125184559.GE29291@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Date: Sat, 30 Jan 2016 10:18:58 -0800
Message-ID: <CAHH2K0ah5y-WkicNNSag=Qcnkp=7JR9mvR4J5+RsPmb2BTjO2A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] proposals for topics
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

On Mon, Jan 25, 2016 at 10:45 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi Michal,
>
> On Mon, Jan 25, 2016 at 02:33:57PM +0100, Michal Hocko wrote:
>> Hi,
>> I would like to propose the following topics (mainly for the MM track
>> but some of them might be of interest for FS people as well)
>> - gfp flags for allocations requests seems to be quite complicated
>>   and used arbitrarily by many subsystems. GFP_REPEAT is one such
>>   example. Half of the current usage is for low order allocations
>>   requests where it is basically ignored. Moreover the documentation
>>   claims that such a request is _not_ retrying endlessly which is
>>   true only for costly high order allocations. I think we should get
>>   rid of most of the users of this flag (basically all low order ones)
>>   and then come up with something like GFP_BEST_EFFORT which would work
>>   for all orders consistently [1]
>
> I think nobody would mind a patch that just cleans this stuff up. Do
> you expect controversy there?
>
>> - GFP_NOFS is another one which would be good to discuss. Its primary
>>   use is to prevent from reclaim recursion back into FS. This makes
>>   such an allocation context weaker and historically we haven't
>>   triggered OOM killer and rather hopelessly retry the request and
>>   rely on somebody else to make a progress for us. There are two issues
>>   here.
>>   First we shouldn't retry endlessly and rather fail the allocation and
>>   allow the FS to handle the error. As per my experiments most FS cope
>>   with that quite reasonably. Btrfs unfortunately handles many of those
>>   failures by BUG_ON which is really unfortunate.
>
> Are there any new datapoints on how to deal with failing allocations?
> IIRC the conclusion last time was that some filesystems simply can't
> support this without a reservation system - which I don't believe
> anybody is working on. Does it make sense to rehash this when nothing
> really changed since last time?
>
>> - OOM killer has been discussed a lot throughout this year. We have
>>   discussed this topic the last year at LSF and there has been quite some
>>   progress since then. We have async memory tear down for the OOM victim
>>   [2] which should help in many corner cases. We are still waiting
>>   to make mmap_sem for write killable which would help in some other
>>   classes of corner cases. Whatever we do, however, will not work in
>>   100% cases. So the primary question is how far are we willing to go to
>>   support different corner cases. Do we want to have a
>>   panic_after_timeout global knob, allow multiple OOM victims after
>>   a timeout?
>
> Yes, that sounds like a good topic to cover. I'm honestly surprised
> that there is so much resistence to trying to make the OOM killer
> deterministic, and patches that try to fix that are resisted while the
> thing can still lock up quietly.
>
> It would be good to take a step back and consider our priorities
> there, think about what the ultimate goal of the OOM killer is, and
> then how to make it operate smoothly without compromising that goal -
> not the other way round.

A few thoughts on our current/future oom killer usage.

We've been using the oom killer as a overcommit tie breaker.  Victim
selection isn't always based on memory usage, instead low priority
jobs are the first victims.  Thus a deterministic scoring system,
independent of memory usage, has been useful.  And a scoring system
that's based on memcg hierarchy.  Because jobs are often defined at
container boundaries it's also expedient to oom kill all processes
within a memcg.

Killing processes isn't always enough to free memory because
tmpfs/hugetlbfs aren't oom direct victims.  Though a combination of
namespaces and kill-all-container-processes is promising, because last
referenced on namespace can umount its filesystems.  Though this
doesn't help if refs to the filesystem exist outside of the namespace
(e.g. fd's passed over unix sockets).  So other ideas are floating
around.

And thrash detection is also quite helpful to decided when oom killing
is better than hamming reclaim for a really long time.  Refaulting is
one signal of when to oom kill, but another is that high priority
tasks are only willing to spend X before oom killing a lower prio
victim (sorry X is vague, because it hasn't been sorted out yet, it
could be wallclock, cpu time, disk bandwidth, etc.).

>> - sysrq+f to trigger the oom killer follows some heuristics used by the
>>   OOM killer invoked by the system which means that it is unreliable
>>   and it might skip to kill any task without any explanation why. The
>>   semantic of the knob doesn't seem to clear and it has been even
>>   suggested [3] to remove it altogether as an unuseful debugging aid. Is
>>   this really a general consensus?
>
> I think it's an okay debugging aid, but I worry about it coming up so
> much in discussions about how the OOM killer should behave. We should
> never *require* manual intervention to put a machine back into known
> state after it ran out of memory.
>
>> - One of the long lasting issue related to the OOM handling is when to
>>   actually declare OOM. There are workloads which might be trashing on
>>   few last remaining pagecache pages or on the swap which makes the
>>   system completely unusable for considerable amount of time yet the
>>   OOM killer is not invoked. Can we finally do something about that?
>
> I'm working on this, but it's not an easy situation to detect.
>
> We can't decide based on amount of page cache, as you could have very
> little of it and still be fine. Most of it could still be used-once.
>
> We can't decide based on number or rate of (re)faults, because this
> spikes during startup and workingset changes, or can be even sustained
> when working with a data set that you'd never expect to fit into
> memory in the first place, while still making acceptable progress.
>
> The only thing that I could come up with as a meaningful metric here
> is the share of actual walltime that is spent waiting on refetching
> stuff from disk. If we know that in the last X seconds, the whole
> system spent more than idk 95% of its time waiting on the disk to read
> recently evicted data back into the cache, then it's time to kick the
> OOM killer, as this state is likely not worth maintaining.
>
> Such a "thrashing time" metric could be great to export to userspace
> in general as it can be useful in other situations, such as quickly
> gauging how comfortable a workload is (inside a container), and how
> much time is wasted due to underprovisioning of memory. Because it
> isn't just the pathological cases, you migh just wait a bit here and
> there and could it still add up to a sizable portion of a job's time.
>
> If other people think this could be a useful thing to talk about, I'd
> be happy to discuss it at the conference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
