Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1F43C31E44
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:47:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71BC0207E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:47:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="JrvP60GK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71BC0207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03BE56B0003; Tue, 11 Jun 2019 22:47:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F301D6B0005; Tue, 11 Jun 2019 22:47:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1DF76B0008; Tue, 11 Jun 2019 22:47:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92B8D6B0003
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 22:47:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so23610856ede.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:47:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ptASItmcUSNnhSb4M1FVZMgI8ehvXZD+lmmHC8Q/l1Q=;
        b=BDAnrA+DBogrN/98SPJ3Hp6AAbJMgMiMrYD1L/YWPfemxqI2G1rBsKDOUPVENt16Y+
         +d6SHeautbFojOF+dDc1sXtP6o06Za4umNz/N1bSAlVAsnGvm1B6So2q60Hko96KAPeO
         y8RNal4O7gAWChsn56Ly4ArBz10hXCOS58MApXx4O6UgLYZ+zX9nfJsnXoFP8pJ5FHRu
         eTRNDc6NFTnlpGGNnjd3WnYmPc61pj48RJ14d43Vk52P6ICuwiJHjXE0yMXtdtFa83il
         evTNsrNsO286GFTLVVKV/pxa9rTcL1ZUnFECHlknLq7Svmp+hMzBatzCZn/yCUsJeP2b
         QcCA==
X-Gm-Message-State: APjAAAXwjs8+AeX5zJjR2ko5MEZ5yyJ5agvs+7yybE9zp5zSRlQbI6Ms
	YkobATMNIBZ+Whr5v1+OAMVmnCBEqEJHvR1+svuw8JWFV64LsmcmWK0YdlyORmXNHPAyekQNb/W
	Lzea9WXH29NwYL6oykfUQZLTyhm4B1JO1uPzCy9JXGBXV86jNS3x9Xw2HbxTzFB8e5Q==
X-Received: by 2002:a50:91e5:: with SMTP id h34mr37381170eda.72.1560307669182;
        Tue, 11 Jun 2019 19:47:49 -0700 (PDT)
X-Received: by 2002:a50:91e5:: with SMTP id h34mr37381128eda.72.1560307668467;
        Tue, 11 Jun 2019 19:47:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560307668; cv=none;
        d=google.com; s=arc-20160816;
        b=OM4sqlos6Z1PcPq1W0hHyskJ/IaKnUwy0c1v+aRWQIftr5+wNF53i2jVGzq2F8FuvV
         oCrMEo4bep3A5D6BlEEsr5SwhUtqHgNgO0uF9UTsJoMwekINQfIq71ArxhDLG7GluY8k
         GWGZL5TE/1sxbDCKsLVi5qd0iqkKVHeoDk4/ucLZcNdoXoSCZcgtKolLRj5oLzAZlx6h
         y8ht5EEphYsDmGAh+07vd2rhHgkt2Mun/zW1GCpb8pjM102GS8VcVQ74u5aNIpzQ5T0R
         4piKqH3aReMnRV3xcL0+UC2VefJLzpTwRl+LbFQoWUwtQ1TeW/DkUsUFK8QFnAbwieO/
         ghvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ptASItmcUSNnhSb4M1FVZMgI8ehvXZD+lmmHC8Q/l1Q=;
        b=T/md8zGTYsvBW0gH4EY3KkXa+8Genfsl3iGcc3jpItfHpw0gAEzt/ISLu2YqzwBUqp
         T7I08TyZMQhOaij2mmJrJIQC/+dNLvkkHJ4wNso76DtpxaHU91ucmSb3FV4lXAyiKeHC
         GdOUY1VgjfmI82DdbAvc4W6PJCmmyNOsZNKUGJFm4aJMD3h31n5wZgtG5ExSHOY4roDt
         jMyiYBX7qY0BOIJ+Gl4XzIv7vDOP5/5kBxwh4kU4afOdw+i92O79a0YM3adaYRvadXhq
         2ySvw+PKhsSCyt14VpfsDZyffiNgyRyNE0Rrqni0AHoGO1O+7GnYVGytCz9FsOsspKNz
         v0fg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=JrvP60GK;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cw2sor4726087ejb.24.2019.06.11.19.47.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 19:47:48 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=JrvP60GK;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ptASItmcUSNnhSb4M1FVZMgI8ehvXZD+lmmHC8Q/l1Q=;
        b=JrvP60GK41wKZgrh/T4MTTXu9mTuEbTyFZskN+iq7VD9X78OuMK1ZUG8iWOOdLQoFH
         n6rVFXBAPhLjS1F4qeKN/h+l7QoTXdhnmmEKOeHW0lPEeO1nSy0YYqxYoyzymp3dFtpC
         oOIwa5YjNGEeuW/EPPU/kfQXm/Cy2vlqra4N6Xu2DAE1jdYAiPTaU32dXmyo5nZf7gbx
         k2hKtqiXueXmkCfspVH/5/n0H/yPOxW5D9k5GSjuB+gkfLOgLb22peR4ZZ/ftc94pmku
         GMD7JzRJ7ofhp4s2xHsfWwGHHjpJcDKVEmzkuiIh27sMT/n7zLpe7bRcfLBbTTiJ5tdZ
         66mw==
X-Google-Smtp-Source: APXvYqx+plsRJYH/COPz7/gHfMLDquyGp1ATrNtdlNVMWvpKBkg4rGfRPX1fOyim62NphdiSKueEyw==
X-Received: by 2002:a17:906:c459:: with SMTP id ck25mr25010903ejb.32.1560307668058;
        Tue, 11 Jun 2019 19:47:48 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a53sm1093281eda.56.2019.06.11.19.47.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 19:47:47 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id CE049102306; Wed, 12 Jun 2019 05:47:47 +0300 (+03)
Date: Wed, 12 Jun 2019 05:47:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com,
	shakeelb@google.com, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/4] mm: thp: make deferred split shrinker memcg aware
Message-ID: <20190612024747.f5nsol7ntvubjckq@box>
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 02:07:37PM +0800, Yang Shi wrote:
> +	/*
> +	 * The THP may be not on LRU at this point, e.g. the old page of
> +	 * NUMA migration.  And PageTransHuge is not enough to distinguish
> +	 * with other compound page, e.g. skb, THP destructor is not used
> +	 * anymore and will be removed, so the compound order sounds like
> +	 * the only choice here.
> +	 */
> +	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {

What happens if the page is the same order as THP is not THP? Why removing
of destructor is required?

-- 
 Kirill A. Shutemov

