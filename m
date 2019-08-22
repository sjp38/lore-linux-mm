Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 882A9C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:51:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 344E521848
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:51:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 344E521848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84986B02E4; Thu, 22 Aug 2019 04:51:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D34276B02E5; Thu, 22 Aug 2019 04:51:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4CA46B02E6; Thu, 22 Aug 2019 04:51:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id A46946B02E4
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 04:51:41 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 57F448154
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:51:41 +0000 (UTC)
X-FDA: 75849445602.30.range43_8309da2960130
X-HE-Tag: range43_8309da2960130
X-Filterd-Recvd-Size: 6879
Received: from outbound-smtp15.blacknight.com (outbound-smtp15.blacknight.com [46.22.139.232])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:51:40 +0000 (UTC)
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp15.blacknight.com (Postfix) with ESMTPS id A63DE1C2196
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:51:38 +0100 (IST)
Received: (qmail 25689 invoked from network); 22 Aug 2019 08:51:38 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 22 Aug 2019 08:51:38 -0000
Date: Thu, 22 Aug 2019 09:51:35 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Nitin Gupta <nigupta@nvidia.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com,
	dan.j.williams@intel.com, Yu Zhao <yuzhao@google.com>,
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Roman Gushchin <guro@fb.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Arun KS <arunks@codeaurora.org>,
	Janne Huttunen <janne.huttunen@nokia.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC] mm: Proactive compaction
Message-ID: <20190822085135.GS2739@techsingularity.net>
References: <20190816214413.15006-1-nigupta@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190816214413.15006-1-nigupta@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 02:43:30PM -0700, Nitin Gupta wrote:
> For some applications we need to allocate almost all memory as
> hugepages. However, on a running system, higher order allocations can
> fail if the memory is fragmented. Linux kernel currently does
> on-demand compaction as we request more hugepages but this style of
> compaction incurs very high latency. Experiments with one-time full
> memory compaction (followed by hugepage allocations) shows that kernel
> is able to restore a highly fragmented memory state to a fairly
> compacted memory state within <1 sec for a 32G system. Such data
> suggests that a more proactive compaction can help us allocate a large
> fraction of memory as hugepages keeping allocation latencies low.
> 

Note that proactive compaction may reduce allocation latency but it is not
free either. Even though the scanning and migration may happen in a kernel
thread, tasks can incur faults while waiting for compaction to complete if
the task accesses data being migrated. This means that costs are incurred
by applications on a system that may never care about high-order allocation
latency -- particularly if the allocations typically happen at application
initialisation time.  I recognise that kcompactd makes a bit of effort to
compact memory out-of-band but it also is typically triggered in response
to reclaim that was triggered by a high-order allocation request. i.e. the
work done by the thread is triggered by an allocation request that hit
the slow paths and not a preemptive measure.

> For a more proactive compaction, the approach taken here is to define
> per page-order external fragmentation thresholds and let kcompactd
> threads act on these thresholds.
> 
> The low and high thresholds are defined per page-order and exposed
> through sysfs:
> 
>   /sys/kernel/mm/compaction/order-[1..MAX_ORDER]/extfrag_{low,high}
> 

These will be difficult for an admin to tune that is not extremely
familiar with how external fragmentation is defined. If an admin asked
"how much will stalls be reduced by setting this to a different value?",
the answer will always be "I don't know, maybe some, maybe not".

> Per-node kcompactd thread is woken up every few seconds to check if
> any zone on its node has extfrag above the extfrag_high threshold for
> any order, in which case the thread starts compaction in the backgrond
> till all zones are below extfrag_low level for all orders. By default
> both these thresolds are set to 100 for all orders which essentially
> disables kcompactd.
> 
> To avoid wasting CPU cycles when compaction cannot help, such as when
> memory is full, we check both, extfrag > extfrag_high and
> compaction_suitable(zone). This allows kcomapctd thread to stays inactive
> even if extfrag thresholds are not met.
> 

There is still a risk that if a system is completely fragmented that it
may consume CPU on pointless compaction cycles. This is why compaction
from kernel thread context makes no special effort and bails relatively
quickly and assumes that if an application really needs high-order pages
that it'll incur the cost at allocation time. 

> This patch is largely based on ideas from Michal Hocko posted here:
> https://lore.kernel.org/linux-mm/20161230131412.GI13301@dhcp22.suse.cz/
> 
> Testing done (on x86):
>  - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} = {25, 30}
>  respectively.
>  - Use a test program to fragment memory: the program allocates all memory
>  and then for each 2M aligned section, frees 3/4 of base pages using
>  munmap.
>  - kcompactd0 detects fragmentation for order-9 > extfrag_high and starts
>  compaction till extfrag < extfrag_low for order-9.
> 

This is a somewhat optimisitic allocation scenario. The interesting
ones are when a system is fragmenteed in a manner that is not trivial to
resolve -- e.g. after a prolonged period of time with unmovable/reclaimable
allocations stealing pageblocks. It's also fairly difficult to analyse
if this is helping because you cannot measure after the fact how much
time was saved in allocation time due to the work done by kcompactd. It
is also hard to determine if the sum of the stalls incurred by proactive
compaction is lower than the time saved at allocation time.

I fear that the user-visible effect will be times when there are very
short but numerous stalls due to proactive compaction running in the
background that will be hard to detect while the benefits may be invisible.

> The patch has plenty of rough edges but posting it early to see if I'm
> going in the right direction and to get some early feedback.
> 

As unappealing as it sounds, I think it is better to try improve the
allocation latency itself instead of trying to hide the cost in a kernel
thread. It's far harder to implement as compaction is not easy but it
would be more obvious what the savings are by looking at a histogram of
allocation latencies -- there are other metrics that could be considered
but that's the obvious one.

-- 
Mel Gorman
SUSE Labs

