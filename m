Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F8D3C74A52
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBC8320872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 09:00:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBC8320872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BD998E00AD; Thu, 11 Jul 2019 05:00:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56DEF8E0032; Thu, 11 Jul 2019 05:00:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45CF88E00AD; Thu, 11 Jul 2019 05:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1198D8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 05:00:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4so2420780plp.4
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 02:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=bNmC4lhjQI857Soa+Epyw7Vt/WQjIf48DeZAJ73vozc=;
        b=Opu/nq8IFElOAEKagP5cQAmI7D7ppZA+p4J+nwV2ILYoDnQL/wM8L0NYy5azGD6SSg
         x7mJaL85delvJUDFIuMxSEQUOe929G1pjgdKi+nekVYfViqBUQdfjMiLWSb0BILL/emx
         sslJEp7kcEwfm2KfN0Hxm0e2zdoJQH3VmcYNxEmVh18rWPhecouJjdCKLlg7DD0B5IT7
         YJea/1MyaobPwX6i030mIYnQPQ8HWRZGRvFiO1wpXPes+pHIhi2PwMaEyE42TbYdztwf
         rO/eVcKBp7FJoAdJeGELDNY9I2/84Y49xHO3+60BFwDEeOJib0Y5G57LQMJt6+PXpDzS
         Qa1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUcxln7/827AtDpYwmKqrMb1119EdublIov7SRxS2CpmOgBbtqS
	8PaVY/BkIGvi0zfea/Optl1L/aQgM46JsxLQSasRotF6Dcda9jPbJTtrDpKuJYKiCB/0gMJnk2S
	x1TSxZukZYH8TY+UsNF2iY1bjDjMGTOV/mB5QAJ6JcDv+zAtsAS/NmPaTgFEis20JRQ==
X-Received: by 2002:a63:3f48:: with SMTP id m69mr3150478pga.17.1562835619209;
        Thu, 11 Jul 2019 02:00:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI77GceNDok4oGk3hY7omHTGDk8PO58navwxEagMeyArFHlit5jY9Trs7oR6NKeOFASyLC
X-Received: by 2002:a63:3f48:: with SMTP id m69mr3150415pga.17.1562835618414;
        Thu, 11 Jul 2019 02:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562835618; cv=none;
        d=google.com; s=arc-20160816;
        b=qOYDYx4gE9xniCrxwtxH6jdByDrbc7CDUWUlwkpoIjZigy97UxVniLaxeUbIs9wJMw
         dQBLZhgbvbgaTzMCNGOYdjdoUaoVVlzhParbVr1nogM+SMJx/cDSaqd2IHuvH9O4FPYg
         w4u9fgKSdSq9AtSVnhY0r63QkjQa+MJhtqJp4wfiw46FAMdfAownqmWZbqOIyav7H0Wa
         c94hOSlRtWetsq14P54orVIa0mU7meXrFQCuUBj9MZSlW8eXLpihooxbG6FdZin/tpc1
         BJvGDABf/eDe+N7RkgoO2BqmdpAZc60fcnfuBWbcvMCXDm+E4zyteX3sIzRrguYmi/ew
         dtNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=bNmC4lhjQI857Soa+Epyw7Vt/WQjIf48DeZAJ73vozc=;
        b=M8agNSddSOpaLH2pdLgS7q6OV5mx9HitSdCuMF+MTZ4U/JPnVlq6MPu9PjkX0MMP4n
         FOeh39oZxzWSTTyugL+YiT8WuTN//2sfEzjMruypWwSApL5lPcmMyhrnWIYnn0tIY5Hj
         kxrbersePSesNIW8M9XPIntPKtSBF4GnCv5Hd9puGio2cnIvfHlLWw6zK5eHxm5lvm3N
         64JRLZK8r5V3fj2n+1LWITakPzZAWiOHk3xvOvZhYxEZJYEEjLjcwBjdpAxF9xGKtC7M
         JTJ/E0JJnw9aGlPI29INgAxhgbw3Yz/jUodSSy7aGvcINboPaDs+XktNU2GdXzzWUWGn
         5vlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id r26si4900988pgv.189.2019.07.11.02.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 02:00:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TWcBEPJ_1562835610;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWcBEPJ_1562835610)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 11 Jul 2019 17:00:11 +0800
Subject: Re: [PATCH 0/4] per cgroup numa suite
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Message-ID: <6a050974-30f3-66b6-4c99-c7e376fb84d8@linux.alibaba.com>
Date: Thu, 11 Jul 2019 17:00:10 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,

How do you think about these patches?

During most of our tests the results show stable improvements, thus
we consider this as a generic problem and proposed this solution,
hope to help address the issue.

Comments are sincerely welcome :-)

Regards,
Michael Wang

On 2019/7/3 上午11:26, 王贇 wrote:
> During our torturing on numa stuff, we found problems like:
> 
>   * missing per-cgroup information about the per-node execution status
>   * missing per-cgroup information about the numa locality
> 
> That is when we have a cpu cgroup running with bunch of tasks, no good
> way to tell how it's tasks are dealing with numa.
> 
> The first two patches are trying to complete the missing pieces, but
> more problems appeared after monitoring these status:
> 
>   * tasks not always running on the preferred numa node
>   * tasks from same cgroup running on different nodes
> 
> The task numa group handler will always check if tasks are sharing pages
> and try to pack them into a single numa group, so they will have chance to
> settle down on the same node, but this failed in some cases:
> 
>   * workloads share page caches rather than share mappings
>   * workloads got too many wakeup across nodes
> 
> Since page caches are not traced by numa balancing, there are no way to
> realize such kind of relationship, and when there are too many wakeup,
> task will be drag from the preferred node and then migrate back by numa
> balancing, repeatedly.
> 
> Here the third patch try to address the first issue, we could now give hint
> to kernel about the relationship of tasks, and pack them into single numa
> group.
> 
> And the forth patch introduced numa cling, which try to address the wakup
> issue, now we try to make task stay on the preferred node on wakeup in fast
> path, in order to address the unbalancing risk, we monitoring the numa
> migration failure ratio, and pause numa cling when it reach the specified
> degree.
> 
> Michael Wang (4):
>   numa: introduce per-cgroup numa balancing locality statistic
>   numa: append per-node execution info in memory.numa_stat
>   numa: introduce numa group per task group
>   numa: introduce numa cling feature
> 
>  include/linux/memcontrol.h   |  37 ++++
>  include/linux/sched.h        |   8 +-
>  include/linux/sched/sysctl.h |   3 +
>  kernel/sched/core.c          |  37 ++++
>  kernel/sched/debug.c         |   7 +
>  kernel/sched/fair.c          | 455 ++++++++++++++++++++++++++++++++++++++++++-
>  kernel/sched/sched.h         |  14 ++
>  kernel/sysctl.c              |   9 +
>  mm/memcontrol.c              |  66 +++++++
>  9 files changed, 628 insertions(+), 8 deletions(-)
> 

