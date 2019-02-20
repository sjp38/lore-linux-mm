Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBAB2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:10:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 955CA2183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:10:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 955CA2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1672A8E001B; Wed, 20 Feb 2019 09:10:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EEEE8E0002; Wed, 20 Feb 2019 09:10:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F21A68E001B; Wed, 20 Feb 2019 09:10:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9523D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:10:52 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so9974352edd.11
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:10:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CiGghaBUIBt+eWRIFaZstE7zzkTaR0bhR77TOKp0CKM=;
        b=TvotQPzFmYsRaghZHApnPpuFD00HPuONXLwLLJuVw4ZkPTngFu7llTTRTdAgHKAtl8
         y1QLbrVDjqC9lRBx6YEBog3gqyaALjt/mz40ReraBe3UV2fQCIHbtAPn2BHYI+VAsBhk
         Z77sqq1O22mEtiqPnsbt5yJ9RUUUk/OV9DLQFQ6G2hoeT84cpndWIUdWwSnZiMacvUa+
         Kku19GASSjai1G2Pn0H/P11sAEvXiijQuvW7Fw4atjjnaFsozlk+B2eyoCW8gHqICbGw
         XwwXT59/59rvhO2NxwfVl7u1HKmdcZjwKSCwZQDoe5UNOEiN511ser/8iRK4XoMdZs35
         RuGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuaXH6ls9ycoTkyZyDP6PWFZZytvdkvFpPt38BniiRNyyxKRJo5Z
	JOTSdyoFbMGlVBXsVItVo9oXD/uvbem3s10f0L3CXEO3qp/oUi7Ljqt16GzjzCXd5hv3+qrTazP
	8WawNnsDrAKdesxAoEGMqoAnrHfLk0b0Aix8yGaawCF5qj8jM4ZeWI3Z6RtJbjF6Ccg==
X-Received: by 2002:a50:b2e1:: with SMTP id p88mr27030793edd.254.1550671852182;
        Wed, 20 Feb 2019 06:10:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbXcpR8uOmyOr2yrEKCjKNw76Zcih9wH1KolVleYr2cca6eJU2fozChxRXi2RwZ5rx6Fk+A
X-Received: by 2002:a50:b2e1:: with SMTP id p88mr27030763edd.254.1550671851426;
        Wed, 20 Feb 2019 06:10:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550671851; cv=none;
        d=google.com; s=arc-20160816;
        b=V30Zs/GPwBGWH+IrkuGcl+i5NhMrk5UCZObNLW62CLnoqdWIyjsUHweqhOY//vcyw/
         +6AqIvmpcVc++2GCDB9kvbhhhpjTMd0hplw92d8AQMjUNqdMa0HCblPwF8OnB5Ks6XWa
         5HNoS3QTeQUDfPlWJa7xyE9FvNis70rhCMQQkW2oY+ZpMFJI8NtSvOrjN81Yyv3uE1xl
         5joaE/iNEf6x56QTbvrBPYxEsEEImdsefW9/izO4dNFFO/6lb61kp7f8PO0UX7jAF5uR
         Q/MzpqrXpauaNDk+wV6n0ZfPFVeYBfmGZ5EUnZMW25UJJtPKPp9bXUG/QPh8PZRIjVr6
         A4cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=CiGghaBUIBt+eWRIFaZstE7zzkTaR0bhR77TOKp0CKM=;
        b=ZF6scW28bZ1dvntGTHPxYkh4U1NDQIXSWanq1BGlKMFUclcJ8D4MZz00yLahK0jUml
         VKlYc2ADZF9CAxM9ppyI6hSzl6CtHA56Sa36aQoivKt0gIh9usQZK3B42DGLr28NSC3K
         O3c9lctT/9phEoYjpLMAuwOBs2eu1eX2StjKPTBq3cManWGyFsYestTVeJUV5Ue+0Tpv
         QYwlOTjuqJNVzb5QjIBJabyi9ixeb75mnyBeNyXMArLw8FnIZnX/JriTQ4LcK7l2pQEV
         K/1LDdRnXkkSS5QlFsc3IJj0FQps5XBsFKLLBitY9mxT9RD9cODA9z02XqR5FuRxBRBA
         JPXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p21si3059455eda.281.2019.02.20.06.10.50
        for <linux-mm@kvack.org>;
        Wed, 20 Feb 2019 06:10:51 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 35BEAEBD;
	Wed, 20 Feb 2019 06:10:50 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5E0F83F690;
	Wed, 20 Feb 2019 06:10:47 -0800 (PST)
Subject: Re: [PATCH 06/13] mm: pagewalk: Add 'depth' parameter to pte_hole
To: William Kucharski <william.kucharski@oracle.com>
Cc: "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>, James Morse <james.morse@arm.com>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-7-steven.price@arm.com>
 <52690905-1755-46BD-940B-1EE4CEA5F795@oracle.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <76ce9f9b-eb0d-6ad5-9f57-ff3a8fa6b074@arm.com>
Date: Wed, 20 Feb 2019 14:10:45 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <52690905-1755-46BD-940B-1EE4CEA5F795@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20/02/2019 11:35, William Kucharski wrote:
> 
> 
>> On Feb 15, 2019, at 10:02 AM, Steven Price <Steven.Price@arm.com> wrote:
>>
>> The pte_hole() callback is called at multiple levels of the page tables.
>> Code dumping the kernel page tables needs to know what at what depth
>> the missing entry is. Add this is an extra parameter to pte_hole().
>> When the depth isn't know (e.g. processing a vma) then -1 is passed.
>>
>> Note that depth starts at 0 for a PGD so that PUD/PMD/PTE retain their
>> natural numbers as levels 2/3/4.
> 
> Nit: Could you add a comment noting this for anyone wondering how to
> calculate the level numbers in the future?

Good point! I'll expand the comment in the header file.

Thanks,

Steve

