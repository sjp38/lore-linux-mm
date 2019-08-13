Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB34FC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:16:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CFF2206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OkG7Qgjo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CFF2206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CEB46B0010; Tue, 13 Aug 2019 17:16:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37F206B02B2; Tue, 13 Aug 2019 17:16:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 297226B02B3; Tue, 13 Aug 2019 17:16:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0196.hostedemail.com [216.40.44.196])
	by kanga.kvack.org (Postfix) with ESMTP id 08F836B0010
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:16:33 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A3F5F52C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:16:32 +0000 (UTC)
X-FDA: 75818663424.05.van26_90669d991b555
X-HE-Tag: van26_90669d991b555
X-Filterd-Recvd-Size: 3143
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:16:32 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D5EA8205C9;
	Tue, 13 Aug 2019 21:16:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565730991;
	bh=5lO5nG45fLOHTgE1yvwYm5c55LUdkLb+cAFPTo7XcbE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=OkG7QgjoGy1/FLMnWjN6QVHtQGDQE7lx3AF09Wq1TzQirB9nW7PhsZgi97LYakzAS
	 kpNmEhjjpIsqmSORExdEosdrLv2gJP/YeSBEFOMn1H5v5ee8hvFz/1qjptsMpcWS3X
	 KSFzaA/tLs+FDl9iSVKMYNQ4/gNMWqHEiPVBbtww=
Date: Tue, 13 Aug 2019 14:16:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi
 <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [patch] mm, page_alloc: move_freepages should not examine
 struct page of reserved memory
Message-Id: <20190813141630.bd8cee48e6a83ca77eead6ad@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1908122036560.10779@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1908122036560.10779@chino.kir.corp.google.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 20:37:11 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> After commit 907ec5fca3dc ("mm: zero remaining unavailable struct pages"),
> struct page of reserved memory is zeroed.  This causes page->flags to be 0
> and fixes issues related to reading /proc/kpageflags, for example, of
> reserved memory.
> 
> The VM_BUG_ON() in move_freepages_block(), however, assumes that
> page_zone() is meaningful even for reserved memory.  That assumption is no
> longer true after the aforementioned commit.
> 
> There's no reason why move_freepages_block() should be testing the
> legitimacy of page_zone() for reserved memory; its scope is limited only
> to pages on the zone's freelist.
> 
> Note that pfn_valid() can be true for reserved memory: there is a backing
> struct page.  The check for page_to_nid(page) is also buggy but reserved
> memory normally only appears on node 0 so the zeroing doesn't affect this.
> 
> Move the debug checks to after verifying PageBuddy is true.  This isolates
> the scope of the checks to only be for buddy pages which are on the zone's
> freelist which move_freepages_block() is operating on.  In this case, an
> incorrect node or zone is a bug worthy of being warned about (and the
> examination of struct page is acceptable bcause this memory is not
> reserved).

I'm thinking Fixes:907ec5fca3dc and Cc:stable?  But 907ec5fca3dc is
almost a year old, so you were doing something special to trigger this?


