Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE587C4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 11:41:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 530D62075C
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 11:41:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EVX0v2+b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 530D62075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3E3A6B0003; Thu, 12 Sep 2019 07:41:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEEC06B0005; Thu, 12 Sep 2019 07:41:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DD386B0006; Thu, 12 Sep 2019 07:41:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1EE6B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 07:41:39 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E09F0180AD801
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 11:41:38 +0000 (UTC)
X-FDA: 75926078676.18.alarm08_487e36b387b56
X-HE-Tag: alarm08_487e36b387b56
X-Filterd-Recvd-Size: 16462
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 11:41:38 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id d3so11720219plr.1
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 04:41:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7jb+73QIWJBQBvXdpD48OsLrGOfQt35wV5e9eTpixiI=;
        b=EVX0v2+bwURnn2UjEWN681fGGe4NXW94jt86chvHKSgSIEt1TSXS4cTggD2YmpzmC/
         eR6Z2JDcHpu8C5tzqNSrOKRh+lWqTHmGLbvMRgkkGJQyrnIh7vfbwQuWt8qiJ7FxvFSr
         p/1cuuxRIxCTpdqQo7cMK8skyD0Aq9sPyTwXDgDuLE2Y6i2d+pOSt1HfgZb+KXB9Ksyr
         HUn5ImmpjYDe4yNMZModtFCF0z5rOfVgA5Vmk9AMMrsk6bi6rXEshjN5eOlfd9zKhFIY
         iqK2410yb9A/l/ZHYWOLsLwKn7vnww1qWOIC55h99Z5Ow3GTVRRjoFRQ/BhVLN2vFk2x
         ukcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=7jb+73QIWJBQBvXdpD48OsLrGOfQt35wV5e9eTpixiI=;
        b=pleBls1f7mxBvUhyoyvuGrYXIc5p0UERxcEw8zydYKnoh80h6bRzJ2hQ3JOJ5B8nVZ
         XCwpR8UTk4JF8GO8Oy8U00iU2aSqNqcREA3q7sRdmxoY6chU11ImvqHZC2UAKbKIMWP7
         H6Oh6GbBirbofhf4VU3gF31yXGoSbZvyepsrIuiD/yhaoEHplDm7WlBNJHlVm084sIt/
         lfeLiPLs5bVU3MVQ+GnTHG6MB5kpy0Xfkd1tNl8ZSAwVTXycASJe8HU+QwjUTNKbVPcf
         PdsWMGd1ORy4a4nRs4aBa/r7CIkbnnT01yySKurD4DE9JGPAV4RsgoTsd1bUIbcO6P5c
         qTkQ==
X-Gm-Message-State: APjAAAVxB+/lTCOZncRyNs7CeD+NEo1ydb+BK4qnKIPnu8h8XP0KjIz3
	ORfdAKXrZzGTAEDBIGHa/io=
X-Google-Smtp-Source: APXvYqwkDHPD00AoXL5NQS39oyISQ56yBzkN2xW5YuvUQDSpxLTPMfhAjcshGHszaEgsRppXeZVVJQ==
X-Received: by 2002:a17:902:bd09:: with SMTP id p9mr34319395pls.28.1568288496935;
        Thu, 12 Sep 2019 04:41:36 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([117.198.99.29])
        by smtp.gmail.com with ESMTPSA id w6sm50192995pfj.17.2019.09.12.04.41.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Sep 2019 04:41:36 -0700 (PDT)
Date: Thu, 12 Sep 2019 17:11:27 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Nitin Gupta <nigupta@nvidia.com>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>,
	"willy@infradead.org" <willy@infradead.org>,
	"allison@lohutok.net" <allison@lohutok.net>,
	"vbabka@suse.cz" <vbabka@suse.cz>,
	"aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"cai@lca.pw" <cai@lca.pw>,
	"arunks@codeaurora.org" <arunks@codeaurora.org>,
	"yuzhao@google.com" <yuzhao@google.com>,
	"richard.weiyang@gmail.com" <richard.weiyang@gmail.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"khalid.aziz@oracle.com" <khalid.aziz@oracle.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: Add callback for defining compaction completion
Message-ID: <20190912114126.GA4219@bharath12345-Inspiron-5559>
References: <20190910200756.7143-1-nigupta@nvidia.com>
 <20190910201905.GG4023@dhcp22.suse.cz>
 <MN2PR12MB30229414332206E25B9F3B8BD8B60@MN2PR12MB3022.namprd12.prod.outlook.com>
 <20190911064520.GI4023@dhcp22.suse.cz>
 <4ba8a6810cb481204deae4a7171dded1d8b5e736.camel@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ba8a6810cb481204deae4a7171dded1d8b5e736.camel@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nitin,
