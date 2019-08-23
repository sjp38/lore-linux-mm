Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DD45C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C574A22CE3
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 11:54:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="dc1S0At/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C574A22CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36A056B0391; Fri, 23 Aug 2019 07:54:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31B7B6B0393; Fri, 23 Aug 2019 07:54:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 231A96B0394; Fri, 23 Aug 2019 07:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id D3CA56B0391
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 07:54:38 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9DBD0181AC9B4
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:54:38 +0000 (UTC)
X-FDA: 75853535436.14.angle96_2875d4678cb3e
X-HE-Tag: angle96_2875d4678cb3e
X-Filterd-Recvd-Size: 3876
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:54:37 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id w5so13074343edl.8
        for <linux-mm@kvack.org>; Fri, 23 Aug 2019 04:54:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XWn2j85u6MVOX5qSxDVagBkhlB2EkHiVTQW8X727y+g=;
        b=dc1S0At/n/qGw9IaZnZaZvHsXo1g8UvqK5wd3lUYPL75cIQnLXYjDknkgn81nTUdTI
         9i64luC5bT5RcmZrTlqltNCokNe9n6OW63na5HKNIOyt5MAhVreWyIa5MyTVDImdCsrQ
         Ug0Y7rq0jBNKwmO51LTC0gqoBkET5U9WcEAaEvIHmGqkIaviJExN8h7helrkd/x6PP0D
         RvJgqHjyK6gpU9Ww985miklt3Zxs11bOUbTDtbnEmbVdXbdxZvR3qLZaEfV0eKUvG0XZ
         Aby/utk7ua2Hvg4Y4OPyoHM05KpsJ/JxiYyBGVhYGCIlDnf4jNHft6w9US72KkW7cMRw
         BdJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=XWn2j85u6MVOX5qSxDVagBkhlB2EkHiVTQW8X727y+g=;
        b=nTCpPCvBTN90aT9Rnq9Q6zDtwbOBQTAvCy/kJlEf2BRTza9wPfQhVMOCpSkqu9s4Xs
         R0QXZ/bLHeaqM9KZdiQfu+olRHfkEa83ATll7BGEIzA8a5Xsw75p4X4EusNu+1SS/POv
         Ez5+RFqODEiDSItkPL3StYdtDNPeUFe+Nd+Dou/DQV2nxhYVW5dse+V4cbsfGWbytSlW
         U76t7WW4IccYcDSJzw6STPJstWBn8l2F91dGrnkfCToPnUjB6sXMqxVOWmkeODmdYU7N
         6S5eHgHeV6RMcFy7JI2ZFDWDyt0fiHeftXPcc8l7CRyXu1ra18+p4fB7qhD0UyVWADpa
         gHQQ==
X-Gm-Message-State: APjAAAWD5+z54l4kM64UlBgfsjSJUBU6tZHPJtS2oJzJsiqf4sHVXTqJ
	hQZ0Sv47ssxhKdA/1DV6dVYV/Q==
X-Google-Smtp-Source: APXvYqznjHJq0BolOPAuW51zUFcfiGmPBgOuocOnkkjGRBdnvn/D+UzOsViex3gjDmlYfZj3iLVVuw==
X-Received: by 2002:aa7:d1c6:: with SMTP id g6mr3956660edp.85.1566561276792;
        Fri, 23 Aug 2019 04:54:36 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id b18sm378982eju.0.2019.08.23.04.54.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Aug 2019 04:54:36 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id DA3AD10074E; Fri, 23 Aug 2019 14:54:35 +0300 (+03)
Date: Fri, 23 Aug 2019 14:54:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: zhengbin <zhengbin13@huawei.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com,
	jglisse@redhat.com, mike.kravetz@oracle.com, rcampbell@nvidia.com,
	ktkhai@virtuozzo.com, aryabinin@virtuozzo.com, hughd@google.com,
	linux-mm@kvack.org, yi.zhang@huawei.com
Subject: Re: [PATCH] mm/rmap.c: remove set but not used variable 'cstart'
Message-ID: <20190823115435.tcfpfudczuqomp6p@box>
References: <1566533321-23131-1-git-send-email-zhengbin13@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566533321-23131-1-git-send-email-zhengbin13@huawei.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 12:08:41PM +0800, zhengbin wrote:
> Fixes gcc '-Wunused-but-set-variable' warning:
> 
> mm/rmap.c: In function page_mkclean_one:
> mm/rmap.c:906:17: warning: variable cstart set but not used [-Wunused-but-set-variable]
> 
> It is not used since commit 0f10851ea475 ("mm/mmu_notifier:
> avoid double notification when it is useless")
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: zhengbin <zhengbin13@huawei.com>

There is already fix in the mm tree. See

http://lkml.kernel.org/r/20190724141453.38536-1-yuehaibing@huawei.com

-- 
 Kirill A. Shutemov

