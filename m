Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C46FBC76191
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:36:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9303021926
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:36:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9303021926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26B676B0007; Sun, 21 Jul 2019 22:36:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21BCF6B0008; Sun, 21 Jul 2019 22:36:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1324D8E0001; Sun, 21 Jul 2019 22:36:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D46D16B0007
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 22:36:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so18942244pll.22
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 19:36:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3m2dGoHi3M1vDO3xQ6pGA27Sr9eswVkrO4mdt+cFKLY=;
        b=QG+/saZKXEVg6FIhvVB102oXqXB44plMSzgMVprZFOAJLy2y0hfpU1INAIQRnuqP0z
         SN+Mmy0zJQ1oXqgKEiMwrlC1SP/o0P9rDeolG1xSXt73FzEMxr9pT1bZemKCXJSJXemw
         rlgypDKhusqoPiUqxMN7p6setwslIqExqUXdlWozES3j7/4AcBEDLGVsiKWXTjnW0+UZ
         3VEzrHujQ4qj4cmeloV6gyw6q0UKiCOf89Hy37eYpM7P6Xd/64wSjGOVjcIjSsaGvbru
         F6vJ5M6G/jBKfl3ho4fartxZmIIJip7bFUf2G5y0aikjjjhLfiuwhHl7mj8k6MUwU52g
         0aKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXnMJXhx3IUHVU/H2UtjHRdklCIXjGefaJpj5fuCtNKSlBKAxSa
	E6qSdAl0CnQa6PWIoIo+Y856LJZkEk+aVLec/hcm4D04/yle3AfM3ItFc0vx0ow7sWqNXYpLU93
	n009hJRrX3+/VzCh+7zIyYTiJzW+qDqvH1qgtonks+9Niboce6Z/EYZW+Uh6SbgDx4w==
X-Received: by 2002:a63:c302:: with SMTP id c2mr65113772pgd.300.1563763009450;
        Sun, 21 Jul 2019 19:36:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlOsr9518JOvMoq4LtdAFIPkOjNFZyFSNUlkCeOgdu6282W/CVL9VBZznbh3A5n3aGpBGQ
X-Received: by 2002:a63:c302:: with SMTP id c2mr65113713pgd.300.1563763008528;
        Sun, 21 Jul 2019 19:36:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563763008; cv=none;
        d=google.com; s=arc-20160816;
        b=cS9VeafP/FhjP0UMfcbs0vfTLiy5ulWVHnbtBgPyuM9uoDl1TyxUjxUJ0PGGIfvNi5
         tpb/JSsInX9ezKOrNWC3Z/nVQqA3h/qiPZBDO2WGxkx0bKnYeIouj8v9/eSZGsQgTYqW
         BlDdcUSU5LRVCcf/bAUmzBEg4Dy9w/bl/oygmTfcqGcMDUTs93g97DDTZNc4LYsfAJEj
         3ULHR3uyzmr9IBDHABPy8wsK5q12nvzNYeCKy3DoV/naDdfbGpPdFVz7yTZgYTCZX4/0
         /jhkj/Tx/sGT7toshCgj7ioa3Im7gqKRGLUCHXgoUrA05RFT/3CBxhBol8J1dyKVRg9e
         QDtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3m2dGoHi3M1vDO3xQ6pGA27Sr9eswVkrO4mdt+cFKLY=;
        b=WulacBSXy7p8VaS1qUjnv5sPhRLTWwb5AaXA0O8Uy/+vPGZMqXnMFhk2CxyEdJu7s2
         1wn/C/dSpuoLH3Nk1fVlAOYeDQbfnnHERnULng6mY7QoPgx6Gr33WBot7vFUXZMlfxst
         y7BCF9pnUeSzSjdDbj4T7NUZ64O4wILfWTIleVG0AkS/+Tnv106do88iBHNLVA34E71A
         064rWUndzLEKF/GRxWp1cg6NfKJL5d5CfAxa4vu7htIllHjBq+M7c6qgkrx4Xv4cCMWX
         T2MTAjawoMXxVWFagUID3JE0fYshkOCwBqUSGknM5+0EvYm0FLcRT4WMhtJIc1Vor+0t
         6zAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id v8si7363502plg.122.2019.07.21.19.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 19:36:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TXSIFIJ_1563763005;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TXSIFIJ_1563763005)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 22 Jul 2019 10:36:46 +0800
Subject: Re: [PATCH v2 2/4] numa: append per-node execution time in
 cpu.numa_stat
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com,
 Peter Zijlstra <peterz@infradead.org>, mhocko@kernel.org,
 Ingo Molnar <mingo@redhat.com>, keescook@chromium.org, mcgrof@kernel.org,
 linux-mm@kvack.org, Hillf Danton <hdanton@sina.com>,
 cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
 <6973a1bf-88f2-b54e-726d-8b7d95d80197@linux.alibaba.com>
 <20190719163930.GA854@blackbody.suse.cz>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <08280b56-edc1-288a-d38d-1c8bf8b988a7@linux.alibaba.com>
Date: Mon, 22 Jul 2019 10:36:45 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190719163930.GA854@blackbody.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/20 上午12:39, Michal Koutný wrote:
> On Tue, Jul 16, 2019 at 11:40:35AM +0800, 王贇  <yun.wang@linux.alibaba.com> wrote:
>> By doing 'cat /sys/fs/cgroup/cpu/CGROUP_PATH/cpu.numa_stat', we see new
>> output line heading with 'exectime', like:
>>
>>   exectime 311900 407166
> What you present are times aggregated over CPUs in the NUMA nodes, this
> seems a bit lossy interface. 
> 
> Despite you the aggregated information is sufficient for your
> monitoring, I think it's worth providing the information with the
> original granularity.

As Peter suggested previously, kernel do not report jiffies to user anymore
and 'ms' could be better, I guess usually we care about how much the percentage
is on a particular node?

> 
> Note that cpuacct v1 controller used to report such percpu runtime
> stats. The v2 implementation would rather build upon the rstat API.

Support cgroup v2 is on the plan :-) let's mark this as todo currently,
i suppose they may not share the same piece of code.

Regards,
Michael Wang

> 
> Michal
> 

