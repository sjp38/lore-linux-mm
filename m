Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A527C4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:16:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFB73218CA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:16:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFB73218CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 775CB6B0003; Fri,  5 Jul 2019 07:16:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FEDB8E0003; Fri,  5 Jul 2019 07:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C6868E0001; Fri,  5 Jul 2019 07:16:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3DF6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 07:16:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so1345692edr.8
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 04:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hcCysOb0fV5PB4onrn+Z2hf+HkNCar9Z741PWfWLs1c=;
        b=VgtctVQmieIhTSXp6HlkKBdjJyj+1hLmxskJip1AGxG/QlvnP3xTnpNz/16Jrguqmk
         2c3tKnHxU7IsLdRbA9s6t2cTPLoVdV40/bGdTShG1JDg9LkqZAsFDvBnsUUpmO71JeB+
         vIc6mU2eyQcCaQZvwfTBUZTkokoYKcobgGn2Jzon1vZZILC+5NodKpr3xFaTO8xW965D
         SLomIjrshqRLUoD2DpC1gIp8wI8ZI05tZ/C472rd9VR/EECyg+THVx4Tvd9Yft8/OO0a
         CA908myPBUlLyzI3o24VsaDmSPmI3pF5radglQTuZLDPxQWKHndd2aDXhCULnqW7in5Q
         aC/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAVcOJjtGZ0P9Wg0iEGHPqzNdqREpOTac9MF6Jo9FerxjTMN47Sn
	GaBgGbuySU/PulSJnTpFSk3ne1LYt/2scCuf8H38JZVN12CBEUfvGJ8RUZ0w7xErGwmPlKOiTPU
	psQ3s1R5Q+gO027Kb3I2H9fHuU8yXdg+MuDf/KHGwBLp5b/QSkarzWewa4j4cJU2k1g==
X-Received: by 2002:a17:906:edcb:: with SMTP id sb11mr2975685ejb.260.1562325377626;
        Fri, 05 Jul 2019 04:16:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3TW79phOf+3BVIyRIyeAm+XVdVnwVWy2tDi89UAoyXOrRwR21mYTxd51fW2l+n8Sbi9Jn
X-Received: by 2002:a17:906:edcb:: with SMTP id sb11mr2975617ejb.260.1562325376869;
        Fri, 05 Jul 2019 04:16:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562325376; cv=none;
        d=google.com; s=arc-20160816;
        b=Y2KtowNbvXkPi8gQ1be0aczvdi00WmjXFw5tre20kCGpvwCFX+sokw2cHxQmC7dD0N
         tVFd1UgTI97mDQNPpqkMhrwnULFx1RlWw3qDMEQQbAPjx5JRoH0ritLvNGQ6iuu5jimX
         UjD2lSi0xRrK2nFnpfhDF6Nagiat9vAIyCv75XQ4g2wb9BkIZvCnjzT4p68c8uB5roYf
         0Mq70TxWtpJQgpjqhZfi89/ICMv6IuNuPN2ynTLGu4J8t6jKe/Z5U/ZXzZoXaw1hYjDy
         fMDjBkxyYDwYL1wpcIQ0g+oNJOppycjGM2HAFEd/WCbQmNIktuEH6QYqEptR+7mHL9Y/
         B6xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=hcCysOb0fV5PB4onrn+Z2hf+HkNCar9Z741PWfWLs1c=;
        b=CSE4ITjZYBx6qRyjmNr53P+LCxxeSyZsZUHLgv7Apa/zAQVC+KpY5LCWmt8/0qB3nh
         Zj835nUPFKkIyI7WGKtJh/mqTW8reoECvtzex24cniLhRUvvZ/W8hFGfooCaDaInKUKb
         dU1O4PwisDEofXCVFHmFDKg6Xw371DBm0JLPEYoMU7uxI/gJj5Fsh+i0icxqw4isz/2n
         vOa2bT2l9tyqVYsA65DElmuaRWS6zY22PqXnOZ8U/djuIxZmkX6jMgkAfHSS6dW55jqC
         tXaDknQWozT6zYMFkHxWhn7pPXsNUW67Ys1tlubz4/P1myDVu9q/K0Ah67XfVVfrWwAj
         4Tig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w1si6750743edc.440.2019.07.05.04.16.16
        for <linux-mm@kvack.org>;
        Fri, 05 Jul 2019 04:16:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 070222B;
	Fri,  5 Jul 2019 04:16:16 -0700 (PDT)
Received: from [10.1.197.57] (e110467-lin.cambridge.arm.com [10.1.197.57])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8A6613F703;
	Fri,  5 Jul 2019 04:16:14 -0700 (PDT)
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig
 <hch@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <20190626073533.GA24199@infradead.org>
 <20190626123139.GB20635@lakrids.cambridge.arm.com>
 <20190626153829.GA22138@infradead.org> <20190626154532.GA3088@mellanox.com>
 <20190626203551.4612e12be27be3458801703b@linux-foundation.org>
 <20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
 <20190704195934.GA23542@mellanox.com>
 <de2286d9-6f5c-a79c-dcee-de4225aca58a@arm.com>
 <20190704141358.495791a385f7dd762cb749c2@linux-foundation.org>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <63abcc24-2b2d-b148-36bf-01dd730948c6@arm.com>
Date: Fri, 5 Jul 2019 12:16:13 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190704141358.495791a385f7dd762cb749c2@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/07/2019 22:13, Andrew Morton wrote:
> On Thu, 4 Jul 2019 21:54:36 +0100 Robin Murphy <robin.murphy@arm.com> wrote:
> 
>>>> mm-clean-up-is_device__page-definitions.patch
>>>> mm-introduce-arch_has_pte_devmap.patch
>>>> arm64-mm-implement-pte_devmap-support.patch
>>>> arm64-mm-implement-pte_devmap-support-fix.patch
>>>
>>> This one we discussed, and I thought we agreed would go to your 'stage
>>> after linux-next' flow (see above). I think the conflict was minor
>>> here.
>>
>> I can rebase and resend tomorrow if there's an agreement on what exactly
>> to base it on - I'd really like to get this ticked off for 5.3 if at all
>> possible.
> 
> I took another look.  Yes, it looks like the repairs were simple.
> 
> Let me now try to compile all this...

Thanks, the revised patches look OK to me, and I've confirmed that 
today's -next builds and boots for arm64.

Cheers,
Robin.

