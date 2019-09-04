Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0EC3C3A5AB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:55:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81C8221883
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:55:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81C8221883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EDFD6B0006; Wed,  4 Sep 2019 16:55:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29E816B0007; Wed,  4 Sep 2019 16:55:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5F66B0008; Wed,  4 Sep 2019 16:55:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id EFA3F6B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:55:24 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9D16D180AD801
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:55:24 +0000 (UTC)
X-FDA: 75898443768.27.kick82_4c4a247465b03
X-HE-Tag: kick82_4c4a247465b03
X-Filterd-Recvd-Size: 9834
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:55:24 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0783C7FD45;
	Wed,  4 Sep 2019 20:55:23 +0000 (UTC)
Received: from mail (ovpn-120-101.rdu2.redhat.com [10.10.120.101])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BF5735D9E1;
	Wed,  4 Sep 2019 20:55:22 +0000 (UTC)
Date: Wed, 4 Sep 2019 16:55:22 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote hugepages
Message-ID: <20190904205522.GA9871@redhat.com>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 04 Sep 2019 20:55:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 04, 2019 at 12:54:15PM -0700, David Rientjes wrote:
> Two commits:
> 
> commit a8282608c88e08b1782141026eab61204c1e533f
> Author: Andrea Arcangeli <aarcange@redhat.com>
> Date:   Tue Aug 13 15:37:53 2019 -0700
> 
>     Revert "mm, thp: restore node-local hugepage allocations"
> 
> commit 92717d429b38e4f9f934eed7e605cc42858f1839
> Author: Andrea Arcangeli <aarcange@redhat.com>
> Date:   Tue Aug 13 15:37:50 2019 -0700
> 
>     Revert "Revert "mm, thp: consolidate THP gfp handling into alloc_hugepage_direct_gfpmask""
> 
> made their way into 5.3-rc5
> 
> We (mostly Linus, Andrea, and myself) have been discussing offlist how to
> implement a sane default allocation strategy for hugepages on NUMA
> platforms.
> 
> With these reverts in place, the page allocator will happily allocate a
> remote hugepage immediately rather than try to make a local hugepage
> available.  This incurs a substantial performance degradation when
> memory compaction would have otherwise made a local hugepage available.
> 
> This series reverts those reverts and attempts to propose a more sane
> default allocation strategy specifically for hugepages.  Andrea
> acknowledges this is likely to fix the swap storms that he originally
> reported that resulted in the patches that removed __GFP_THISNODE from
> hugepage allocations.

I sent a single comment about this patch in the private email thread
you started, and I quote my answer below for full disclosure:

============
> This is an admittedly hacky solution that shouldn't cause anybody to 
> regress based on NUMA and the semantics of MADV_HUGEPAGE for the past 
> 4 1/2 years for users whose workload does fit within a socket.

How can you live with the below if you can't live with 5.3-rc6? Here
you allocate remote THP if the local THP allocation fails.

>  			page = __alloc_pages_node(hpage_node,
>  						gfp | __GFP_THISNODE, order);
> +
> +			/*
> +			 * If hugepage allocations are configured to always
> +			 * synchronous compact or the vma has been madvised
> +			 * to prefer hugepage backing, retry allowing remote
> +			 * memory as well.
> +			 */
> +			if (!page && (gfp & __GFP_DIRECT_RECLAIM))
> +				page = __alloc_pages_node(hpage_node,
> +						gfp | __GFP_NORETRY, order);
> +

You're still going to get THP allocate remote _before_ you have a
chance to allocate 4k local this way. __GFP_NORETRY won't make any
difference when there's THP immediately available in the remote nodes.

My suggestion is to stop touching and tweaking the gfp_mask second
parameter, and I suggest you to tweak the third parameter instead. If
you set the order=(1<<0)|(1<<9) (instead of current order = 9), only
then we'll move in the right direction and we'll get something that
can work better than 5.3-rc6 no matter what which workload you throw
at it.

