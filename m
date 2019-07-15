Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAB2AC73C66
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 02:09:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DCFB20868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 02:09:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DCFB20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BE9E6B0003; Sun, 14 Jul 2019 22:09:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96F9A6B0006; Sun, 14 Jul 2019 22:09:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 885976B0007; Sun, 14 Jul 2019 22:09:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50A616B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 22:09:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so7651326plj.19
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:09:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=gU1TeLTfZpNx4P4FC5hk6hna9nzDElLZqUWIzjJCMGc=;
        b=Vbg6mddMwQiLPs+Z/oWiLUv0P3LxhuNvX9n5fCEDugSea1ek6n/rKW06VIl9RwfpP2
         BUAs7kvTtXJlxPSTNTxuzRZxkFOUa/JKVz4Eit+tcLbbcqaZ0XsU/c/5FfecZr9g7KYm
         mDYGO7Mqn0D8nw9v3crCySB1lKGg+baoccmA0tbKlf1L6bbfoHNMksnjlw6dqzcI7AoY
         8Lr538xPy8zGX4bS2GVNbMBEDiYDHzAGGhtdKELC8hQJMoH4939y6MuALA0e3eEpuoLU
         gItrNqnN95eMaR+rquGCfFE3sUn40iJbnVUGxfGO6YRM9fOVztxMIf/uvGPfeEaW8CDu
         MS9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVijKOKEGm6DyGlEHykt0E/O5ue8ulU1OczYVw5uEdjH2Jx/VRv
	HiWYW2TGKpxMEanatCbf1XzPMY+/hDrMtHcGK1PM11yk9Hw+8OIScJD639+vsj8grUEbY8ktlRj
	6kc75OgQISQEr+JRdByLlpfdhF1A/aRkUm8FDS/qmIHTOtulqoRyGxGyy+a9hMUENIQ==
X-Received: by 2002:a17:902:4c:: with SMTP id 70mr25533598pla.308.1563156581873;
        Sun, 14 Jul 2019 19:09:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz84qfR6TmunDWM9q+ULk1ZT5sZrPGkSrJTXBL2uii1zEJvmkysLx3FGtInfvHQKJ61ulIq
X-Received: by 2002:a17:902:4c:: with SMTP id 70mr25533546pla.308.1563156581064;
        Sun, 14 Jul 2019 19:09:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563156581; cv=none;
        d=google.com; s=arc-20160816;
        b=BlZgW+iQqMBpafgEtnSp322nAs5nq9lgBPYUm5fUzsvdskAS4LNYS1iJ8+MkTiavQL
         /FNWa2bSnTSSfu2zHid+T35mB1SyO/9Hr5sED0NuVgzCqMKizQmvfvma6eqylqaIhRxR
         PwIIfhKqSlC2IdQx/cyFPoO4ZihyTu5pFTw7PwN4D6gAR3QqisTFzPkZqxUUa69IAEUk
         EN7ok3zHXr7GC0Ko+4b8HFv6EYKrWqpcBFalqA8VvU2VN7o5fO7TJjpvnAkD18wSqWpz
         QkvoTJX2FaeVqrn3nUjEgX2NeQ7WWAZNj2F7wteS4X+TxVjCeDCEWufMJf4qefEHT+R9
         9Yqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=gU1TeLTfZpNx4P4FC5hk6hna9nzDElLZqUWIzjJCMGc=;
        b=LdtmsUt2MTmOmDaJ2/UyF0yuAS/VW3JKCYZ9usz4KIuBED9aTKMrKkuV1MWTKNNj5t
         qh/jynKhYXEM1rSOP//BP2OryRmOCfTZe6B81Y371z2cAgfIh3xrEY20zSRAG/fWe1Fs
         gu0PG/9o6gO5asZe6hXDuwuRY0B2XIqX1iUU0ZSR9Nb4SThzARJ3hMjlJd90ADJwCp+X
         gALD9efUdSgSpJLtBDWVg6/wnM+5m7+WjJHAbFhl6Z0vRwa+yMZtTVAA9hDSOQO13HvG
         AblHzWmfxVkdmXzV4aqrwCCLaikTrWrV+IOAIzS1DAAR+JYBg9x9QQwXoR1S8enXOjRU
         LYbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id c1si16144184pfc.80.2019.07.14.19.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 19:09:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R791e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWte0iC_1563156576;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWte0iC_1563156576)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 15 Jul 2019 10:09:37 +0800
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
 <20190712075815.GN3402@hirez.programming.kicks-ass.net>
 <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
 <20190712094214.GR3402@hirez.programming.kicks-ass.net>
 <f8020f92-045e-d515-360b-faf9a149ab80@linux.alibaba.com>
Message-ID: <673993cf-c5cc-475d-1396-991edcf367ea@linux.alibaba.com>
Date: Mon, 15 Jul 2019 10:09:36 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <f8020f92-045e-d515-360b-faf9a149ab80@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/12 下午6:10, 王贇 wrote:
[snip]
>>
>> Documentation/cgroup-v1/cpusets.txt
>>
>> Look for mems_allowed.
> 
> This is the attribute belong to cpuset cgroup isn't it?
> 
> Forgive me but I have no idea on how to combined this
> with memory cgroup's locality hierarchical update...
> parent memory cgroup do not have influence on mems_allowed
> to it's children, correct?
> 
> What about we just account the locality status of child
> memory group into it's ancestors?

We have rethink about this, and found no strong reason to stay
with memory cgroup anymore.

We used to acquire pages number, exectime and locality together
from memory cgroup, to make thing easier for our numa balancer
module, as now we use the numa group approach, maybe we can just
move these accounting into cpu cgroups, so all these features
stay in one subsys and could be hierarchical :-)

Regards,
Michael Wang

> 
> Regards,
> Michael Wang
> 
>>

