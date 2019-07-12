Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45DF1C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1317521019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:17:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1317521019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FEF38E0112; Thu, 11 Jul 2019 23:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AF5E8E00DB; Thu, 11 Jul 2019 23:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 876E58E0112; Thu, 11 Jul 2019 23:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFE08E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 23:17:48 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id l15so3911392oth.7
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 20:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jH+kc63oVu70cF5h/e4lW5SvQKYlS6ecu/Urk6oC5eM=;
        b=Vqdb34sivkgna2jgSsmB0MFiumQQ0KZVel3JA9Aw54if1lkXUUsXPbSj8TcuRGcpnZ
         bOXjOZ/SkPRGs6NJKJQ6g1pZ3V+EBmf5EKkLSlUSvS193m/yIQ+76mGq6VqjWLm2+ckO
         rzZblGu8Ai2d4uGnTWmxq6RxM3HjuHa5ttQTpUMWETO4Orypzd+CGeGKznYx5CEtg5VO
         DUjEAnB4SPTj1vvH8CtyDhUJUOHj+i8rP32Kbwp+NKyGa91duc2WSLoZMlt3RIZMa1t5
         mI00htr+Xth8OQlNp8ftpuJ8Ms9VlaJqeJE1LjMjp9G/CxiATsZ5fj0rQzSWs/dtLrUy
         Ry+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXnhSDmO8mKk2QnPqSoWmYtsNZDbPM8UmyCYVlP0c8D/PABa45/
	KH0WmgIF5CVOeecbgq2mOj4PwvjxrXl5nwOICo/MpVUFaF2dM0v9k+n0ye2QpugRwMA0o1hpcIx
	XQqI0iGBH6nEvuQ4z6BM9wt8ldxrYqDIGTFUnZ0twHi67Azn2W8ScJqcBKbffWOyOrg==
X-Received: by 2002:a9d:6754:: with SMTP id w20mr6133022otm.41.1562901467991;
        Thu, 11 Jul 2019 20:17:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHoJDqo/glA1B6rzYqvkK8N9kLDPHgsSU/qViwi3gF90RSx8ngqNhRQyXo3xGRZC9Qgz1X
X-Received: by 2002:a9d:6754:: with SMTP id w20mr6132995otm.41.1562901467478;
        Thu, 11 Jul 2019 20:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562901467; cv=none;
        d=google.com; s=arc-20160816;
        b=hNNhDv44rm+OcQrX/TPxmHUjBpGh2jfT9yI/+qMpVj1CCfPEUqucoisYX/uZybRUJ6
         q90JDoxBBl7i3jG1F/kD+JqvLPyUQU0Spxq4S8nCNQFP/QbelT7t5YhkQMdHyyya2fL3
         fcGTA8h1QFqcfE+qjdelEu/DSgjpSYMQuTRFfR6nnVBxuvbhB35/APpnvhS0u7vNrMo6
         /S5TPPw9DcRcXb4pOv/HqMFWHkPd6eDUczwvMCGQrcf8hM7+OPqGBgHAaEslyE4iJ9er
         LZNtann6s2kMZ1dnfi6KDGsdXHOK4jCfu46i8LLjxRJECEJdycBpSXUtml1yd+TpBr/A
         SLDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jH+kc63oVu70cF5h/e4lW5SvQKYlS6ecu/Urk6oC5eM=;
        b=W6g1FbdUPTZhm3AEYD6aM/ltuf+9W7ehPColg/wMwTXqy7gK8YoaZ7FHtVp/zBYiqL
         rbt0XVjtI5RVTgHfpzbwTim+pWSgogSyWyKJq90IFceFOe14luKwp4GXFErkbDSZyyVk
         K2EV5C7nbREl358JSerL7CBcjzUliUVXBZ67eoU2B2up5L997wdzyIcTWf20YcDl0hOK
         YbWOfr8kpzhSP3Tcazs/gmfnesFVBVu1ZDj29WfYQAqlryVngXwtBBmP0S3XrJcVY7QS
         RxHc4joIkSfvIQkus326AdOwvjuh0qBTR7AQFnzmN+6W5vXuP+w2lGLGPqHeBicIkzCm
         tiMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id 31si4730076otd.7.2019.07.11.20.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 20:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWfas.h_1562901451;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWfas.h_1562901451)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 11:17:32 +0800
Subject: Re: [PATCH 2/4] numa: append per-node execution info in
 memory.numa_stat
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <825ebaf0-9f71-bbe1-f054-7fa585d61af1@linux.alibaba.com>
 <20190711134527.GC3402@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <e0c38e99-7a01-7a84-2030-6cb963452e81@linux.alibaba.com>
Date: Fri, 12 Jul 2019 11:17:31 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190711134527.GC3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/11 下午9:45, Peter Zijlstra wrote:
> On Wed, Jul 03, 2019 at 11:29:15AM +0800, 王贇 wrote:
> 
>> +++ b/include/linux/memcontrol.h
>> @@ -190,6 +190,7 @@ enum memcg_numa_locality_interval {
>>
>>  struct memcg_stat_numa {
>>  	u64 locality[NR_NL_INTERVAL];
>> +	u64 exectime;
> 
> Maybe call the field jiffies, because that's what it counts.

Sure, will be in next version.

Regards,
Michael Wang

> 
>>  };
>>
>>  #endif
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 2edf3f5ac4b9..d5f48365770f 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3575,6 +3575,18 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
>>  		seq_printf(m, " %u", jiffies_to_msecs(sum));
>>  	}
>>  	seq_putc(m, '\n');
>> +
>> +	seq_puts(m, "exectime");
>> +	for_each_online_node(nr) {
>> +		int cpu;
>> +		u64 sum = 0;
>> +
>> +		for_each_cpu(cpu, cpumask_of_node(nr))
>> +			sum += per_cpu(memcg->stat_numa->exectime, cpu);
>> +
>> +		seq_printf(m, " %llu", jiffies_to_msecs(sum));
>> +	}
>> +	seq_putc(m, '\n');
>>  #endif
>>
>>  	return 0;

