Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF97C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46E3C2070B
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 06:01:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46E3C2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C72D66B000A; Tue, 27 Aug 2019 02:01:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFCC06B000C; Tue, 27 Aug 2019 02:01:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE9576B000D; Tue, 27 Aug 2019 02:01:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9596B000A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 02:01:42 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 25FB46107
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:01:42 +0000 (UTC)
X-FDA: 75867161244.04.songs58_661c120b13a61
X-HE-Tag: songs58_661c120b13a61
X-Filterd-Recvd-Size: 8176
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 06:01:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3ACDEB62C;
	Tue, 27 Aug 2019 06:01:40 +0000 (UTC)
Date: Tue, 27 Aug 2019 08:01:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190827060139.GM7538@dhcp22.suse.cz>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
 <20190822152934.w6ztolutdix6kbvc@box>
 <20190826074035.GD7538@dhcp22.suse.cz>
 <20190826131538.64twqx3yexmhp6nf@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826131538.64twqx3yexmhp6nf@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 26-08-19 16:15:38, Kirill A. Shutemov wrote:
> On Mon, Aug 26, 2019 at 09:40:35AM +0200, Michal Hocko wrote:
> > On Thu 22-08-19 18:29:34, Kirill A. Shutemov wrote:
> > > On Thu, Aug 22, 2019 at 02:56:56PM +0200, Vlastimil Babka wrote:
> > > > On 8/22/19 10:04 AM, Michal Hocko wrote:
> > > > > On Thu 22-08-19 01:55:25, Yang Shi wrote:
> > > > >> Available memory is one of the most important metrics for memory
> > > > >> pressure.
> > > > > 
> > > > > I would disagree with this statement. It is a rough estimate that tells
> > > > > how much memory you can allocate before going into a more expensive
> > > > > reclaim (mostly swapping). Allocating that amount still might result in
> > > > > direct reclaim induced stalls. I do realize that this is simple metric
> > > > > that is attractive to use and works in many cases though.
> > > > > 
> > > > >> Currently, the deferred split THPs are not accounted into
> > > > >> available memory, but they are reclaimable actually, like reclaimable
> > > > >> slabs.
> > > > >> 
> > > > >> And, they seems very common with the common workloads when THP is
> > > > >> enabled.  A simple run with MariaDB test of mmtest with THP enabled as
> > > > >> always shows it could generate over fifteen thousand deferred split THPs
> > > > >> (accumulated around 30G in one hour run, 75% of 40G memory for my VM).
> > > > >> It looks worth accounting in MemAvailable.
> > > > > 
> > > > > OK, this makes sense. But your above numbers are really worrying.
> > > > > Accumulating such a large amount of pages that are likely not going to
> > > > > be used is really bad. They are essentially blocking any higher order
> > > > > allocations and also push the system towards more memory pressure.
> > > > > 
> > > > > IIUC deferred splitting is mostly a workaround for nasty locking issues
> > > > > during splitting, right? This is not really an optimization to cache
> > > > > THPs for reuse or something like that. What is the reason this is not
> > > > > done from a worker context? At least THPs which would be freed
> > > > > completely sound like a good candidate for kworker tear down, no?
> > > > 
> > > > Agreed that it's a good question. For Kirill :) Maybe with kworker approach we
> > > > also wouldn't need the cgroup awareness?
> > > 
> > > I don't remember a particular locking issue, but I cannot say there's
> > > none :P
> > > 
> > > It's artifact from decoupling PMD split from compound page split: the same
> > > page can be mapped multiple times with combination of PMDs and PTEs. Split
> > > of one PMD doesn't need to trigger split of all PMDs and underlying
> > > compound page.
> > > 
> > > Other consideration is the fact that page split can fail and we need to
> > > have fallback for this case.
> > > 
> > > Also in most cases THP split would be just waste of time if we would do
> > > them at the spot. If you don't have memory pressure it's better to wait
> > > until process termination: less pages on LRU is still beneficial.
> > 
> > This might be true but the reality shows that a lot of THPs might be
> > waiting for the memory pressure that is essentially freeable on the
> > spot. So I am not really convinced that "less pages on LRUs" is really a
> > plausible justification. Can we free at least those THPs which are
> > unmapped completely without any pte mappings?
> 
> Unmapped completely pages will be freed with current code. Deferred split
> only applies to partly mapped THPs: at least on 4k of the THP is still
> mapped somewhere.

Hmm, I am probably misreading the code but at least current Linus' tree
reads page_remove_rmap -> [page_remove_anon_compound_rmap ->\ deferred_split_huge_page even
for fully mapped THP.

> > > Main source of partly mapped THPs comes from exit path. When PMD mapping
> > > of THP got split across multiple VMAs (for instance due to mprotect()),
> > > in exit path we unmap PTEs belonging to one VMA just before unmapping the
> > > rest of the page. It would be total waste of time to split the page in
> > > this scenario.
> > > 
> > > The whole deferred split thing still looks as a reasonable compromise
> > > to me.
> > 
> > Even when it leads to all other problems mentioned in this and memcg
> > deferred reclaim series?
> 
> Yes.
> 
> You would still need deferred split even if you *try* to split the page on
> the spot. split_huge_page() can fail (due to pin on the page) and you will
> need to have a way to try again later.
> 
> You'll not win anything in complexity by trying split_huge_page()
> immediately. I would ague you'll create much more complexity.

I am not arguing for in place split. I am arguing to do it ASAP rather
than to wait for memory pressure which might be in an unbound amount of
time. So let me ask again. Why cannot we do that in the worker context?
Essentially schedure the work item right away?

> > > We may have some kind of watermark and try to keep the number of deferred
> > > split THP under it. But it comes with own set of problems: what if all
> > > these pages are pinned for really long time and effectively not available
> > > for split.
> > 
> > Again, why cannot we simply push the freeing where there are no other
> > mappings? This should be pretty common case, right?
> 
> Partly mapped THP is not common case at all.
> 
> To get to this point you will need to create a mapping, fault in THP and
> then unmap part of it. It requires very active memory management on
> application side. This kind of applications usually knows if THP is a fit
> for them.

See other email by Yang Shi for practical examples.

> > I am still not sure that waiting for the memory reclaim is a general
> > win.
> 
> It wins CPU cycles by not doing the work that is likely unneeded.
> split_huge_page() is not particularly lightweight operation from locking
> and atomic ops POV.
> 
> > Do you have any examples of workloads that measurably benefit from
> > this lazy approach without any other downsides? In other words how
> > exactly do we measure cost/benefit model of this heuristic?
> 
> Example? Sure.
> 
> Compiling mm/memory.c in my setup generates 8 deferred split. 4 of them
> triggered from exit path. The rest 4 comes from MADV_DONTNEED. It doesn't
> make sense to convert any of them to in-place split: for short-lived
> process any split if waste of time without any benefit.

Right, I understand that part. And again, I am not arguing for in place
split up. All I do care about is _when_ to trigger the "cleanup" aka
when we do free the memory or split the THP depending on its state. I
argue that waiting for the memory pressure is too late and examples
mentioned elsewhere in the thread confirm that.
-- 
Michal Hocko
SUSE Labs

