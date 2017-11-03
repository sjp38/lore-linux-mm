Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 889A86B025F
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 09:40:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k15so1636113wrc.1
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 06:40:43 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id s52si5075809eda.2.2017.11.03.06.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 06:40:42 -0700 (PDT)
Received: from outbound-smtp14.blacknight.com (outbound-smtp14.blacknight.com [46.22.139.231])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id E35A11C2959
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 13:40:41 +0000 (GMT)
Received: from mail.blacknight.com (unknown [81.17.254.17])
	by outbound-smtp14.blacknight.com (Postfix) with ESMTPS id D2AB51C29FA
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 13:40:41 +0000 (GMT)
Date: Fri, 3 Nov 2017 13:40:20 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator bottleneck
Message-ID: <20171103134020.3hwquerifnc6k6qw@techsingularity.net>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Thu, Nov 02, 2017 at 07:21:09PM +0200, Tariq Toukan wrote:
> 
> 
> On 18/09/2017 12:16 PM, Tariq Toukan wrote:
> > 
> > 
> > On 15/09/2017 1:23 PM, Mel Gorman wrote:
> > > On Thu, Sep 14, 2017 at 07:49:31PM +0300, Tariq Toukan wrote:
> > > > Insights: Major degradation between #1 and #2, not getting any
> > > > close to linerate! Degradation is fixed between #2 and #3. This is
> > > > because page allocator cannot stand the higher allocation rate. In
> > > > #2, we also see that the addition of rings (cores) reduces BW (!!),
> > > > as result of increasing congestion over shared resources.
> > > > 
> > > 
> > > Unfortunately, no surprises there.
> > > 
> > > > Congestion in this case is very clear. When monitored in perf
> > > > top: 85.58% [kernel] [k] queued_spin_lock_slowpath
> > > > 
> > > 
> > > While it's not proven, the most likely candidate is the zone lock
> > > and that should be confirmed using a call-graph profile. If so, then
> > > the suggestion to tune to the size of the per-cpu allocator would
> > > mitigate the problem.
> > > 
> > Indeed, I tuned the per-cpu allocator and bottleneck is released.
> > 
> 
> Hi all,
> 
> After leaving this task for a while doing other tasks, I got back to it now
> and see that the good behavior I observed earlier was not stable.
> 
> Recall: I work with a modified driver that allocates a page (4K) per packet
> (MTU=1500), in order to simulate the stress on page-allocator in 200Gbps
> NICs.
> 

There is almost new in the data that hasn't been discussed before. The
suggestion to free on a remote per-cpu list would be expensive as it would
require per-cpu lists to have a lock for safe remote access.  However,
I'd be curious if you could test the mm-pagealloc-irqpvec-v1r4 branch
ttps://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git .  It's an
unfinished prototype I worked on a few weeks ago. I was going to revisit
in about a months time when 4.15-rc1 was out. I'd be interested in seeing
if it has a postive gain in normal page allocations without destroying
the performance of interrupt and softirq allocation contexts. The
interrupt/softirq context testing is crucial as that is something that
hurt us before when trying to improve page allocator performance.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
