Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D218C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D98D42083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:43:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D98D42083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C2738E0003; Thu, 28 Feb 2019 06:43:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7700F8E0001; Thu, 28 Feb 2019 06:43:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 639C78E0003; Thu, 28 Feb 2019 06:43:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09F408E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:43:37 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u12so8416861edo.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:43:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ikpFdwIkhgdzCfuYj1ACSBrGmyUU+sWaR/BAehbLF+0=;
        b=IjIeQNbmNXVt/miQMzt2fpHjEMBWcNQdwV4jHeKZJMosH7fLp427MA3oMklVgNZuDa
         k0deby8kd+ocl9tt8eZIvxGOwnJ1elX9gIb6eKXIQrAC/qJA1i0kkGIIUAC5uErtD8jp
         PVncSSNkUcZCrUn+9OUv5NhS1fiCdwz+kF42WCfoMNjrWWJjaYCESF6y+PYoZSGq/kSE
         Z5ElPConoAAfxY2QECUY1ENp3dgvjt3wzH6ziOuwh+mg0rJindX8i3+e42idh3TW3iF9
         Z8BiqHYDSaxLJp/v0+ykoOWkUkIXs6xezCq0enipC9yUgyhzSVR8Mory1gK9sW1cvt2a
         RaSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXRtEskvLz/7NGLW2+K3wUegLstF22A3lU2CKrVkFK/a2DU9ltW
	sf9Klw9cqawuHKUzRH0dKiJfWYUsaISMa8F1p8B7bkYVfme1JCzFZt/u5mRHGIaTLKhA5wo2beY
	XiBTrIw7bXlhQ9wId8FUVNQxJb4GnBQiBavYwyGjtbWZ7cggVkN0uiXKP92V+j9fYug==
X-Received: by 2002:a50:b36b:: with SMTP id r40mr1139613edd.12.1551354216587;
        Thu, 28 Feb 2019 03:43:36 -0800 (PST)
X-Google-Smtp-Source: APXvYqwX2KDC20fFi0uiuCFgUpd6gZxve7khLmRJxF7BvFRCC9THX2yGXeoPqGCLXtSb7lM6EzEB
X-Received: by 2002:a50:b36b:: with SMTP id r40mr1139568edd.12.1551354215728;
        Thu, 28 Feb 2019 03:43:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551354215; cv=none;
        d=google.com; s=arc-20160816;
        b=hXUucvtHfIpqNY1gR01OtzIcP3kkTNfVrWAsSlx29dp4h+c1lkVLxmHw1vrSi+G0HS
         wPNJ536eqg+88LnznjwdbLXT7y4b9Ju/qq2a2nRji95mWoxutvrjhfbEqaD4gPQ8eCxh
         mxn962pSpVASUlkIX05MTvMlvQsKwJh3506T5Q78yNLdkxUiCuTyzoIcp1MNoizAaUJK
         Kz5gUZoBC+DMoCLS8jO5ARI8PExOZ5MD69iCVU9osmxgK5o3WvAnBhwWI24mZ3EGbz5A
         IvC/c8oWI6X0u8+mplVllR0gZ11gw+Wi73HF0CQt9UJRBuUJ9IdMzZkGwvFIIwOZZfLo
         Cxdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ikpFdwIkhgdzCfuYj1ACSBrGmyUU+sWaR/BAehbLF+0=;
        b=09f4VF6s+WjvOnDcEJN2uRHt8cxvpS224KQTPQ65MhweiwkuLA6I//qsD7b4hCD6Tv
         NDrM9+BHTmvJZoqlfVlE2eAAc6C9Tf/Qcpcw+0XBXvi0KIgbgl2CIwt7Ono3RmAMZeY2
         cdxxUPHsEmIq0ytseIpg4cvn34S3q9eexN8XKSINq2DadKwmAAA/t95q+fUW0fuIfHAH
         oWuwb3duv+fWXuwG1nBjo7tetPAlb1Tqsy7d5SM5SrdXSGMo+kozhoFdlsjceS3wBa7Y
         xNH/NqsGM/gjMQYUXiAclLDIAJU+nAvz2hRAnptYrxXNQfod3UVEeDknwm4R3G8OZxLm
         AzvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e54si2626165eda.118.2019.02.28.03.43.35
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 03:43:35 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9746280D;
	Thu, 28 Feb 2019 03:43:34 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 30B8D3F738;
	Thu, 28 Feb 2019 03:43:31 -0800 (PST)
Subject: Re: [PATCH v3 18/34] s390: mm: Add p?d_large() definitions
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-s390@vger.kernel.org,
 x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-19-steven.price@arm.com>
 <20190227184012.2e251154@mschwideX1>
From: Steven Price <steven.price@arm.com>
Message-ID: <0ad6ff76-bbe8-122c-f0e1-54f567dc9753@arm.com>
Date: Thu, 28 Feb 2019 11:43:29 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190227184012.2e251154@mschwideX1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27/02/2019 17:40, Martin Schwidefsky wrote:
> On Wed, 27 Feb 2019 17:05:52 +0000
> Steven Price <steven.price@arm.com> wrote:
> 
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_large() functions/macros.
>>
>> For s390, we don't support large pages, so add a stub returning 0.
> 
> Well s390 does support 1MB and 2GB large pages, pmd_large() and pud_large()
> are non-empty. We do not support 4TB or 8PB large pages though, which
> makes the patch itself correct. Just the wording is slightly off.

Sorry, you're absolutely right - I'll update the commit message for the
next posting.

Thanks,

Steve

>> CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> CC: Heiko Carstens <heiko.carstens@de.ibm.com>
>> CC: linux-s390@vger.kernel.org
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  arch/s390/include/asm/pgtable.h | 10 ++++++++++
>>  1 file changed, 10 insertions(+)
>>
>> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
>> index 063732414dfb..9617f1fb69b4 100644
>> --- a/arch/s390/include/asm/pgtable.h
>> +++ b/arch/s390/include/asm/pgtable.h
>> @@ -605,6 +605,11 @@ static inline int pgd_present(pgd_t pgd)
>>  	return (pgd_val(pgd) & _REGION_ENTRY_ORIGIN) != 0UL;
>>  }
>>
>> +static inline int pgd_large(pgd_t pgd)
>> +{
>> +	return 0;
>> +}
>> +
>>  static inline int pgd_none(pgd_t pgd)
>>  {
>>  	if (pgd_folded(pgd))
>> @@ -645,6 +650,11 @@ static inline int p4d_present(p4d_t p4d)
>>  	return (p4d_val(p4d) & _REGION_ENTRY_ORIGIN) != 0UL;
>>  }
>>
>> +static inline int p4d_large(p4d_t p4d)
>> +{
>> +	return 0;
>> +}
>> +
>>  static inline int p4d_none(p4d_t p4d)
>>  {
>>  	if (p4d_folded(p4d))
> 
> 

