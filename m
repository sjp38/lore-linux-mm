Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 0FDB26B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 04:11:29 -0400 (EDT)
Message-ID: <51627BCB.1060603@parallels.com>
Date: Mon, 8 Apr 2013 12:11:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/28] memcg-aware slab shrinking
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <20130401123843.GC5217@sergelap> <51598168.4050404@parallels.com> <20130401141217.GA9336@sergelap>
In-Reply-To: <20130401141217.GA9336@sergelap>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: linux-mm@kvack.org, hughd@google.com, containers@lists.linux-foundation.org, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 04/01/2013 06:12 PM, Serge Hallyn wrote:
> Quoting Glauber Costa (glommer@parallels.com):
>> On 04/01/2013 04:38 PM, Serge Hallyn wrote:
>>> Quoting Glauber Costa (glommer@parallels.com):
>>>> Hi,
>>>>
>>>> Notes:
>>>> ======
>>>>
>>>> This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
>>>> and it behaves well, at least from the isolation point of view. However,
>>>> I feel some more testing is needed before we commit to it. Still, this is
>>>> doing the job fairly well. Comments welcome.
>>>
>>> Do you have any performance tests (preferably with enough runs with and
>>> without this patchset to show 95% confidence interval) to show the
>>> impact this has?  Certainly the feature sounds worthwhile, but I'm
>>> curious about the cost of maintaining this extra state.
>>>
>>> -serge
>>>
>> Not yet. I intend to include them in my next run. I haven't yet decided
>> on a set of tests to run (maybe just a memcg-contained kernel compile?)
>>
>> So if you have suggestions of what I could run to show this, feel free
>> to lay them down here.
> 
> Perhaps mount a 4G tmpfs, copy kernel tree there, and build kernel on
> that tmpfs?
> 

I've just run kernbench with 2Gb setups, with 3 different kernels. I
will include all this data in my opening letter for the next submission,
but wanted to drop a heads up here:

Kernels
========
base: the current -mm
davelru: that + dave's patches applied
fulllru: that + my patches applied.

I've ran all of them in a 1st level cgroup. Please note that the first
two kernels are not capable of shrinking metadata, so I had to select a
size that is enough to be in relatively constant pressure, but at the
same time not having that pressure to be exclusively from kernel memory.
2Gb did the job. This is a 2-node 24-way machine. My access to it is
very limited, and I have no idea when I'll be able to get my hands into
it again

Results:

Base
====

Average Optimal load -j 24 Run (std deviation):
Elapsed Time 415.988 (8.37909)
User Time 4142 (759.964)
System Time 418.483 (62.0377)
Percent CPU 1030.7 (267.462)
Context Switches 391509 (268361)
Sleeps 738483 (149934)

Dave
====

Average Optimal load -j 24 Run (std deviation):
Elapsed Time 424.486 (16.7365) ( + 2 % vs base)
User Time 4146.8 (764.012) ( + 0.84 % vs base)
System Time 419.24 (62.4507) (+ 0.18 % vs base)
Percent CPU 1012.1 (264.558) (-1.8 % vs base)
Context Switches 393363 (268899) (+ 0.47 % vs base)
Sleeps 739905 (147344) (+ 0.19 % vs base)


Full
=====

Average Optimal load -j 24 Run (std deviation):
Elapsed Time 456.644 (15.3567) ( + 9.7 % vs base)
User Time 4036.3 (645.261) ( - 2.5 % vs base)
System Time 438.134 (82.251) ( + 4.7 % vs base)
Percent CPU 973 (168.581) ( - 5.6 % vs base)
Context Switches 350796 (229700) ( - 10 % vs base)
Sleeps 728156 (138808) ( - 1.4 % vs base )

Discussion:
===========

First-level analysis: All figures fall within the std dev, except for
Full LRU wall time. It does fall within 2 std devs, though.
On the other hand, Full LRU kernel leads to better cpu utilization and
greater efficiency.

Details: The reclaim patterns in the three kernels are expected to be
different. User memory will always be the main driver, but in case of
pressure the first two kernels will shrink it while keeping the metadata
intact. This should lead to smaller system times figure at expense of
bigger user time figures, since user pages will be evicted more often.
This is consistent with the figures I've found.

Full LRU kernels have a 2.5 % better user time utilization, with 5.6 %
less CPU consumed and 10 % less context switches.

This comes at the expense of a 4.7 % loss of system time. Because we
will have to bring more dentry and inode objects back from caches, we
will stress more the slab code.

Because this is a benchmark that stresses a lot of metadata, it is
expected that this increase affects the end wall result proportionally.
We notice that the mere introduction of LRU code (Dave's Kernel) does
not affect the end wall time result outside the standard deviation.
Shrinking those objects, however, will lead to bigger wall times. This
is within the expected. No one would ever argue that the right kernel
behavior for all cases should keep the metadata in memory at expense of
user memory (and even if we should, we should do it the same way for the
cgroups).

My final conclusions is that performance wise the work is sound and
operates within expectations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
