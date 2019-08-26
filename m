Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7403AC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:47:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25C0820874
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:47:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25C0820874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4FA96B0570; Mon, 26 Aug 2019 07:47:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A26766B0571; Mon, 26 Aug 2019 07:47:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93CEC6B0572; Mon, 26 Aug 2019 07:47:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 758146B0570
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:47:33 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 23FBC1F06
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:47:33 +0000 (UTC)
X-FDA: 75864403986.18.duck87_79c031278915
X-HE-Tag: duck87_79c031278915
X-Filterd-Recvd-Size: 12056
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com [81.17.249.8])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:47:32 +0000 (UTC)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 6B99798A2B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:47:30 +0100 (IST)
Received: (qmail 1646 invoked from network); 26 Aug 2019 11:47:30 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 26 Aug 2019 11:47:30 -0000
Date: Mon, 26 Aug 2019 12:47:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Nitin Gupta <nigupta@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"vbabka@suse.cz" <vbabka@suse.cz>,
	"mhocko@suse.com" <mhocko@suse.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	Yu Zhao <yuzhao@google.com>, Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Roman Gushchin <guro@fb.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Arun KS <arunks@codeaurora.org>,
	Janne Huttunen <janne.huttunen@nokia.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC] mm: Proactive compaction
Message-ID: <20190826114727.GT2739@techsingularity.net>
References: <20190816214413.15006-1-nigupta@nvidia.com>
 <20190822085135.GS2739@techsingularity.net>
 <BYAPR12MB3015E9DC9DDBA965372ABA6BD8A50@BYAPR12MB3015.namprd12.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <BYAPR12MB3015E9DC9DDBA965372ABA6BD8A50@BYAPR12MB3015.namprd12.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 09:57:22PM +0000, Nitin Gupta wrote:
> > Note that proactive compaction may reduce allocation latency but it is not
> > free either. Even though the scanning and migration may happen in a kernel
> > thread, tasks can incur faults while waiting for compaction to complete if the
> > task accesses data being migrated. This means that costs are incurred by
> > applications on a system that may never care about high-order allocation
> > latency -- particularly if the allocations typically happen at application
> > initialisation time.  I recognise that kcompactd makes a bit of effort to
> > compact memory out-of-band but it also is typically triggered in response to
> > reclaim that was triggered by a high-order allocation request. i.e. the work
> > done by the thread is triggered by an allocation request that hit the slow
> > paths and not a preemptive measure.
> > 
> 
> Hitting the slow path for every higher-order allocation is a signification
> performance/latency issue for applications that requires a large number of
> these allocations to succeed in bursts. To get some concrete numbers, I
> made a small driver that allocates as many hugepages as possible and
> measures allocation latency:
> 

Every higher-order allocation does not necessarily hit the slow path nor
does it incur equal latency.

> The driver first tries to allocate hugepage using GFP_TRANSHUGE_LIGHT
> (referred to as "Light" in the table below) and if that fails, tries to
> allocate with `GFP_TRANSHUGE | __GFP_RETRY_MAYFAIL` (referred to as
> "Fallback" in table below). We stop the allocation loop if both methods
> fail.
> 
> Table-1: hugepage allocation latencies on vanilla 5.3.0-rc5. All latencies
> are in microsec.
> 
> | GFP/Stat |        Any |   Light |   Fallback |
> |--------: | ---------: | ------: | ---------: |
> |    count |       9908 |     788 |       9120 |
> |      min |        0.0 |     0.0 |     1726.0 |
> |      max |   135387.0 |   142.0 |   135387.0 |
> |     mean |    5494.66 |    1.83 |    5969.26 |
> |   stddev |   21624.04 |    7.58 |   22476.06 |
> 

Given that it is expected that there would be significant tail latencies,
it would be better to analyse this in terms of percentiles. A very small
number of high latency allocations would skew the mean significantly
which is hinted by the stddev.

> As you can see, the mean and stddev of allocation is extremely high with
> the current approach of on-demand compaction.
> 
> The system was fragmented from a userspace program as I described in this
> patch description. The workload is mainly anonymous userspace pages which
> as easy to move around. I intentionally avoided unmovable pages in this
> test to see how much latency do we incur just by hitting the slow path for
> a majority of allocations.
> 

Even though, the penalty for proactive compaction is that applications
that may have no interest in higher-order pages may still stall while
their data is migrated if the data is hot. This is why I think the focus
should be on reducing the latency of compaction -- it benefits
applications that require higher-order latencies without increasing the
overhead for unrelated applications.

> 
> > > For a more proactive compaction, the approach taken here is to define
> > > per page-order external fragmentation thresholds and let kcompactd
> > > threads act on these thresholds.
> > >
> > > The low and high thresholds are defined per page-order and exposed
> > > through sysfs:
> > >
> > >   /sys/kernel/mm/compaction/order-[1..MAX_ORDER]/extfrag_{low,high}
> > >
> > 
> > These will be difficult for an admin to tune that is not extremely familiar with
> > how external fragmentation is defined. If an admin asked "how much will
> > stalls be reduced by setting this to a different value?", the answer will always
> > be "I don't know, maybe some, maybe not".
> >
> 
> Yes, this is my main worry. These values can be set to emperically
> determined values on highly specialized systems like database appliances.
> However, on a generic system, there is no real reasonable value.
> 

