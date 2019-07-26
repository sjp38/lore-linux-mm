Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22569C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 04:28:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFDA621951
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 04:28:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFDA621951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 708946B0003; Fri, 26 Jul 2019 00:28:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B81B6B0005; Fri, 26 Jul 2019 00:28:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5822B8E0002; Fri, 26 Jul 2019 00:28:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6756B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:28:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f3so33314638edx.10
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 21:28:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=HLudmlLWcjH1Sdmii0KLBfAF2iJqc6JtZYLk3NV48rE=;
        b=PJEkOLO/UhxFUYFhNivsNZU1eeE1LzDAJR4nVUPthqPjb5VMfwhnqfZL0MBu17qiFV
         1pwA/lTys1Hr7Go5cZebnnB3thNnhbZHOc1Yl+XedwOYPkgnHBZEzko/ybReMEXw9hW3
         TiLK8hjrVwDmFhHP+4UaiHNe+ykC2vVs4Ok/IXshTfTe4CWQU3FI+1/96TftCcBA6MJX
         EXkwMUbjPyc7+IdsJmFmezHwBNTNuNGwN4X4fjX79D7Sr5VN7Q/C0cIjGWOl6gAoJMfq
         AKwoYtP1rUXH9yXwI0alKZP/kEZO2pGECc9ljzR776lzjYJl9S6wRQpmzIvSUaNYeu1L
         ixlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU/fjGxgQwztBW3hxNBnNehyaeQLsH1rB5+laUhS/Q++PZ39cCx
	fpAP3LfbukoD7gGpmt89AyTb4nVeW6L1dRQARjYC1b/Y9jcNCK3hAbEPjSk3mY2ByTvUlCjl7hH
	gxzRA8wrDjGxlEaT+y/xUaJhGsd9ZfiPtfFX0lNfFd1U7RuEH0aBknFQV9X2Pn2bo+A==
X-Received: by 2002:a17:906:19cc:: with SMTP id h12mr3420181ejd.304.1564115305562;
        Thu, 25 Jul 2019 21:28:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8eA4PO9+EfxgC9LmuSqr/HLU+fDAlVz1aPOcq739xhJCKM0SulWu5kd2jRtBF/ycQfUFD
X-Received: by 2002:a17:906:19cc:: with SMTP id h12mr3420160ejd.304.1564115304865;
        Thu, 25 Jul 2019 21:28:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564115304; cv=none;
        d=google.com; s=arc-20160816;
        b=yVlXCrUiJ8KMg/zwlKP5bdHlxvz5kCvfCIkIiu4zZK2uVr3FaVdiEg8eRs67gCXNap
         +vdRZEFoUw3qXBAwu9fKaQJIl0erbEARHrAIlxUF8S7vRkpwj1M4pnJfsSJxY5YlVqyC
         VWuAfwTbf9fKu9++HVzHjIlW5QSP+u2mIBP7Zpu314DPnflk7qUz0bXx1YoE3/qnsNkk
         8fFK7xfLBpwNdZD5opkCK6vsdaRHA1mJIVBOx4nIc7skrEusCQFmVSIo5j5ZZ1ZqH9E8
         C7auY1O4qRAHDqVRd4dvFrblCjlC9ECeavJfqQymyeRGXZhEeRlUbLghgmI9Q81y0gEk
         JOow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=HLudmlLWcjH1Sdmii0KLBfAF2iJqc6JtZYLk3NV48rE=;
        b=pvsdc9lXqpFiDSEJgwTBcdBf2oMMk45uBpCzMJDzOtiFHMDqveC7coW89hNIEY7GgC
         0e7RjYh6+xIhXayfW20e4N/BMTl46B6UAAVh0bFRuwrY1BNnH1oIf3sDwzcBlHOU3lZe
         zpHPkYh+VWesKidDKQZhZ3mOUiA8ggFbOpKMIcAscPfF40IXDGpvO86n4IMTBvrAe4fD
         H732GNN/X64SqIU+RYQAkugHWpkpEmaacKHude5TumbkzV0RxXlLawCp6m384Pq3HLIw
         nXjO/XG4vUf2OopnwFiGjwOhhg0KWkUYFuPkS6t9UCWlO3usPhJOy04PUTuWXdrQ5yag
         hx9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x34si12562350edm.138.2019.07.25.21.28.24
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 21:28:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D942A337;
	Thu, 25 Jul 2019 21:28:23 -0700 (PDT)
Received: from [10.163.1.197] (unknown [10.163.1.197])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 387953F694;
	Thu, 25 Jul 2019 21:28:18 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>, x86@kernel.org,
 Kees Cook <keescook@chromium.org>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
 Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mark Brown <Mark.Brown@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
 Steven Price <Steven.Price@arm.com>, linux-arm-kernel@lists.infradead.org
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725170720.GB11545@arrakis.emea.arm.com>
Message-ID: <066e69dc-6ecc-6aba-0226-ba1d61ca0fa8@arm.com>
Date: Fri, 26 Jul 2019 09:58:56 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190725170720.GB11545@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 07/25/2019 10:37 PM, Catalin Marinas wrote:
> On Thu, Jul 25, 2019 at 12:25:23PM +0530, Anshuman Khandual wrote:
>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
>> +static void pud_clear_tests(void)
>> +{
>> +	pud_t pud;
>> +
>> +	pud_clear(&pud);
>> +	WARN_ON(!pud_none(pud));
>> +}
> 
> For the clear tests, I think you should initialise the local variable to
> something non-zero rather than rely on whatever was on the stack. In
> case it fails, you have a more deterministic behaviour.

Sure, it makes sense, will change.

