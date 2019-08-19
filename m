Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14D7DC41514
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B96942085A
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:35:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B96942085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 495486B0006; Mon, 19 Aug 2019 09:35:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41DCE6B0007; Mon, 19 Aug 2019 09:35:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30C606B0008; Mon, 19 Aug 2019 09:35:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6286B0006
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:35:46 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B246F8248AA9
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:35:45 +0000 (UTC)
X-FDA: 75839275050.08.power24_6c6db8e2bb20f
X-HE-Tag: power24_6c6db8e2bb20f
X-Filterd-Recvd-Size: 3966
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com [81.17.249.8])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:35:44 +0000 (UTC)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 3F34698A5B
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 14:35:43 +0100 (IST)
Received: (qmail 26429 invoked from network); 19 Aug 2019 13:35:43 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 19 Aug 2019 13:35:43 -0000
Date: Mon, 19 Aug 2019 14:35:41 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [patch] mm, page_alloc: move_freepages should not examine struct
 page of reserved memory
Message-ID: <20190819133541.GP2739@techsingularity.net>
References: <alpine.DEB.2.21.1908122036560.10779@chino.kir.corp.google.com>
 <20190813141630.bd8cee48e6a83ca77eead6ad@linux-foundation.org>
 <alpine.DEB.2.21.1908131625310.224017@chino.kir.corp.google.com>
 <20190814154929.f050d937f2bd2c4d80c7f772@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190814154929.f050d937f2bd2c4d80c7f772@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 03:49:29PM -0700, Andrew Morton wrote:
> On Tue, 13 Aug 2019 16:31:35 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > > > Move the debug checks to after verifying PageBuddy is true.  This isolates
> > > > the scope of the checks to only be for buddy pages which are on the zone's
> > > > freelist which move_freepages_block() is operating on.  In this case, an
> > > > incorrect node or zone is a bug worthy of being warned about (and the
> > > > examination of struct page is acceptable bcause this memory is not
> > > > reserved).
> > > 
> > > I'm thinking Fixes:907ec5fca3dc and Cc:stable?  But 907ec5fca3dc is
> > > almost a year old, so you were doing something special to trigger this?
> > > 
> > 
> > We noticed it almost immediately after bringing 907ec5fca3dc in on 
> > CONFIG_DEBUG_VM builds.  It depends on finding specific free pages in the 
> > per-zone free area where the math in move_freepages() will bring the start 
> > or end pfn into reserved memory and wanting to claim that entire pageblock 
> > as a new migratetype.  So the path will be rare, require CONFIG_DEBUG_VM, 
> > and require fallback to a different migratetype.
> > 
> > Some struct pages were already zeroed from reserve pages before 
> > 907ec5fca3c so it theoretically could trigger before this commit.  I think 
> > it's rare enough under a config option that most people don't run that 
> > others may not have noticed.  I wouldn't argue against a stable tag and 
> > the backport should be easy enough, but probably wouldn't single out a 
> > commit that this is fixing.
> 
> OK, thanks.  I added the above two paragraphs to the changelog and
> removed the Fixes:
> 
> Hopefully Mel will be able to review this for us.

Bit late as I was offline but FWIW

Acked-by: Mel Gorman <mgorman@techsingularity.net>

That said, the overhead of the debugging check is higher with this
patch although it'll only affect debug builds and the path is not
particularly hot. If this was a concern, I think it would be reasonable
to simply remove the debugging check as the zone boundaries are checked
in move_freepages_block and we never expect a zone/node to be smaller
than a pageblock and stuck in the middle of another zone.

-- 
Mel Gorman
SUSE Labs

