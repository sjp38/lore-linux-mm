Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97026C282E3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:10:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC84B2087B
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:10:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC84B2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DE2F6B0003; Sun, 21 Apr 2019 22:10:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38DC86B0006; Sun, 21 Apr 2019 22:10:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27DC66B0007; Sun, 21 Apr 2019 22:10:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E593F6B0003
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 22:10:15 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n5so7102336pgk.9
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 19:10:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=2q443B0eOWyL/uLnvbH3BRqdzuFql2rjMMi/K1LHZUk=;
        b=l7y/v27MeqjE4P/bNba2qwVswz9x3W21s4Zn3+dIMZuOOQpVDLfSK99q92/AwRm/ed
         fGQQ4NZEp7wb/Tuumd3G6vpXbPoOcHJH/frLHfJkGr7pZW8b2Vz2XlYJw2tidV9NIj8v
         Ckta9cKUWvu+EqjeOjYbQEFS5JM+FRyWbEo5pBuzp2/6Zk9r1xHTmuWh3apZVfKVAvT8
         e964Dx4drVS4ZCJePRBHxzR4O5dMNt7p3UpIM+Qzou7JCG/ThyNYDuNJmHTqJVxoto2k
         THc4THn/90hzFdx4Yu9lQQvInYoJa3Z13uPSPpwM+9LYtXtvAYglP6G9bAyg1Pwc0JXD
         OKWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU3TVoB4nQWpaLhNOy+gzCjo2JhnHqM0Qz248g5zto7CjCfyvz/
	DN+pJEJAgZRqZtH6daoWqvriKb/KCDLQN7bhxPmiuGRYTmd0pXQh7ehUWVlg1Lf7n5mhJT9j6Z3
	b1ewzzC1WR1Uq+epolouRLg4v5NwPXO2s83QaL8ijcq+FAVdBfkd0R4/Dqq+SKiRvFw==
X-Received: by 2002:a65:63d7:: with SMTP id n23mr16767736pgv.26.1555899015431;
        Sun, 21 Apr 2019 19:10:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWhVNZ07bHb4Sct6zqRdTO8iJ3y7QL1tJX/WFZM+iMoSQXpM51aFboQ6YMRYaVWlyftkG5
X-Received: by 2002:a65:63d7:: with SMTP id n23mr16767655pgv.26.1555899013958;
        Sun, 21 Apr 2019 19:10:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555899013; cv=none;
        d=google.com; s=arc-20160816;
        b=XHWK94izikqIlufCLrfgwNebXeiyl0YJLAzxeRmUAJPq6pB+XNAnEievDKChz5+L6Q
         lHCTLD4YAoFtWqjCpIgqcvjaK34blaF6LfgEXRUBfyeXibjo7dsdY7tscVJvmchmnMjA
         nrz8399Mi63ZxSx3bag3Ey53y19ppS7LLfNe2I/Z+3pIwoOFf1Sh9f7O2+bUZmrZ11YA
         e9Q1gQbFv1SSSVNxCuUjDRJJFryzDr1Vugz4W05SLpEeRJwGTXrklhimFmzYsBGm52Nr
         t3KdcSpFFqvNfkhJx4UqZVwIbKJnGZA+uId8N7ai9G3TR9Yz836SwgHfTq0+OlNBU5JR
         HTLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to;
        bh=2q443B0eOWyL/uLnvbH3BRqdzuFql2rjMMi/K1LHZUk=;
        b=muyTbjkzuuqj2i7d77ymbd3y+dCHqYeXVrmkpqVNxqcscsBje6HAq0u4Pk62KBQVtv
         u0FPi+7gu3OYsjEts3S1RXA2N48RFHs//TiMr4+TUve09t93z8mJGY5OtNS4KZDsG3qg
         mvFu5QApjVjVQX42XlOP9AUF4UOW+uyqfXmY79MJs0s6Ra6gTu2h2PGDxLdaPXl2CNkS
         lgpA3QdeB4QxFFjf/zKv2QzRrCtFK+XZRF1nqTx4SBVrCnQXYqcGeTNZsMjAOo/L9oX+
         NoD/mlEpQy1MldCNdHmU3FFB8PZPvPtRBHI1ptBBarkcJBli49uo8rFuJ6QOcNRcI8VN
         wsYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id b5si10742200pgw.359.2019.04.21.19.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Apr 2019 19:10:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TPtsupF_1555899010;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TPtsupF_1555899010)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 22 Apr 2019 10:10:10 +0800
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Subject: [RFC PATCH 0/5] NUMA Balancer Suite
Message-ID: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Date: Mon, 22 Apr 2019 10:10:10 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We have NUMA Balancing feature which always trying to move pages
of a task to the node it executed more, while still got issues:

