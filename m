Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A60CC31E49
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 01:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07E712089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 01:31:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07E712089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 525A38E0003; Sun, 16 Jun 2019 21:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D5AB8E0001; Sun, 16 Jun 2019 21:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A0658E0003; Sun, 16 Jun 2019 21:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E16C68E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:31:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so14035841eda.6
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 18:31:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Q+TPkG7VuBBLLNsNn7AA/WEqzduHLE1RPY5aPgZf1ZA=;
        b=LChV08TdStPzY/WHr/wcFiwxQoGYTpd4kUf53Y4r48toVOzkPAgJ0L5kSAcABZkgBX
         XxIprNAONem2UGnBWO48Su8/0SFLLFf5vQdvP875iuXWcv8PtMBacyt1lXvQqhY+N+LI
         9WYxQAlx79TKoirUcfyF29gLUrFju8XaBq5sizM7toFfrbCxbumUEYeIoNNck2q7Y1pJ
         SxJLEW99OVHJwEFDqbf/B/sgWC+Y6aP/1BcY4e+SFr579e3fIKeiZDjHa39vOkfnjJSq
         hovoO/7vZqGnegMsJx7VHMDj8TAii2MMlp2rHE37RMputx90HCEs/xPx+2DGX5AtpyYH
         3Aug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUjfMl0S6MiE1tPHw9Isd1yq7QdSs6rCbUZ0eNbt0wVFxeekJY+
	WnQEHdAgsWGORA1naAob1265Bw41N4rOh/73kfD9vdpZUBHVdnCeVrcx4LBrkshsW9/HcXL6bmG
	J9Q/AtPn4460Q+dmkAN4va2FTakVeJAwD+diHs2VfaZ6ojYFNI6NakxM9NLWAJwZ5YA==
X-Received: by 2002:a17:906:74e:: with SMTP id z14mr15978035ejb.310.1560735105395;
        Sun, 16 Jun 2019 18:31:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgNfV+fo1y5OUSblZvIhr2lVfLeSceDPga0YraRzw/uVLsJgOVhl1JeJvjl+RyHUypXLuR
X-Received: by 2002:a17:906:74e:: with SMTP id z14mr15978007ejb.310.1560735104569;
        Sun, 16 Jun 2019 18:31:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560735104; cv=none;
        d=google.com; s=arc-20160816;
        b=P1/8rHwxsI86Fz6GjtILU8Yf+RS7kFFRpsGVxgibRHOccCAxVEQalCRIKrkAmy3zwp
         C70Vpf5HK/WGB3Mto6RTMO9DFYZO3hGvs3RQv7aZp6IIbFtgHDIWbNBuoYADhyHDnVIj
         UMrTB2iQCqj7Vv85dGgboNScDWA7GLFoGnTX1Kcgxs+yN4LMhqtpjCzmqGxgjmsk8+S0
         iY/NALw7cCEZqmbIcouHI6fGEtlXcfqmHtSs9fL+cyTvxVGdx70jd9l48q2XviaTA517
         V4GSO86lh8fO3FgABhZBHfBzELsDyJglxgjGYvIJXUC8411Yq3VJsfnFz2MAmUGRMnIc
         fJ9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Q+TPkG7VuBBLLNsNn7AA/WEqzduHLE1RPY5aPgZf1ZA=;
        b=We2zZOBWcmfZ8NU2Gku7HY7pOodD91TqHk13a93U3hKE0QEQXxhbYKHXrC5OR5CDGk
         EJwss2EjPisuJ3kLrkWAr8LdPZl36Gt/KUspZidu4OYxIw5kl0VaJWnmiG/o0oLS8uIM
         JSwNcH08Rcw3f6F9f0Bb/k2fszm4dvN9gGKWf7fWvKXTKMNV34r3/OycoAlRkhfbhZYN
         lXJ+YsebHl/kvDqZY2Tj+N1hfLO6tFgIjvQIeNffX+34d5z4JKEAEhRI+nFYNnvr8iJP
         fHXrTKlmNJl4r0pG3bsKAK4w6LpjWT/vCNFFH8F8+9qowG6oOf7G6QdLcRQ1evyd/A/Q
         PqXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q46si7301497eda.329.2019.06.16.18.31.44
        for <linux-mm@kvack.org>;
        Sun, 16 Jun 2019 18:31:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 73BDD28;
	Sun, 16 Jun 2019 18:31:43 -0700 (PDT)
Received: from [10.162.42.123] (p8cg001049571a15.blr.arm.com [10.162.42.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6CA773F246;
	Sun, 16 Jun 2019 18:31:41 -0700 (PDT)
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
To: Qian Cai <cai@lca.pw>, Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-arm-kernel@lists.infradead.org
References: <1560461641.5154.19.camel@lca.pw>
 <20190614102017.GC10659@fuggles.cambridge.arm.com>
 <1560514539.5154.20.camel@lca.pw>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <054b6532-a867-ec7c-0a72-6a58d4b2723e@arm.com>
Date: Mon, 17 Jun 2019 07:02:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1560514539.5154.20.camel@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Qian,

On 06/14/2019 05:45 PM, Qian Cai wrote:
> On Fri, 2019-06-14 at 11:20 +0100, Will Deacon wrote:
>> Hi Qian,
>>
>> On Thu, Jun 13, 2019 at 05:34:01PM -0400, Qian Cai wrote:
>>> LTP hugemmap05 test case [1] could not exit itself properly and then degrade
>>> the
>>> system performance on arm64 with linux-next (next-20190613). The bisection
>>> so
>>> far indicates,
>>>
>>> BAD:  30bafbc357f1 Merge remote-tracking branch 'arm64/for-next/core'
>>> GOOD: 0c3d124a3043 Merge remote-tracking branch 'arm64-fixes/for-next/fixes'
>>
>> Did you finish the bisection in the end? Also, what config are you using
>> (you usually have something fairly esoteric ;)?
> 
> No, it is still running.
> 
> https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
> 

Were you able to bisect the problem till a particular commit ?

- Anshuman

