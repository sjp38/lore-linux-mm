Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 833A2C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4077B2147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:33:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4077B2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB8416B0005; Mon,  5 Aug 2019 21:33:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C414E6B0008; Mon,  5 Aug 2019 21:33:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B08C66B000A; Mon,  5 Aug 2019 21:33:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 751DF6B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:33:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so54713643pfw.16
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:33:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=Jgunc0VzKPPT337tIgA99pIQxve5Qfra/3N36KHQ8iw=;
        b=qV0ZaUNF5jv2Nl89RsfW2EMsbEhqSrFQCHR4YmWrGs509aYQCnHfyJZsUo21eElX6k
         mzBWrBl12IE5UzrLRW+I1qIHzIpKT/93FDm1mCHuArXbElP9uM54QH43k952WKGjAaa/
         HjlWFL5o6P+DbMccEn7ez8j+jUnNgLOXjmq1PGLtZXb255pe5QcNjB3VbafsYF3tfWi7
         IRKrbQBsIX/8WRNWSe4XgH3v3ICxY9xDhYrWfvexuW2AO06Wh7utzsyxYyVmFje2+N5i
         n5f2pqGzieb9Ym7zLXhTeJoDTRxkMRsO3PslgM4oQQy6Rd/N0xUnQWmxF8cxjon65szb
         hT/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWyA6c7r8raXK9BfsPTBRGzmB6ihnubF2TL+JM+tGY2/zttSsNc
	MOVQthuBcrBidNZUxBwMT2egnWfERuqMEqhQG3UaN2NJrByT6TMyV7CHbZXR6EXUiv0c29uOXnT
	SqdA9sESCg0KojnRUE89zA4++RmqlZPLK6HRB2kFQ7roPDg4k+NooMLXzmk2puiCUMw==
X-Received: by 2002:a17:902:3081:: with SMTP id v1mr606802plb.169.1565055224128;
        Mon, 05 Aug 2019 18:33:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxXXKGC/jZYG8HcrW4jwWZIz7IFSwVQU3N7afDYyEVCn6RMN/SPkXp2Vk2I/iH/Sk6Xnxh
X-Received: by 2002:a17:902:3081:: with SMTP id v1mr606752plb.169.1565055223100;
        Mon, 05 Aug 2019 18:33:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565055223; cv=none;
        d=google.com; s=arc-20160816;
        b=tR4ttxa7xUj8DdAzLIEPGVRbKoB+dphyDTUPeBCnNIj3oZTyEwF62xCPbr6B5Ugq95
         esnGqK/AxAO1Y1ajznD3CyOgEQegkHlq/g5DoO4YHSP/C/GP2yVEV+sFOXjCl7Mmeq5r
         NNEionI1eBoTwp/ehiFvRULQ2RqSp76hDMlb8W6fo3dSlCLAslK+46QVXh6EcTc6npxB
         ArmWd+19euNu5mB27o1ERHkMdVdX6g6nxx9ibGcTctGhWPiTlBWXtNU3giiFqUStIhHS
         Q89gNJT0svK3rvgz2G+1jw4pkBH7YwkiqBKPoLew/9vw1VAMzXMrdWnAu/U+lYMCDUAW
         sezA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=Jgunc0VzKPPT337tIgA99pIQxve5Qfra/3N36KHQ8iw=;
        b=q+93Ob4VLKCEFxZXkjCGNAi/awhsl85pV+6wpggUi9oJHjf4hgKYXrTkX8J83lvni1
         g3XjFIK4kvnoKAjDs3/s1h8Xrz4nHsGEFYzXUoHQHJT1j8zQze7ttbU6TEF7vh+jxV2e
         0EBwPFuTmy9PmTVqBJs48+rqJghwr1ACIVpbteBtaiVh4bnOApcvSf/Vh04csHuIgR3/
         8/L3HUJWQPrkIqHJbqm82RT+jHwBUTEXvstOpQO23s7ZESekhxBGYyje/HZ7CbFATxna
         OtpIi6Fv2EkjmCPamF2td0TJ2GmBELIkxz2T7BTfic/AbbZkrwdWmd14ukKxCXPysSpo
         f/NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id n9si41369851plk.166.2019.08.05.18.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 18:33:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R641e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TYmOEx4_1565055217;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TYmOEx4_1565055217)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 06 Aug 2019 09:33:40 +0800
Subject: Re: [PATCH v2 0/4] per-cgroup numa suite
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
 Hillf Danton <hdanton@sina.com>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
Message-ID: <789b95a2-6a92-eb30-85c5-af8e5dcc8048@linux.alibaba.com>
Date: Tue, 6 Aug 2019 09:33:37 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Folks

Please feel free to comment if you got any concerns :-)

Hi, Peter

How do you think about this version?

Please let us know if it's still not good enough to be accepted :-)

Regards,
Michael Wang

On 2019/7/16 上午11:38, 王贇 wrote:
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
> Since v1:
>   * move statistics from memory cgroup into cpu group
>   * statistics now accounting in hierarchical way
>   * locality now accounted into 8 regions equally
>   * numa cling no longer override select_idle_sibling, instead we
>     prevent numa swap migration with tasks cling to dst-node, also
>     prevent wake affine to drag tasks away which already cling to
>     prev-cpu
>   * other refine on comments and names
> 
> Michael Wang (4):
>   v2 numa: introduce per-cgroup numa balancing locality statistic
>   v2 numa: append per-node execution time in cpu.numa_stat
>   v2 numa: introduce numa group per task group
>   v4 numa: introduce numa cling feature
> 
>  include/linux/sched.h        |   8 +-
>  include/linux/sched/sysctl.h |   3 +
>  kernel/sched/core.c          |  85 ++++++++
>  kernel/sched/debug.c         |   7 +
>  kernel/sched/fair.c          | 510 ++++++++++++++++++++++++++++++++++++++++++-
>  kernel/sched/sched.h         |  41 ++++
>  kernel/sysctl.c              |   9 +
>  7 files changed, 651 insertions(+), 12 deletions(-)
> 

