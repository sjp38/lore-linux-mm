Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01E53C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:26:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97A7821721
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:26:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97A7821721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E11E76B0003; Tue,  2 Jul 2019 23:26:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9B098E0003; Tue,  2 Jul 2019 23:26:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C88448E0001; Tue,  2 Jul 2019 23:26:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4D26B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 23:26:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b18so718128pgg.8
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 20:26:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=FXTHuE8n8Fdbb10Mu4GwGw31C/u8ypoVa/YghvrmjrY=;
        b=ToPQAQ631m1HBz65U2bBmG+gJvriCdDCEXFapSrl9RwBC+VHtGvGvjKOpNiloqptgp
         ImCcz+PiTjV8OJM+zioiUj+gyt9B7QUp3HRN2TV2MWzUAIdMS4epwz1FQ+UYFW0dGU0V
         aiGONriJsNnpBJw82yMUYm0OGluOtGltwIcKQ76pdwJifvCjb5FNPI3rPeZ0EmqHKQgE
         cnll25cerUHClb/g8e+dNkhSeK2AVuy/uhSPAC5kpD6Ow1djY3n9CHUobZl7pVdSLFt5
         yndKGGYtxN8uCErcR4u+IeoVS24zRykU5PcFH9H4xw/7CPICO6Ea6OHU85DOQS01o8f/
         cjxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU8gceo8VKqlvBB+yiGPLgYKPyTj6tu7nkZ9phg4HCRcjL/6Cfl
	N3xy5uYM4R6+eGGjZzAZuI71P1V6wsd+pUhnEWZos6V5OPCMkhcPfsdShtxZiXBDO7jAQdU9WRZ
	inG9INpOJDqWPVos0F0vFDHFr2Q/sLrrxwJ0oTqq7LZFlVM5ck3Ev8qtOJY7RiNtKBg==
X-Received: by 2002:a65:6694:: with SMTP id b20mr4398720pgw.155.1562124398190;
        Tue, 02 Jul 2019 20:26:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2jim/pzyJ9nozLVqnn8Can2ZNNTaTIz19v+zKRCP6l7Lq3PTIDe0dzbCIwXY6pnu7PT3h
X-Received: by 2002:a65:6694:: with SMTP id b20mr4398656pgw.155.1562124397360;
        Tue, 02 Jul 2019 20:26:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562124397; cv=none;
        d=google.com; s=arc-20160816;
        b=Yo4SHtgVIbUkMV/tdm3o+0XRRiq2cFX6Dbac6i+DenR5oxYze2o89/OV5DmIV09xX8
         YG+G6sd/7/pR1NzlRzVVv06Dn2+mUK+3xglvph3u5xpp03F1sx+W2uaz9L+zj+ftiJyP
         K04vgMGDefPg8QT0ThmTzw9qE0EOLtfe4U7T86fLKv6Y+stx0L5yU0j2z97eS63KtuY4
         OeZFre75RxAAcr/ViRhHWZNvzYxhq2ElMorWTW+1jR5vPHcdlZbXP1NMdlQ/9thYLoRl
         1GDSMEA0N4rN/Ct8302yzPZzYQvVCQYWogN5Ua/sES5/+MpuM3Rt7hIcs8nunI2uHIKZ
         m5CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=FXTHuE8n8Fdbb10Mu4GwGw31C/u8ypoVa/YghvrmjrY=;
        b=YgcnQGpQXHaV4IoYaC0KD979CypFXD8JgaGV4Ljoy1/dHJUb27BT7IUibW70conbYx
         hTKw64PeJ8EDQFF5VHNcX9kKtyMG0ye1I+B5ihRnb3eBv7E9Hw/gBM0JKi5fgQoJCbxJ
         ziEtRvh6r0HDielVQahbJurYmn7AwCaxziEjC44nTkWC9ns1StB8W0aarHLGrfTeFXCr
         sqLJlTEQ0Rsty98B7qUdzYN1vQDs+lQYJbrYfMeOEZ7gkttrAdhw4nCLf/lVVr4rVNgQ
         Wb4VVYrfZBl7w0rHr3L7v8KKO3AwzE4oZ5YCX1/iWLLUurNZZ/3MfZzIex5trIlthbat
         p8pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id m127si816722pgm.594.2019.07.02.20.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 20:26:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R451e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVvT.Sc_1562124377;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TVvT.Sc_1562124377)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 03 Jul 2019 11:26:33 +0800
Subject: [PATCH 0/4] per cpu cgroup numa suite
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Message-ID: <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Date: Wed, 3 Jul 2019 11:26:17 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

During our torturing on numa stuff, we found problems like:

  * missing per-cgroup information about the per-node execution status
  * missing per-cgroup information about the numa locality

That is when we have a cpu cgroup running with bunch of tasks, no good
way to tell how it's tasks are dealing with numa.

The first two patches are trying to complete the missing pieces, but
more problems appeared after monitoring these status:

  * tasks not always running on the preferred numa node
  * tasks from same cgroup running on different nodes

The task numa group handler will always check if tasks are sharing pages
and try to pack them into a single numa group, so they will have chance to
settle down on the same node, but this failed in some cases:

  * workloads share page caches rather than share mappings
  * workloads got too many wakeup across nodes

Since page caches are not traced by numa balancing, there are no way to
realize such kind of relationship, and when there are too many wakeup,
task will be drag from the preferred node and then migrate back by numa
balancing, repeatedly.

Here the third patch try to address the first issue, we could now give hint
to kernel about the relationship of tasks, and pack them into single numa
group.

And the forth patch introduced numa cling, which try to address the wakup
issue, now we try to make task stay on the preferred node on wakeup in fast
path, in order to address the unbalancing risk, we monitoring the numa
migration failure ratio, and pause numa cling when it reach the specified
degree.

Michael Wang (4):
  numa: introduce per-cgroup numa balancing locality statistic
  numa: append per-node execution info in memory.numa_stat
  numa: introduce numa group per task group
  numa: introduce numa cling feature

 include/linux/memcontrol.h   |  37 ++++
 include/linux/sched.h        |   8 +-
 include/linux/sched/sysctl.h |   3 +
 kernel/sched/core.c          |  37 ++++
 kernel/sched/debug.c         |   7 +
 kernel/sched/fair.c          | 455 ++++++++++++++++++++++++++++++++++++++++++-
 kernel/sched/sched.h         |  14 ++
 kernel/sysctl.c              |   9 +
 mm/memcontrol.c              |  66 +++++++
 9 files changed, 628 insertions(+), 8 deletions(-)

-- 
2.14.4.44.g2045bb6

