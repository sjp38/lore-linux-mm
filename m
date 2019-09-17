Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B429C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA001214AF
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:32:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rGBdWLZb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA001214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83F4B6B0005; Tue, 17 Sep 2019 17:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F05F6B0006; Tue, 17 Sep 2019 17:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705476B0007; Tue, 17 Sep 2019 17:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id 484356B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:32:26 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E470A181AC9B4
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:32:25 +0000 (UTC)
X-FDA: 75945711450.26.bomb70_8995a5d413360
X-HE-Tag: bomb70_8995a5d413360
X-Filterd-Recvd-Size: 2773
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:32:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CNs6p3CN2rZixC1bXHXk6bkwsrcCvyP5gXyakxApfJE=; b=rGBdWLZbq5+gzJ+jj3XIjjqSn
	GmVIL/s4VgFbdaGepjYSl5ywB6tY9FFcTfM+9QfsRNM+pJtU4+rS0h81SxCEf10skCQ/G7d/bM9Ah
	Moa96U22+2max/iAs7IlP2xMYYKy/7LaF6rFqkg7hBJomVsC3x+l15nq/QABKGQ6j2VoiVltclVQ/
	EWEjyd+fU4wxle7cAfJAAt9SAH7m2xLtxwyi8r0kuGiCfxQ37NEN7wTZqBxyoo/TgzwJ0GzRPnAyb
	QRsxasaJW56EUBXjlLHpgYVfRH1af2oBntCWx9y1UQhGOjAX873ZaGrJnM6/KmEP7vBSrTYtvKMtW
	vV/AKRtwg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1iAL5A-0005kc-IT; Tue, 17 Sep 2019 21:32:20 +0000
Date: Tue, 17 Sep 2019 14:32:20 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Kees Cook <keescook@chromium.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2] usercopy: Avoid HIGHMEM pfn warning
Message-ID: <20190917213220.GV29434@bombadil.infradead.org>
References: <201909171056.7F2FFD17@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201909171056.7F2FFD17@keescook>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 11:00:25AM -0700, Kees Cook wrote:
> When running on a system with >512MB RAM with a 32-bit kernel built with:
> 
> 	CONFIG_DEBUG_VIRTUAL=y
> 	CONFIG_HIGHMEM=y
> 	CONFIG_HARDENED_USERCOPY=y
> 
> all execve()s will fail due to argv copying into kmap()ed pages, and on
> usercopy checking the calls ultimately of virt_to_page() will be looking
> for "bad" kmap (highmem) pointers due to CONFIG_DEBUG_VIRTUAL=y:
> 
> Now we can fetch the correct page to avoid the pfn check. In both cases,
> hardened usercopy will need to walk the page-span checker (if enabled)
> to do sanity checking.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Tested-by: Randy Dunlap <rdunlap@infradead.org>
> Fixes: f5509cc18daa ("mm: Hardened usercopy")
> Cc: Matthew Wilcox <willy@infradead.org>

Reviewed-by: Matthew Wilcox (Oracle) <willy@infradead.org>

I want to make virt_to_page() do the right thing for kmapped pages,
but that is completely outside the scope of this patch.

