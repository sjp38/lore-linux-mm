Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24CAAC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:38:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B32C7217D8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:38:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iqa/5AWM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B32C7217D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DE498E0016; Wed, 26 Jun 2019 11:38:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08F188E0002; Wed, 26 Jun 2019 11:38:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBFEB8E0016; Wed, 26 Jun 2019 11:38:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B59E48E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:38:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so2014410pfn.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:38:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+/or7RUo8RlGi5/xsF/irgqT3ptx8jRXk2ETY+C794o=;
        b=tXpxSVJ80d+K3wbxlJVU7NT0+c9NS3MS48LaMrU49vAT7U/JRCcBCKi9C9BfFshBXV
         o2zvyxPTxII42YPIzcZ6DCW1ahg8Uas8LCJjovcNaLxBhbr72XnHP1neYNijfBSjZ7/u
         O6pFQPA6rCc0i7TibfwVhp4IIxOzRqu5VmY/yxXnPxf48fPLnDhigi4rUrMp6g+vkc93
         yupTzqGvLi/hP1tId3qPiOvDvpA3+t/FhamG+2OPpuNXAFvzKgMMWV4isHAfJ4e6jllK
         /SQZSj7jEqpY2WqEMapvZnPffuRu6cCiEAV+zfq91/6JwnnmCD/AXFeaxV/JBN50hxnm
         VQvg==
X-Gm-Message-State: APjAAAVn+0Q2YhCCc59cswMx1UIGESrkMsca/pxOOf59WIUHg2m0T8HN
	p8P9v0LMc3FSofHlUMSr7mPND5DP2yqYh+TT/SjCGr3V6t0zMRaHes3LM4w/7rppZquJzcFhHt6
	28HowLG0vSjqwHq1o1Knx+z+8x7ZINsMvMSYX7qy2dYuaWhGwHZ7pOrWeua7YAkuP8Q==
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr5535773pjb.92.1561563512244;
        Wed, 26 Jun 2019 08:38:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrnxs9RWTcTKWb30ooE931zCsdGcDVoYrMOd0Rk6UsnAV323uMzg03Y91SFOHCz4lOpkVc
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr5535694pjb.92.1561563511417;
        Wed, 26 Jun 2019 08:38:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561563511; cv=none;
        d=google.com; s=arc-20160816;
        b=ucJ9P3/VVshx4FPzhA1oconbURqRmiXm7VHJNUOqPruXL1K0j8wR5r6vdcbqRmYH+j
         ipywH8M+caZ7+yQunF1YviDqA/XBgspcsWeX/eVIVOfJH1KzALM/6E95qWqqgXP1BriZ
         bSDbBtS7Au8DdfBSL0K84rJfoYEanQuHlZe1bWIS6oto4aAqxJzm0A7r+OlHi4ntcKg2
         Czp0al9eoeqrZgPcZr1bCOQx+FRnEeBJfkdb9VClTAoJ0T46WguMnck0/OOJNXjW4gCX
         Jy9t+1v89dRHt/G2XknicjIhzxi1jtCJIcGfchTxBshvd48/LjpkbQBnminfq1QQ6uFH
         Q80w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+/or7RUo8RlGi5/xsF/irgqT3ptx8jRXk2ETY+C794o=;
        b=blUvN/uvzsu+0P9AlJzRSo0eBTu53qHYXBKtTWM/g05SCveir/JeWLVfooB9JFNQAG
         9LSIZDUQk7gAOFIkvmci5XpYZqq8NbBuG3ayvhsswOVxRnSori6mgbiSIsudRxX2qsY5
         MldxKE4P40YWualt7CGaKi9GKTX7YRiFTQGTEBGtx43WxPsdeXSqqJOPuhJz8oqetmao
         GeG7Biex//Qj7MqbDbZWaCPSveNMhHmoQp0wB86xUz3Ofum/CxiFN5RZHls8l8l4QWqi
         CxPu16DBFiCkrZbp/kK2GQgg0roI4lHp7ZDF+JG+O3BVKNv+WxhIOCzTs9fwUcQj7BQ9
         5/lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="iqa/5AWM";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a10si16356589pgq.194.2019.06.26.08.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 08:38:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="iqa/5AWM";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+/or7RUo8RlGi5/xsF/irgqT3ptx8jRXk2ETY+C794o=; b=iqa/5AWMRhPrM653o+fAvvzP/
	3Lu11i5qtEA4ol0XFXBypacKt3hMduvti/cE2K/yNgiQ4JRON9meWX+Po+pL5yBo6NP8FgwZSYEFc
	Mdj4WQn2vH6kw8etGhdrkBZHybPguu7XHlfgj+JQix/X/BYr1OfCIztMkG8B2KcHQ05PMK0WbemnH
	v50nvf7jL5fZ2lPZYTnNbtdWlaY7trB2NndBDzJ9Nf+Dm5tLjPQUoHrmoaAT8wTKYmzbFSOO+uUbZ
	F2Bz/idD0WyKulTxAegisbOggsq6y/MYuNqTHpvvgnVktWlVD18xTtxTQlhbkT6gRspskDQF9ZtLw
	6G1KTOdiw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hgA0D-0006Qo-QY; Wed, 26 Jun 2019 15:38:29 +0000
Date: Wed, 26 Jun 2019 08:38:29 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Robin Murphy <robin.murphy@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Jason Gunthorpe <jgg@mellanox.com>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Message-ID: <20190626153829.GA22138@infradead.org>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <20190626073533.GA24199@infradead.org>
 <20190626123139.GB20635@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626123139.GB20635@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 01:31:40PM +0100, Mark Rutland wrote:
> On Wed, Jun 26, 2019 at 12:35:33AM -0700, Christoph Hellwig wrote:
> > Robin, Andrew:
> 
> As a heads-up, Robin is currently on holiday, so this is all down to
> Andrew's preference.
> 
> > I have a series for the hmm tree, which touches the section size
> > bits, and remove device public memory support.
> > 
> > It might be best if we include this series in the hmm tree as well
> > to avoid conflicts.  Is it ok to include the rebase version of at least
> > the cleanup part (which looks like it is not required for the actual
> > arm64 support) in the hmm tree to avoid conflicts?
> 
> Per the cover letter, the arm64 patch has a build dependency on the
> others, so that might require a stable brnach for the common prefix.

I guess we'll just have to live with the merge errors then, as the
mm tree is a patch series and thus can't easily use a stable base
tree.  That is unlike Andrew wants to pull in the hmm tree as a prep
patch for the series.

