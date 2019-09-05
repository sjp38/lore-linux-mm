Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDD70C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 09:00:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3EAD21743
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 09:00:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3EAD21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A4EC6B0273; Thu,  5 Sep 2019 05:00:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27C956B0274; Thu,  5 Sep 2019 05:00:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 192676B0276; Thu,  5 Sep 2019 05:00:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id EBF606B0273
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 05:00:11 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7A447824CA39
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 09:00:11 +0000 (UTC)
X-FDA: 75900270222.13.day96_198eea45113a
X-HE-Tag: day96_198eea45113a
X-Filterd-Recvd-Size: 4669
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 09:00:10 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9EA39AE39;
	Thu,  5 Sep 2019 09:00:09 +0000 (UTC)
Date: Thu, 5 Sep 2019 11:00:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [rfc 3/4] mm, page_alloc: avoid expensive reclaim when
 compaction may not succeed
Message-ID: <20190905090009.GF3838@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1909041253390.94813@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1909041253390.94813@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Ccing Mike for checking on the hugetlb side of this change]

On Wed 04-09-19 12:54:22, David Rientjes wrote:
> Memory compaction has a couple significant drawbacks as the allocation
> order increases, specifically:
> 
>  - isolate_freepages() is responsible for finding free pages to use as
>    migration targets and is implemented as a linear scan of memory
>    starting at the end of a zone,
> 
>  - failing order-0 watermark checks in memory compaction does not account
>    for how far below the watermarks the zone actually is: to enable
>    migration, there must be *some* free memory available.  Per the above,
>    watermarks are not always suffficient if isolate_freepages() cannot
>    find the free memory but it could require hundreds of MBs of reclaim to
>    even reach this threshold (read: potentially very expensive reclaim with
>    no indication compaction can be successful), and
> 
>  - if compaction at this order has failed recently so that it does not even
>    run as a result of deferred compaction, looping through reclaim can often
>    be pointless.
> 
> For hugepage allocations, these are quite substantial drawbacks because
> these are very high order allocations (order-9 on x86) and falling back to
> doing reclaim can potentially be *very* expensive without any indication
> that compaction would even be successful.
> 
> Reclaim itself is unlikely to free entire pageblocks and certainly no
> reliance should be put on it to do so in isolation (recall lumpy reclaim).
> This means we should avoid reclaim and simply fail hugepage allocation if
> compaction is deferred.
> 
> It is also not helpful to thrash a zone by doing excessive reclaim if
> compaction may not be able to access that memory.  If order-0 watermarks
> fail and the allocation order is sufficiently large, it is likely better
> to fail the allocation rather than thrashing the zone.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4458,6 +4458,28 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		if (page)
>  			goto got_pg;
>  
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
>  		/*
>  		 * Checks for costly allocations with __GFP_NORETRY, which
>  		 * includes THP page fault allocations

-- 
Michal Hocko
SUSE Labs

