Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEE4E6B0504
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 19:19:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a186so1601980pge.8
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 16:19:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i186si67071pfb.657.2017.08.22.16.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 16:19:31 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/2] Separate NUMA statistics from zone statistics
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
	<alpine.DEB.2.20.1708221620060.18344@nuc-kabylake>
Date: Tue, 22 Aug 2017 16:19:30 -0700
In-Reply-To: <alpine.DEB.2.20.1708221620060.18344@nuc-kabylake> (Christopher
	Lameter's message of "Tue, 22 Aug 2017 16:22:40 -0500 (CDT)")
Message-ID: <874lszi41p.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kemi Wang <kemi.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Christopher Lameter <cl@linux.com> writes:

> Can we simple get rid of the stats or make then configurable (off by
> defaut)? I agree they are rarely used and have been rarely used in the past.
>
> Maybe some instrumentation for perf etc will allow
> similar statistics these days? Thus its possible to drop them?
>
> The space in the pcp pageset is precious and we should strive to use no
> more than a cacheline for the diffs.

The statistics are useful and we need them sometimes. And more and more
runtime switches are a pain -- if you need them they would be likely
turned off. The key is just to make them cheap enough that they're not a
problem.

The only problem was just that that the standard vmstats which are
optimized for readers too are too expensive for them.

The motivation for the patch was that the frequent atomics
were proven to slow the allocator down, and Kemi's patch
fixed it and he has shown it with lots of data.

I don't really see the point of so much discussion about a single cache
line.

There are lots of cache lines used all over the VM. Why is this one
special? Adding one more shouldn't be that bad.

But there's no data at all that touching another cache line
here is a problem.

It's next to an already touched cache line, so it's highly
likely that a prefetcher would catch it anyways.

I can see the point of worrying about over all cache line foot print
("death of a thousand cuts") but the right way to address problems like
this is use a profiler in a realistic workload and systematically
look at the code who actually has cache misses. And I bet we would
find quite a few that could be easily avoided and have real
payoff. I would really surprise me if it was this cache line.

But blocking real demonstrated improvements over a theoretical
cache line doesn't really help.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
