Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E14A3C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 19:30:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EA2F21A4A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 19:30:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EA2F21A4A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33556B0003; Mon,  9 Sep 2019 15:30:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBC7D6B0006; Mon,  9 Sep 2019 15:30:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAB066B0007; Mon,  9 Sep 2019 15:30:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0120.hostedemail.com [216.40.44.120])
	by kanga.kvack.org (Postfix) with ESMTP id B3CD36B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:30:24 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4EA9BAF98
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 19:30:24 +0000 (UTC)
X-FDA: 75916373568.04.shirt95_3d9902d376834
X-HE-Tag: shirt95_3d9902d376834
X-Filterd-Recvd-Size: 4769
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 19:30:23 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A4E75B621;
	Mon,  9 Sep 2019 19:30:21 +0000 (UTC)
Date: Mon, 9 Sep 2019 21:30:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote hugepages
Message-ID: <20190909193020.GD2063@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
 <20190904205522.GA9871@redhat.com>
 <alpine.DEB.2.21.1909051400380.217933@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1909051400380.217933@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 05-09-19 14:06:28, David Rientjes wrote:
> On Wed, 4 Sep 2019, Andrea Arcangeli wrote:
> 
> > > This is an admittedly hacky solution that shouldn't cause anybody to 
> > > regress based on NUMA and the semantics of MADV_HUGEPAGE for the past 
> > > 4 1/2 years for users whose workload does fit within a socket.
> > 
> > How can you live with the below if you can't live with 5.3-rc6? Here
> > you allocate remote THP if the local THP allocation fails.
> > 
> > >  			page = __alloc_pages_node(hpage_node,
> > >  						gfp | __GFP_THISNODE, order);
> > > +
> > > +			/*
> > > +			 * If hugepage allocations are configured to always
> > > +			 * synchronous compact or the vma has been madvised
> > > +			 * to prefer hugepage backing, retry allowing remote
> > > +			 * memory as well.
> > > +			 */
> > > +			if (!page && (gfp & __GFP_DIRECT_RECLAIM))
> > > +				page = __alloc_pages_node(hpage_node,
> > > +						gfp | __GFP_NORETRY, order);
> > > +
> > 
> > You're still going to get THP allocate remote _before_ you have a
> > chance to allocate 4k local this way. __GFP_NORETRY won't make any
> > difference when there's THP immediately available in the remote nodes.
> > 
> 
> This is incorrect: the fallback allocation here is only if the initial 
> allocation with __GFP_THISNODE fails.  In that case, we were able to 
> compact memory to make a local hugepage available without incurring 
> excessive swap based on the RFC patch that appears as patch 3 in this 
> series.

That patch is quite obscure and specific to pageblock_order+ sizes and
for some reason requires __GPF_IO without any explanation on why. The
problem is not THP specific, right? Any other high order has the same
problem AFAICS. So it is just a hack and that's why it is hard to reason
about.

I believe it would be the best to start by explaining why we do not see
the same problem with order-0 requests. We do not enter the slow path
and thus the memory reclaim if there is any other node to pass through
watermakr as well right? So essentially we are relying on kswapd to keep
nodes balanced so that allocation request can be satisfied from a local
node. We do have kcompactd to do background compaction. Why do we want
to rely on the direct compaction instead? What is the fundamental
difference?

Your changelog goes in length about some problems in the compaction but
I really do not see the underlying problem description. We cannot do any
sensible fix/heuristic without capturing that IMHO. Either there is
some fundamental difference between direct and background compaction
and doing a the former one is necessary and we should be doing that by
default for all higher order requests that are sleepable (aka
__GFP_DIRECT_RECLAIM) or there is something to fix for the background
compaction to be more pro-active.
 
> > I said one good thing about this patch series, that it fixes the swap
> > storms. But upstream 5.3 fixes the swap storms too and what you sent
> > is not nearly equivalent to the mempolicy that Michal was willing
> > to provide you and that we thought you needed to get bigger guarantees
> > of getting only local 2m or local 4k pages.
> > 
> 
> I haven't seen such a patch series, is there a link?

not yet unfortunatelly. So far I haven't heard that you are even
interested in that policy. You have never commented on that IIRC.
-- 
Michal Hocko
SUSE Labs

