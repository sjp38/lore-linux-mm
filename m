Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43C1CC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 20:43:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DDF021773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 20:43:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DDF021773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DEA96B0005; Wed, 17 Apr 2019 16:43:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18CE96B0006; Wed, 17 Apr 2019 16:43:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A3FD6B0007; Wed, 17 Apr 2019 16:43:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C47436B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:43:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z12so15356883pgs.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:43:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=gPAoHrmOWmoZ0TaqEOJEK8z2yhB8ryvYgpIjCo9Xlu0=;
        b=LNdmY+DZi5fuZqjjaVa/vvWY0hUiqn3oDP6V7SAY37ugtvPBfzo7qCH2qzdYc4DqMA
         jmbz9TR/pitsoKK0iQFIBx9PR7EHYYFzIGjmQxJf6fJ8UyVRjlPFq0KO5AwK1XiTNiSG
         6N9xH2Dubk2ryo9HUa8D59Dc6GNsBl3KAvvZQILA9X2EBtF327yXm/ojGKLmLE+wdqki
         lsmMTOhFIjS10hgvwoko4jy/sIO0Ar43IKOevctdIHEegDb5mQw6egRHzNjteo3afdUx
         zBwBPtEIMaeGGNswkt3PeYhjxiLCiXj+XLIPMcnX4z4rq1ZNItJzpz7N9Z+4uEc192hj
         KChw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUX6tD5JM+ApSOEWUWzeLJ5dnBVRnyhmMTMkc4l4wMd9mxrxK0X
	2Q+B0rPRK0PGruBfOfnMnNh9xSsKihbvY28dzl4YWQZwSS1vAJh1ae4fYAUIDdd6Emrmgw6cdSI
	2tYmYfAicpCe2oLrF7qcayLi3zmji3sVF48EF/4fNAonu3Lm7NLEM2g6W0gk+GAgL9g==
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr34219820plb.236.1555533833411;
        Wed, 17 Apr 2019 13:43:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1EZgnPBQ50LbdSgbavsRd4awNtUJg+fnHfA88Jtxp3NfoWfc5M1KMVBkW/XXD8LTgQI4+
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr34219766plb.236.1555533832716;
        Wed, 17 Apr 2019 13:43:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555533832; cv=none;
        d=google.com; s=arc-20160816;
        b=VfNihD6Qp8jykWyMhYw15GzRmLGjHf0QKchOKzylJXx1QVYTGg4D38HEb6og/ue9Ly
         rnTkT+KzZgPfpSvKY7enZVXeEp2RNByCif03TgS1Q6qgLFPiQH310GrkM4/qbIR1qjlm
         7lv6ElCGQCthwJw0x2MSP/8U1tCENVXaqV17Oi0kpwHclhJudg+SjmkOwOiko8VwUZ0T
         RQr8tXH0Ffam7tmu/wHySe2hrfhwq6ymdVCOUTuS4xjNBynGePvwUAPXeZ4BFCpWEd00
         gumGgjhE+RQS4UFxxAcs6fUnKCVI7Exi3kmW9JGM2tWo0ht+fGC9cXMrMoBqQldIX6oA
         77fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=gPAoHrmOWmoZ0TaqEOJEK8z2yhB8ryvYgpIjCo9Xlu0=;
        b=wqCPys+1G9KNADDroclNaT22igzyW9TihohE1cOGVLWI1rlPfiWeAuNtfLio+RIg0s
         Ye+M3AMPDYAp2ERwGKZ3r1RGGDXs4hTzX7J6/s5BWoUCqYv3OV8JxU/rJEOQT4umT7uj
         CHg6x8DZyLKUWppGkkA/upbkUgpp7Wnin26GxxQda3S2uOJVbCm7D5kY/mc17UDN0YrA
         5C01nK7ElChWJN6T1YB4bhXRE38rAT8zbckxjDnrRBfJdlvw9LZFUQSb/jMw73NhLf4O
         qS37TE5zc8Z3g0Lm2Nq+M8nd2DCqsR1K0Y/sF6fEKpe9L7BkRdlZN5ZctoVSLWmn5OhA
         i26g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id n13si41018390pgl.348.2019.04.17.13.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 13:43:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TPaV10X_1555533824;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPaV10X_1555533824)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Apr 2019 04:43:49 +0800
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dave.hansen@intel.com, keith.busch@intel.com,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
Message-ID: <c0fe0c54-b61a-4f5d-8af5-59818641e747@linux.alibaba.com>
Date: Wed, 17 Apr 2019 13:43:44 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


>>
>>>> I would also not touch the numa balancing logic at this stage and 
>>>> rather
>>>> see how the current implementation behaves.
>>> I agree we would prefer start from something simpler and see how it 
>>> works.
>>>
>>> The "twice access" optimization is aimed to reduce the PMEM 
>>> bandwidth burden
>>> since the bandwidth of PMEM is scarce resource. I did compare "twice 
>>> access"
>>> to "no twice access", it does save a lot bandwidth for some once-off 
>>> access
>>> pattern. For example, when running stress test with mmtest's
>>> usemem-stress-numa-compact. The kernel would promote ~600,000 pages 
>>> with
>>> "twice access" in 4 hours, but it would promote ~80,000,000 pages 
>>> without
>>> "twice access".
>> I pressume this is a result of a synthetic workload, right? Or do you
>> have any numbers for a real life usecase?
>
> The test just uses usemem.

I tried to run some more real life like usecases, the below shows the 
result by running mmtest's db-sysbench-mariadb-oltp-rw-medium test, 
which is a typical database workload, with and w/o "twice access" 
optimization.

                              w/                  w/o
promotion          32771           312250

We can see the kernel did 10x promotion w/o "twice access" optimization.

I also tried kernel-devel and redis tests in mmtest, but they can't 
generate enough memory pressure, so I had to run usemem test to generate 
memory pressure. However, this brought in huge noise, particularly for 
the w/o "twice access" case. But, the mysql test should be able to 
demonstrate the improvement achieved by this optimization.

And, I'm wondering whether this optimization is also suitable to general 
NUMA balancing or not.

