Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AE44C76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:33:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D44521734
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:33:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D44521734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAE318E0024; Wed, 24 Jul 2019 22:33:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A600C8E001C; Wed, 24 Jul 2019 22:33:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 974498E0024; Wed, 24 Jul 2019 22:33:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3F98E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:33:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so25338931pld.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:33:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=XwLqp8Z3M5R9sJyY1dCHjhkB3k3wy7et1I50y6Zfs+0=;
        b=A6kgOk3QkpPIgOlaClUocgaNpmpEyXEODEncBABFrQCYYj3VxGF4YIRbN3DgfnFOC1
         YwDNQueDB9mD/18I0fVzxIV1ZtACLxoxGxFQh+D6Vs+32a4qqSKaWmHS6XN7L2ltKVbB
         AGhozGYYoxOC9qhTHiPSvl+QSz05OvqfzBr7WLhoc56RsZ6FmdAa9/vlgcoyd2cHHe6E
         DKal0+xsDn4/L92GsmCRvm8UBTKsWvUE3gDkB+deEetzFQcYUSuQhdClLIxLbj9fAGyy
         x9aXjQfnCZBbcyHQIvTrQB1+WQYF5GGH86UmPYq5LQ79vRLP6dqNcq2GU9OwqEyQFM7D
         OM4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW7DeSEv6SvvxLhs9PHjziCYuFuvz+8KIgQfe05LdHA5ZQrDwMj
	77d6bZbOuHuFarZTczMxhwKVuPXXzbKQzeJPLCO4uDemlXSGy7C5uGDyxaOI6LT8ZcsmwHjQrnP
	DZxdK1DkbZKkxjshtWS72o31fORZb0TyKTvsVX2gYI7oF2fzcIIzTTQNdJVKudRSLGQ==
X-Received: by 2002:a17:90a:a407:: with SMTP id y7mr90609079pjp.97.1564021997986;
        Wed, 24 Jul 2019 19:33:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw36Kbn4QxuBDDAuySKYtu5uQaGXe8pmu3R3GDBHXSbInjZ4AxW7WgxlDfTpP8LVVONARBo
X-Received: by 2002:a17:90a:a407:: with SMTP id y7mr90609056pjp.97.1564021997239;
        Wed, 24 Jul 2019 19:33:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564021997; cv=none;
        d=google.com; s=arc-20160816;
        b=wwD1m3NfLz+jtx8iyCzvBpUbpuxpAekO/JiwhuiNAawbak9NPE3kxWW2Gc8JvM4hvq
         0+DZP11Fn3XjZLRYr2/xXOmeJSy0m9n/+SBuqqoaW18TpwbqBq0GaxVh+bAcxleX9WPO
         1m3BsfvmTJrcrDvSkMq7tB9gn9qgjdELSxMAkU9aKun6Vwox1pTebxIKdvJEz9NseKXS
         uVWEXq65GvChgI3ATVaskG7ao4XStml3d0znqPYVpiJ3asICa3djJGfcVUqsjmebH+8a
         U+iE98VWv+SEVCOcn12U1AiDI/blfQMfdUAcpPex8sHt4ZYJBbtJmTF7WOXP66Qws+Pn
         o/mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=XwLqp8Z3M5R9sJyY1dCHjhkB3k3wy7et1I50y6Zfs+0=;
        b=e7LyV8Rpf05m7rucs68f8Hrtr4YhP1VH2fhPNlTzVtfONwyxrlP8n1GFIOEg0jbUqq
         hZbOwERgHjxHysIdKN1K82711FXwZZUuVakZk6a3rKaWnZb18SG77RzPbMIZ5XuToxoH
         CWrBN0+4TwgnvBv+Qv3oD0Uam/LzVNBjb1IB1QJTlZZtouoKNEl1+KOKNGUaIfZx0J/n
         zJ7JMt7mN14sgskvAI1tJ6EiiS1razIK6EYs50oDI45JwFmX3hr3uQQHNzMjVEuDAVXW
         xeaibgI5Mhax8wkSktTyDSIbD+/oBVvpgv2JdyaBm/gkIv1HyeQ/93/7OQxg8BTGNaTQ
         29gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id u10si17535495pgj.588.2019.07.24.19.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:33:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TXkJoVQ_1564021990;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TXkJoVQ_1564021990)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 25 Jul 2019 10:33:11 +0800
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
Message-ID: <2203b828-1458-5fec-f4f6-353f51091e2a@linux.alibaba.com>
Date: Thu, 25 Jul 2019 10:33:10 +0800
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

Hi, Peter

Now we have all these stuff in cpu cgroup, with the new statistic
folks should be able to estimate their per-cgroup workloads on
numa platform, and numa group + cling would help to address the
issue when their workloads can't be settled on one node.

How do you think about this version :-)

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

