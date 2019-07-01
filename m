Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FD0FC06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:03:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 711CD20881
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 711CD20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0983A6B0006; Mon,  1 Jul 2019 06:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 047DF8E0003; Mon,  1 Jul 2019 06:03:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E53CF8E0002; Mon,  1 Jul 2019 06:03:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF076B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:03:57 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id k15so16486689eda.6
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:03:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=K0mgmTcmYXP8qDylUGCEGeIJ5ZlkkY6bcSPbLKy0oAQ=;
        b=tgDoVVRnu6+3OnnPa8FcqA5gIPeDVNmdUmQFuywl3NC+JKkDu6KudvE4WCBs3ZkCPc
         WYIVYxw9NSWw1U8VKCxVARutRDiFm/DtDqLMO8nW+DuMrypvDS7qNekKYOTuqAlwnZvd
         cgG22WZdmSKfxrVAlL/07gQl+TsYslkjNu6SyJapIO3CW7Bsu8Dohs7TwnciLMc9aS6e
         gAoefhg4c7o4IR+ksmrJV1R2CQik0p59BIdhTgWfQzL7DNc5oWhsewl/jhgzaUlPoOBH
         fSlKQF+1IMyxu2muaZUoPN8ohIwv+8jhfS8Z9fDD7NwhlXMvbk2jsjczKTexzjVfyYsQ
         fDNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWhhu/97nvzJIUF4ReFDx5mRUDcxoGVhgtNxhHcLDI7KVLHNMfw
	cgxrhLiG86P27pbTXz6vvVJ+1BzovbB96pqDfTV/YgLdxexZ09bUx1dnrY6GMc0WG5/Ax2SPw3W
	o9AMrCZ1ZbBlgZJUtOcz6tPQjq1XHK+MJE9xhGkjZPhFnq2HiWIGm2N8vueP0g+I8pA==
X-Received: by 2002:a05:6402:1801:: with SMTP id g1mr27619780edy.262.1561975437212;
        Mon, 01 Jul 2019 03:03:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyL2mwN5mhWaA8cZT4vOstMj39mYprkvc7uzA5G2M3eiw0BSKh2xLYf14Ynr7X3ezpRncyL
X-Received: by 2002:a05:6402:1801:: with SMTP id g1mr27619703edy.262.1561975436516;
        Mon, 01 Jul 2019 03:03:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561975436; cv=none;
        d=google.com; s=arc-20160816;
        b=b2UXngytmLoKmlXkGxxbnZAgb1if4YQfN+mU/zWbZFfPSMNkBNI7ezgRoPaa5cT/Z2
         4RNrML6cZbHu+kxy/Mb9ClBOdx4+dkxmOIpC1JuaV2Bdyu73Zql0Kot9M8xHwT/7/2e2
         5HSE3E+BqulHnFscMg/v8O0VPeSG/zG4X3tZy0oODdo0+3fnBMJBHFzkvTQHHZdagpsW
         tbvt/MbUgfN2eNo2mTjsePY6+MfWblhKWFjAQq6WcSFhEi3jTJp9gncj9ldmkuHMUW5j
         ulXAoYP4nMQjM/yRwROhL3cENQ2aK3234xM1SBk+2bRN36Fqn0mkghEk3d/S1MBRzKc4
         4Gyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=K0mgmTcmYXP8qDylUGCEGeIJ5ZlkkY6bcSPbLKy0oAQ=;
        b=WEJLoZcJyhBu20HyOcr4msYYRu+FYbELYQ6zzrFB3+uD2cmRjZjJv1WvC2vJcOUlix
         vSKB6WiKcngjQ8Tja3QnipL+8JNaOafaAkkeRT8gaDvzgQFeHxEkYavJzD6eG8bmJLfX
         LQTMeIbZwFGJX/53Me1Uf9jtRJKAuy+AdJdRAiZEbrzmgYa8YCVt6jcoPvH01SmrWTsW
         /nkp3y3wv86MLzaPO6s0POmo91yUMe214WUf/DWqTz0XAHGrT1hgXi+qgSOSM5EI+fh1
         7XHQ1tur4TiRxeu3RqQub6KGV2UVwFzT2Mu9HDvmCfLxWvkIhR03XjR6aZSSB4BYXRTD
         M1Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k15si4504228edd.268.2019.07.01.03.03.56
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 03:03:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8F1772B;
	Mon,  1 Jul 2019 03:03:55 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0B4143F718;
	Mon,  1 Jul 2019 03:03:52 -0700 (PDT)
Subject: Re: Re: [PATCH 1/3] arm64: mm: Add p?d_large() definitions
To: Will Deacon <will@kernel.org>, Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org, Christophe Leroy <christophe.leroy@c-s.fr>,
 Mark Rutland <mark.rutland@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon
 <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
References: <20190623094446.28722-1-npiggin@gmail.com>
 <20190623094446.28722-2-npiggin@gmail.com>
 <20190701092756.s4u5rdjr7gazvu66@willie-the-truck>
From: Steven Price <steven.price@arm.com>
Message-ID: <3d002af8-d8cd-f750-132e-12109e1e3039@arm.com>
Date: Mon, 1 Jul 2019 11:03:51 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701092756.s4u5rdjr7gazvu66@willie-the-truck>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/07/2019 10:27, Will Deacon wrote:
> Hi Nick,
> 
> On Sun, Jun 23, 2019 at 07:44:44PM +1000, Nicholas Piggin wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information will be provided by the
>> p?d_large() functions/macros.
> 
> I can't remember whether or not I asked this before, but why not call
> this macro p?d_leaf() if that's what it's identifying? "Large" and "huge"
> are usually synonymous, so I find this naming needlessly confusing based
> on this patch in isolation.

Hi Will,

You replied to my posting of this patch before[1], to which you said:

> I've have thought p?d_leaf() might match better with your description
> above, but I'm not going to quibble on naming.

Have you changed your mind about quibbling? ;)

Steve

[1]
https://lore.kernel.org/lkml/20190611153650.GB4324@fuggles.cambridge.arm.com/

