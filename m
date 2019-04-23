Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F94C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:36:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E34AE20811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:36:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E34AE20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 842AF6B0007; Tue, 23 Apr 2019 05:36:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CBBA6B000A; Tue, 23 Apr 2019 05:36:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 645866B000C; Tue, 23 Apr 2019 05:36:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3C46B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:36:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r13so9742935pga.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:36:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wvJjD0kmOc+9xsN987BUq3kXI+cR8pOakXt5jDPPYbA=;
        b=gZOCFgQX10W/UsOVZO3uVlYYbWafNIBDGwi/fsK7vjv0+JbK8wGEOX5AsW0siNrXIy
         ZA0+IwcVAwCmve6BEfowcXzDJLg5etl3ThRihOtvknA+Hrc0hb3n34WzJOC2IPCmEd+v
         8v/+FFG7X+pMBBYj/uEdbNup6lusImPrhjOYToAhCRwseC4Azu2JJCTgS6AKwcEB3+T5
         0ZTqLB0ZMdh8lsypfPtGUtrSqky29/uEMqS3DUUikFSvtmJl+3mcI2pJl2AzQvi78BCT
         o80vwBNYTD0nm2A+wQEC8IswjjLzmxCN9SW0AuKll7DeQSn/L28ILgMeVQNbNcrQPX/T
         jCTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW9i4dCkLmTAbaFsGhtkdgnQDRD+KX5hHnI16wpROjCphaZoz69
	PSOAVzpFnWIQvc8OyqWYqR/rHNGVuD/AQIe+RVLKNmb2A0QVT5JbH3DdqvrEtZV8tsJuo53fE2t
	yVmE/B9ycrf1mLBYDFnTir2DipXPYSuhB5PkNDnW8kniSXqy5k6emraQasxDXnbNbog==
X-Received: by 2002:aa7:8552:: with SMTP id y18mr25103889pfn.176.1556012189838;
        Tue, 23 Apr 2019 02:36:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4upToSVMRzs9Cd1Wrs2SIo3equCvXJJhWOrvwBjLcsNgLo0RbTMjVG9wOHoSlPg1qArIz
X-Received: by 2002:aa7:8552:: with SMTP id y18mr25103839pfn.176.1556012189212;
        Tue, 23 Apr 2019 02:36:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556012189; cv=none;
        d=google.com; s=arc-20160816;
        b=IiC6urswVHF4mlG+dic5DHa2fLeAzaKaYrAbBVGRoMDRwB9MPGtm1smBuh9qWQcij4
         xeWCrhK0XfIRmXihj95w1qEZfRSermvC4/L9m9fIxtNpx3tp91if746Bj1hXYccKHqm8
         46XgQ2gn1FM9B2SjfaQqzz9/laESivB4kGyZDrerEdrrNOmbHsy5nf7fB5c9yIasm6kP
         x5tC2PtUfNLwfV6fubh3qgOX8GT6+AI+ERQGA2HUzGq+jo862/qFbSX2SpAaSko9ZI+P
         UyX7bsPSM/1YPyEQPbaxyf5EZLe1ewPuvyxHhYmV0yj1Tfi1lPNswAnGZQJ8x+2POgea
         5IVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wvJjD0kmOc+9xsN987BUq3kXI+cR8pOakXt5jDPPYbA=;
        b=eNahPmbW5tfDdECht9E9NMQVktTRN2wXsOsuJSf7MJskj6iDIcuFB2WzyrxG6Ohpq8
         JFHXMv9oqCRzzxW1txbDpzF5Vp3SCsqX859Tegeor9xwmQZcpkSPAu25cdMfSvKKcFdI
         /8JsgXUmmrYigqxy3IhdKBrWDd4IfZAioOEq+Rvk4VuIyvwcxm6maLSUMvvgozal3Mx0
         3H0VhXGdwkfSk53+f+2KYNRD58TjB8HCpohOPCUyaeosdO7YRgb/Qdvk7TVbGVOgCbLd
         AcH4ZgBiPUm//xdw4IoOGmyu0cS0chgSmcmnG9b7U2EvwJM5d5Ekreqv24V3hR19JLjI
         S0ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id t136si14384675pgc.538.2019.04.23.02.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 02:36:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ1gYRd_1556012185;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ1gYRd_1556012185)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 17:36:26 +0800
Subject: Re: [RFC PATCH 2/5] numa: append per-node execution info in
 memory.numa_stat
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <7be82809-79d3-f6a1-dfe8-dd14d2b35219@linux.alibaba.com>
 <20190423085248.GE11158@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <8c3ad96d-7f3d-d966-6acc-8327023ae3f9@linux.alibaba.com>
Date: Tue, 23 Apr 2019 17:36:25 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423085248.GE11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/23 下午4:52, Peter Zijlstra wrote:
> On Mon, Apr 22, 2019 at 10:12:20AM +0800, 王贇 wrote:
>> This patch introduced numa execution information, to imply the numa
>> efficiency.
>>
>> By doing 'cat /sys/fs/cgroup/memory/CGROUP_PATH/memory.numa_stat', we
>> see new output line heading with 'exectime', like:
>>
>>   exectime 24399843 27865444
>>
>> which means the tasks of this cgroup executed 24399843 ticks on node 0,
>> and 27865444 ticks on node 1.
> 
> I think we stopped reporting time in HZ to userspace a long long time
> ago. Please don't do that.

Ah I see, let's make it us maybe?

Regards,
Michael Wang

> 

