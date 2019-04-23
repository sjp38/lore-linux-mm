Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72D8CC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 10:01:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33036206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 10:01:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33036206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5F976B0006; Tue, 23 Apr 2019 06:01:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D10056B000D; Tue, 23 Apr 2019 06:01:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4E2E6B000E; Tue, 23 Apr 2019 06:01:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF496B0006
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:01:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f7so9751024pgi.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:01:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=IOJKiNhiIz6QMuZcHD/rTzeb8CECBL/PkwFKGXOJifs=;
        b=Dl1rk8SKdDMmUDld449CshTiCNifnKFjQT5PlAjvowjuIKQz57bZ3U1MKKO5Uwp95E
         XkXmMm1Ie6of3yVqi7tVy33AeJEqYYklIc3gL7GcS0uSyWQ9PTHle6CHKwMvU5MmnACv
         o0RtvoX9eMxN5UOOsEf8qBtTb8MKCMCsA6jWdqr7KIw5VyKPaGLVaFIGxNys3Wfuth+K
         ip89DbugjeMnGVzzJUhJ0RSPOQaXq6egpgZPSwd8uq9l/RwL7nSdcgG/KoYNyOGSfiLw
         eGEFMvk41rj4s4vhJRpdPFoHeH8WTQlxQSDHujD2EcxSblzckye1p/zCAXh8M1zCO4qj
         bCmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWOCC5hnOMDfgLK+aayQMhqmiETEvFY8YAR8Dnb6lSZ6wnSXuQI
	tyFHvTxguVOiCkmeCvKa4aIA1dMs7GIEmawE1ZawwZ9x66xzp1hgmWNCnFC45VqnabbpOqyeYrR
	6XV8BLYfPgX954vzDrUwQa64aESPhlOUy+cyqCZK8UzpeIpQn3bZhFLFhUAWeOMLKMA==
X-Received: by 2002:a63:2a8f:: with SMTP id q137mr23893555pgq.31.1556013679828;
        Tue, 23 Apr 2019 03:01:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx66pBdb/L1xtWJQHY/OnrBDJ9dnmyn9rHSoZ8vQcdXc2wD15SH/VcLGFgSnAk638MzXkL1
X-Received: by 2002:a63:2a8f:: with SMTP id q137mr23893497pgq.31.1556013679254;
        Tue, 23 Apr 2019 03:01:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556013679; cv=none;
        d=google.com; s=arc-20160816;
        b=03t2k0zGCL2JTtPwzr5xK70jA8jny/KJeQB9Su7byDoe3ixl+dh8Em63N2Yb1S6hma
         SezKbcyjwCUKO/0j0NS3VwY8XOIpLWpfdvzDrv2rNUbD7G7j84y5QaVwdL7podlDsNtR
         rDTz9FELFLtq1EU9PpFhAuppz4UsgLw/2BHvjte39whptSkI65MDmkQ2FlNqspp7Dj3Q
         ZPXgUC+PyRGjd4ElJ1w3e4Pr+VcxbC98mJfg/IgMf8gtPyPjlvC6nuGYRWbZHmWQcQGP
         wHNY32e65qKFs7HUFdKP+rbcpafpPO7h2kNviWzg8n5LHTUUTHRdiVDtcj9fQG6x3nme
         sQrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=IOJKiNhiIz6QMuZcHD/rTzeb8CECBL/PkwFKGXOJifs=;
        b=Jz/4S8NTyonxZxeVLY+QjxScc90pfQsxMMvK4Bsb3fsYQl6NW21wcT2kxftl0rEFFS
         8+ZQUwEcMiT/6ndSmS8m2+qlQ0e0mwvpJGAIJmWFSq0mlsuN/l+aaKXUCKSFCpvnWB5z
         7GZAlbR1FmtqjDLO2peLdb80L9PIL2K4KK06IR4v366FDfagBoWlrH5Lx0cDrFdltkSq
         X/eupEDxVJpt6ypVdTLvLc5Lk7occUDVCQiq1BojRTf/I+C40Xh55Xo1MsVndrW2NZd4
         ZW5UFPWMNun4bvpbog2Yp49iaIqjYraeK/D/EsfbfZLh4CvBn8t06QC4I7ljsFRL8Ed1
         Vzvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id 17si16666034pfw.148.2019.04.23.03.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 03:01:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ2QHDj_1556013675;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ2QHDj_1556013675)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 18:01:15 +0800
Subject: Re: [RFC PATCH 2/5] numa: append per-node execution info in
 memory.numa_stat
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <7be82809-79d3-f6a1-dfe8-dd14d2b35219@linux.alibaba.com>
 <20190423085248.GE11158@hirez.programming.kicks-ass.net>
 <8c3ad96d-7f3d-d966-6acc-8327023ae3f9@linux.alibaba.com>
 <20190423094644.GL11158@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <9e3c163c-2a89-72d9-ee93-7fea3692b609@linux.alibaba.com>
Date: Tue, 23 Apr 2019 18:01:14 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423094644.GL11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/23 下午5:46, Peter Zijlstra wrote:
> On Tue, Apr 23, 2019 at 05:36:25PM +0800, 王贇 wrote:
>>
>>
>> On 2019/4/23 下午4:52, Peter Zijlstra wrote:
>>> On Mon, Apr 22, 2019 at 10:12:20AM +0800, 王贇 wrote:
>>>> This patch introduced numa execution information, to imply the numa
>>>> efficiency.
>>>>
>>>> By doing 'cat /sys/fs/cgroup/memory/CGROUP_PATH/memory.numa_stat', we
>>>> see new output line heading with 'exectime', like:
>>>>
>>>>   exectime 24399843 27865444
>>>>
>>>> which means the tasks of this cgroup executed 24399843 ticks on node 0,
>>>> and 27865444 ticks on node 1.
>>>
>>> I think we stopped reporting time in HZ to userspace a long long time
>>> ago. Please don't do that.
>>
>> Ah I see, let's make it us maybe?
> 
> ms might be best I think.

Will be in next version.

Regards,
Michael Wang

> 

