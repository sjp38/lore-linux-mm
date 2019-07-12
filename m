Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE1E7C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 04:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90AE9217D6
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 04:03:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90AE9217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE9148E0114; Fri, 12 Jul 2019 00:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBDE98E00DB; Fri, 12 Jul 2019 00:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAC508E0114; Fri, 12 Jul 2019 00:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A544B8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:03:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h5so4909906pgq.23
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 21:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iCtnrK+bGTr4rq4X2juOQQxAl0Jsp90zb3U2SYf2if4=;
        b=jN+r7XDWMAXSiSUAVJ4VGMdXgdZB9QAOh/6HMs3cRP8cprd/XRYE7UuBLRzcrSJa5i
         1lX6iRRvvy4jzeAeG5GB7H3nsGSMmW/c+fpk/l7NiXgXWVgfHbN1DehXFuHTyUbKZjm3
         45YW/FtqBZ3UoLv4++rjmt4hGzNmDNDLW9gn29IJ1SIQCl7viv4MwKuh3JZHDzmLZRYK
         62ubd4ll/fSsZmEqcC1PXvicAf9Gslh3ujxcl/Egoexd0axvQA0R40AvqOwD0yMxNCxz
         OQoX+UA+8cd0a84fwQ3D0EQuvb4RFWiEsb3t2u4r6TO4TQNhSYa7dnRTBTzqafTwNiGo
         FUQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVt1xfNioeHnRNzNjLOZQ9MoC3zfeSsUZsUGgHXnKrGInzegcAG
	9PTG63y1F2slU8LfMlAtJGLhka60Fhi1aJWy7kR4jpbqiRe8zyi8DPFRZAv46oRRCoz+Q9YCucC
	Z7t58uTCE9ThpS4h68dkzmes/pXDBV/hVQLiWnFuRc+CG9TkjPF1QC3bKlVlu4Ghx4g==
X-Received: by 2002:a17:902:9004:: with SMTP id a4mr8826384plp.109.1562904207343;
        Thu, 11 Jul 2019 21:03:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKq4fJ6Vh4AtNiSNl3GIRou/M5rO3t8MH3M2Yjg4o+i9yu2XCopvjOg1MpwfQcA0B6aIJH
X-Received: by 2002:a17:902:9004:: with SMTP id a4mr8826331plp.109.1562904206658;
        Thu, 11 Jul 2019 21:03:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562904206; cv=none;
        d=google.com; s=arc-20160816;
        b=bSZznEC2sZNTGpf4NdKb0B7j2eIUL28UDaZGnXveJkGfvyAHvaVGa9uSOi1sVN35iu
         pEmQYdgyEAJ76gFNhA8h/dDPU7QnjNh6swd8Ybn9zh/rc4uykhF5HODAwEYXqJwn4f9N
         QBoDEvqWZ7P11mqXfVUH918G8438ltFTylIPmsN/cv9LgZ3vVPwRUfzfCakOd6w/9/Ki
         U6BglYsEG4WFkqNnzP96S81+UlSUxMiRR/pzmChCf6DVvUk2ISk0dwO256aVvIbIFWKl
         KR0ixsXwPAdLUKdHMDz8j+FOqNkTpax9L/x7wOjtZrY2RgH07ABh15rDVJxW0zfO/lnN
         6x7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iCtnrK+bGTr4rq4X2juOQQxAl0Jsp90zb3U2SYf2if4=;
        b=XmTdv23o8zUcoKfK8wt60JMXKQUWU3jTY8oFQxt2/etJBOqDrn3EcrhJfI6j/LIn6e
         5Wosz2MnKSEhich4zFg1mJ1DhngTEh+dmssFiNzvEBOpA93efegz6Q/j1UKITqQDTBBR
         j21F9oXNwUyvHljyIZnqQ1Gjq+Njwgd+uEyqEBirv/p0rclQUaRPik1dSOmwkM3laLL7
         5tnIVp00/NlA5ouNFjsPed5UVPZfgS4aQTpOGKoafdDm5xvD1aGH/2GpobgKaBv6Mf5S
         Rak1LF0WkadeMG4TRglBchlOTYgwvkGPK5eKQR21yUJvrKuILSg8+OtcpPZY0xL9/y5t
         Zdyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id u62si1444638pjb.3.2019.07.11.21.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 21:03:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWfcT1L_1562904203;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWfcT1L_1562904203)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 12:03:24 +0800
Subject: Re: [PATCH 3/4] numa: introduce numa group per task group
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <93cf9333-2f9a-ca1e-a4a6-54fc388d1673@linux.alibaba.com>
 <20190711141038.GE3402@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <50a5ae9e-6dbd-51b6-a374-1b0e45588abf@linux.alibaba.com>
Date: Fri, 12 Jul 2019 12:03:23 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190711141038.GE3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/11 下午10:10, Peter Zijlstra wrote:
> On Wed, Jul 03, 2019 at 11:32:32AM +0800, 王贇 wrote:
>> By tracing numa page faults, we recognize tasks sharing the same page,
>> and try pack them together into a single numa group.
>>
>> However when two task share lot's of cache pages while not much
>> anonymous pages, since numa balancing do not tracing cache page, they
>> have no chance to join into the same group.
>>
>> While tracing cache page cost too much, we could use some hints from
> 
> I forgot; where again do we skip shared pages? task_numa_work() doesn't
> seem to skip file vmas.

That's the page cache generated by file read/write, rather than the pages
for file mapping, pages of memory to support IO also won't be considered as
shared between tasks since they don't belong to any particular task, but may
serving multiples.

> 
>> userland and cpu cgroup could be a good one.
>>
>> This patch introduced new entry 'numa_group' for cpu cgroup, by echo
>> non-zero into the entry, we can now force all the tasks of this cgroup
>> to join the same numa group serving for task group.
>>
>> In this way tasks are more likely to settle down on the same node, to
>> share closer cpu cache and gain benefit from NUMA on both file/anonymous
>> pages.
>>
>> Besides, when multiple cgroup enabled numa group, they will be able to
>> exchange task location by utilizing numa migration, in this way they
>> could achieve single node settle down without breaking load balance.
> 
> I dislike cgroup only interfaces; it there really nothing else we could
> use for this?

Me too... while at this moment that's the best approach we have got, we also
tried to use separately module to handle these automatically, but this need
a very good understanding of the system, configuration and workloads which
only known by the owner.

So maybe just providing the functionality and leave the choice to user is not
that bad?

Regards,
Michael Wang

> 

