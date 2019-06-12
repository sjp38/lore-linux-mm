Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6719C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:24:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E7FD2082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:24:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pu7FtOXG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E7FD2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33F16B0006; Wed, 12 Jun 2019 07:24:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE5066B0007; Wed, 12 Jun 2019 07:24:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD3956B0008; Wed, 12 Jun 2019 07:24:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A23246B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:24:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j21so11803510pff.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:24:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KJAXvYM0DI4vnD/0tu+larrshBV1A0aACdJmWI9kxzw=;
        b=JU64LmtUPLKsCPn4aBRUdxViAmPjNSMqsnNoqAOY/cKZiT+e9ihkCA0F0H7p2Ffblb
         oqhHmAgRm9VVKnVNErRfExinOF2Q8aINA3Fe7zFTNBBOPWLt4hu0epPksETZ3jn7qN4i
         cA0k4UWLzUHsnrvFPsccT4WiWxna+4qozi+bqaq0lPFEx3NPA03t7NCYTxF5aHDGVGO3
         S4JKgrm8+wgzW4fbzK+faGbg4L/aHJF8IBToMlsI9t+R1ZNgjHVsQ15pjb2aUHTX4WY4
         NtKS5chhGQOLFthmAqwIOeqsZ1aiLNxYzr5rEIYbnNBjChvnmUGIoKYx39wnaWosU3mC
         Wefg==
X-Gm-Message-State: APjAAAUEKfzTEYZwaOnfAmiSslgcZEMobmP91eX3l5YklLPvX9whwLjY
	yoSErJ1QL90IQp3yZnalZLdS2rCCG+ZN2rT2TCVvdd4v0zG7jUdKtRjHS6xjd0qb/raG5jINmIS
	ok7fHXlHAFHOGImgPKmcANZRaLKhciKSHJ1clQPOSjwdzWxlBV6v1VmLz5tD0ZyG4iw==
X-Received: by 2002:a17:902:70c4:: with SMTP id l4mr64468031plt.185.1560338657323;
        Wed, 12 Jun 2019 04:24:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlc6uV2vVs+ZOXSAyBsET/NkbkhhbzC/j/RBMpIptVgNFaaoYm9TX5Cmm0wqMQqKgInsta
X-Received: by 2002:a17:902:70c4:: with SMTP id l4mr64467999plt.185.1560338656624;
        Wed, 12 Jun 2019 04:24:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560338656; cv=none;
        d=google.com; s=arc-20160816;
        b=xdc3VSghMPa4QAx/ts8CLLJCuW4giTI7Us8ejcnibfBrtyvdUfxwxIGiV5dv6tz+d/
         tVLm25+bxvzCgAhhhvQjep/qLHTPSmyZdlwkPX9RWd1qCb8kfMh5eYBWkF5E1bD7yd43
         moVF6zpbUZ9jPtkPsE3fkG9adcvrBI1cXM2zVxkwhuH2yqFolEufVjeqV3ZAeSyvJC2V
         0bpqPCTuoPVBp1v97ngnhG2PMspbGv4nCQV8BMZLyhUEbFTpRMsowNIxtprT6gRL9viy
         LMOkEz1JVGltugSOCp7oZBkeVLz7psnYcrKjZblz4/MJI2eXrizBtcYlo76BUYiLOoss
         1jfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=KJAXvYM0DI4vnD/0tu+larrshBV1A0aACdJmWI9kxzw=;
        b=kkcl2nivOF2QdZ25g6BCUTauG458kH7MFDqvCFrx3MDKfqUWfRY/qD2AglXGskkVFT
         54ImwEtLtHZOv2h+yc8blcHj9VuKxIwLwGC/OwcMtc3gKbM28foAB0aNkvc9zd2ssIA9
         FVRlH729tl8glZYZJITWI5kHW3zC7NRoyvaSNT39MD53+QqtqtOliWQv/4pAOnLeItoL
         mFmkGx2xV/0r+dg8uHvm6zPcq1oYX8vlneY7362+o/je+W7NB0V955xYF7DpK3irH+7T
         bZc/XI17tlZzBVPgZFeuCYAonUFEoSWsSjUt11IgW1EpeP8Gw7R9JjO60hEdgMlmwdjs
         AsVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pu7FtOXG;
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q4si16238615pfb.272.2019.06.12.04.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 04:24:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pu7FtOXG;
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=KJAXvYM0DI4vnD/0tu+larrshBV1A0aACdJmWI9kxzw=; b=pu7FtOXG6wwPz8NJqGleP0ENqZ
	mWOWq7bfIS7I5pJndBO7Iorv4+OVLhztJH0MIESlmLmmGgHrX5hLbLEBOu5/+LynDGtoTdbcUkwHz
	m+0nmPp8W2Zntos4QTutZ9PdRPfjOaERnezAPGG3G6HwOydPr0nIyh6ofXteGyBhSrbeCM90amEhl
	OvRad6uKCL5pbwCDcWfUThMqxLI35Q+Iv2FUvjxoK6yPof3pP/uGWUbgh7SyFzGn2D06ZiXnMuLmo
	FR8QqLtcf0RpwhAoW7YZQpMmHjkcYzS44RCzNLkzUQGIM1bRdNtGmin0BBuQtePw75gHO3CRPmO21
	BHvzeyqQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hb1M6-0005io-1P; Wed, 12 Jun 2019 11:23:50 +0000
Date: Wed, 12 Jun 2019 04:23:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thellstrom@vmwopensource.org>
Cc: dri-devel@lists.freedesktop.org, linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com, linux-kernel@vger.kernel.org,
	nadav.amit@gmail.com, Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH v5 3/9] mm: Add write-protect and clean utilities for
 address space ranges
Message-ID: <20190612112349.GA20226@infradead.org>
References: <20190612064243.55340-1-thellstrom@vmwopensource.org>
 <20190612064243.55340-4-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612064243.55340-4-thellstrom@vmwopensource.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 08:42:37AM +0200, Thomas Hellström (VMware) wrote:
> From: Thomas Hellstrom <thellstrom@vmware.com>
> 
> Add two utilities to a) write-protect and b) clean all ptes pointing into
> a range of an address space.
> The utilities are intended to aid in tracking dirty pages (either
> driver-allocated system memory or pci device memory).
> The write-protect utility should be used in conjunction with
> page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
> accesses. Typically one would want to use this on sparse accesses into
> large memory regions. The clean utility should be used to utilize
> hardware dirtying functionality and avoid the overhead of page-faults,
> typically on large accesses into small memory regions.

Please use EXPORT_SYMBOL_GPL, just like for apply_to_page_range and
friends.  Also in general new core functionality like this should go
along with the actual user, we don't need to repeat the hmm disaster.

