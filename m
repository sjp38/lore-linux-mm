Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88EB3C41517
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:11:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D9AD21E73
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:11:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WY6tCtRo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D9AD21E73
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA8AC6B0008; Wed,  7 Aug 2019 11:11:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C59726B000A; Wed,  7 Aug 2019 11:11:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B482F6B000C; Wed,  7 Aug 2019 11:11:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD566B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:11:05 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 65so52450401plf.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:11:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qNky4UNJfhbaacqAKPCp1Cl/iNKLfOo72Ypj0bndXBI=;
        b=n9dEmGGYG3nAFN/Qd4x+lcVgWCXo1V3L283/0kXmDZpI+q7wDk7KE6BRG5MY10NXyX
         yh4tfuBCNmMsTa551kyvIi/04uDuMT5VFADB+FpEI/+QV16R/YBCWTN4bxH4/5sg2P98
         wGYruZwjOnR4x4IX+ot33YOmo8zQDpcL98RdgePri4as0WEWD59wmdOLXfpYxGeFIqm6
         8okihT8rBxxrcTfpAOcOV0uZ7RTdUO+DCFyLBE8vKGQooa4podaltN+6790ie9xwUXbh
         UaUf0htFI/veyFj7c46y/WxnNouPhzgw5fx+tq+R9EfppAVeBCs/t7bVqPu8/CjOBQpK
         uoLw==
X-Gm-Message-State: APjAAAV7J9WJghQEoYXTuKGX7fhnBWMGuFhSLi2GSIqVBUlohVqaD49M
	qjWNWU0zDWgw+Ij9l3VK0uFWP0KdR+BliEwdKR4DeCnTZaZvFxI4sQLFXGIi7qkUGZK3od4qCOW
	Z4PdPsqnv44AbYBWxOrD88we3lQAlDzr4uGYivZXTDR7q/vb4zL504yVF1C2N+XTuQA==
X-Received: by 2002:a17:902:361:: with SMTP id 88mr8693242pld.123.1565190665179;
        Wed, 07 Aug 2019 08:11:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPkyTweE7MWY+4VbU1N44nSb5I27TuMYONUrofh7NAtUpyYtOhhTBsyTdS+dUDtS/x8nuv
X-Received: by 2002:a17:902:361:: with SMTP id 88mr8693192pld.123.1565190664527;
        Wed, 07 Aug 2019 08:11:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565190664; cv=none;
        d=google.com; s=arc-20160816;
        b=DyYje+WtnXuyMqpxH1GAHuxAuqvh/133f3wlDWnpZqsecINtYRoEYxOi5/ZN7A0zJu
         fs3MnIUTHFRgW84ykXHhBd0epmBoc3dE4geiKdBDmsN2xQA5Q9qU0nIMQPsh7V4V4J4l
         koE71E6b5p5SDcFj4kdw6dixhE7Zh3S/g9UIxHBT3SLGszzmtOGZR/vF643RUgGJUTy5
         +VC8fEOmNvjnaPxshK4OQj/ALi7fAI9psHBxyE4Kwo3Qhk6WwSaWOfoGnmFJwerlNf0E
         uNdv49jCU3C+NemWBjbNXtXvPlu/V4RZgVrhnQowjzVYxIh6eoB6cpI/J5wiMgPjxh01
         slBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=qNky4UNJfhbaacqAKPCp1Cl/iNKLfOo72Ypj0bndXBI=;
        b=Pwy/OjgwFMrJGkUYZiPqXwOhonnbuizwwaX33Cjd7SLYCwopq1wDl6ul6yOMrXIoMB
         VAFo9XsN8EghfjOa+75DKyYF7AWhjomGsRoCoYM66rPbQqevS3qe5t5af9RLAmCLsgtZ
         S0/35vZawEOXy9WByiKOiC4LA4PyjJPSRZOavfvAgDkhC2HP5aU6hdQmqz/ZipwteZ7j
         kSt9tV3Yg9cuXoqR62MiLVhHkieARDgzToqk0LhShq90HyLd7Vw39oncN/9pzv455MEX
         ycwy0WmRRZQgSngLIL2R6YIePYuJUgL+jr40dqZwdBYxrYvN9W1KJroiqnh6vHoXiV7y
         DVxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WY6tCtRo;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p3si44350559plo.185.2019.08.07.08.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 08:11:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WY6tCtRo;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=qNky4UNJfhbaacqAKPCp1Cl/iNKLfOo72Ypj0bndXBI=; b=WY6tCtRotzKTFTGqidAnSGXlR
	213xSXqebqIXDv0n3X6EupaDMeXze0yMpcbn6ON+Z2ieSbg6eAiELkkVrjVPeIEgbJyguwULVr6Ks
	qbkWwxLEuUIigtlIuNxZDfZsl+Sn9NJu8C1bYGcKfJknsrJ9f5tk6CC9srZAM62OuD0VSwrSqYfRh
	WnLi+sjttk850La810W1krlCZ8m7OYPXWFAud3XSRJDveTkYep5BXDDbTk06DA3yxC4clJZHlkxJz
	dRxo67TYYEjsls/wHXjBZWRTIsY21t1p6IIsmqIDwPmxtARnYw1F4cy+agJIz5UtcIToY0SB91q3n
	kByFPx/Qg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvNag-0004IV-RD; Wed, 07 Aug 2019 15:11:02 +0000
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
To: Stephen Rothwell <sfr@canb.auug.org.au>,
 Linux Next Mailing List <linux-next@vger.kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
 Song Liu <songliubraving@fb.com>
References: <20190807183606.372ca1a4@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
Date: Wed, 7 Aug 2019 08:11:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807183606.372ca1a4@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 1:36 AM, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20190806:
> 

on i386:

when CONFIG_SHMEM is not set/enabled:

../mm/khugepaged.c: In function ‘khugepaged_scan_mm_slot’:
../mm/khugepaged.c:1874:2: error: implicit declaration of function ‘khugepaged_collapse_pte_mapped_thps’; did you mean ‘collapse_pte_mapped_thp’? [-Werror=implicit-function-declaration]
  khugepaged_collapse_pte_mapped_thps(mm_slot);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


-- 
~Randy

