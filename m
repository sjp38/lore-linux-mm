Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 615BEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BBF82087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:21:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BBF82087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE4FB6B0003; Wed, 27 Mar 2019 07:21:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B95166B0006; Wed, 27 Mar 2019 07:21:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A86A96B0007; Wed, 27 Mar 2019 07:21:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5749F6B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 07:21:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h27so6521390eda.8
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:21:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=M9JOBseDHYG3yQbCojyig8s1Tq1vXhZwTRXS/P2ca1Q=;
        b=kChPTnja6T6+3sj07TliHhhhIhueIR2LkG0y+v5VMuj90jdFfuwIB+rquTGyaW9KAK
         uGseGRAUew2muXDJbDqjihY7FOa8Ii4w9xkuA3LVZwMjCmhsAtVfgyrtOFuK8ZJZ7DRk
         yF3jWNYv7dIctYY3pAl0O2V68M9ca8Was32czgpInoihojmT12/Mh09jDQ/GSoJNbU7D
         4GFK+t2+C5uDbGSznhp9m2SwJCfK2gYmD+8Y+IP+9WM1UuK3Ok1VmxHYXO/lJnVR4wFE
         XAP8Ujz9rfKQdrs7epVGqdt0QP6dRaX+oDvtpRn9qlXTd1u1+MSH/QhseUmp+LLdT1VU
         haLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWbJwCQ/KUMhd60fmkbjpW8mDdeUEJE3luLZoNGNqgwRlKhChXr
	xtd5LwhCFL6aAbzfvOj8TZuvtaiosmimSOSuC4LqNaAXTlAr1CC41DZ5883X19PLlOl/+MVs3OL
	SsIrqYb8m1lSBwnqwGfijeyynCq6BPiZoNWyYpGHDQDCOx78+dcsN37Yi4w1v3jdFOA==
X-Received: by 2002:a50:8ba6:: with SMTP id m35mr24362235edm.33.1553685693921;
        Wed, 27 Mar 2019 04:21:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHWTQ6Qwfv8Ae9cu6wMLx7oZrpjwwaluBzjKCdXzSW9FLebdYOmpeqvJEIAqPmJE4/wOvb
X-Received: by 2002:a50:8ba6:: with SMTP id m35mr24362185edm.33.1553685693064;
        Wed, 27 Mar 2019 04:21:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553685693; cv=none;
        d=google.com; s=arc-20160816;
        b=j0r5+WGSjupZgeAPzfH3rmYVHYDZ7sxVtAsHm01KHac0nJQVoYnTq/y7sICCKVt1ID
         7VfUWFNiH+wHJcROooMsHxzANQdHp3xck9w/3Z9ahLxQhkeA8ZTd/ACCyIN4BShNJrqJ
         Xvwbu6uooGGtZAfzXbwGOf1IH/Dd9iDkp5AT4uInuT0jmcF52aUIPqqRrnqUrfz6/Cra
         6bqGDZp/I+V7q15ki2ytCLvIgCO4k/W1bCg4ipfKLsBz9g2YLIn97AqedXyDA5wIt+o5
         yUdVEbtn2aRlei4zR+yc3ZfzwCDCMdzyniTNxaRsqjzI8ptB7BYI9tR3Z7u9h62OXXm6
         UvfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=M9JOBseDHYG3yQbCojyig8s1Tq1vXhZwTRXS/P2ca1Q=;
        b=BU7LNUego7z5Gl9FsrBcXfm5gYBjnPCGrTV4fAbEqKTDuYQWudq+dnRQiJIiavu4sN
         p5M27H1YO1M7MDZN2gb8O80vp8kTbwTDaXeko5pIQUAOfDd/FpbHsyOcKTW0Zs4eXteH
         8BPI5+iZ9R3sfSRico8m6VRoIHPKHErtGo6ooMYzO+cH/ooboPL8B7W75hzqh0/jOK/I
         suqPSwdK4p2ZrNK60sb9vsIYjOQsJnDJFkMMFPuU7oYoBwszrBGqjYzrWx1EbUni1iDz
         T7ertxlFqnxrHbxmAlX9+vwbIz0LsuixD/iGyloh+81G4EqpfzNzbfU4uKRn8Y3JKT/P
         9CaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a6si422138edt.219.2019.03.27.04.21.32
        for <linux-mm@kvack.org>;
        Wed, 27 Mar 2019 04:21:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F305BA78;
	Wed, 27 Mar 2019 04:21:31 -0700 (PDT)
Received: from [10.162.40.146] (p8cg001049571a15.blr.arm.com [10.162.40.146])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A8BD93F557;
	Wed, 27 Mar 2019 04:21:29 -0700 (PDT)
Subject: Re: early_memtest() patterns
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>,
 Dave Hansen <dave.hansen@intel.com>,
 Vladimir Murzin <vladimir.murzin@arm.com>, Tony Luck <tony.luck@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <7da922fb-5254-0d3c-ce2b-13248e37db83@arm.com>
 <20190326135420.GA23024@rapoport-lnx>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <2f272c22-8453-7637-f744-632e70404e61@arm.com>
Date: Wed, 27 Mar 2019 16:51:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190326135420.GA23024@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/26/2019 07:24 PM, Mike Rapoport wrote:
> On Tue, Mar 26, 2019 at 01:39:14PM +0530, Anshuman Khandual wrote:
>> Hello,
>>
>> early_memtest() is being executed on many platforms even though they dont enable
>> CONFIG_MEMTEST by default. Just being curious how the following set of patterns
>> got decided. Are they just random 64 bit patterns ? Or there is some particular
>> significance to them in detecting bad memory.
>>
>> static u64 patterns[] __initdata = {
>>         /* The first entry has to be 0 to leave memtest with zeroed memory */
>>         0,
>>         0xffffffffffffffffULL,
>>         0x5555555555555555ULL,
>>         0xaaaaaaaaaaaaaaaaULL,
>>         0x1111111111111111ULL,
>>         0x2222222222222222ULL,
>>         0x4444444444444444ULL,
>>         0x8888888888888888ULL,
>>         0x3333333333333333ULL,
>>         0x6666666666666666ULL,
>>         0x9999999999999999ULL,
>>         0xccccccccccccccccULL,
>>         0x7777777777777777ULL,
>>         0xbbbbbbbbbbbbbbbbULL,
>>         0xddddddddddddddddULL,
>>         0xeeeeeeeeeeeeeeeeULL,
>>         0x7a6c7258554e494cULL, /* yeah ;-) */
>> };
>>
>> BTW what about the last one here.
> It's 'LINUXrlz' ;-)

Yeah eventually figured that. Though first 16 patterns switch on/off individual
bits on a given byte, there does not seem to be any order or pattern to it.
Never mind, was just curious.

