Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 200B4C3A5A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:51:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8AC422CE3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:51:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MFT1spad"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8AC422CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7424D6B02E3; Thu, 22 Aug 2019 04:51:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F3116B02E4; Thu, 22 Aug 2019 04:51:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 609726B02E5; Thu, 22 Aug 2019 04:51:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0115.hostedemail.com [216.40.44.115])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB086B02E3
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 04:51:39 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E88D681F5
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:51:38 +0000 (UTC)
X-FDA: 75849445476.03.soda25_82b1918e9c237
X-HE-Tag: soda25_82b1918e9c237
X-Filterd-Recvd-Size: 3911
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:51:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/4rJRZsfJXe9oSAm3OkCNAzkFSYWRZ0OphOb1fZTRSo=; b=MFT1spadGIPSvmC2gKecCHqZF
	w7GUDDQBE5aFoSYzdPeE7sJ8YF3nkFj2Jy5vf/N/WOQg9N9srHtwabN1t2gnYz+1QjJdmv6MG+XAW
	CI0reqeS7a778ZKVQljeLq5AtIfmbrUvEt9kwyX+KPne83nSBoe7mfI1mGNmLnQVG5d2Ao84F1Ksq
	XKYkDFEDrvwtPDhELKoNmJN2NvrZO16zsxPWdwcU21mRQ+utXKVVq3aRmlWMABG8zZXOpm5WMLBB2
	jpdMJlqjgP1UhuDgnX6xRQkxqlwICL/N/zrsfXrgZ093ZXcpHtsr51C0NaZeRlQF082tvpq4QcO8x
	7HW1ZJdwQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i0iof-0002XU-70; Thu, 22 Aug 2019 08:51:33 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id C0CCE305F65;
	Thu, 22 Aug 2019 10:50:58 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id BAC9B20B335AE; Thu, 22 Aug 2019 10:51:30 +0200 (CEST)
Date: Thu, 22 Aug 2019 10:51:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	penguin-kernel@I-love.SAKURA.ne.jp
Subject: Re: [PATCH 2/3] xfs: add kmem_alloc_io()
Message-ID: <20190822085130.GI2349@hirez.programming.kicks-ass.net>
References: <20190821083820.11725-1-david@fromorbit.com>
 <20190821083820.11725-3-david@fromorbit.com>
 <20190821232440.GB24904@infradead.org>
 <20190822003131.GR1119@dread.disaster.area>
 <20190822075948.GA31346@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822075948.GA31346@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 12:59:48AM -0700, Christoph Hellwig wrote:
> On Thu, Aug 22, 2019 at 10:31:32AM +1000, Dave Chinner wrote:
> > > Btw, I think we should eventually kill off KM_NOFS and just use
> > > PF_MEMALLOC_NOFS in XFS, as the interface makes so much more sense.
> > > But that's something for the future.
> > 
> > Yeah, and it's not quite as simple as just using PF_MEMALLOC_NOFS
> > at high levels - we'll still need to annotate callers that use KM_NOFS
> > to avoid lockdep false positives. i.e. any code that can be called from
> > GFP_KERNEL and reclaim context will throw false positives from
> > lockdep if we don't annotate tehm correctly....
> 
> Oh well.  For now we have the XFS kmem_wrappers to turn that into
> GFP_NOFS so we shouldn't be too worried, but I think that is something
> we should fix in lockdep to ensure it is generally useful.  I've added
> the maintainers and relevant lists to kick off a discussion.

Strictly speaking the fs_reclaim annotation is no longer part of the
lockdep core, but is simply a fake lock in page_alloc.c and thus falls
under the mm people's purview.

That said; it should be fairly straight forward to teach
__need_fs_reclaim() about PF_MEMALLOC_NOFS, much like how it already
knows about PF_MEMALLOC.

