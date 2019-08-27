Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F12D4C3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 18:41:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A03CE21881
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 18:41:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A03CE21881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22A956B000A; Tue, 27 Aug 2019 14:41:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D27C6B000C; Tue, 27 Aug 2019 14:41:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E7B26B000D; Tue, 27 Aug 2019 14:41:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0238.hostedemail.com [216.40.44.238])
	by kanga.kvack.org (Postfix) with ESMTP id DF4CB6B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:41:46 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 621427832
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:41:46 +0000 (UTC)
X-FDA: 75869076612.13.hour69_2c85fc2ff6705
X-HE-Tag: hour69_2c85fc2ff6705
X-Filterd-Recvd-Size: 6197
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:41:45 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 37152AE2F;
	Tue, 27 Aug 2019 18:41:44 +0000 (UTC)
Date: Tue, 27 Aug 2019 20:41:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH] mm: drop mark_page_access from the unmap path
Message-ID: <20190827184142.GK7538@dhcp22.suse.cz>
References: <20190731054447.GB155569@google.com>
 <20190731072101.GX9330@dhcp22.suse.cz>
 <20190806105509.GA94582@google.com>
 <20190809124305.GQ18351@dhcp22.suse.cz>
 <20190809183424.GA22347@cmpxchg.org>
 <20190812080947.GA5117@dhcp22.suse.cz>
 <20190812150725.GA3684@cmpxchg.org>
 <20190813105143.GG17933@dhcp22.suse.cz>
 <20190826120630.GI7538@dhcp22.suse.cz>
 <20190827160026.GA27686@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827160026.GA27686@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 12:00:26, Johannes Weiner wrote:
> On Mon, Aug 26, 2019 at 02:06:30PM +0200, Michal Hocko wrote:
> > On Tue 13-08-19 12:51:43, Michal Hocko wrote:
> > > On Mon 12-08-19 11:07:25, Johannes Weiner wrote:
> > > > On Mon, Aug 12, 2019 at 10:09:47AM +0200, Michal Hocko wrote:
> > [...]
> > > > > > Maybe the refaults will be fine - but latency expectations around
> > > > > > mapped page cache certainly are a lot higher than unmapped cache.
> > > > > >
> > > > > > So I'm a bit reluctant about this patch. If Minchan can be happy with
> > > > > > the lock batching, I'd prefer that.
> > > > > 
> > > > > Yes, it seems that the regular lock drop&relock helps in Minchan's case
> > > > > but this is a kind of change that might have other subtle side effects.
> > > > > E.g. will-it-scale has noticed a regression [1], likely because the
> > > > > critical section is shorter and the overal throughput of the operation
> > > > > decreases. Now, the w-i-s is an artificial benchmark so I wouldn't lose
> > > > > much sleep over it normally but we have already seen real regressions
> > > > > when the locking pattern has changed in the past so I would by a bit
> > > > > cautious.
> > > > 
> > > > I'm much more concerned about fundamentally changing the aging policy
> > > > of mapped page cache then about the lock breaking scheme. With locking
> > > > we worry about CPU effects; with aging we worry about additional IO.
> > > 
> > > But the later is observable and debuggable little bit easier IMHO.
> > > People are quite used to watch for major faults from my experience
> > > as that is an easy metric to compare.
> 
> Rootcausing additional (re)faults is really difficult. We're talking
> about a slight trend change in caching behavior in a sea of millions
> of pages. There could be so many factors causing this, and for most
> you have to patch debugging stuff into the kernel to rule them out.
> 
> A CPU regression you can figure out with perf.
> 
> > > > > As I've said, this RFC is mostly to open a discussion. I would really
> > > > > like to weigh the overhead of mark_page_accessed and potential scenario
> > > > > when refaults would be visible in practice. I can imagine that a short
> > > > > lived statically linked applications have higher chance of being the
> > > > > only user unlike libraries which are often being mapped via several
> > > > > ptes. But the main problem to evaluate this is that there are many other
> > > > > external factors to trigger the worst case.
> > > > 
> > > > We can discuss the pros and cons, but ultimately we simply need to
> > > > test it against real workloads to see if changing the promotion rules
> > > > regresses the amount of paging we do in practice.
> > > 
> > > Agreed. Do you see other option than to try it out and revert if we see
> > > regressions? We would get a workload description which would be helpful
> > > for future regression testing when touching this area. We can start
> > > slower and keep it in linux-next for a release cycle to catch any
> > > fallouts early.
> > > 
> > > Thoughts?
> > 
> > ping...
> 
> Personally, I'm not convinced by this patch. I think it's a pretty
> drastic change in aging heuristics just to address a CPU overhead
> problem that has simpler, easier to verify, alternative solutions.
> 
> It WOULD be great to clarify and improve the aging model for mapped
> cache, to make it a bit easier to reason about.

I fully agree with this! Do you have any specific ideas? I am afraid I
am unlikely to find time for a larger project that this sounds to be but
maybe others will find this as a good fit.

> But this patch does
> not really get there either. Instead of taking a serious look at
> mapped cache lifetime and usage scenarios, the changelog is more in
> "let's see what breaks if we take out this screw here" territory.

You know that I tend to be quite conservative. In this case I can see
the cost which is not negligible and likely to hit many workloads
because it is a common path. The immediate benefit is not really clear,
though, at least to me. We can speculate and I would really love to hear
from Nick what exactly led him to this change.
 
> So I'm afraid I don't think the patch & changelog in its current shape
> should go upstream.

I will not insist of course but it would be really great to know and
_document_ why we are doing this. I really hate how often we keep
different heuristics and build more complex solutions on top just
because nobody dares to change that.

Our code is really hard to reason about.

-- 
Michal Hocko
SUSE Labs

