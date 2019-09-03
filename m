Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77C20C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 21:28:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CAFB230F2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 21:28:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CAFB230F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD9666B0007; Tue,  3 Sep 2019 17:28:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8A056B0008; Tue,  3 Sep 2019 17:28:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA06C6B000A; Tue,  3 Sep 2019 17:28:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 98B1D6B0007
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 17:28:33 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 174053AA7
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 21:28:33 +0000 (UTC)
X-FDA: 75894898506.05.move05_105ff6c68b90d
X-HE-Tag: move05_105ff6c68b90d
X-Filterd-Recvd-Size: 2029
Received: from nautica.notk.org (nautica.notk.org [91.121.71.147])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 21:28:32 +0000 (UTC)
Received: by nautica.notk.org (Postfix, from userid 1001)
	id E8C3DC009; Tue,  3 Sep 2019 23:28:30 +0200 (CEST)
Date: Tue, 3 Sep 2019 23:28:15 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: How to use huge pages in drivers?
Message-ID: <20190903212815.GA7518@nautica>
References: <20190903182627.GA6079@nautica>
 <20190903184230.GJ29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190903184230.GJ29434@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000026, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote on Tue, Sep 03, 2019:
> > What I'd like to know is:
> >  - we know (assuming the other side isn't too bugged, but if it is we're
> > fucked up anyway) exactly what huge-page-sized physical memory range has
> > been mapped on the other side, is there a way to manually gather the
> > pages corresponding and merge them into a huge page?
> 
> You're using the word 'page' here, but I suspect what you really mean is
> "pfn" or "pte".  As you've described it, it doesn't matter what data structure
> Linux is using for the memory, since Linux doesn't know about the memory.

Correct, we're already using vmf_insert_pfn

> We have vmf_insert_pfn_pmd() which is designed to be called from your
> ->huge_fault handler.  See dev_dax_huge_fault() -> __dev_dax_pmd_fault()
> for an example.  It's a fairly new mechanism, so I don't think it's
> popular with device drivers yet.
> 
> All you really need is the physical address of the memory to make this work.

Great; I'm not sure how I had missed the pmd variant here. It's even
been around for long enough to be available on our "old" el7 kernels so
I'll be able to test this quickly.

Thanks!
-- 
Dominique

