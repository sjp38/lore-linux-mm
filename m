Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C79C7C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:34:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9839121926
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:34:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9839121926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2406A6B026B; Wed, 24 Jul 2019 10:34:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 217AF6B026C; Wed, 24 Jul 2019 10:34:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E0CA8E0002; Wed, 24 Jul 2019 10:34:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D85EB6B026B
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:34:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 145so28679321pfv.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:34:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HsXRVuRBjoA/JcCG8ikelY2YldtlCG0cYYX0W5/OmLY=;
        b=Q/174x/AeITo5ISa6wzVzzEMMTrwuYhOnpqJqFQ2/tAf8MIwCURYTB/oCsNJdVw3Ga
         /3FYg0gU28lXGeaL7YGShDqLpnl0GJWydodxzdY1UrCgGdhQM7NoLq4BpwLuFCX+Irrm
         yw/hc8/MB6/JWYmlC/ayXIHOq7JAt2MpaU1iFa8k+Hg1MoUhhHjgtwsg+dmldwSK8Ffl
         nhWfef/rS9BPPXM/bnSrEmt5xeaAwFBYu+LPoF3s/4V0jnh77N6JLpMWUl/E0d3QnSy9
         l7TYgg9pSkjbAHIlCbU3CsV+OeN8E/EetSOIxmu7xejULz63BaFkV5mNvlgPb0XUSTmA
         vq8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVhA8wjPSfnyzWmLxkbqTF0ICxtZHSmPC0KIlIT8zT6KSZRahnL
	PDzd563BN2ZORgrqb+pMZTIp8mCVACUALE/icPjDYA76InS6IcXTWGp90X95KopjvuhpPvnHpmQ
	oj09bDNkcSVVGo7Q8w4XvfA0DB6Z2Zg9R5ZaUgFrRIqEzvuF4UDmmHkD8gZ9tGa0dIw==
X-Received: by 2002:a17:902:2aea:: with SMTP id j97mr73919048plb.153.1563978890559;
        Wed, 24 Jul 2019 07:34:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymNsrsO+CH9iJaQHpxs/oJUcmZ31nS/6ZVkGVXTqVQ9KeP+xblqAuaIQeMZbidgFjqi2US
X-Received: by 2002:a17:902:2aea:: with SMTP id j97mr73918992plb.153.1563978889926;
        Wed, 24 Jul 2019 07:34:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563978889; cv=none;
        d=google.com; s=arc-20160816;
        b=RXOpthQiefCpRoyZbcxytIr9nBAnOfW1PyLPxa08hSaR3AkSnN6DZyFJs/Orpt/Mqj
         DaakzX7PosY6JeXqwovfjdO7ww7rcpIynQvqEzGEV+WNVieGTWZJN0Kxb8Vo/sZShNtD
         WECiyvMIki8H8foEw+rfoiYOaY6VXc5ZpgokZ9C11gC0YR+mPVuYzfiMYwSmytDBQUaS
         YZMCEHfIg7Zja5T0T0UUlJPoWYTRI1aLuBR+bthSfBDXVJ5zAAaFgGpYNn5YhIvRMzG7
         wmvmCU8nQkl3SBTSsFOeKyTK6fO+m3esLjehn8sLYr2kaAy4FwoKWtWLrItu+yf2woKi
         850w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HsXRVuRBjoA/JcCG8ikelY2YldtlCG0cYYX0W5/OmLY=;
        b=yYjXs79VChQ/LVuJq3qpej9Wo2E1v1QhqduCIxsjfF/IFR86/vx0OF6cl2AaurTNiw
         ZYQjNv/RYyTuncL75hgNkWfsCcjegnthQyUlQ6zBC6iXGiYMiikXe3OeuctERjTduQh1
         pCs5dmHCnFbd8W8jIMDnXXJG569Ma2NUpaEeNHKN2Og09rn/olXrnXqyWqJhC69kd399
         6UeDyoh0nV8AIuMgyYEE1lLPE6mQqfdxN9y5bpNNxRPiiYqhuFWjESldVJuP7mG3ly3w
         4xGAxwoUwVz2TEOgBO6gxjo9oxffxydCDQxpY3CAgBKqQxDzrz5FM2l2+YGTrVyUONhw
         /OIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o6si14274257pgv.273.2019.07.24.07.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:34:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 07:34:49 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,303,1559545200"; 
   d="scan'208";a="171518552"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga007.fm.intel.com with ESMTP; 24 Jul 2019 07:34:47 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 39248130; Wed, 24 Jul 2019 17:34:46 +0300 (EEST)
Date: Wed, 24 Jul 2019 17:34:46 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: YueHaibing <yuehaibing@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz,
	yang.shi@linux.alibaba.com, jannh@google.com, walken@google.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm/mmap.c: silence variable 'new_start' set but not used
Message-ID: <20190724143445.ezii7bwbbxxxtu2k@black.fi.intel.com>
References:<20190724140739.59532-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<20190724140739.59532-1-yuehaibing@huawei.com>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 02:07:39PM +0000, YueHaibing wrote:
> 'new_start' is used in is_hugepage_only_range(),
> which do nothing in some arch. gcc will warning:

Make is_hugepage_only_range() reference the variable on such archs:

#define is_hugepage_only_range(mm, addr, len)   ((void) addr, 0)

-- 
 Kirill A. Shutemov

