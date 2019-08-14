Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA696C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 22:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78DD7208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 22:50:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AEyC3bO5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78DD7208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03F816B0003; Wed, 14 Aug 2019 18:50:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F31DF6B0005; Wed, 14 Aug 2019 18:50:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E489E6B0007; Wed, 14 Aug 2019 18:50:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0026.hostedemail.com [216.40.44.26])
	by kanga.kvack.org (Postfix) with ESMTP id BE0BC6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:50:06 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6B2208248AA4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:50:06 +0000 (UTC)
X-FDA: 75822528012.06.tail57_9a03f2bce4e
X-HE-Tag: tail57_9a03f2bce4e
X-Filterd-Recvd-Size: 3463
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:50:04 +0000 (UTC)
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A59C9208C2;
	Wed, 14 Aug 2019 22:49:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565822969;
	bh=jivfAMepI0RUEpSZlQtSBIqThWImtRCXpi21oTCQTL4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=AEyC3bO50FxmVPrQA2snFZCblJWdXrtODi/2F368XEFE6EwllYrn61TVyVwiklr+M
	 41FZYVj3/ITFicX9hQXRcaNzdphMeDFeC9pxp15jEgjtlDBTdxgeedz4+0+3rtiX+V
	 SY8knh1Dj7cuDUsu2alp1f4KqD/Yd05rMFu6yrpU=
Date: Wed, 14 Aug 2019 15:49:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi
 <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [patch] mm, page_alloc: move_freepages should not examine
 struct page of reserved memory
Message-Id: <20190814154929.f050d937f2bd2c4d80c7f772@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1908131625310.224017@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1908122036560.10779@chino.kir.corp.google.com>
	<20190813141630.bd8cee48e6a83ca77eead6ad@linux-foundation.org>
	<alpine.DEB.2.21.1908131625310.224017@chino.kir.corp.google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 16:31:35 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> > > Move the debug checks to after verifying PageBuddy is true.  This isolates
> > > the scope of the checks to only be for buddy pages which are on the zone's
> > > freelist which move_freepages_block() is operating on.  In this case, an
> > > incorrect node or zone is a bug worthy of being warned about (and the
> > > examination of struct page is acceptable bcause this memory is not
> > > reserved).
> > 
> > I'm thinking Fixes:907ec5fca3dc and Cc:stable?  But 907ec5fca3dc is
> > almost a year old, so you were doing something special to trigger this?
> > 
> 
> We noticed it almost immediately after bringing 907ec5fca3dc in on 
> CONFIG_DEBUG_VM builds.  It depends on finding specific free pages in the 
> per-zone free area where the math in move_freepages() will bring the start 
> or end pfn into reserved memory and wanting to claim that entire pageblock 
> as a new migratetype.  So the path will be rare, require CONFIG_DEBUG_VM, 
> and require fallback to a different migratetype.
> 
> Some struct pages were already zeroed from reserve pages before 
> 907ec5fca3c so it theoretically could trigger before this commit.  I think 
> it's rare enough under a config option that most people don't run that 
> others may not have noticed.  I wouldn't argue against a stable tag and 
> the backport should be easy enough, but probably wouldn't single out a 
> commit that this is fixing.

OK, thanks.  I added the above two paragraphs to the changelog and
removed the Fixes:

Hopefully Mel will be able to review this for us.

