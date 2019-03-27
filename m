Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EA5AC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:45:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 194D12082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:45:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 194D12082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A81226B0007; Wed, 27 Mar 2019 04:45:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A32506B0008; Wed, 27 Mar 2019 04:45:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 921976B000A; Wed, 27 Mar 2019 04:45:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0D16B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:45:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so6373071edh.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 01:45:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=aZ4XjenjOWwY5Allx5WgjsAlXn+yjTfQ/prclQMlcVQ=;
        b=sZBGH4OS+i+kzSrlIYchAL3M9+nGFQy0n8UzCP8S7daFE/pfD1LCGiGfHS3h7SQZWb
         xoO5LUjL4v6KmxGIcUjnFWBZ/6Kjfbn3tIunsrvoX7g5uMo2/j7NoRdpF12+g7D/g1WG
         dEsza/epvIgLCmMmv398gvKxqJ/2+jS3dBQwT++ks5Ew91qgVNq7OqKUED0Mt74qx5mr
         VPMlOdO2QsivF16XuznOQE1uMIKE0p7WEWMKiSxH59p4cmDkNaxuabA6W3qkzvEHcQBU
         /+udAPyeIafXkU4wZn8Lui9Onk59BMoSh/cr+8K5sLrWLtuJy+GXAvPRf9VorifV6fh+
         EnDQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVYauHu6DUcIm78K+O29E+0ClnVOn/o47csI9YA1frDO0ONimBU
	+gnvK8fvO1Xh11mo8+tfEJsvva+VUT06KINp5epn/udK6KiMOtZ39AaYw8xG5gwNVt0pENdeHrX
	nouwbYUEa8fesdZngRMGlHicEZQP97Satpvw0GZ5TXTZ3v/qE5Yd21mBDUB3wyEM=
X-Received: by 2002:a17:906:c7c2:: with SMTP id dc2mr18782596ejb.182.1553676323789;
        Wed, 27 Mar 2019 01:45:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7MflTDr/U6WpAy8bXJ6/Gv5Y4TuF0RhKT5SWlgO/j1nV6DXrC4LE4iVRmkwvTdvhBMNww
X-Received: by 2002:a17:906:c7c2:: with SMTP id dc2mr18782557ejb.182.1553676322829;
        Wed, 27 Mar 2019 01:45:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553676322; cv=none;
        d=google.com; s=arc-20160816;
        b=BcY2wyRLLk0Cnc3EqMgM/9fVWcWCOp50sTFEQANRhJGd4Qn5edocjqbnIsRHHeeOOx
         ykNsBUoJVRl8ToqEqsKiuNRme3cEoJRpt/yngRe0qFn3cHv7rb0yWKWCEEDUBO5b0B9Y
         hNfN2s8gqgfWH+33EQMO8jw+IV9EwsKS0+hgHgiIq2Q7E3dCippK8GMIilZ9DWKM+Jy3
         WYZDXurIjlwGK2rVzQP1CfULMY6O/qvI+Qc/ouM+oxUm3q5gTwpBh6vHqJhKaoK/YvWH
         Ej5guqgeewbT/2FS+ZtwJt6V/5CdG649FH6AWlUIYJG4SVcpmYIVb1Ud5+wEzsHwV7MO
         nYVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=aZ4XjenjOWwY5Allx5WgjsAlXn+yjTfQ/prclQMlcVQ=;
        b=C5bG4OKUvU4xGnVA2kVH+wSKe3kscKmxsUHKHUKFT7AzAR280wJ6fX8BjMAZq00qGI
         9Y7OjVvby0A5CojUiMUlp26qKK79CbJBsuscavrVhQM3m9rKpxv32ilTB0XstmlydJgY
         7Y6MvEEwpDfTEYx9Ua2IpZK3tMNLnTOXIIG7Zk1P1mUBcxLX4it3/xv2xkeF2feXa9MG
         9xtCGzqY9AHyR7KjjeHdR8E8kG3KdAW+7mFpEhlwukiEYqMrfC+POz0mJea6yTWZdeJz
         r/A8guWIo1EPIMHHHeOoLjzlCE7p06iV6vhNCHNd4e3WM8pQq5LBLwK1aw/z+tCbtK7s
         D1pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id n1si1669585eja.176.2019.03.27.01.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 01:45:22 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 8DB451C0004;
	Wed, 27 Mar 2019 08:45:15 +0000 (UTC)
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, mpe@ellerman.id.au,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190327063626.18421-1-alex@ghiti.fr>
 <20190327063626.18421-5-alex@ghiti.fr>
 <f6e74ad8-acca-3b1e-27eb-a2881ac8437d@linux.ibm.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <fbae7220-2e6f-8516-cf93-fbe430452043@ghiti.fr>
Date: Wed, 27 Mar 2019 09:44:56 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <f6e74ad8-acca-3b1e-27eb-a2881ac8437d@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/27/2019 08:01 AM, Aneesh Kumar K.V wrote:
> On 3/27/19 12:06 PM, Alexandre Ghiti wrote:
>> On systems without CONTIG_ALLOC activated but that support gigantic 
>> pages,
>> boottime reserved gigantic pages can not be freed at all. This patch
>> simply enables the possibility to hand back those pages to memory
>> allocator.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
>>
>> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h 
>> b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>> index ec2a55a553c7..7013284f0f1b 100644
>> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
>> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>> @@ -36,8 +36,8 @@ static inline int hstate_get_psize(struct hstate 
>> *hstate)
>>       }
>>   }
>>   -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>> -static inline bool gigantic_page_supported(void)
>> +#define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>> +static inline bool gigantic_page_runtime_supported(void)
>>   {
>>       /*
>>        * We used gigantic page reservation with hypervisor assist in 
>> some case.
>> @@ -49,7 +49,6 @@ static inline bool gigantic_page_supported(void)
>>         return true;
>>   }
>> -#endif
>>     /* hugepd entry valid bit */
>>   #define HUGEPD_VAL_BITS        (0x8000000000000000UL)
>
> Is that correct when CONTIG_ALLOC is not enabled? I guess we want
>
> gigantic_page_runtime_supported to return false when CONTIG_ALLOC is 
> not enabled on all architectures and on POWER when it is enabled we 
> want it to be conditional as it is now.
>
> -aneesh
>

CONFIG_ARCH_HAS_GIGANTIC_PAGE is set by default when an architecture 
supports gigantic
pages: on its own, it allows to allocate boottime gigantic pages AND to 
free them at runtime
(this is the goal of this series), but not to allocate runtime gigantic 
pages.
If CONTIG_ALLOC is set, it allows in addition to allocate runtime 
gigantic pages.

I re-introduced the runtime checks because we can't know at compile time 
if powerpc can
or not support gigantic pages.

So for all architectures, gigantic_page_runtime_supported only depends on
CONFIG_ARCH_HAS_GIGANTIC_PAGE enabled or not. The possibility to 
allocate runtime
gigantic pages is dealt with after those runtime checks.

By the way, I forgot to ask you why you think that if an arch cannot 
allocate runtime gigantic
pages, it should not be able to free boottime gigantic pages ?

