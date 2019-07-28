Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2A3DC433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 11:44:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0E932075B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 11:44:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0E932075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B70C8E0005; Sun, 28 Jul 2019 07:44:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 366688E0002; Sun, 28 Jul 2019 07:44:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22EB28E0005; Sun, 28 Jul 2019 07:44:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C562B8E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 07:44:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so36617811edu.11
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 04:44:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qf44Lm6Ndt0XoGZ1L+ZSAACYvmYohYh9reXk0byi8+A=;
        b=D0WCAkTBs1O7PaPvtHIcEWFCHhEwXcg04w3PaXDxEVuTDuhRu/Y2yj5wKy5nn8NIoX
         YksrIp60kgeSQRmgEYxNlqT1XzCvCZAscgEnhr1nWmo8JVZzm1JTIeJVm4w7RGP/ZrxV
         D5dRAIjktruhJH/WUr+ZLSyNgF9UMdZx1+mh3AI3EhD4iI2e++76IVPZXWgusxkYUCwz
         NFw+nIGp/a0xmHQBScdW5RENUkz9BcYkifqKLuW+E4cY2YQxJd4vtg8AkjNYlsu8sjLC
         jSt6XLpIlhKd3c9tMWU1D3umyyC8jEOd8+tjXtodX9i1p/JeNnxgN2TMLHQcNRIicYiP
         9oNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU2rFjDCLk0cWX5bBPzcYIIdEvXre8UDiUzfNr4P/OMZAuKc3jh
	2wHMTwc66OYAoxWfvKW14L+65yyTzqFy+G2V+kdNtrdRk5hfh6quN4E47FDc/EMBO0GzM9ty2tL
	vZFpHEhqejfSp+qsztea8WJE99vv4UQR5vxbyxEBK9tG7pIrs941vsR+m/Me4eRVIlA==
X-Received: by 2002:a17:906:1303:: with SMTP id w3mr67325240ejb.143.1564314240361;
        Sun, 28 Jul 2019 04:44:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6PDuUEKSFbysxLDx8oT2n8h2BQpWVBUaWxtjW5sZJHY0n0mWu2XNv0CeftNwm4YEpdLGI
X-Received: by 2002:a17:906:1303:: with SMTP id w3mr67325203ejb.143.1564314239448;
        Sun, 28 Jul 2019 04:43:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564314239; cv=none;
        d=google.com; s=arc-20160816;
        b=1D2obzd8e6cqrsT8LG3U1SUrtJyKpDaHZo+7yyeRb7ZJOTQb2mX0Yqf2A3N+/9/SoR
         7LWLQl6se/l9glRkHWyZGV83qz1vWEonlp6Vrw1ptFrWSdAAg9mreI0FEaxWyojYEryW
         MuSE7Ak0gkIQ2WWlDvR4g93bMxQk1dbXG59owloPJMLbBJX/RkvqzBAK97lEm7NyowWs
         MMW93lke+5cx/30m3WDGM8L+umCKGrPGJJRkR8BjGaOKdhlG+ith+/GJCQv8m3zN5MDi
         fCP7UqmeAlj0gv0x9aqNq13cJoJAR+KH9ewQUVN55FEWuDuAINaXP183Qkd+KKiQe4TY
         x71Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qf44Lm6Ndt0XoGZ1L+ZSAACYvmYohYh9reXk0byi8+A=;
        b=zGrpB0H/oiOctxWIgdiAQEhoyltmEVm745UuMSlfxfxoeacUGfY9DzQEyOM4/qokb2
         soYXzlaLbfB7Y3MaLsqIllbYE4cQ61VUS1sQJUeKsK06Mg4t8wJMFN5/mPY53Ogq4B2K
         j2zReBiw5bdrPWCl+Gj1N3UEt3RgOGoea3mjxtbWSszwykl7RsBx30F3vQkhzcPmUxnZ
         dhpksjcchhkQE486vFTsaIZwImtjOL5ZIzHvqOv3QqVYiXxQXxJQ3Wtuuht02ULj7uVK
         Tx/X1vC3gCkRx1cb2eehNGs3nW1J3wEDZQtb9b/1L9Bn19mAoaTp3hN4QshBm56vr2m5
         v/hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w17si13649864ejv.23.2019.07.28.04.43.58
        for <linux-mm@kvack.org>;
        Sun, 28 Jul 2019 04:43:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A702F337;
	Sun, 28 Jul 2019 04:43:57 -0700 (PDT)
Received: from [10.163.1.126] (unknown [10.163.1.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F39DE3F71F;
	Sun, 28 Jul 2019 04:43:50 -0700 (PDT)
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
To: Mark Rutland <mark.rutland@arm.com>, Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 "Liang, Kan" <kan.liang@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-11-steven.price@arm.com>
 <20190723094113.GA8085@lakrids.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ce4e21f2-020f-6677-d79c-5432e3061d6e@arm.com>
Date: Sun, 28 Jul 2019 17:14:31 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190723094113.GA8085@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/23/2019 03:11 PM, Mark Rutland wrote:
> On Mon, Jul 22, 2019 at 04:41:59PM +0100, Steven Price wrote:
>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>> we may come across the exotic large mappings that come with large areas
>> of contiguous memory (such as the kernel's linear map).
>>
>> For architectures that don't provide all p?d_leaf() macros, provide
>> generic do nothing default that are suitable where there cannot be leaf
>> pages that that level.
>>
>> Signed-off-by: Steven Price <steven.price@arm.com>
> 
> Not a big deal, but it would probably make sense for this to be patch 1
> in the series, given it defines the semantic of p?d_leaf(), and they're
> not used until we provide all the architectural implemetnations anyway.

Agreed.

> 
> It might also be worth pointing out the reasons for this naming, e.g.
> p?d_large() aren't currently generic, and this name minimizes potential
> confusion between p?d_{large,huge}().

Agreed. But these fallback also need to first check non-availability of large
pages. I am not sure whether CONFIG_HUGETLB_PAGE config being clear indicates
that conclusively or not. Being a page table leaf entry has a broader meaning
than a large page but that is really not the case today. All leaf entries here
are large page entries from MMU perspective. This dependency can definitely be
removed when there are other types of leaf entries but for now IMHO it feels
bit problematic not to directly associate leaf entries with large pages in
config restriction while doing exactly the same.

