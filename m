Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC7ECC3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 22:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70E452146E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 22:27:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ApdJs2Ng"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70E452146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C99286B04EC; Sat, 24 Aug 2019 18:27:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C22EE6B04ED; Sat, 24 Aug 2019 18:27:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEA246B04EE; Sat, 24 Aug 2019 18:27:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0097.hostedemail.com [216.40.44.97])
	by kanga.kvack.org (Postfix) with ESMTP id 867E56B04EC
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 18:27:07 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 30EEA824CA38
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 22:27:07 +0000 (UTC)
X-FDA: 75858758094.07.sea29_5b3456c4eb317
X-HE-Tag: sea29_5b3456c4eb317
X-Filterd-Recvd-Size: 2868
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 22:27:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nurlPYQx2ItprLfZNVFEAgIWj9lAPjByXFVyqakf/bs=; b=ApdJs2NgoerPDGq+Qjl6yD3Md
	GAULGKDGkBAbH361DaCiAt7apWygm/BAIZROhFYyzzMy4bwRaulxMebUnRGt24wWjEHXE7r4N/M+1
	7K1XiSiZbchjPReLHlJUoBk8rUxdYj8WswiJJgI1k8AMf2ndViz9WFs48YpT2ny0R4jkZAGNBZY7z
	SrbzGB+qb1C1wMkNFkQXyo/QADwO9W4GP2/vGdw40zAoAIJxqymHVTyATGkDslXwQieI9sYh+BbxP
	WbaWlsz0+F+mkfsbscFFsGSRFpy++c/HluVp56qcN2/+dQLk5bMWMceetVLSPQ6dESrRMYa7edSJa
	L01aladlw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i1eUp-0007Y8-25; Sat, 24 Aug 2019 22:26:55 +0000
Date: Sat, 24 Aug 2019 15:26:55 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: cleanup the walk_page_range interface
Message-ID: <20190824222654.GA28766@infradead.org>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org>
 <20190823134308.GH12847@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823134308.GH12847@mellanox.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 01:43:12PM +0000, Jason Gunthorpe wrote:
> > So what is the plan forward?  Probably a little late for 5.3,
> > so queue it up in -mm for 5.4 and deal with the conflicts in at least
> > hmm?  Queue it up in the hmm tree even if it doesn't 100% fit?
> 
> Did we make a decision on this? Due to travel & LPC I'd like to
> finalize the hmm tree next week.

I don't think we've made any decision.  I'd still love to see this
in hmm.git.  It has a minor conflict, but I can resend a rebased
version.

