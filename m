Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABBDFC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 08:09:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66704206C2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 08:09:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66704206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB50C6B0003; Mon, 12 Aug 2019 04:09:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D65EC6B0005; Mon, 12 Aug 2019 04:09:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C544E6B0006; Mon, 12 Aug 2019 04:09:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0007.hostedemail.com [216.40.44.7])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7BC6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 04:09:56 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4E6248248AA3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:09:56 +0000 (UTC)
X-FDA: 75813052392.21.jewel73_39987b0038731
X-HE-Tag: jewel73_39987b0038731
X-Filterd-Recvd-Size: 6549
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:09:55 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1017FAF7E;
	Mon, 12 Aug 2019 08:09:54 +0000 (UTC)
Date: Mon, 12 Aug 2019 10:09:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH] mm: drop mark_page_access from the unmap path
Message-ID: <20190812080947.GA5117@dhcp22.suse.cz>
References: <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
 <20190730125751.GS9330@dhcp22.suse.cz>
 <20190731054447.GB155569@google.com>
 <20190731072101.GX9330@dhcp22.suse.cz>
 <20190806105509.GA94582@google.com>
 <20190809124305.GQ18351@dhcp22.suse.cz>
 <20190809183424.GA22347@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809183424.GA22347@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 14:34:24, Johannes Weiner wrote:
> On Fri, Aug 09, 2019 at 02:43:24PM +0200, Michal Hocko wrote:
> > On Tue 06-08-19 19:55:09, Minchan Kim wrote:
> > > On Wed, Jul 31, 2019 at 09:21:01AM +0200, Michal Hocko wrote:
> > > > On Wed 31-07-19 14:44:47, Minchan Kim wrote:
> > [...]
> > > > > As Nick mentioned in the description, without mark_page_accessed in
> > > > > zapping part, repeated mmap + touch + munmap never acticated the page
> > > > > while several read(2) calls easily promote it.
> > > > 
> > > > And is this really a problem? If we refault the same page then the
> > > > refaults detection should catch it no? In other words is the above still
> > > > a problem these days?
> > > 
> > > I admit we have been not fair for them because read(2) syscall pages are
> > > easily promoted regardless of zap timing unlike mmap-based pages.
> > > 
> > > However, if we remove the mark_page_accessed in the zap_pte_range, it
> > > would make them more unfair in that read(2)-accessed pages are easily
> > > promoted while mmap-based page should go through refault to be promoted.
> > 
> > I have really hard time to follow why an unmap special handling is
> > making the overall state more reasonable.
> > 
> > Anyway, let me throw the patch for further discussion. Nick, Mel,
> > Johannes what do you think?
> > 
> > From 3821c2e66347a2141358cabdc6224d9990276fec Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Fri, 9 Aug 2019 14:29:59 +0200
> > Subject: [PATCH] mm: drop mark_page_access from the unmap path
> > 
> > Minchan has noticed that mark_page_access can take quite some time
> > during unmap:
> > : I had a time to benchmark it via adding some trace_printk hooks between
> > : pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
> > : device is 2018 premium mobile device.
> > :
> > : I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
> > : task runs on little core even though it doesn't have any IPI and LRU
> > : lock contention. It's already too heavy.
> > :
> > : If I remove activate_page, 35-40% overhead of zap_pte_range is gone
> > : so most of overhead(about 0.7ms) comes from activate_page via
> > : mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
> > : accumulate up to several ms.
> > 
> > bf3f3bc5e734 ("mm: don't mark_page_accessed in fault path") has replaced
> > SetPageReferenced by mark_page_accessed arguing that the former is not
> > sufficient when mark_page_accessed is removed from the fault path
> > because it doesn't promote page to the active list. It is true that a
> > page that is mapped by a single process might not get promoted even when
> > referenced if the reclaim checks it after the unmap but does that matter
> > that much? Can we cosider the page hot if there are no other
> > users? Moreover we do have workingset detection in place since then and
> > so a next refault would activate the page if it was really hot one.
> 
> I do think the pages can be very hot. Think of short-lived executables
> and their libraries. Like shell commands. When they run a few times or
> periodically, they should be promoted to the active list and not have
> to compete with streaming IO on the inactive list - the PG_referenced
> doesn't really help them there, see page_check_references().

Yeah, I am aware of that. We do rely on more processes to map the page
which I've tried to explain in the changelog.

Btw. can we promote PageReferenced pages with zero mapcount? I am
throwing that more as an idea because I haven't really thought that
through yet.

> Maybe the refaults will be fine - but latency expectations around
> mapped page cache certainly are a lot higher than unmapped cache.
>
> So I'm a bit reluctant about this patch. If Minchan can be happy with
> the lock batching, I'd prefer that.

Yes, it seems that the regular lock drop&relock helps in Minchan's case
but this is a kind of change that might have other subtle side effects.
E.g. will-it-scale has noticed a regression [1], likely because the
critical section is shorter and the overal throughput of the operation
decreases. Now, the w-i-s is an artificial benchmark so I wouldn't lose
much sleep over it normally but we have already seen real regressions
when the locking pattern has changed in the past so I would by a bit
cautious. 

As I've said, this RFC is mostly to open a discussion. I would really
like to weigh the overhead of mark_page_accessed and potential scenario
when refaults would be visible in practice. I can imagine that a short
lived statically linked applications have higher chance of being the
only user unlike libraries which are often being mapped via several
ptes. But the main problem to evaluate this is that there are many other
external factors to trigger the worst case.

[1] http://lkml.kernel.org/r/20190806070547.GA10123@xsang-OptiPlex-9020
-- 
Michal Hocko
SUSE Labs