* page cache can't be handled
* no cgroup level balancing

Suppose we have a box with 4 cpu, two cgroup A & B each running 4 tasks,
below scenery could be easily observed:

NODE0			|	NODE1
			|
CPU0		CPU1	|	CPU2		CPU3
task_A0		task_A1	|	task_A2		task_A3
task_B0		task_B1	|	task_B2		task_B3

and usually with the equal memory consumption on each node, when tasks have
similar behavior.

In this case numa balancing try to move pages of task_A0,1 & task_B0,1 to node 0,
pages of task_A2,3 & task_B2,3 to node 1, but page cache will be located randomly,
depends on the first read/write CPU location.

Let's suppose another scenery:

NODE0			|	NODE1
			|
CPU0		CPU1	|	CPU2		CPU3
task_A0		task_A1	|	task_B0		task_B1
task_A2		task_A3	|	task_B2		task_B3

By switching the cpu & memory resources of task_A0,1 and task_B0,1, now workloads
of cgroup A all on node 0, and cgroup B all on node 1, resource consumption are same
but related tasks could share a closer cpu cache, while cache still randomly located.

Now what if the workloads generate lot's of page cache, and most of the memory
accessing are page cache writing?

A page cache generated by task_A0 on NODE1 won't follow it to NODE0, but if task_A0
was already on NODE0 before it read/write files, caches will be there, so how to
make sure this happen?

Usually we could solve this problem by binding workloads on a single node, if the
cgroup A was binding to CPU0,1, then all the caches it generated will be on NODE0,
the numa bonus will be maximum.

However, this require a very well administration on specified workloads, suppose in our
cases if A & B are with a changing CPU requirement from 0% to 400%, then binding to a
single node would be a bad idea.

So what we need is a way to detect memory topology on cgroup level, and try to migrate
cpu/mem resources to the node with most of the caches there, as long as the resource
is plenty on that node.

This patch set introduced:
  * advanced per-cgroup numa statistic
  * numa preferred node feature
  * Numa Balancer module

Which helps to achieve an easy and flexible numa resource assignment, to gain numa bonus
as much as possible.

Michael Wang (5):
  numa: introduce per-cgroup numa balancing locality statistic
  numa: append per-node execution info in memory.numa_stat
  numa: introduce per-cgroup preferred numa node
  numa: introduce numa balancer infrastructure
  numa: numa balancer

 drivers/Makefile             |   1 +
 drivers/numa/Makefile        |   1 +
 drivers/numa/numa_balancer.c | 715 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/memcontrol.h   |  99 ++++++
 include/linux/sched.h        |   9 +-
 kernel/sched/debug.c         |   8 +
 kernel/sched/fair.c          |  41 +++
 mm/huge_memory.c             |   7 +-
 mm/memcontrol.c              | 246 +++++++++++++++
 mm/memory.c                  |   9 +-
 mm/mempolicy.c               |   4 +
 11 files changed, 1133 insertions(+), 7 deletions(-)
 create mode 100644 drivers/numa/Makefile
 create mode 100644 drivers/numa/numa_balancer.c

-- 
2.14.4.44.g2045bb6