On Wed, Sep 11, 2019 at 10:33:39PM +0000, Nitin Gupta wrote:
> On Wed, 2019-09-11 at 08:45 +0200, Michal Hocko wrote:
> > On Tue 10-09-19 22:27:53, Nitin Gupta wrote:
> > [...]
> > > > On Tue 10-09-19 13:07:32, Nitin Gupta wrote:
> > > > > For some applications we need to allocate almost all memory as
> > > > > hugepages.
> > > > > However, on a running system, higher order allocations can fail if the
> > > > > memory is fragmented. Linux kernel currently does on-demand
> > > > > compaction
> > > > > as we request more hugepages but this style of compaction incurs very
> > > > > high latency. Experiments with one-time full memory compaction
> > > > > (followed by hugepage allocations) shows that kernel is able to
> > > > > restore a highly fragmented memory state to a fairly compacted memory
> > > > > state within <1 sec for a 32G system. Such data suggests that a more
> > > > > proactive compaction can help us allocate a large fraction of memory
> > > > > as hugepages keeping allocation latencies low.
> > > > > 
> > > > > In general, compaction can introduce unexpected latencies for
> > > > > applications that don't even have strong requirements for contiguous
> > > > > allocations.
> > 
> > Could you expand on this a bit please? Gfp flags allow to express how
> > much the allocator try and compact for a high order allocations. Hugetlb
> > allocations tend to require retrying and heavy compaction to succeed and
> > the success rate tends to be pretty high from my experience.  Why that
> > is not case in your case?
> > 
The link to the driver you send on gitlab is not working :(
> Yes, I have the same observation: with `GFP_TRANSHUGE |
> __GFP_RETRY_MAYFAIL` I get very good success rate (~90% of free RAM
> allocated as hugepages). However, what I'm trying to point out is that this
> high success rate comes with high allocation latencies (90th percentile
> latency of 2206us). On the same system, the same high-order allocations
> which hit the fast path have latency <5us.
> 
> > > > > It is also hard to efficiently determine if the current
> > > > > system state can be easily compacted due to mixing of unmovable
> > > > > memory. Due to these reasons, automatic background compaction by the
> > > > > kernel itself is hard to get right in a way which does not hurt
> > > > > unsuspecting
> > > > applications or waste CPU cycles.
> > > > 
> > > > We do trigger background compaction on a high order pressure from the
> > > > page allocator by waking up kcompactd. Why is that not sufficient?
> > > > 
> > > 
> > > Whenever kcompactd is woken up, it does just enough work to create
> > > one free page of the given order (compaction_control.order) or higher.
> > 
> > This is an implementation detail IMHO. I am pretty sure we can do a
> > better auto tuning when there is an indication of a constant flow of
> > high order requests. This is no different from the memory reclaim in
> > principle. Just because the kswapd autotuning not fitting with your
> > particular workload you wouldn't want to export direct reclaim
> > functionality and call it from a random module. That is just doomed to
> > fail because different subsystems in control just leads to decisions
> > going against each other.
> > 
> 
> I don't want to go the route of adding any auto-tuning/perdiction code to
> control compaction in the kernel. I'm more inclined towards extending
> existing interfaces to allow compaction behavior to be controlled either
> from userspace or a kernel driver. Letting a random module control
> compaction or a root process pumping new tunables from sysfs is the same in
> principle.
Do you think a kernel module and root user process have the same
privileges? You can only export so much info to sysfs to use? Also
wouldn't this introduce more tunables, per driver tunables to be more
specific?
> This patch is in the spirit of simple extension to existing
> compaction_zone_order() which allows either a kernel driver or userspace
> (through sysfs) to control compaction.
> 
> Also, we should avoid driving hard parallels between reclaim and
> compaction: the former is often necessary for forward progress while the
> latter is often an optimization. Since contiguous allocations are mostly
> optimizations it's good to expose hooks from the kernel that let user
> (through a driver or userspace) control it using its own heuristics.
How is compaction an optimization? If I have a memory zone which has
memory pages more than zone_highwmark and if higher order allocations a
re failing because the memory is awfully fragmented, We need compaction
to furthur progress here. I have seen workloads where kswapd won't help
in progressing furthur because memory is so awfully fragmented.
The workload I am quoting is the thpscale_workload from Mel Gorman's mmtests
workloads.
> 
> I thought hard about whats lacking in current userspace interface (sysfs):
>  - /proc/sys/vm/compact_memory: full system compaction is not an option as
>    a viable pro-active compaction strategy.
Don't we have a sysfs interface to compact memory per node through 
/sys/devices/system/node/node<node_number>/compact? CONFIG_SYSFS AND
CONFIG_NUMA are enabled on a lot of systems? Why are we not talking
about this?
I don't think kcompactd can go finer grain than per node. per-zone is 
an option but then that would be overkill I feel.
>  - possibly expose [low, high] threshold values for each node and let
>    kcompactd act on them. This was my approach for my original patch I
>    linked earlier. Problem here is that it introduces too many tunables.
> 
> Considering the above, I came up with this callback approach which make it
> trivial to introduce user specific policies for compaction. It puts the
> onus of system stability, responsive in the hands of user without burdening
> admins with more tunables or adding crystal balls to kernel.
I have the same question as Michal, that is won't this cause conflicts
among different subsystems? If you did answer it in your previous
mails, could you point to as I may have missed it :)
> > > Such a design causes very high latency for workloads where we want
> > > to allocate lots of hugepages in short period of time. With pro-active
> > > compaction we can hide much of this latency. For some more background
> > > discussion and data, please see this thread:
> > > 
> > > https://patchwork.kernel.org/patch/11098289/
> > 
> > I am aware of that thread. And there are two things. You claim the
> > allocation success rate is unnecessarily lower and that the direct
> > latency is high. You simply cannot assume both low latency and high
> > success rate. Compaction is not free. Somebody has to do the work.
> > Hiding it into the background means that you are eating a lot of cycles
> > from everybody else (think of a workload running in a restricted cpu
> > controller just doing a lot of work in an unaccounted context).
> > 
> > That being said you really have to be prepared to pay a price for
> > precious resource like high order pages.
> > 
> > On the other hand I do understand that high latency is not really
> > desired for a more optimistic allocation requests with a reasonable
> > fallback strategy. Those would benefit from kcompactd not giving up too
> > early.
> 
> Doing pro-active compaction in background has merits in reducing reducing
> high-order alloc latency. Its true that it would end up burning cycles with
> little benefit in some cases. Its upto the user of this new interface to
> back off if it detects such a case.
Are these cycles worth considering in the big picture of reducing high
order allocation latency? 
> >  
> > > > > Even with these caveats, pro-active compaction can still be very
> > > > > useful in certain scenarios to reduce hugepage allocation latencies.
> > > > > This callback interface allows drivers to drive compaction based on
> > > > > their own policies like the current level of external fragmentation
> > > > > for a particular order, system load etc.
> > > > 
> > > > So we do not trust the core MM to make a reasonable decision while we
> > > > give
> > > > a free ticket to modules. How does this make any sense at all? How is a
> > > > random module going to make a more informed decision when it has less
> > > > visibility on the overal MM situation.
> > > > 
> > > 
> > > Embedding any specific policy (like: keep external fragmentation for
> > > order-9
> > > between 30-40%) within MM core looks like a bad idea.
> > 
> > Agreed
> > 
> > > As a driver, we
> > > can easily measure parameters like system load, current fragmentation
> > > level
> > > for any order in any zone etc. to make an informed decision.
> > > See the thread I refereed above for more background discussion.
> > 
> > Do that from the userspace then. If there is an insufficient interface
> > to do that then let's talk about what is missing.
> > 
> 
> Currently we only have a proc interface to do full system compaction.
> Here's what missing from this interface: ability to set per-node, per-zone,
> per-order, [low, high] extfrag thresholds. This is what I exposed in my
> earlier patch titled 'proactive compaction'. Discussion there made me realize
> these are too many tunables and any admin would always get them wrong. Even
> if intended user of these sysfs node is some monitoring daemon, its
> tempting to mess with them.
> 
> With a callback extension to compact_zone_order() implementing any of the
> per-node, per-zone, per-order limits is straightforward and if needed the
> driver can expose debugfs/sysfs nodes if needed at all. (nvcompact.c
> driver[1] exposes these tunables as debugfs nodes, for example).
> 
> [1] https://gitlab.com/nigupta/linux/snippets/1894161
Now, your proposing a system where we have interfaces from each driver.
That could be more confusing for a sys admin to configure I feel?

