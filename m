Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D260C742A2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF68021019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:16:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF68021019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B6838E0111; Thu, 11 Jul 2019 23:16:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73FDA8E00DB; Thu, 11 Jul 2019 23:16:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B96C8E0111; Thu, 11 Jul 2019 23:16:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24A358E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 23:16:00 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so4399490plk.11
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 20:16:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=R93yLVnAsPXT8b8mxuxaUeLoFSeRIrrDZYtn6SthsCM=;
        b=pNe3yzTabaYJ2rgGYn8qfFW/3rsM+XWQtxCHAo9n+BBlWsvG+LDTm6iEFTq0VI/Awo
         WSFb2d1PfQ0scWt5R64aTEoUGAEG41PEQxHlkYliy7rP0XjD2lEPnC5cYpJQfCzLzctC
         CeBMUdHY+2lg0FLtE/yqG1+D2y7cnIq/KdwVNtZLWzy2LN7WWzBQFHTzX3qIjx/VCn9H
         y3SNxmZVa6SlAGdSL78Y3SKgyIAI3tP3TngWyliRdbgB/Qd8fYDVWjml2cPqqp7Xvciy
         MytLIKSlEV7OdEEAwXyIhBoSH0aR+372ctGTJ6qYXqxL9lE5Y0VyazkrOg/7zNZofawu
         A00g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX2A7qmcmmPXBFWLZzi2AS1RUDwsmlqcAjXmVUx/O1KDMn+Uhxt
	tUAssASzyIo3aShOm7hsS0icDg0Gu6hPkZ82HNFFPN3KCDJTGM+sVksuCN7x/hXg4y8K1D2AdkD
	lv5ZniSOZMZbcQHKJTer7YusG/dWm2sQKEhpeWnyBtILAbb2hMW6GwZZGtll+yBcWsQ==
X-Received: by 2002:a17:902:28:: with SMTP id 37mr7972323pla.188.1562901359777;
        Thu, 11 Jul 2019 20:15:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgzCKQ8TgyMnQBHFfO3OzVqU99qjNOAZeP7q169dxwvQUNwJV7kxIs+RkSnBrgVruv5nk4
X-Received: by 2002:a17:902:28:: with SMTP id 37mr7972220pla.188.1562901358214;
        Thu, 11 Jul 2019 20:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562901358; cv=none;
        d=google.com; s=arc-20160816;
        b=RsbbLFRixTIYQY0YCWiiYSu0zMmUYCUF/S75V8MLZkGtfXbQdt5u6q1S4pgI4594gN
         M4VWdZuQZjZJRuKj1/PLoaa3yk6ZZmmPLtj+opASwWjoHROt6a4TOdQcvIqPp1Jb623N
         QAHQuPukMbpNcYNy9bgJ9Aq10DUtgfHlyOPiD/12WBeGcyuIXsHJQAXw1nV7phyeAqkB
         bwcBOZt8Zjk/MVzxN6bnwSxuiQlbdzjBBsuZE6Sj+E+PLukQNPM23BKqZm5QHopP8X9n
         raHuUW4TYugaJYqAsTPKmsmraFmgwaJkhGseqAov2kz8+YkZM1twXAzX13mKUHk4j6g1
         mk1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=R93yLVnAsPXT8b8mxuxaUeLoFSeRIrrDZYtn6SthsCM=;
        b=0V53xhOnmGnYT+ruOa+VOJ/Exw9wzZpqEVNnuoNPI3nroMubrcVSFDZ77xjLsqEzwb
         VxAuFvCNHkMWBMJ2H+Z7oA62gbyj59NaHC1oUlVsBUSTQszlZHmmM+LChFmsiM3HEBJK
         vKhe7InABfAMXizfKK9GLj1hWqEthlYhbIIuuczvICnQ5k5kX66EDN6/itbfFwDRl3sI
         apoZ0EtGjnuUrCVHy0JRDh1V9XEUpvdJTCtV1Ua/vZsTKRi1TSzaVFhTsf5PcSRBiqTX
         X99U+Fs4knzFgDAuS9piGUqLhW8Qobsui4vow/PZRVKOYiwaM899GcdsDwG3QeDwJFJP
         tG8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id e14si7089728pfd.141.2019.07.11.20.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 20:15:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWfarb8_1562901341;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWfarb8_1562901341)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 11:15:42 +0800
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134353.GB3402@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <f8766405-70f3-71b0-60de-03425350189d@linux.alibaba.com>
Date: Fri, 12 Jul 2019 11:15:41 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190711134353.GB3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/11 下午9:43, Peter Zijlstra wrote:
> On Wed, Jul 03, 2019 at 11:28:10AM +0800, 王贇 wrote:
>> +#ifdef CONFIG_NUMA_BALANCING
>> +
>> +enum memcg_numa_locality_interval {
>> +	PERCENT_0_29,
>> +	PERCENT_30_39,
>> +	PERCENT_40_49,
>> +	PERCENT_50_59,
>> +	PERCENT_60_69,
>> +	PERCENT_70_79,
>> +	PERCENT_80_89,
>> +	PERCENT_90_100,
>> +	NR_NL_INTERVAL,
>> +};
> 
> That's just daft; why not make 8 equal sized buckets.
> 
>> +struct memcg_stat_numa {
>> +	u64 locality[NR_NL_INTERVAL];
>> +};
> 
>> +	if (remote || local) {
>> +		idx = ((local * 10) / (remote + local)) - 2;
> 
> 		idx = (NR_NL_INTERVAL * local) / (remote + local);

Make sense, we actually want to observe the situation rather than
the ratio itself, will be in next version.

Regards,
Michael Wang

> 
>> +	}
>> +
>> +	rcu_read_lock();
>> +	memcg = mem_cgroup_from_task(p);
>> +	if (idx != -1)
>> +		this_cpu_inc(memcg->stat_numa->locality[idx]);
>> +	rcu_read_unlock();
>> +}
>> +#endif

