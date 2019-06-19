Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1656C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:39:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC89421783
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:39:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC89421783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BFC68E0008; Wed, 19 Jun 2019 12:39:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 270728E0001; Wed, 19 Jun 2019 12:39:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 187648E0008; Wed, 19 Jun 2019 12:39:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D59B58E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:39:56 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i3so10157814plb.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:39:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=2cMoTlAA83QbDo3lkTgaHN7bfou2ujrS8HB+JRyolTg=;
        b=StYCZYK50b7GG9s9cXHXVNl37s/cKAxYRe8PL2ZVHezXPWAwBTHcVqhKPelHxu6dcW
         oaNkZ1bKixbNP7I6vw+0qMysFOUVdhmJcbNjpFsXceQrkuBOVbUydC7fv15R4XFwDVtK
         iXsygHj8SDNPoJntOUoEjZK6LDu5xVpJ8PwqI6AcfDTH9P13NSP6Yghcc2O9ls5pqVIk
         P5Cw4eSjEfMU6VgF+yz1c0mWX7AJzO2hQmGhQ0l0byDzubAofShM1I+jDWpYG/TuFFTi
         3LK3D+O51R418URwZnarTsffUpfO4GxMJKTfusSpbuDLi58QkFt9d1HEJIRjEat73p+N
         mp2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUyDfAF/mzd003qwQOThjAwGrzD475ldnA6uiqEOwko/7/kzcfi
	bauitIWvd2bM0VUMMeq6p0nM8V3IHeZI+wDOp2PB1rtcg/nfyLshGMLPzQwYjLTRIbMNAebT/WP
	//pUB1DfJjkVGRyz6tAY4rDnSum/Y6Vou15LN4U5lvPt3NYNxCtWxcI6aMrRgj9djmg==
X-Received: by 2002:a63:a1a:: with SMTP id 26mr8431372pgk.265.1560962396514;
        Wed, 19 Jun 2019 09:39:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2kiUAiHYfeavE+GdiFBuqaaLTIhT10D6xyo2eV90FCcgYZ8tWvxCgLhy5H1jCzpDBmMnN
X-Received: by 2002:a63:a1a:: with SMTP id 26mr8431343pgk.265.1560962395948;
        Wed, 19 Jun 2019 09:39:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560962395; cv=none;
        d=google.com; s=arc-20160816;
        b=ItO9MDT6vRRsyHU7+R/GddKqFdcGnd8wqopJacKASrpwwmwpllA4wvdyDsdAGGsRDr
         JRzericAlGyJTJjO6X0GoFJdaK0N1scd+qw7IDrZ8k7dEcBLU3N6Q/K6dd9VUqdovWwE
         EqZJL+CLeKxovZs7HISIkcFZQ6w46wo2HVr5hUdAdyi7kUpem3y4nflnYDS2tJ3PFWDj
         /a/NDzKwgv9RvYMYrqIAO/UVDZpZOcPT//53DyN8p7ewwB9CFTR64d8n57VToIOSNCL+
         UuWqaZRuVjNvgLfEMPxW+ALuPrQwa7WLZZBzEJ83F7YbG3BVgdna0EMmec/lX3KA+82Z
         kRBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2cMoTlAA83QbDo3lkTgaHN7bfou2ujrS8HB+JRyolTg=;
        b=AORZZfA9VhnRr/B2WL1ywsmMprmHvuSGQsoX5slmHq/nLtmlt0Y1Vbk1oWD9rs/SmJ
         obN1+Sf5vsAb/dnDqHeN1M6jHWMAok9/OQPY1ViItnpe6p0/R4uy7gQdttFcVVeRGa5f
         4XIHcFt8OkrnLoYDVHBaogpy5pKVtvuFWaqdfhmeEaofc6s8s8naSwqWAgBSx8LRL0ge
         mN+2/8FsoZy1NkoolxiG2QFYt5ZgQzMRopN8POCPXATXlsv+dCHu922GsGRoiaIAyvQV
         nbq+FtyQha9p19aMblKTSfV1sFPd3QjeVitWFoHaCSCo3vXc3Z0bNr+LH9gTmgGcDTpR
         2sag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id 92si16111239plf.299.2019.06.19.09.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 09:39:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TUccqUw_1560962390;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUccqUw_1560962390)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 20 Jun 2019 00:39:52 +0800
Subject: Re: [PATCH] mm: mempolicy: handle vma with unmovable pages mapped
 correctly in mbind
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>,
 netdev@vger.kernel.org
References: <1560797290-42267-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190618130253.GH3318@dhcp22.suse.cz>
 <cf33b724-fdd5-58e3-c06a-1bc563525311@linux.alibaba.com>
 <2c30d86f-43e4-f43c-411d-c916fb1de44e@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <68b67faf-d1c3-bc36-3db4-c86c6dfd8f11@linux.alibaba.com>
Date: Wed, 19 Jun 2019 09:39:48 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <2c30d86f-43e4-f43c-411d-c916fb1de44e@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/19/19 1:18 AM, Vlastimil Babka wrote:
> On 6/18/19 7:06 PM, Yang Shi wrote:
>> The BUG_ON was removed by commit
>> d44d363f65780f2ac2ec672164555af54896d40d ("mm: don't assume anonymous
>> pages have SwapBacked flag") since 4.12.
> Perhaps that commit should be sent to stable@ ? Although with
> VM_BUG_ON() this is less critical than plain BUG_ON().

I don't think we have to. I agree it is less critical,  VM_DEBUG should 
be not enabled for production environment.

And, it doesn't actually break anything since split_huge_page would just 
return error, and those unmovable pages are silently ignored by isolate.


