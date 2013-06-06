Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 649E66B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 04:53:40 -0400 (EDT)
Date: Thu, 6 Jun 2013 09:53:36 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7] RFC: adding compaction to zone_reclaim_mode > 0
Message-ID: <20130606085335.GB1936@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 05:10:30PM +0200, Andrea Arcangeli wrote:
> Hello everyone,
> 
> I got a bugreport showing some problem with NUMA affinity with CPU
> node bindings when THP is enabled and /proc/sys/vm/zone_reclaim_mode
> is > 0.
> 

zone_reclaim_mode has generated a number of bugs for me in the past. In
my experience almost all of them were related to excessive stalling. The
most recent example was stalls measured in minutes while memory was free
on other nodes although this was with an old kernel that would not affect
mainline today.

> When THP is disabled, zone_reclaim_mode set to 1 (or higher) tends to
> allocate memory in the local node with quite some accuracy in presence
> of CPU node bindings (and weak or no memory bindings). However THP
> enabled tends to spread the memory to other nodes erroneously.
> 

This does not surprise me as such. zone reclaim is expected today to
fail quickly. I would expect a process to make more forware progress if
it uses remote memory quickly or allocates base pages locally than stall
trying to allocate a THP locally. There was a time when THP were allocated
aggressively with lumpy reclaim, repeated attempts at allocation etc and
we moved away from that. zone_reclaim is very similar.

> I also found zone_reclaim_mode is quite unreliable in presence of
> multiple threads allocating memory at the same time from different
> CPUs in the same node, even when THP is disabled and there's plenty of
> clean cache to trivially reclaim.
> 

There is a flag that prevents multiple zone_reclaims within a zone and it
had at least two purposes.  One was that reclaim in the past was excessive
and multiple processes entering reclaim simultaneously tended to reclaim
way more than required. Second, multiple processes in zone reclaim mode
interfered with each other reclaiming each others memory in a stupid
loop. It should be better today for a variety of reasons but these are
the two primary problems to watch out for.

> The major problem with THP enabled is that zone_reclaim doesn't even
> try to use compaction. Then there are more changes suggested to make
> the whole compaction process more reliable than it is now.
> 

It has less *overhead*. The success rate is actually lower today because it
no longer reclaims the world and heavily disrupts the system to allocate
a THP. It's a long-standing TODO item to implement proper capture logic
in compaction but it has not happened yet. It's a fair bit down the TODO
list unfortunately.