Yep, which means the tunable will be vulnerable to cargo-cult tuning
recommendations. Or worse, the tuning recommendation will be a flat
"disable THP".

> Still, at the very least, I would like an interface that allows compacting
> system to a reasonable state. Something like:
> 
>     compact_extfrag(node, zone, order, high, low)
> 
> which start compaction if extfrag > high, and goes on till extfrag < low.
> 
> It's possible that there are too many unmovable pages mixed around for
> compaction to succeed, still it's a reasonable interface to expose rather
> than forced on-demand style of compaction (please see data below).
> 
> How (and if) to expose it to userspace (sysfs etc.) can be a separate
> discussion.
> 

That would be functionally similar to vm.compact_memory although it
would either need an extension or a separate tunable. With sysfs, there
could be a per-node file that takes with a watermark and order tuple to
trigger the interface.

> 
> > > Per-node kcompactd thread is woken up every few seconds to check if
> > > any zone on its node has extfrag above the extfrag_high threshold for
> > > any order, in which case the thread starts compaction in the backgrond
> > > till all zones are below extfrag_low level for all orders. By default
> > > both these thresolds are set to 100 for all orders which essentially
> > > disables kcompactd.
> > >
> > > To avoid wasting CPU cycles when compaction cannot help, such as when
> > > memory is full, we check both, extfrag > extfrag_high and
> > > compaction_suitable(zone). This allows kcomapctd thread to stays
> > > inactive even if extfrag thresholds are not met.
> > >
> > 
> > There is still a risk that if a system is completely fragmented that it may
> > consume CPU on pointless compaction cycles. This is why compaction from
> > kernel thread context makes no special effort and bails relatively quickly and
> > assumes that if an application really needs high-order pages that it'll incur
> > the cost at allocation time.
> > 
> 
> As data in Table-1 shows, on-demand compaction can add high latency to
> every single allocation. I think it would be a significant improvement (see
> Table-2) to at least expose an interface to allow proactive compaction
> (like compaction_extfrag), which a driver can itself run in background. This
> way, we need not add any tunables to the kernel itself and leave compaction
> decision to specialized kernel/userspace monitors.
> 

I do not have any major objection -- again, it's not that dissimilar to
compact_memory (although that was intended as a debugging interface).

> 
> > > This patch is largely based on ideas from Michal Hocko posted here:
> > > https://lore.kernel.org/linux-
> > mm/20161230131412.GI13301@dhcp22.suse.cz
> > > /
> > >
> > > Testing done (on x86):
> > >  - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} = {25, 30}
> > > respectively.
> > >  - Use a test program to fragment memory: the program allocates all
> > > memory  and then for each 2M aligned section, frees 3/4 of base pages
> > > using  munmap.
> > >  - kcompactd0 detects fragmentation for order-9 > extfrag_high and
> > > starts  compaction till extfrag < extfrag_low for order-9.
> > >
> > 
> > This is a somewhat optimisitic allocation scenario. The interesting ones are
> > when a system is fragmenteed in a manner that is not trivial to resolve -- e.g.
> > after a prolonged period of time with unmovable/reclaimable allocations
> > stealing pageblocks. It's also fairly difficult to analyse if this is helping
> > because you cannot measure after the fact how much time was saved in
> > allocation time due to the work done by kcompactd. It is also hard to
> > determine if the sum of the stalls incurred by proactive compaction is lower
> > than the time saved at allocation time.
> > 
> > I fear that the user-visible effect will be times when there are very short but
> > numerous stalls due to proactive compaction running in the background that
> > will be hard to detect while the benefits may be invisible.
> > 
> 
> Pro-active compaction can be done in a non-time-critical context, so to
> estimate its benefits we can just compare data from Table-1 the same run,
> under a similar fragmentation state, but with this patch applied:
> 

How do you define what a non-time-critical context is? Once compaction
starts, an applications data becomes temporarily unavailable during
migration.

> 
> Table-2: hugepage allocation latencies with this patch applied on
> 5.3.0-rc5.
> 
> | GFP_Stat |        Any |     Light |   Fallback |
> | --------:| ----------:| ---------:| ----------:|
> |   count  |   12197.0  |  11167.0  |    1030.0  |
> |     min  |       2.0  |      2.0  |       5.0  |
> |     max  |  361727.0  |     26.0  |  361727.0  |
> |    mean  |    366.05  |     4.48  |   4286.13  |
> |   stddev |   4575.53  |     1.41  |  15209.63  |
> 
> 
> We can see that mean latency dropped to 366us compared with 5494us before.
> 
> This is an optimistic scenario where there was a little mix of unmovable
> pages but still the data shows that in case compaction can succeed,
> pro-active compaction can give signification reduction higher-order
> allocation latencies.
> 

Which still does not address the point that reducing compaction overhead
is generally beneficial without incurring additional overhead to
unrelated applications.

I'm not against the use of an interface because it requires an application
to make a deliberate choice and understand the downsides which can be
documented. An automatic proactive compaction may impact users that have
no idea the feature even exists.

-- 
Mel Gorman
SUSE Labs

