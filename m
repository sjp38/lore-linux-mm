Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51A1CC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 044272077C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:28:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EvXHTIUx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 044272077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BBAA6B0003; Fri, 16 Aug 2019 02:28:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86BD66B0005; Fri, 16 Aug 2019 02:28:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75ADE6B0006; Fri, 16 Aug 2019 02:28:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0214.hostedemail.com [216.40.44.214])
	by kanga.kvack.org (Postfix) with ESMTP id 5730D6B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:28:02 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0069B55FA3
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:28:01 +0000 (UTC)
X-FDA: 75827310804.09.moon88_8044d095e613c
X-HE-Tag: moon88_8044d095e613c
X-Filterd-Recvd-Size: 3872
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:28:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oU/+XLvJ/zQXeVSNiDSSlJqSG/SneSmtCzvqLBroOSY=; b=EvXHTIUxlRbzNA+RRnALDlEZ7
	V3/RDd3Mqg1DeQl7oV3ZkPJfeP0TE9G+7oHZoME5kQqbbL1z3akBM3MJsWG4ZlgbDgyd82M7oWvyA
	GIb5p2vce+b8aoyegq2NmEVZpH/sS0JOOfWgR6BdSLNS588kchnd87R9V3mNofTE+dipTfnFZbAUy
	kIWl9m2vTro537iAS/fgltZp681Tr6OPWOzXSwHDBxwmzvR2MWdqzOKcK3nE2w1IMuYRSztBQ1Z9/
	OID7tNU5sXdkolwAetL2OKma/9NdaQ6ME+emgjtNyITJ1/CQjFauz9IogkNnsfAgfMGSjsPpzY77I
	pZ1/YO/Rg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hyViJ-00064g-AM; Fri, 16 Aug 2019 06:27:51 +0000
Date: Thu, 15 Aug 2019 23:27:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: cleanup the walk_page_range interface
Message-ID: <20190816062751.GA16169@infradead.org>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 10:50:37AM -0700, Linus Torvalds wrote:
> On Thu, Aug 8, 2019 at 8:42 AM Christoph Hellwig <hch@lst.de> wrote:
> >
> > this series is based on a patch from Linus to split the callbacks
> > passed to walk_page_range and walk_page_vma into a separate structure
> > that can be marked const, with various cleanups from me on top.
> 
> The whole series looks good to me. Ack.
> 
> > Note that both Thomas and Steven have series touching this area pending,
> > and there are a couple consumer in flux too - the hmm tree already
> > conflicts with this series, and I have potential dma changes on top of
> > the consumers in Thomas and Steven's series, so we'll probably need a
> > git tree similar to the hmm one to synchronize these updates.
> 
> I'd be willing to just merge this now, if that helps. The conversion
> is mechanical, and my only slight worry would be that at least for my
> original patch I didn't build-test the (few) non-x86
> architecture-specific cases. But I did end up looking at them fairly
> closely  (basically using some grep/sed scripts to see that the
> conversions I did matched the same patterns). And your changes look
> like obvious improvements too where any mistake would have been caught
> by the compiler.
> 
> So I'm not all that worried from a functionality standpoint, and if
> this will help the next merge window, I'll happily pull now.

So what is the plan forward?  Probably a little late for 5.3,
so queue it up in -mm for 5.4 and deal with the conflicts in at least
hmm?  Queue it up in the hmm tree even if it doesn't 100% fit?

