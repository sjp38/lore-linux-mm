Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DATE_IN_PAST_96_XX,
	DKIM_SIGNED,DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 276D5C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D641F20879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="i3R6Bb/6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D641F20879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED7D86B0007; Tue, 14 May 2019 09:16:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E89F76B0008; Tue, 14 May 2019 09:16:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D29E56B000A; Tue, 14 May 2019 09:16:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7925F6B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:16:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f41so23316398ede.1
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:16:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CHWpX3YGoQ1Jip23f4D3yyKcuL7/asBYsb1wj7F4V2Y=;
        b=GhYQEYZNy6J+d5wdzG8t3U4Fz2cwXiXipN4oavNgx44AhEaxLH76dyq37oG0yPUpeX
         /PX+X4xelwXf4CTM22qWKE24K18abWbSKdmqGS1XpaGigoE00uOy6HT4ShQkegOqxgWd
         qz6kYK6FZGfpHUR0bN6675xg2TztWrK3rX0IV5oy2lt/1kGXxmhZPfNWLZ4B6umYj/PS
         uijUvvLYSjGfw4NUudSB9q98CcQziuYNLLcJxglr1r18eU3mFwLoPolOx+Nxt9D3lZJV
         gMXPjq2f5XHx+1zEifazVaEtYc/I00YyIElkOAJrL1Nlj/Xoj55dxrk5xGWT7VGLc9XW
         iIQw==
X-Gm-Message-State: APjAAAVv2rMpAscWO1Onww3zpaTdFMHlD5Z6c/mLtNYt7Do0VvjSZYZc
	l6jCJ3y2XxKOtx+8qfzcBumQ4ouTmjL9TClMmDHHxCgdu0/C/EUVytIALabv70D8hArEwgE+AP1
	QS5D1QOajY8pK9rq9rduji/Qqw2UGVqr9+lAULxtneufT4XFoVge0UumeoSRYLuR55Q==
X-Received: by 2002:a50:ce5b:: with SMTP id k27mr35968092edj.48.1557839817107;
        Tue, 14 May 2019 06:16:57 -0700 (PDT)
X-Received: by 2002:a50:ce5b:: with SMTP id k27mr35968021edj.48.1557839816444;
        Tue, 14 May 2019 06:16:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839816; cv=none;
        d=google.com; s=arc-20160816;
        b=xSqg2LY6uRDM72/1vN9L1VCdowELBTG7aFlCIjAyfYgeDrwt43udf0SHMALRM/3qHW
         X2YKSh1hwgcbpse2at0czcB2dbb996Iofpn1azG+hXcc5pK5Dgvvu7uOOd83dF2OCc6q
         gdXJ/Qld2Lg7XhjZDLPSh41VPgu6myq/YKHFOZZ9D0UcJLNIjACi3mnZ0kGZGnxfJBP2
         8ghPirjN9k7OTi+6fwdlMxGcwwExa1Np2WpM8J6oS9AoJK/rhG3N56hVfJyXCyYDptg0
         awssmJVm733bpEOOCbjRhSu0DYRqzlKifn2EFPsqJSmSDXwzQkXkaKm7t+AoYVD8maH3
         /haw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CHWpX3YGoQ1Jip23f4D3yyKcuL7/asBYsb1wj7F4V2Y=;
        b=wieLmmjEeix4osgw1skWuwWuW307XSOB+P1CxQIkf+n+GIMiCepzXHV+50ZPpxHweP
         xR+8YKOtY8WI1gRx5zS8BGcYndR3CCS+91Kjl/NC6FdkiODTOw5P4HU4Tl3CZOuXo71H
         AQ9daUa/ZRjMzRaHpbCffpbonCqIbFoTAuzx9ZZe6yayQ1en51GCEWt2WkREYi12dMu9
         vZdN4unaiB0G0kFyX5OiXQMw+SCQq0OwinvdY/av/ZR/u9id22MuiarOvKcGDiCublWz
         dbzo4JCWDsr76d1fh52Jp6xeyCC9SuuzJXNeZ6lbYDRhhKWpWGnDgnGJ75/VhrqvzEsx
         Aj8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="i3R6Bb/6";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l25sor3740744ejr.60.2019.05.14.06.16.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:16:56 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="i3R6Bb/6";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CHWpX3YGoQ1Jip23f4D3yyKcuL7/asBYsb1wj7F4V2Y=;
        b=i3R6Bb/6RnFRIMhy1HfmYjDK7U/AedptQyTgt9ifxkgQGCWAoFRsJTJZC9vFsQNJGA
         BttrzfhbZQ61b/Q5+CMg+qu0kpkH/hntHEjQuPpWw7G/WcNrEtD2SGGT11FtpskpIyBu
         PC3Fp0ivqDSytGifw0HXzDy8Vew3zlRojUGn0CFiMSoeYEZDbjnJALk51Y1VoQpN7fxV
         3Z1Pe9SBjAoDdgbVisp0jsWjJVQs2LZhamXZnvK+1lhcR8i3hw736TA0AbWcpbDEI7ff
         ZcFgBWmGQgtnNLDj28St102ONuenQoq1Fme/Fqp3wyWGLQNC74q8Kv106fkqZDV7r0IF
         wXrA==
X-Google-Smtp-Source: APXvYqytopfYB8ZsBvCLtaSyDP+kl/LQatUzrykx1ROp+rWThl1TA00nGWPGpzhE3uazmcmUmYtOpw==
X-Received: by 2002:a17:906:e29a:: with SMTP id gg26mr15319678ejb.121.1557839816136;
        Tue, 14 May 2019 06:16:56 -0700 (PDT)
Received: from box.localdomain (mm-137-212-121-178.mgts.dynamic.pppoe.byfly.by. [178.121.212.137])
        by smtp.gmail.com with ESMTPSA id i33sm4578223ede.47.2019.05.14.06.16.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 06:16:53 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id EE01E100C32; Thu,  9 May 2019 13:59:59 +0300 (+03)
Date: Thu, 9 May 2019 13:59:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH 02/11] mm: Pass order to __alloc_pages_nodemask in GFP
 flags
Message-ID: <20190509105959.ry7vhxerweov5qpo@box>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190507040609.21746-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507040609.21746-3-willy@infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000029, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 09:06:00PM -0700, Matthew Wilcox wrote:
> +/*
> + * Extract the order from a GFP bitmask.
> + * Must be the top bits to avoid an AND operation.  Don't let
> + * __GFP_BITS_SHIFT get over 27

Should we have BUILD_BUG_ON() for this?

