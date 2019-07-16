Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1457CC76191
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:38:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C51AC2080A
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:38:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C51AC2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 657A26B0006; Mon, 15 Jul 2019 23:38:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 607AF6B0008; Mon, 15 Jul 2019 23:38:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 544946B000A; Mon, 15 Jul 2019 23:38:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFFF6B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 23:38:52 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 71so9435630pld.1
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 20:38:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=4XZ4kZiD1bnzc5b4F0vzeHtZeHLCPA8a+pxHJcUamzk=;
        b=XyABGGgPAFCJexr1ChjeLOYbxg4lZY4QykUtV5Yej4kFBCN+kMfgx291ltVIky2BJq
         G1d3NPTJWZZxOUzYF3Aq9/qE/jCXqQrjXQLvkwz6hhE7EfJu6Z51500Q1P84JiIz7b5e
         OkC6aWiU9f/lIC24rc508BywyifhrETxn6fyu6hAjq0JIef9/3NSMehjsljFxjLyJ3B5
         QmSO9BuojYv5wyA0qbNONZLX4nYzdGV55naXMKp4VCbUlYSGtrJAzpBYzyBzvN43uOdC
         QU/FNAbg/Gq3uZKd8uuQaLQWAWqtFLk3pRt2BqLyBlutuYaZc8wbNJcR+I2cy3iYFXJA
         xYQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVLlXVK3QOEec75LqUXNJAfMAa2pYB5zb4vvN2bbin+mw0Bts4H
	aCv8GC5YOnzjgOjQQYY2rCSMA2WWGsNLA09Qi3AhftxYS6NcWzGTT4hihhS9HFxxCH2fL9Qwjp6
	VxS9ChWDv4Hn1ZTEFzStThAEJBz8c0so0JIKS+sa9uOtWsBDtYWX5ffg9k1zr4V5yoQ==
X-Received: by 2002:a17:90a:9903:: with SMTP id b3mr33094557pjp.80.1563248331774;
        Mon, 15 Jul 2019 20:38:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNs8MVCECdLRJwC+PnvC4cNwG8NaZgzVFaJbkHYm03qz4x/ua4v2viojKdVHpjJnfUMNQp
X-Received: by 2002:a17:90a:9903:: with SMTP id b3mr33094495pjp.80.1563248331004;
        Mon, 15 Jul 2019 20:38:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563248331; cv=none;
        d=google.com; s=arc-20160816;
        b=f6xWlzpKVRYYp/UnMv+1R8ubxDQ/Gdz08OKeWhYIKhlxcHBr6/CvLWk/FUQ+0rCGmM
         sDJFJcG0qyF08cPO0r1MLmXzg3TYKntjau1KxlG+UrDLQZe8zm/IpEamkju14gEjsprB
         Gn/6U8iXRqhjao9Y8mIBvPmDE2Gww7RStWHpi34BawvzbwF3LVYicFu0rAVjqxfJSfDO
         zsKZAEqwfMcO73ISALJG4BhU4M4iCXnT8DT1r/iVuyoDvynOGLE2cJ9GTTvR9O/cGW0g
         PRoLB53DPQs5N9Avi7Okl5KBFbyY7G/IT93mVE5oqBHqLtiEuniSoFWH7DYgT4T4ftJB
         Bjig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=4XZ4kZiD1bnzc5b4F0vzeHtZeHLCPA8a+pxHJcUamzk=;
        b=HFxp6z+AOMLXpsDtVvMXlP8W2ZV85sPcqSy0cFQN01aKoT/DEWXbkTHhmxYW8fsiSo
         pyLE5GqMj8MTDBXKxPhOkxzzTrOjWQheLP3x6bnk0rGQMCRIx/5UhXKkYNRTiC/yqJ9q
         6YkIjUT6n7JakuvkbhYAeyn3C5vubsdHpESAWqc/TUvZ9DUHdGPRdfg4+WTtDolZKyo4
         oNgNQES/N8Ea8rcv9gKXxpJ8t83pcZZMwzrwsKsq+hZ7oK0vV/6vVxmohxLNeldPFAFm
         qGKTPFc2Fp8FDujXaqFsyFRXjMcE7PL7TSZ/bx6u9N9dElpSswQUGx9oi1gbyoHJTb04
         Dnow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id i127si18386608pfc.177.2019.07.15.20.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 20:38:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R461e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TX1ZLm-_1563248327;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TX1ZLm-_1563248327)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 11:38:47 +0800
Subject: [PATCH v2 0/4] per-cgroup numa suite
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
 Hillf Danton <hdanton@sina.com>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Message-ID: <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
Date: Tue, 16 Jul 2019 11:38:47 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
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

Since v1:
  * move statistics from memory cgroup into cpu group
  * statistics now accounting in hierarchical way
  * locality now accounted into 8 regions equally
  * numa cling no longer override select_idle_sibling, instead we
    prevent numa swap migration with tasks cling to dst-node, also
    prevent wake affine to drag tasks away which already cling to
    prev-cpu
  * other refine on comments and names

Michael Wang (4):
  v2 numa: introduce per-cgroup numa balancing locality statistic
  v2 numa: append per-node execution time in cpu.numa_stat
  v2 numa: introduce numa group per task group
  v4 numa: introduce numa cling feature

 include/linux/sched.h        |   8 +-
 include/linux/sched/sysctl.h |   3 +
 kernel/sched/core.c          |  85 ++++++++
 kernel/sched/debug.c         |   7 +
 kernel/sched/fair.c          | 510 ++++++++++++++++++++++++++++++++++++++++++-
 kernel/sched/sched.h         |  41 ++++
 kernel/sysctl.c              |   9 +
 7 files changed, 651 insertions(+), 12 deletions(-)

-- 
2.14.4.44.g2045bb6

