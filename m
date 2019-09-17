Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD55AC49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 00:32:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93CB920650
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 00:32:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EKBUzXLj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93CB920650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33FCE6B0003; Mon, 16 Sep 2019 20:32:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF436B0005; Mon, 16 Sep 2019 20:32:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 205D16B0006; Mon, 16 Sep 2019 20:32:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id F2EDF6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:32:23 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A38EB758D
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 00:32:23 +0000 (UTC)
X-FDA: 75942536166.24.scene06_31d38ffe39e2e
X-HE-Tag: scene06_31d38ffe39e2e
X-Filterd-Recvd-Size: 2311
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 00:32:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=1PxCHCzaKSbBf9rQHzOPWiqgMBxIvS6Iq4POGaifyXQ=; b=EKBUzXLj3MJGCQpH2J47/ny/v
	Y+v6GWj6Khs7GfhrmTvRgzHpJUBQoXd/IN9sLAgOp4Okd2T3aGduXKIFl6m/zGr3zl1lE7wZV/t00
	c7d7mSWs/Gt5HfHT8MTkGWrQSano25MQu+53hbzIfR7c3fMfWf1S8pPGuui0uXdDjYUfUWnHCqLJ+
	AfVR0hiTEk43CILYHGcn42rGHF1f+QPyuEQ9+IcgozZVCLqm6x2uTCAe8fATmJlStTlTlvpIgQW7Y
	FHiBr3G/Yud478ZDsrWglXj4sw5S2lf5ETD6nkLt1YdkoWjF71I1G6QXg6pc93tTLSM0wfKNej1gs
	nx5l3NK7Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1iA1Pd-0002oB-Hk; Tue, 17 Sep 2019 00:32:09 +0000
Date: Mon, 16 Sep 2019 17:32:09 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Kees Cook <keescook@chromium.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] usercopy: Skip HIGHMEM page checking
Message-ID: <20190917003209.GS29434@bombadil.infradead.org>
References: <201909161431.E69B29A0@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201909161431.E69B29A0@keescook>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 02:32:56PM -0700, Kees Cook wrote:
> When running on a system with >512MB RAM with a 32-bit kernel built with:
> 
> 	CONFIG_DEBUG_VIRTUAL=y
> 	CONFIG_HIGHMEM=y
> 	CONFIG_HARDENED_USERCOPY=y
> 
> all execve()s will fail due to argv copying into kmap()ed pages, and on
> usercopy checking the calls ultimately of virt_to_page() will be looking
> for "bad" kmap (highmem) pointers due to CONFIG_DEBUG_VIRTUAL=y:

I don't understand why you want to skip the check.  We must not cross a
page boundary of a kmapped page.