> After setting zone_reclaim_mode to 1 and booting with
> numa_zonelist_order=n, with this patchset applied I get this NUMA placement:
> 
>   PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
>  7088 breakthp              0      2.1M [   2.1M     0  ]
>  7089 breakthp              1      2.1M [   2.1M     0  ]
>  7090 breakthp              2      2.1M [   2.1M     0  ]
>  7091 breakthp              3      2.1M [   2.1M     0  ]
>  7092 breakthp              6      2.1M [     0    2.1M ]
>  7093 breakthp              7      2.1M [     0    2.1M ]
>  7094 breakthp              8      2.1M [     0    2.1M ]
>  7095 breakthp              9      2.1M [     0    2.1M ]
>  7097 breakthp              0      2.1M [   2.1M     0  ]
>  7098 breakthp              1      2.1M [   2.1M     0  ]
>  7099 breakthp              2      2.1M [   2.1M     0  ]
>  7100 breakthp              3      2.1M [   2.1M     0  ]
>  7101 breakthp              6      2.1M [     0    2.1M ]
>  7102 breakthp              7      2.1M [     0    2.1M ]
>  7103 breakthp              8      2.1M [     0    2.1M ]
>  7104 breakthp              9      2.1M [     0    2.1M ]
>   PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
>  7106 usemem                0     1.00G [  1.00G     0  ]
>  7107 usemem                1     1.00G [  1.00G     0  ]
>  7108 usemem                2     1.00G [  1.00G     0  ]
>  7109 usemem                3     1.00G [  1.00G     0  ]
>  7110 usemem                6     1.00G [     0   1.00G ]
>  7111 usemem                7     1.00G [     0   1.00G ]
>  7112 usemem                8     1.00G [     0   1.00G ]
>  7113 usemem                9     1.00G [     0   1.00G ]
> 
> Without current upstream without the patchset and still
> zone_reclaim_mode = 1 and booting with numa_zonelist_order=n:
> 
>   PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
>  2950 breakthp              0      2.1M [   2.1M     0  ]
>  2951 breakthp              1      2.1M [   2.1M     0  ]
>  2952 breakthp              2      2.1M [   2.1M     0  ]
>  2953 breakthp              3      2.1M [   2.1M     0  ]
>  2954 breakthp              6      2.1M [     0    2.1M ]
>  2955 breakthp              7      2.1M [     0    2.1M ]
>  2956 breakthp              8      2.1M [     0    2.1M ]
>  2957 breakthp              9      2.1M [     0    2.1M ]
>  2966 breakthp              0      2.1M [   2.0M    96K ]
>  2967 breakthp              1      2.1M [   2.0M    96K ]
>  2968 breakthp              2      1.9M [   1.9M    96K ]
>  2969 breakthp              3      2.1M [   2.0M    96K ]
>  2970 breakthp              6      2.1M [   228K   1.8M ]
>  2971 breakthp              7      2.1M [    72K   2.0M ]
>  2972 breakthp              8      2.1M [    60K   2.0M ]
>  2973 breakthp              9      2.1M [   204K   1.9M ]
>   PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
>  3088 usemem                0     1.00G [ 856.2M 168.0M ]
>  3089 usemem                1     1.00G [ 860.2M 164.0M ]
>  3090 usemem                2     1.00G [ 860.2M 164.0M ]
>  3091 usemem                3     1.00G [ 858.2M 166.0M ]
>  3092 usemem                6     1.00G [ 248.0M 776.2M ]
>  3093 usemem                7     1.00G [ 248.0M 776.2M ]
>  3094 usemem                8     1.00G [ 250.0M 774.2M ]
>  3095 usemem                9     1.00G [ 246.0M 778.2M ]
> 
> Allocation speed seems a bit faster with the patchset applied likely
> thanks to the increased NUMA locality that even during a simple
> initialization, more than offsets the compaction costs.
> 
> The testcase always uses CPU bindings (half processes in one node, and
> half processes in the other node). It first fragments all memory
> (breakthp) by breaking lots of hugepages with mremap, and then another
> process (usemem) allocates lots of memory, in turn exercising the
> reliability of compaction with zone_reclaim_mode > 0.
> 

Ok.

> Very few hugepages are available when usemem starts, but compaction
> has a trivial time to generate as many hugepages as needed without any
> risk of failure.
> 
> The memory layout when usemem starts is like this:
> 
> 4k page anon
> 4k page free
> another 512-2 4k pages free
> 4k page anon
> 4k page free
> another 512-2 4k pages free
> [..]
> 
> If automatic NUMA balancing is enabled, this isn't as critical issues
> as without (the placement will be fixed later at runtime with THP NUMA
> migration faults), but it still looks worth optimizing the initial
> placement to avoid those migrations and for short lived computations
> (where automatic NUMA balancing can't help). Especially if the process
> has already been pinned to the CPUs of a node like in the bugreport I
> got.
> 

I had debated with myself whether zone_reclaim_mode and automatic numa
placement would be mutually exclusive. I felt that it would be sufficient for
the local memory allocation policy to handle initial placement without using
zone_reclaim_mode and have automatic numa placement fix it up later. This
would minimise application startup time and initial poor placement would not
be a problem for long-lived processes. I did not do anything about actually
setting the defaults but I became less concerned with zone_reclaim_mode
as a result. Still, it would not kill to improve zone_reclaim_mode either.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
