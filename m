Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16C5AC10F11
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 02:14:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 794C22077C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 02:14:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 794C22077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFB006B0003; Mon, 22 Apr 2019 22:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAB326B0006; Mon, 22 Apr 2019 22:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC23C6B0007; Mon, 22 Apr 2019 22:14:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9045D6B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 22:14:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u191so4854204pgc.0
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 19:14:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lbk35pR5DXGh8DawLtOrlI+xz3J0D+CCE1+tytl6bdI=;
        b=dsO7q1m/OcLvm3H8K8bG1mJEcKqF43qp5+JOcAOkk3+OeCmydCtIfLadz6yED+EYK5
         nsFrZy/W4DtIU8DlEy0XEeA46OHR1h7JkaE0DbQmf2xUqT8vG/dKu3KC1P1XI5V7uzea
         vUdAGVFa1zPl4p/fyatTdRdz5hERlHLq9Nkw0+3ju8h/5gmj/c6c8N0d7bjKIqCGAfDs
         iJ7thffJW4scd38ziIMFVxNz2yhO4oDu7SPWZjlCx5OOrXzS2REkiVrZzjp67TqN1mA3
         tSchYN0MsRhzuZtK6EVbfT8h//cglVcdn/kKdDomGnSL7ZcD09k7tHN4I5dnrrr4PwBR
         A+8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWt50JZhXgJBFtH8lOgnc8GybfOOSksK4sv3+QQqY5HCtTjH9Ge
	AKLBO2mYd8oOlP3KfGEVxYfrGr0e5yrpEsiINMFP3XFrcvIxHMQDiJLne0kfFfymJAyp89LYvLL
	AADJUzHISs0UT77MYeSC1Hc9oC5P13DhCuJ2EUw4oHNna22faKhgz2VayfFKL3s8TJA==
X-Received: by 2002:a63:b48:: with SMTP id a8mr20913829pgl.368.1555985685112;
        Mon, 22 Apr 2019 19:14:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbd+AxQ/yuLXYqX28E70bFZ35MosqJoxmfj7FX+csxe14ufMY0EKMzbKF70GQoc9NeJ1UG
X-Received: by 2002:a63:b48:: with SMTP id a8mr20913709pgl.368.1555985682822;
        Mon, 22 Apr 2019 19:14:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555985682; cv=none;
        d=google.com; s=arc-20160816;
        b=gqVoIXn1FAz6JqM242cUjgx4x6ZHniefj5kkEA/qPMcZLTsgbpyeG2vCOS7Ho6ICfs
         Z/Luom3CQlHPuR/tbbvPQAC6hFop0T/9tCXF/D4V8303xY4fSicFlPzdHBwaOrICiun+
         0zeQqL+Cxiu2gkCvqab++ZsDSBqDe5ktr19VMPtdH4WEOwVzbcg5PwlRXtV2pPN9uRrD
         zU/J7ynbt3V6k5A3MtRpvUYp5pE2GhJrAp58CHJebDiem9fK2uAKxnr4Oc9a/BnL+Ks1
         HsL0gqYkiftsMeDuKQ8+fTHI8Vxhl839TvhzTxlw9peSrIhAm7RmPYc1+PaL6cL/ZuMR
         zb3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=lbk35pR5DXGh8DawLtOrlI+xz3J0D+CCE1+tytl6bdI=;
        b=oNEcy8z1sZyq6X2HA2d61JUuRwaWQ/ah+UfOh0Our6O+1CMRUdvMVebVeqH2OMY8zE
         JdFPNNHF9TRQGsgHFL4YNw2wJDTguzIVTzCc8ER/NB4Uj6bOvufpTU8Q9kycb8dYVzC3
         AwmRBqpc4YmsDRt3qE096hodzEOctctynL4yIrwCh0Yf688x6LJC69oP+KMyhwA0+R1W
         v6j30drZNXcdxYGln4q36ez4DrrLV7ON3SRjP8DbcNacbUy1QTqSm5mhRthozVgXKDDj
         coC6efejl15KsVd8OlpYDWJHthAdBrlWwYcf8rZPFX30D3ClCltkv8PhaurrKagZriIQ
         cMwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id w3si14859109plp.260.2019.04.22.19.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 19:14:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TQ03nrF_1555985678;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ03nrF_1555985678)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 10:14:39 +0800
Subject: Re: [RFC PATCH 0/5] NUMA Balancer Suite
To: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <CAHCio2gEw4xyuoiurvwzvEiU8eLas+5ZLhzmqm1V2CJqvt+cyA@mail.gmail.com>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <a1262b55-c6a1-d3a6-6715-61ebcfad9f9f@linux.alibaba.com>
Date: Tue, 23 Apr 2019 10:14:38 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAHCio2gEw4xyuoiurvwzvEiU8eLas+5ZLhzmqm1V2CJqvt+cyA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/4/22 下午10:34, 禹舟键 wrote:
> Hi, Michael
> I really want to know how could you fix the conflict between numa balancer and load balancer. Maybe you gained numa bonus by migrating some tasks to the node with most of the cache there, but, cpu load balance was break, so how to do it ?

