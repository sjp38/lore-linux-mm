Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F2AAC3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 09:11:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A47B22CE3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 09:11:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YaiC1+wc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A47B22CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8F586B02E9; Thu, 22 Aug 2019 05:11:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3FB06B02EA; Thu, 22 Aug 2019 05:11:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92F9A6B02EB; Thu, 22 Aug 2019 05:11:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 723936B02E9
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 05:11:04 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 195888248AB7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:11:04 +0000 (UTC)
X-FDA: 75849494448.24.noise36_944430841c5b
X-HE-Tag: noise36_944430841c5b
X-Filterd-Recvd-Size: 4242
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:11:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=x4foXpuRFuIwOjwAh/WD4Jpq4dQ0elk1+Aq1lb6/PQ0=; b=YaiC1+wcqYrXMCnzzZkJlOM7Y
	es9C6umm9YWRG7LOsHvpT1WC84Xg1bLLowkwVZM6jBEobZIGvTOpYNOGp/eCB3/Bp3Q12ioQCHE9u
	i1V6veZ+0P+hHkPhbY1rhdb3yXQsEHT9DEERtX/hF+x+3Iwj21iFCrtgb0cl9vdoz1UGz5+60d/38
	VVdSI9Amrr/nLfWis5wiNIgZZwDWJClE4w2ItR8aPBh2CYKO5kSrqNJOIwKMAEyT3ebk64Ba3KsRl
	lhce65fR8vXYVeh2YC7HxlrsSMpornazboOGM8fs3X8KSYXETw5O5C3bp4ze+f5mxKQlExTUAFtQ6
	JCuzSfd3A==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i0j7T-0003l1-BB; Thu, 22 Aug 2019 09:10:59 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id 139B8305F65;
	Thu, 22 Aug 2019 11:10:25 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0D9A92029B084; Thu, 22 Aug 2019 11:10:57 +0200 (CEST)
Date: Thu, 22 Aug 2019 11:10:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	penguin-kernel@I-love.SAKURA.ne.jp
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
Message-ID: <20190822091057.GK2386@hirez.programming.kicks-ass.net>
References: <20190821083820.11725-1-david@fromorbit.com>
 <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
 <20190822085130.GI2349@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822085130.GI2349@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 10:51:30AM +0200, Peter Zijlstra wrote:
> On Thu, Aug 22, 2019 at 12:59:48AM -0700, Christoph Hellwig wrote:
> > On Thu, Aug 22, 2019 at 10:31:32AM +1000, Dave Chinner wrote:
> > > > Btw, I think we should eventually kill off KM_NOFS and just use
> > > > PF_MEMALLOC_NOFS in XFS, as the interface makes so much more sense.
> > > > But that's something for the future.
> > > 
> > > Yeah, and it's not quite as simple as just using PF_MEMALLOC_NOFS
> > > at high levels - we'll still need to annotate callers that use KM_NOFS
> > > to avoid lockdep false positives. i.e. any code that can be called from
> > > GFP_KERNEL and reclaim context will throw false positives from
> > > lockdep if we don't annotate tehm correctly....
> > 
> > Oh well.  For now we have the XFS kmem_wrappers to turn that into
> > GFP_NOFS so we shouldn't be too worried, but I think that is something
> > we should fix in lockdep to ensure it is generally useful.  I've added
> > the maintainers and relevant lists to kick off a discussion.
> 
> Strictly speaking the fs_reclaim annotation is no longer part of the
> lockdep core, but is simply a fake lock in page_alloc.c and thus falls
> under the mm people's purview.
> 
> That said; it should be fairly straight forward to teach
> __need_fs_reclaim() about PF_MEMALLOC_NOFS, much like how it already
> knows about PF_MEMALLOC.

Ah, current_gfp_context() already seems to transfer PF_MEMALLOC_NOFS
into the GFP flags.

So are we sure it is broken and needs mending?

