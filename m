Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2EA5C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:14:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71828206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:14:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71828206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1780A6B0003; Tue, 23 Apr 2019 05:14:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1279A6B0006; Tue, 23 Apr 2019 05:14:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 015716B0007; Tue, 23 Apr 2019 05:14:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBF176B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:14:57 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y2so9358687pfn.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:14:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=D/P+xqvNSA/F4wBM5RyP1OHDtLtEm1REdIf8KqjOVRI=;
        b=pR6oEF2BmZRMTYIWkRyj0AdiYuQAlqomZ9elUZgxfuMz4VtAh8Vm82X1euWK26cEpe
         CVpu4rkStK1zBbjxgZeKjUmihamy8Aui6PDaM1xSn12QUmb+TB/6XkoHmJ7cI5lMhwHI
         pdNRZ5sHUQZHMLugl2Z4lBS/N/MnaJIxEgFNDOrtnBeVGv8rfAfg25G1ZJ63ITZWM9+r
         QKKTVZmbhaLHBAtPY7sRCFOcMd8RNH36qKL9zlneeUojLvUDU5lpBA3wzXMohpMCO6q7
         WBYCYFQ2wUkGbWMZVazgZx1AAyaOu2QHenmHMb+oKJfXPNVPS1gsPBa/M1m05jvg1Na1
         EoOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUZ2q/9Bt7KmTvkappgwCD7Ioh3i624yH8TlkEJ/2T8M1WrWAX/
	enqLcEfpgon/riSzZpI2NX0kjChrxy92Tmh6PRbOvnBixAU5984k7veFvHZ/Ec7h9EKZSXKQBns
	vxIZtHKhMlyZ6pq9iQfSVh55w1J7JjhVp5v4w6rIvf6KinNwp1iMdAQwLbYi0GCqp5Q==
X-Received: by 2002:a63:28c8:: with SMTP id o191mr22248347pgo.164.1556010897408;
        Tue, 23 Apr 2019 02:14:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUdJBOmHA150rhVBiN3tSGdjgqocUC04BLVqACUFH0lG9W8sBTFAAuP3KnaFR8lZlhO1cm
X-Received: by 2002:a63:28c8:: with SMTP id o191mr22248314pgo.164.1556010896745;
        Tue, 23 Apr 2019 02:14:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556010896; cv=none;
        d=google.com; s=arc-20160816;
        b=wZMzhIW9J9G7IqJDPC7w5thdW7cVs5n3ZtyuYOzHyG6iupa3f9SLIVV9BNKbvA8rJG
         hwslZO1jmGlJiX0iJtwB6dW7RcjlbnvznFggB2C5GakEyrX/01sWeHP7+kKnEIYv+0dk
         si2arefkjWyMicKA9J35NFH3+SydbE267cFM1ApWVE3HLfPiif4VN3lTludBS00KcXas
         LKDwrX2qlkxiAoB4yjAw1IKaOl3rAzF0y9PTjilMnst3iXM/DdRcU/ryIYkXEDGj+XfW
         ILYEGODciVBANKyqHgpyStdoHlYe8mV9htmsgENiS65roWA8UdBGZiryhjbwm07KnxfN
         3+nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=D/P+xqvNSA/F4wBM5RyP1OHDtLtEm1REdIf8KqjOVRI=;
        b=o/fSVolLcB6QiR3yKTK38ZWlpi3rr2bkemDlIxF0QwpJC7WJaJOEdAggLNFEUzSlfe
         ICMQepyoscnlzujh37idd/Kz811PRYdDXwjUlGw1XO2jjs8TYMueT6SXeN6Fn3omxmVE
         OmOh+YUXM86oC0DKvBvv5cP35ncxuGeKjQslji2AnI4v9GppPlsg6B4sT5QSWMVEp95G
         CgKNraXGXiPlatJZOOi5bha8VWF6zdITXhDyf9M8MVQpeEUo7q4+IxPGbYBge6SI6g3p
         KosZG+fp4pGE7JzuW1cKM7u/VdgrjLhfiAcKexoU06lp2gGdJHB/ycKKpW3Fk8yJVzeR
         fcZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id h63si14431283pgc.404.2019.04.23.02.14.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 02:14:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R821e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ1rXBG_1556010893;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ1rXBG_1556010893)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 17:14:53 +0800
Subject: Re: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing
 locality, statistic
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
 <20190423084444.GB11158@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <b0148598-3a9c-d5d5-4c30-5bbb0f68145d@linux.alibaba.com>
Date: Tue, 23 Apr 2019 17:14:53 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423084444.GB11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/4/23 下午4:44, Peter Zijlstra wrote:
> On Mon, Apr 22, 2019 at 10:11:24AM +0800, 王贇 wrote:
>> +#ifdef CONFIG_NUMA_BALANCING
>> +
>> +enum memcg_numa_locality_interval {
>> +	PERCENT_0_9,
>> +	PERCENT_10_19,
>> +	PERCENT_20_29,
>> +	PERCENT_30_39,
>> +	PERCENT_40_49,
>> +	PERCENT_50_59,
>> +	PERCENT_60_69,
>> +	PERCENT_70_79,
>> +	PERCENT_80_89,
>> +	PERCENT_90_100,
>> +	NR_NL_INTERVAL,
>> +};
>> +
>> +struct memcg_stat_numa {
>> +	u64 locality[NR_NL_INTERVAL];
>> +};

> If you make that 8 it fits a single cacheline. Do you really need the
> additional resolution? If so, then 16 would be the next logical amount
> of buckets. 10 otoh makes no sense what so ever.

Thanks for point out :-) not have to be 10, I think we can save first two
and make it PERCENT_0_29, already wrong enough if it drops below 30% and
it's helpless to know detail changes in this section.

Regards,
Michael Wang

> 

