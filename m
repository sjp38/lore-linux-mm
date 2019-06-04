Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA1C0C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DA1D24A8F
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:17:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jfoi2joh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DA1D24A8F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AE3C6B0269; Tue,  4 Jun 2019 03:17:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2381C6B026A; Tue,  4 Jun 2019 03:17:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B1EC6B026B; Tue,  4 Jun 2019 03:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C33B46B0269
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:17:34 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id u10so3259899plq.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FJORX3JeCyruZ/L/acO0maUXTCoUb/nO5fa3SUQgrYQ=;
        b=AncZ9gouYlVnyfgtsw4dP8n786MMFn615PZ8mLgyeBT5Lvl4ryMvZ0Lbi+vl8f2iMY
         ZCu0XUYbx0uNSxV8I5CjYtb6FgYmCvhCJLi2/iWBjrB6HvRa6nvMV9ZLh0raXwpBV5Dj
         QZOgxCPBY+Mtwu55mgz7TuttFGCmJK6YAW/NxYX9x9ZKbHcmW9tkVFqGnfm8f4SHRgjJ
         By5aEPuWF221qftvx2RAiXqVdtYQZ/wx5uJIcBM/GJICU5ofjtnwY8vVuvYKUEiyYjhf
         aH2jTjpKCQlAjx85JI7PLmrGSgx3sCicE74vHDplaN/DT+FtcWigyN7sb6RxtIUdqRVd
         n4HQ==
X-Gm-Message-State: APjAAAUoKtfHCX8AP9Yq3WQTdXAwHIoZ4cUBtg+KoQq41Hqq6xjj/IW6
	YHpOkjYTzLUv+0nhHWLGxzVNqkxi/BxTawZIlgNi/E2sKbAEaqObX31fDk15wdeCLVgQVZVc959
	aPaBT8P2nZn0qneJjHv4y7Gs2a7jKYc7AWa3iPd/KS7LFP0p3tX4XEqebIY9dwdh5xg==
X-Received: by 2002:a62:5c84:: with SMTP id q126mr10176951pfb.247.1559632654492;
        Tue, 04 Jun 2019 00:17:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvFR9eSgbvkd3w+iJUQ7VA3RRqzuD/XaJAlyR3NQQYk9BDbR05MUwrGISJ1Hmi5ZLJh/Dx
X-Received: by 2002:a62:5c84:: with SMTP id q126mr10176930pfb.247.1559632654005;
        Tue, 04 Jun 2019 00:17:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559632654; cv=none;
        d=google.com; s=arc-20160816;
        b=jUKcmfLEW73qJQ0DkB7v4iuKtHONkVmcd6gyJeeMR20KfSDgXGXFMVr0TziL7Z2ot7
         Voo7thnTMi5E14lU/XJMn7rKShUo/PVpTHZcrDaOpVkX6Y4JTzxQ9VJCgVTVl2XnrOJ+
         y7O/s86WHwSGJ45b00Ix8nGlgULY/rQZYcqn88SfTyJKpE5Gd5UicQDXo8PuCYVDG6q1
         9JXkzCEUdZE6XzU3Hp1Q/HWUBDvSzIHK8GBb8c/uamEx+X3KHaXR5ymDxGaSTsV0RQT5
         TrExKLUeSv2Q3XYL+JiovKkvoFTJt9z6lkrLROKB7hBsXmAbnvKf6Db+0yK9lQs4WNoi
         ItJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FJORX3JeCyruZ/L/acO0maUXTCoUb/nO5fa3SUQgrYQ=;
        b=UROYFHdSH+6gmkvbGRH+YmvrFKlWE7nfRX8UvNQ8iw+dJmJaxqksIX32GlMw+T1dSw
         LXvq6wtTgrdU60J3xG1UkkQGQHBLlwestM/HzT1zrpqi8wtQh8MZMtsp6tE2btucLovK
         AWYbXCmHLZNIt5uvQ5SevNmGUaKy6P/d6dss83jb0Cfmn6bGcTCJHCvBNzhhDQMCdLMM
         lFcRUWIWJkrHtm0PcUo7FQ11Nc35llBrfVYhqvURON5D3eFLrhOFORoCMRZPxNq3Ezdf
         QfPyErpW4IB0zCaWjkR3BZvAvkt8ifsOGf3x8FIWePrZ/MWO3hfEkHxDtk8WueegzaKQ
         eAxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jfoi2joh;
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f12si6440625pgg.279.2019.06.04.00.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 00:17:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jfoi2joh;
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FJORX3JeCyruZ/L/acO0maUXTCoUb/nO5fa3SUQgrYQ=; b=jfoi2joh/mzGfEk7oqOjRTOHD
	fQCUDoMITayn+YGHm/kNmN0VOvtseeK+mDfRflr4iSKEQ6OZcKPm9BHvlzT65KuEY6P2+H/2WP2zi
	eManJCcPModmnqLCoKEncNg3xHeP5udk7eKFYhOJIKBqs7cegzYTm2NKbXZAwbCfdzaTMaqjgNeGf
	ly5O2TI3dwqi0Y8+m24YCrvDGhzgflwRsnWv1hWG1GbMsgITczeW3h/ssQi3KaXvpxxfNkA0YGQxq
	gqtSvh8l0Mh/2Wbv2KLz03K3vU/Ch8YHaYZV7Vora+ti2qQBTwoyr1cQBQMEinLmojBDOeuxThWE/
	vlpPMpsQQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hY3hL-0004Jf-RP; Tue, 04 Jun 2019 07:17:31 +0000
Date: Tue, 4 Jun 2019 00:17:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190604071731.GA10044@infradead.org>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org>
 <CAFgQCTtUdeq=M=SrVwvggR15Yk+i=ndLkhkw1dxJa7miuDp_AA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTtUdeq=M=SrVwvggR15Yk+i=ndLkhkw1dxJa7miuDp_AA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 03:13:21PM +0800, Pingfan Liu wrote:
> Is it a convention? scripts/checkpatch.pl can not detect it. Could you
> show me some light so later I can avoid it?

If you look at most kernel code you can see two conventions:

 - double tabe indent
 - indent to the start of the first agument line

Everything else is rather unusual.

