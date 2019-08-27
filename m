Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD49BC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 11:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A98952173E
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 11:48:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A98952173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46BDF6B0007; Tue, 27 Aug 2019 07:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F2B96B0008; Tue, 27 Aug 2019 07:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 307D16B000A; Tue, 27 Aug 2019 07:48:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9A06B0007
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:48:12 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9E7A0824CA3F
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:48:11 +0000 (UTC)
X-FDA: 75868034382.01.shirt45_47769dfe6bc45
X-HE-Tag: shirt45_47769dfe6bc45
X-Filterd-Recvd-Size: 6151
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:48:10 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6E947AF19;
	Tue, 27 Aug 2019 11:48:09 +0000 (UTC)
Date: Tue, 27 Aug 2019 13:48:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190827114808.GY7538@dhcp22.suse.cz>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
 <20190822152934.w6ztolutdix6kbvc@box>
 <20190826074035.GD7538@dhcp22.suse.cz>
 <20190826131538.64twqx3yexmhp6nf@box>
 <20190827060139.GM7538@dhcp22.suse.cz>
 <20190827110210.lpe36umisqvvesoa@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827110210.lpe36umisqvvesoa@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 14:02:10, Kirill A. Shutemov wrote:
> On Tue, Aug 27, 2019 at 08:01:39AM +0200, Michal Hocko wrote:
> > On Mon 26-08-19 16:15:38, Kirill A. Shutemov wrote:
> > > On Mon, Aug 26, 2019 at 09:40:35AM +0200, Michal Hocko wrote:
> > > > On Thu 22-08-19 18:29:34, Kirill A. Shutemov wrote:
> > > > > On Thu, Aug 22, 2019 at 02:56:56PM +0200, Vlastimil Babka wrote:
> > > > > > On 8/22/19 10:04 AM, Michal Hocko wrote:
> > > > > > > On Thu 22-08-19 01:55:25, Yang Shi wrote:
> > > > > > >> Available memory is one of the most important metrics for memory
> > > > > > >> pressure.
> > > > > > > 
> > > > > > > I would disagree with this statement. It is a rough estimate that tells
> > > > > > > how much memory you can allocate before going into a more expensive
> > > > > > > reclaim (mostly swapping). Allocating that amount still might result in
> > > > > > > direct reclaim induced stalls. I do realize that this is simple metric
> > > > > > > that is attractive to use and works in many cases though.
> > > > > > > 
> > > > > > >> Currently, the deferred split THPs are not accounted into
> > > > > > >> available memory, but they are reclaimable actually, like reclaimable
> > > > > > >> slabs.
> > > > > > >> 
> > > > > > >> And, they seems very common with the common workloads when THP is
> > > > > > >> enabled.  A simple run with MariaDB test of mmtest with THP enabled as
> > > > > > >> always shows it could generate over fifteen thousand deferred split THPs
> > > > > > >> (accumulated around 30G in one hour run, 75% of 40G memory for my VM).
> > > > > > >> It looks worth accounting in MemAvailable.
> > > > > > > 
> > > > > > > OK, this makes sense. But your above numbers are really worrying.
> > > > > > > Accumulating such a large amount of pages that are likely not going to
> > > > > > > be used is really bad. They are essentially blocking any higher order
> > > > > > > allocations and also push the system towards more memory pressure.
> > > > > > > 
> > > > > > > IIUC deferred splitting is mostly a workaround for nasty locking issues
> > > > > > > during splitting, right? This is not really an optimization to cache
> > > > > > > THPs for reuse or something like that. What is the reason this is not
> > > > > > > done from a worker context? At least THPs which would be freed
> > > > > > > completely sound like a good candidate for kworker tear down, no?
> > > > > > 
> > > > > > Agreed that it's a good question. For Kirill :) Maybe with kworker approach we
> > > > > > also wouldn't need the cgroup awareness?
> > > > > 
> > > > > I don't remember a particular locking issue, but I cannot say there's
> > > > > none :P
> > > > > 
> > > > > It's artifact from decoupling PMD split from compound page split: the same
> > > > > page can be mapped multiple times with combination of PMDs and PTEs. Split
> > > > > of one PMD doesn't need to trigger split of all PMDs and underlying
> > > > > compound page.
> > > > > 
> > > > > Other consideration is the fact that page split can fail and we need to
> > > > > have fallback for this case.
> > > > > 
> > > > > Also in most cases THP split would be just waste of time if we would do
> > > > > them at the spot. If you don't have memory pressure it's better to wait
> > > > > until process termination: less pages on LRU is still beneficial.
> > > > 
> > > > This might be true but the reality shows that a lot of THPs might be
> > > > waiting for the memory pressure that is essentially freeable on the
> > > > spot. So I am not really convinced that "less pages on LRUs" is really a
> > > > plausible justification. Can we free at least those THPs which are
> > > > unmapped completely without any pte mappings?
> > > 
> > > Unmapped completely pages will be freed with current code. Deferred split
> > > only applies to partly mapped THPs: at least on 4k of the THP is still
> > > mapped somewhere.
> > 
> > Hmm, I am probably misreading the code but at least current Linus' tree
> > reads page_remove_rmap -> [page_remove_anon_compound_rmap ->\ deferred_split_huge_page even
> > for fully mapped THP.
> 
> Well, you read correctly, but it was not intended. I screwed it up at some
> point.
> 
> See the patch below. It should make it work as intened.

OK, this would be indeed much better indeed. I was really under
impression that the deferred splitting is required due to locking.

Anyway this should take care of the most common usecase. If we can make
the odd cases of partially mapped THPs be handled deferred&earlier than
maybe do not really need the whole memcg deferred shrinkers and other
complications. So let's see.
-- 
Michal Hocko
SUSE Labs

