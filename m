Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD0C2C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:55:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E059206C1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:55:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="czLuMTr1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E059206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAB6B6B0007; Mon, 19 Aug 2019 19:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E34176B0008; Mon, 19 Aug 2019 19:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFB496B000A; Mon, 19 Aug 2019 19:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id A74336B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:55:02 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 47D42181AC9B4
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:55:02 +0000 (UTC)
X-FDA: 75840835644.12.jewel65_831248250be32
X-HE-Tag: jewel65_831248250be32
X-Filterd-Recvd-Size: 3594
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:55:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:Message-ID:
	Subject:To:From:Date:Sender:Reply-To:Cc:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=TbjkwkGLozMz+tjIqOBE4qbg59ZjOKNgp/t7IRDV4SM=; b=czLuMTr1x075BEUmHMGSTJUpRq
	Y4VbjCScXoRffV01vRJEOff4m2zVZXvlgK31+VfSI46nA9rTvNzuZAz0YEsNtsU/Co2T+XpOhDdTF
	CkC9iKgdBbQKnYNEtivnsnfwgGij4DKbW1jvgzMfxVo4Ppgg2tKAwYd9y9oLHDa6IJLF0P8XjBDb5
	ZoqaPSfoWj6EMVvT1pwHvzeXuqh7V2TqCdzdhBDANi3vTkGntKsL+brQLACUnRHsRiYgkhhHHa+bU
	qtsuI+vZ6FnWQ81urw2i8IMBfBjCrzCT3HfPzD23Ri9rp0jlB5+ihgF2MlaGvn01n1ZRwcQiSMvSo
	x8y/pk3A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hzrUG-00060Q-BA; Mon, 19 Aug 2019 23:54:56 +0000
Date: Mon, 19 Aug 2019 16:54:56 -0700
From: Matthew Wilcox <willy@infradead.org>
To: linux-kernel-mentees@lists.linuxfoundation.org, linux-mm@kvack.org,
	kernel-janitors@vger.kernel.org
Subject: [PROJECT] clean up swapcache use of struct page
Message-ID: <20190819235456.GA9657@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This would be a good project for someone with a little experience and
a lot of attention to detail.

The struct page is probably the most abused data structure in the kernel,
and for good reason.  But some of the abuse is unnecessary ... a mere
historical accident that would be better fixed.

Page cache pages use page->mapping and page->index to indicate which file
the page belongs to and where in that file it is.  page->private may be
used by the filesystem for its own purposes (eg buffer heads).

Anonymous pages use page->mapping to point to the anon VMA they belong
to and page->index to record the offset within the VMA.  Then, if they
are also part of the swap cache, they use page->private to record both
the offset within the swap device and the index of the page within the
swap device.

Then we get abominations like:

static inline pgoff_t page_index(struct page *page)
{
        if (unlikely(PageSwapCache(page)))
                return __page_file_index(page);
        return page->index;
}

My modest proposal for deleting the first two lines of that function is
to first switch the uses of page->private and page->index for anonymous
pages.  Then move the swp_type() back from page->index to page->private
again [1].

I am willing to review patches and provide feedback.  I can go into more
detail about how I think this should be tackled if there's interest.
Also, if you know more than I do about the MM and think this is a bad
idea, please do say ;-)

This is going to be a tough project because there are a lot of
rarely-tested paths which directly reference (eg) page->index, and they
might be talking about a page cache page or a swap page.  This is not
a simple Coccinelle script.

[1] We have enough bits to do this; on a 32-bit machine, we can at most
have a VMA which covers 4GB memory and with a 4kB page size, that's only
20 bits needed to encode all possible offsets within a VMA).

