Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95C25C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:33:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DCA220811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:33:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DCA220811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0086D6B0008; Tue, 23 Apr 2019 05:33:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFA516B000A; Tue, 23 Apr 2019 05:33:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E105B6B000C; Tue, 23 Apr 2019 05:33:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B844E6B0008
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:33:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u191so5502685pgc.0
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:33:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=axIop/PBPeP77k19mIr6V6k1tBKULWGYmjGtcNmtJVQ=;
        b=HKG9m+02/XtCroHfPZAqwVvI3eLF1IaCQDo2jYB+frYLOvP2QcixMCsvNFO04CMTD8
         dnRy61zB3QIzR0EZWRB5dYlqXk0QGFVwxhO/aTbaN/KS+zlCQVsHhPaOk6Cj90bLo/TX
         T17tMefoEpro3hOPU/g+IaQ8Nm/4cciPgNCqG78UJCFKhT5cfNynshobx2OGPj6slE3t
         Mx/w1jup3UjVlZA5roXmG4Ua74NHqVSl8wZpk8sPxrDPOITVwy10Zm8YNPS1FJpSf6SS
         6RqnOPOufU5sDfvHcitE8BLHIIG96sbl3u0eRqlYIFRWlsLNOwNUX2F1OsYkLG6WrD0m
         LjaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVRKxpsIi5r4EtRDXdD/Bk0vRpfI2qlLaEAxds+gTEWcc1vI1bo
	9uVjWWkv8w/r6UUc1bUl3Wlsd5h5pAvfDthYaSmX6eCBagjrBZ9xtibi0jkHtgmucS+vALoGT8C
	A9pfV6+SwKoaxPDCZflMntUDVmMcmja+T5TfLo/8+HM1HzFpRwelsTypQ81YbLia4Sw==
X-Received: by 2002:aa7:9089:: with SMTP id i9mr25621615pfa.115.1556012009435;
        Tue, 23 Apr 2019 02:33:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFDHhbLNsLSR5NGu1TcMmFGR3+tOO3jQRArIANMWgiJWz54x453noiQ/IDcbvFJ8oK3glT
X-Received: by 2002:aa7:9089:: with SMTP id i9mr25621573pfa.115.1556012008870;
        Tue, 23 Apr 2019 02:33:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556012008; cv=none;
        d=google.com; s=arc-20160816;
        b=ECSgyyhgWx4yQpcnccmM/38iT6ny4I35hsR1oPrQ+7j6mbDpJDOwjPIwW4CF6WG4Vh
         4ENmqgkW2kV2pjnliuR5H0XzLaZxLBIi79VFokw9pQWplqFHDQH6PbYpzOzQ9jcWNKqk
         qSQX9d3JUeJTQl2pTFKCDh/u7Hhv+/LERhRbFtgUj9hgVM/nKSyv4jZGPTMEGyqbONVS
         Bmzu1UPCKrISM8hH0jHD/biOm7fDXa4K1GsXRongckK9Vub6P8SDWfHs6AdzPZtgeYdc
         6VF0e6kwR3RFsryM709vqW0YMngk7T6vsbTSm/6HVvuWKY1kTvuYLIXX5siDRdQF8AFv
         Y25A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=axIop/PBPeP77k19mIr6V6k1tBKULWGYmjGtcNmtJVQ=;
        b=yDhJBHiVzkMqCkeUlWeJo18nwjiqQ8uNvokDEm1+wnPNbwd18YgVqJUW2gCtFj7fAM
         U759m9u637E49i821yMyLWSFDJRa9k09wji6BZPPjPqVO2tG2ZTax9oMHKdYlh8Vg1Hk
         MnbLjf4YrsNlpvtOkAgLf+KRwzaDJ7NMfk4R4Z3pKEEx5LorKcJxBnGMZ/+5oeTcwDiB
         EfHwWmEgA2HeKDPkIteKK/w93+eRIrOQMEgK9N8J/RDu+vF6ZNhMB7KA7ebL6dgoQhco
         WZpdq15cvTQbidHEzw/lrbnyH6yggIFfHvLFrn3VxdRyVeHJvPkhkkkHbA9pTinhLb1M
         BxyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id x4si15384033plr.406.2019.04.23.02.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 02:33:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ1iRYv_1556012005;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ1iRYv_1556012005)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 17:33:26 +0800
Subject: Re: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing
 locality, statistic
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
 <20190423084722.GD11158@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <b1a3aebf-e699-23ce-b7b8-06b6155f3dbe@linux.alibaba.com>
Date: Tue, 23 Apr 2019 17:33:25 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423084722.GD11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/23 下午4:47, Peter Zijlstra wrote:
> On Mon, Apr 22, 2019 at 10:11:24AM +0800, 王贇 wrote:
>> +	p->numa_faults_locality[mem_node == numa_node_id() ? 4 : 3] += pages;
> 
> Possibly: 3 + !!(mem_node = numa_node_id()), generates better code.

Sounds good~ will apply in next version.

Regards,
Michael Wang

> 