The trick here is to allow migration when load balancing keep failing,
which means no better tasks to move.

However, since the idea here is cgroup workloads scheduling, it could be
hard to make sure load balanced, for example only two cgroup with different
workloads and putting them to different node.

Thus why we make this a module, rather than changing the kernel logical,
at this moment not every situation could gain benefit from numa balancer,
but in some situations, balanced load can't bring benefit while numa
balancer could.

Also we are improving the module to give it an overall sight, so it will
know whether the decision is breaking the load balance, but this introduced
big lock and more per cpu/node counters, we need more testing to know whether
this is really helpful.

Anyway, if you have any scenery may could gain benefit, please take a try
and let me know what's the problem is, we'll try to address them :-)

Regards,
Michael Wang

> 
> Thanks
> Wind
> 
> 
> 王贇 <yun.wang@linux.alibaba.com <mailto:yun.wang@linux.alibaba.com>> 于2019年4月22日周一 上午10:13写道：
> 
>     We have NUMA Balancing feature which always trying to move pages
>     of a task to the node it executed more, while still got issues:
> 
>     * page cache can't be handled
>     * no cgroup level balancing
> 
>     Suppose we have a box with 4 cpu, two cgroup A & B each running 4 tasks,
>     below scenery could be easily observed:
> 
>     NODE0                   |       NODE1
>                             |
>     CPU0            CPU1    |       CPU2            CPU3
>     task_A0         task_A1 |       task_A2         task_A3
>     task_B0         task_B1 |       task_B2         task_B3
> 
>     and usually with the equal memory consumption on each node, when tasks have
>     similar behavior.
> 
>     In this case numa balancing try to move pages of task_A0,1 & task_B0,1 to node 0,
>     pages of task_A2,3 & task_B2,3 to node 1, but page cache will be located randomly,
>     depends on the first read/write CPU location.
> 
>     Let's suppose another scenery:
> 
>     NODE0                   |       NODE1
>                             |
>     CPU0            CPU1    |       CPU2            CPU3
>     task_A0         task_A1 |       task_B0         task_B1
>     task_A2         task_A3 |       task_B2         task_B3
> 
>     By switching the cpu & memory resources of task_A0,1 and task_B0,1, now workloads
>     of cgroup A all on node 0, and cgroup B all on node 1, resource consumption are same
>     but related tasks could share a closer cpu cache, while cache still randomly located.
> 
>     Now what if the workloads generate lot's of page cache, and most of the memory
>     accessing are page cache writing?
> 
>     A page cache generated by task_A0 on NODE1 won't follow it to NODE0, but if task_A0
>     was already on NODE0 before it read/write files, caches will be there, so how to
>     make sure this happen?
> 
>     Usually we could solve this problem by binding workloads on a single node, if the
>     cgroup A was binding to CPU0,1, then all the caches it generated will be on NODE0,
>     the numa bonus will be maximum.
> 
>     However, this require a very well administration on specified workloads, suppose in our
>     cases if A & B are with a changing CPU requirement from 0% to 400%, then binding to a
>     single node would be a bad idea.
> 
>     So what we need is a way to detect memory topology on cgroup level, and try to migrate
>     cpu/mem resources to the node with most of the caches there, as long as the resource
>     is plenty on that node.
> 
>     This patch set introduced:
>       * advanced per-cgroup numa statistic
>       * numa preferred node feature
>       * Numa Balancer module
> 
>     Which helps to achieve an easy and flexible numa resource assignment, to gain numa bonus
>     as much as possible.
> 
>     Michael Wang (5):
>       numa: introduce per-cgroup numa balancing locality statistic
>       numa: append per-node execution info in memory.numa_stat
>       numa: introduce per-cgroup preferred numa node
>       numa: introduce numa balancer infrastructure
>       numa: numa balancer
> 
>      drivers/Makefile             |   1 +
>      drivers/numa/Makefile        |   1 +
>      drivers/numa/numa_balancer.c | 715 +++++++++++++++++++++++++++++++++++++++++++
>      include/linux/memcontrol.h   |  99 ++++++
>      include/linux/sched.h        |   9 +-
>      kernel/sched/debug.c         |   8 +
>      kernel/sched/fair.c          |  41 +++
>      mm/huge_memory.c             |   7 +-
>      mm/memcontrol.c              | 246 +++++++++++++++
>      mm/memory.c                  |   9 +-
>      mm/mempolicy.c               |   4 +
>      11 files changed, 1133 insertions(+), 7 deletions(-)
>      create mode 100644 drivers/numa/Makefile
>      create mode 100644 drivers/numa/numa_balancer.c
> 
>     -- 
>     2.14.4.44.g2045bb6
> 