But what your proposing really made me think about  what kind
of tunables do we want? Rather than just talking about tunables from the
mm subsystem, can we introduce tunables that indicate the behaviour of
workloads? Using this information from the user, we can look to optimize 
reclaim and compaction for that workload.
If we have a tunable which can indicate that the kernel is running in an
environment where the where the workload will be performing a lot of
higher order allocations, we can improve memory reclaim and compaction
considering these parameters. One optimization I can think of extending
kcompactd to compact more memory when a higher order allocation fails.

One of the biggest issues with having a discussion on proactive
reclaim/compaction is that the workloads are really unpredictable. 
Rather than working on tunables from the mm subsystem which help us take
action on memory pressure, can we talk about interfaces to hint about
workloads so that we can make better informed decisions in the mm
subsystem rather than involving other drivers?
> 
> > > > If you need to control compaction from the userspace you have an
> > > > interface
> > > > for that.  It is also completely unexplained why you need a completion
> > > > callback.
> > > > 
> > > 
> > > /proc/sys/vm/compact_memory does whole system compaction which is
> > > often too much as a pro-active compaction strategy. To get more control
> > > over how to compaction work to do, I have added a compaction callback
> > > which controls how much work is done in one compaction cycle.
> > 
> > Why is a more fine grained control really needed? Sure compacting
> > everything is heavy weight but how often do you have to do that. Your
> > changelog starts with a usecase when there is a high demand for large
> > pages at the startup. What prevents you do compaction at that time. If
> > the workload is longterm then the initial price should just pay back,
> > no?
> > 
> 
> Compacting all NUMA nodes is not practical on large systems in response to,
> say, launching a DB process on a certain node. Also, the frequency of
> hugepage allocation burts may be completely unpredictable. That's why
> background compaction can keep extfrag in check, say while system is
> lightly loaded (adhoc policy), keeping high-order allocation latencies low
> whenever the burst shows up.
> 
> - Nitin
> 
Thank you
Bharath