> +		 if (order >= pageblock_order && (gfp_mask & __GFP_IO)) {
> +			/*
> +			 * If allocating entire pageblock(s) and compaction
> +			 * failed because all zones are below low watermarks
> +			 * or is prohibited because it recently failed at this
> +			 * order, fail immediately.
> +			 *
> +			 * Reclaim is
> +			 *  - potentially very expensive because zones are far
> +			 *    below their low watermarks or this is part of very
> +			 *    bursty high order allocations,
> +			 *  - not guaranteed to help because isolate_freepages()
> +			 *    may not iterate over freed pages as part of its
> +			 *    linear scan, and
> +			 *  - unlikely to make entire pageblocks free on its
> +			 *    own.
> +			 */
> +			if (compact_result == COMPACT_SKIPPED ||
> +			    compact_result == COMPACT_DEFERRED)
> +				goto nopage;
> +		}
> +

Overall this patch would solve the swap storms and it's similar to
__GFP_COMPACTONLY but it also allows to allocate THP in the remote
nodes if remote THP are immediately available in the buddy (despite
there may also be local 4k memory immediately available in the
buddy). So it's just better than just __GFP_COMPACTONLY but it still
cripples compaction a bit and it won't really work a whole lot
different than 5.3-rc6 in terms of prioritizing local 4k over remote
THP.

So it's not clear why you can't live with 5.3-rc6 if you can live with
the above that will provide you no more guarantees than 5.3-rc6 to get
local 4k before remote THP.

Thanks,
Andrea
==============

> The immediate goal is to return 5.3 to the behavior the kernel has
> implemented over the past several years so that remote hugepages are
> not immediately allocated when local hugepages could have been made
> available because the increased access latency is untenable.

Remote hugepages are immediately allocated before local 4k pages with
that patch you sent.

> +				page = __alloc_pages_node(hpage_node,
> +						gfp | __GFP_NORETRY, order);

This doesn't prevent to allocate remote THP if they are immediately
available.

> Merging these reverts late in the rc cycle to change behavior that has
> existed for years and is known (and acknowledged) to create performance
> degradations when local hugepages could have been made available serves
> no purpose other than to make the development of a sane default policy
> much more difficult under time pressure and to accelerate decisions that
> will affect how userspace is written (and how it has regressed) that
> otherwise require carefully crafted and detailed implementations.

Your change is calling alloc_pages first with __GFP_THISNODE in a
__GFP_COMPACTONLY way, and then it falls back immediately to allocate
2M on all nodes, including the local node for a second time, before
allocating local 4k (with a magical __GFP_NORETRY which won't make a
difference anyway if the 2m pages are immediately available).

> Thus, this patch series returns 5.3 to the long-standing allocation
> strategy that Linux has had for years and proposes to follow-up changes
> that can be discussed that Andrea acknowledges will avoid the swap storms
> that initially triggered this discussion in the first place.

I said one good thing about this patch series, that it fixes the swap
storms. But upstream 5.3 fixes the swap storms too and what you sent
is not nearly equivalent to the mempolicy that Michal was willing
to provide you and that we thought you needed to get bigger guarantees
of getting only local 2m or local 4k pages.

In fact we could weaken the aggressiveness of the proposed mempolicy
of an order of magnitude if you can live with the above and the above
performs well for you.

If you could post an open source reproducer of your proprietary binary
that got regressed by 5.3, we could help finding a solution. Instead
it's not clear how you can live with this patch series, but not with
5.3 and also why you insist not making this new allocation policy an
opt-in mempolicy.

Furthermore no generic benchmark has been run on this series to be
sure it won't regress performance for common workloads. So it's
certainly more risky than the current 5.3 status which matches what's
running in production on most enterprise distro.

I thought you clarified that the page fault latency was not the
primary reason you had __GFP_THISNODE there. If instead you've still
got a latency issue in the 2M page fault and that was the real reason
of __GFP_THISNODE, why don't you lower the latency of compaction in
remote nodes without having to call alloc_pages 3 times? I mean I
proposed to call alloc_pages just once instead of the current twice,
with your patch we'd be calling alloc_pages three times, with a
repetition attempt even on the 2m page size on the local node.

Obviously this "hacky solution" is better than 5.3-rc4 and all
previous because it at least doesn't create swap storms. What's not
clear is how this is going to work better than upstream for you. What
I think will happen is that this will work similarly to
__GFP_COMPACTONLY and it'll will weaken THP utilization ratio for
MADV_HUGEPAGE users and it's not tested to be sure it won't perform
worse in other conditions.

Thanks,
Andrea

