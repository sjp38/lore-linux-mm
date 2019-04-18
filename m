Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74EFDC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:23:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22D95214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:23:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22D95214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B50F76B0005; Thu, 18 Apr 2019 15:23:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD7546B0006; Thu, 18 Apr 2019 15:23:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9791A6B0007; Thu, 18 Apr 2019 15:23:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E45B6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:23:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e12so1922460pgh.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:23:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=8QzPRxE9GQoBbILPD9hqOGzz1p8EdnUFfxd0351ryJc=;
        b=EH9DUvwjDBBcFTHr6stv+xAh0OY5tdq3iVLMwrhMRYFB8XbwPSWlPsnXglYl451BhL
         +MU7UQA5BeYfp9YNVriwZJhb4M4/obKvXj5uKhSjHRaBsx7wHOmuRZguFk40+zm6mP0j
         1GDqA+I6aWR4oCAxx2/FjQZmA9Ypf8W4jmN22KlOnUAejSTqkF4OECRr75z8z38RZiPs
         ucOkZLFt1CQ4ZqwZbm2NjXvYI9CeU3t9XxBIXCNuTNYbW6L+pWEbeDSyLrHEpeELtF9H
         GRv3MZHZacbyi9myv2PD5/LU8lvBwvi+xRbA06XWHNq9CL2rprPviTUkwOV/vOiHBBtm
         Oc5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXtSB3W45P5aNFAbTSVsXhY7F3fc181QwfHR7jdEdPB2N436+IJ
	1mrcAU983y3Qs32o7mOTeneu5DyJnSKi8WEWPy9nGUU+PnSA+3lgiUGeU+S96+18pLsEM33il0e
	JxSnUplaYaxwjOKcypGGltBYh45weZCRqNxRdK+SwFx48bbcy1gNAza17k4wIG97LZg==
X-Received: by 2002:a63:170b:: with SMTP id x11mr10030471pgl.186.1555615432030;
        Thu, 18 Apr 2019 12:23:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXJRy2/G43SPRWYgDs9e1sgeECsoO1GxyYGpW/9IWxD7Ir8IuOIZ1Iw0h9RVFEVK0FEYcE
X-Received: by 2002:a63:170b:: with SMTP id x11mr10030427pgl.186.1555615431162;
        Thu, 18 Apr 2019 12:23:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555615431; cv=none;
        d=google.com; s=arc-20160816;
        b=v3xFnqwNU5gCVyKxXfmWGjadLHo65anDDcZz8sarp7psI265f2uehjmr7qjK1HF2zH
         N2UBNBLvxIDZGM29buMLc2Ivh0yZgaFMtoDcH+mkHmBGyrsdR/xRLm/tJ5syUcZ6wBxv
         y5sKiZtEPNhrmBfFmnZd5XYzBLPhrqW7P4RfrCoEAij09ZJ3Y3CwUFWXvkpzuzpTV5QK
         eaI+3wTGxEg6vAY6KgdA93UI6NrV6WATseoo0jkhRihTzfbtB0eXTPFhZRp82Y0U1UBN
         vQCZLNFy43FqbLclndyXT0SKs8VSXV9HoEFjqJqvOUEME0suV3f6ewIbWOQlqmHwuW3T
         YlpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8QzPRxE9GQoBbILPD9hqOGzz1p8EdnUFfxd0351ryJc=;
        b=dwYnOsno2g2j/Q+B4t/W9Vu/Tz6T2CNPwVngWzkO5zQu4AXp0ZHVizirZlndPeDUmN
         Q3yk6j7LHNdZqxUG5+IrADKdgAwdAeXoV711ODJr2m21wNOrht5o/lF6bCKThU8Ec9yt
         8Jv8rVKqmQCZGXqx8bncJhfWjUzmIwkcku7XEWxaZ7KZI8Yo3UGofrePEjNOg1DSt94T
         OCJxo+itU7m42fpQi/bVVVuoW3L9vzhdUJGM/kKwotMKAmR2eRM3YR00zS73KfziIQce
         Lx9ZICF6hw2CxKtoz8eqB3QdKLBS9s+VNqFBI+jYZzE7ClNlU/6deVBn+fbC+aUVLb1X
         PFgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id r6si2850335plo.349.2019.04.18.12.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 12:23:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPeyaMj_1555615421;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPeyaMj_1555615421)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Apr 2019 03:23:47 +0800
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Keith Busch <keith.busch@intel.com>, Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, mgorman@techsingularity.net,
 riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <5c2d37e1-c7f6-5b7b-4f8e-a34e981b841e@intel.com>
 <20190418181643.GB7659@localhost.localdomain>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <8259dfd6-9044-b9f8-29b1-f427b4435eda@linux.alibaba.com>
Date: Thu, 18 Apr 2019 12:23:41 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190418181643.GB7659@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/18/19 11:16 AM, Keith Busch wrote:
> On Wed, Apr 17, 2019 at 10:13:44AM -0700, Dave Hansen wrote:
>> On 4/17/19 2:23 AM, Michal Hocko wrote:
>>> yes. This could be achieved by GFP_NOWAIT opportunistic allocation for
>>> the migration target. That should prevent from loops or artificial nodes
>>> exhausting quite naturaly AFAICS. Maybe we will need some tricks to
>>> raise the watermark but I am not convinced something like that is really
>>> necessary.
>> I don't think GFP_NOWAIT alone is good enough.
>>
>> Let's say we have a system full of clean page cache and only two nodes:
>> 0 and 1.  GFP_NOWAIT will eventually kick off kswapd on both nodes.
>> Each kswapd will be migrating pages to the *other* node since each is in
>> the other's fallback path.
>>
>> I think what you're saying is that, eventually, the kswapds will see
>> allocation failures and stop migrating, providing hysteresis.  This is
>> probably true.
>>
>> But, I'm more concerned about that window where the kswapds are throwing
>> pages at each other because they're effectively just wasting resources
>> in this window.  I guess we should figure our how large this window is
>> and how fast (or if) the dampening occurs in practice.
> I'm still refining tests to help answer this and have some preliminary
> data. My test rig has CPU + memory Node 0, memory-only Node 1, and a
> fast swap device. The test has an application strict mbind more than
> the total memory to node 0, and forever writes random cachelines from
> per-cpu threads.

Thanks for the test. A follow-up question, how about the size for each 
node? Is node 1 bigger than node 0? Since PMEM typically has larger 
capacity, so I'm wondering whether the capacity may make things 
different or not.

> I'm testing two memory pressure policies:
>
>    Node 0 can migrate to Node 1, no cycles
>    Node 0 and Node 1 migrate with each other (0 -> 1 -> 0 cycles)
>
> After the initial ramp up time, the second policy is ~7-10% slower than
> no cycles. There doesn't appear to be a temporary window dealing with
> bouncing pages: it's just a slower overall steady state. Looks like when
> migration fails and falls back to swap, the newly freed pages occasionaly
> get sniped by the other node, keeping the pressure up.

