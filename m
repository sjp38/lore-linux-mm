Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65B3AC742B0
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:59:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3442B2166E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:59:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3442B2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD6A88E012C; Fri, 12 Jul 2019 04:59:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AADA38E00DB; Fri, 12 Jul 2019 04:59:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C3F68E012C; Fri, 12 Jul 2019 04:59:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 663498E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:59:08 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 71so4869537pld.1
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:59:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gzQgdsRGNi0CMqOYGOjwetJRM1cKoVC2v0wzIwk8YQU=;
        b=XlxPUhnyAfY7zIKgBjhJHF7rpqRRCzQwrOUYMyMdS/A8JUWjjw65CQ8t5PdwMnDSF5
         cxAMbu78YLh/2ctGUa/aBtpuvW14kUoCI9BJ3WmHW8j/OZLYNJDdYb5Ta7vmOkMOg3pw
         msRlmhVepy/Bsu/dW6WpbVS4GATeIYxmnSksVOPYx0N7D/XajlIIWefbh8ytX1Ctkf0f
         Xy8W7+OFPl4X0BeWOwCMQIMaH253iQbXz9vM8MuDBC2dLin7qB9xneivtDZfzy09nKzf
         sYZ5v5UFN88yaPB5vFjMhp5Wq7LMelkbCMV3HNuJgHe+mI0357d/j7a3AP2/SjBtQpJY
         RyDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWF9pk+HzecpTrpgr567axf9Z5oOwk7mFy2AF6CcLTL8AN0whUp
	dW2LjcxkylIV1rfY4sPJERcJDjQfsE1tusmMbyRVFCI0DGEcSR7ctHoy0DxqeeCp6+vJSDAevP8
	upwy8aQKeh2EdERJk4K8X3nlV0pfOClEWV7/I8KrUjZsu1jYQXmMLu6G8oMXzejb+gg==
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr9653818plw.13.1562921948079;
        Fri, 12 Jul 2019 01:59:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLF2n0zgKUGCfMiNSDameGT0YYcx0BdM0HCV+i7O2uxr3Zha0peVazT2C2lLAMkeS4JG5V
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr9653735plw.13.1562921946952;
        Fri, 12 Jul 2019 01:59:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562921946; cv=none;
        d=google.com; s=arc-20160816;
        b=tsH72vWDPHuejo7NTXtWu5ysYRZeSR12R1LRshqAZ4caIq53U2qUq1zihPLfsfTaj+
         JIBDEw1Kh9dFI4PHVcbVBAQ3oWBuiIjaMkqxEn3pYGNHvoFiDQ8rZSzRQ7ZmX6vRnLLG
         UUVEuEJnP11NO1EnlDHKrKbMSH/SQ0uXXDVtWAyEEmKasI8atXc90EalgepVehfBu6Ed
         rF2j3cBXZHi83O/IfzPoKU/Jh0JEcNx6XG1U2yVtjxNlUSRC8cZQZzFYY/iRTMkITMQi
         mcaxgSRDIf9Ccve7uXA7ZZ31PiWafqDtpDrEw+B3iFbVwhoPA2z7yiCRrQjrnzYozTlv
         4nCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gzQgdsRGNi0CMqOYGOjwetJRM1cKoVC2v0wzIwk8YQU=;
        b=xwpo5nI36SsZ55JKDGNXw5NsLYHq4shpI8+V/x5HZqm5xnv6xwF7vJtEPlWsJEe4Nx
         jXWpBBHhHkOoYx2MO6Zmqr/5FHzcfqRem+namHhHUYh7NOPjdUEbvIW6jEuXi1lel7xI
         uBVIDWD5P9huDaK0vKHx4BlzJJMAVpMyWNidTdSpw93sLgdLT7VnnV9D/oS/WzNG/ntf
         Jd9vXmpo+2yaGcv5obS4VVM+E3T8Ii51LC2t3wGuzehQlD6mSKon/xsdsDgbVGDlXWTk
         5VbwWDORLU/G6u5cbWNrdRcoW11mb2osJMZl0JuJC7D2JjvQmv7B8mCoTtVzC8tYBHLh
         SJjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id j12si7929861pfe.188.2019.07.12.01.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 01:59:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWh9RaS_1562921921;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWh9RaS_1562921921)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 16:58:42 +0800
Subject: Re: [PATCH 4/4] numa: introduce numa cling feature
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <9a440936-1e5d-d3bb-c795-ef6f9839a021@linux.alibaba.com>
 <20190711142728.GF3402@hirez.programming.kicks-ass.net>
 <82f42063-ce51-dd34-ba95-5b32ee733de7@linux.alibaba.com>
 <20190712075318.GM3402@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <0a5066be-ac10-5dce-c0a6-408725bc0784@linux.alibaba.com>
Date: Fri, 12 Jul 2019 16:58:41 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190712075318.GM3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/12 下午3:53, Peter Zijlstra wrote:
[snip]
>>>>  	return target;
>>>>  }
>>>
>>> Select idle sibling should never cross node boundaries and is thus the
>>> entirely wrong place to fix anything.
>>
>> Hmm.. in our early testing the printk show both select_task_rq_fair() and
>> task_numa_find_cpu() will call select_idle_sibling with prev and target on
>> different node, thus we pick this point to save few lines.
> 
> But it will never return @prev if it is not in the same cache domain as
> @target. See how everything is gated by:
> 
>   && cpus_share_cache(x, target)

Yeah, that's right.

> 
>> But if the semantics of select_idle_sibling() is to return cpu on the same
>> node of target, what about move the logical after select_idle_sibling() for
>> the two callers?
> 
> No, that's insane. You don't do select_idle_sibling() to then ignore the
> result. You have to change @target before calling select_idle_sibling().
> 

I see, we should not override the decision of select_idle_sibling().

Actually the original design we try to achieve is:

  let wake affine select the target
  try find idle sibling of target
  if got one
	pick it
  else if task cling to prev
	pick prev

That is to consider wake affine superior to numa cling.

But after rethinking maybe this is not necessary, since numa cling is
also some kind of strong wake affine hint, actually maybe even a better
one to filter out the bad cases.

I'll try change @target instead and give a retest then.

Regards,
Michael Wang

