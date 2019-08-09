Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE64FC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:19:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65A0F214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:19:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65A0F214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E18E46B0316; Fri,  9 Aug 2019 12:19:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC9606B0319; Fri,  9 Aug 2019 12:19:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE0006B031A; Fri,  9 Aug 2019 12:19:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97A1A6B0316
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:19:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so53111588pgv.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:19:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=rJbFT5gQoRveif9kUWY7/Clp4veLg0UCBWLyKTkbpNU=;
        b=DoZ31AXgXBqQC9k0HOPgR1tIp0PJecQ9/MHz5tX0J1eWrwlBTFAivz6NV+WYImxh2c
         OP0doUszDzb5UhMi/r4aUrMLByMVKOK05G+zqjIuk20B+zomD+cHbjFgKMPcm48aekq3
         e+RJay0qGXTXjGqUAX8qTgOBGsOLFXzr1Wx52v6I7S+c3tHjb/ymhwR8QNnJnqMleiyV
         1tOIb5P5QRhqE1P6UOs6vw3MLTzhzSIc+aJvMmDCA8jVqdLclbgrW6BUCxySNgbW0fzR
         b9y+8HFv5M2/4uXpBv9uumexTc4j4QsjIWpelZALAU/ho5lu4xOJJoZoEGLaHuJZJn2e
         z5bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVfErK+tmXpYNMo/Le/+/qjU/VJe5lj+8tDfvxZi16CO+3jtfGs
	vfJ4imQxUGEP6fobv9lFHGGO11fAiWOZov7A9+G5mebmaxUJji3Q7KYJETP3oxosLO6UjENBXqs
	hlVRB1JUo6UEbdfcf55W37ieBN0wml99JzpzsnoqX9oJ4fbzPxVAMdr08mjremeK36Q==
X-Received: by 2002:a63:6f41:: with SMTP id k62mr18184780pgc.32.1565367562067;
        Fri, 09 Aug 2019 09:19:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqHcnvOYB5XF5DFxEubM5mZFysgtG3BcR0tAFvAnYvIDtBf5MOmnR8YqsfoXkudPBMDyru
X-Received: by 2002:a63:6f41:: with SMTP id k62mr18184715pgc.32.1565367561117;
        Fri, 09 Aug 2019 09:19:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565367561; cv=none;
        d=google.com; s=arc-20160816;
        b=UROn3jhMAi7MmhicYRFAXbwIcHmReTbpC6VcqNosW3rTabfIHiy1wpmEvHgv+DpynF
         UdWVxkIZ+A+DWyo4q2+eg+HDuJ4BcXcLKySz+uE6HCmT5c6i8Zd/TKcWGKVm1bt2F8/m
         vtpZkagEMVFfAzHvOA5V0wnjfT+jEDowHcaQBgL3mypOk19KpWrsBwYJiIt7kSkvWOx3
         VqhMPPueR7EqGTuOQe5PwTKLV2p+fmxiGEl/RZMWcbhXvCe3WpyMQeTVZ2EenJP1TYum
         CddUnwo32EpXIeSMOI/E8SsOt+vwNdpXMTFf6oxrNhG/XEzBxfWy5BJGv2KFykFZePu5
         c5nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rJbFT5gQoRveif9kUWY7/Clp4veLg0UCBWLyKTkbpNU=;
        b=BqYdSX3nyeV+EZd+Z1WP9JsWe31+rsm/WjB0BkUcAnSQcDBOaitDuKGlUfVZOPxylm
         XtN29qwns48o4plJkw9Z7XF/Oz5aYv0VTjphCMgorXKw4EVwznGM8BSH2unzhWXRFwUw
         kN1EkiNrF0+5LiuB3kzcqc0qH8DadoU14epyE4HpVlR5t8W7IGgMaxR+TawgxsalBToC
         MHQT4qaAowvOjxwVkQGz9ndFLLQOi9+J4+jG3YZKyxZXGc2mzc+eojjPJMW9ex0DXQWW
         3k3YQ1F55PYYxE4k5xjIl84yMACKVwqJH4thMmDajwJiSi1jyd6R9bhgOt01ba8T9f/u
         hjLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id g7si52288449plt.244.2019.08.09.09.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:19:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R781e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TZ1jNrk_1565367555;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TZ1jNrk_1565367555)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 10 Aug 2019 00:19:18 +0800
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
To: Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, vbabka@suse.cz,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
Date: Fri, 9 Aug 2019 09:19:13 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190809083216.GM18351@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/9/19 1:32 AM, Michal Hocko wrote:
> On Fri 09-08-19 07:57:44, Yang Shi wrote:
>> When doing partial unmap to THP, the pages in the affected range would
>> be considered to be reclaimable when memory pressure comes in.  And,
>> such pages would be put on deferred split queue and get minus from the
>> memory statistics (i.e. /proc/meminfo).
>>
>> For example, when doing THP split test, /proc/meminfo would show:
>>
>> Before put on lazy free list:
>> MemTotal:       45288336 kB
>> MemFree:        43281376 kB
>> MemAvailable:   43254048 kB
>> ...
>> Active(anon):    1096296 kB
>> Inactive(anon):     8372 kB
>> ...
>> AnonPages:       1096264 kB
>> ...
>> AnonHugePages:   1056768 kB
>>
>> After put on lazy free list:
>> MemTotal:       45288336 kB
>> MemFree:        43282612 kB
>> MemAvailable:   43255284 kB
>> ...
>> Active(anon):    1094228 kB
>> Inactive(anon):     8372 kB
>> ...
>> AnonPages:         49668 kB
>> ...
>> AnonHugePages:     10240 kB
>>
>> The THPs confusingly look disappeared although they are still on LRU if
>> you are not familair the tricks done by kernel.
> Is this a fallout of the recent deferred freeing work?

This series follows up the discussion happened when reviewing "Make 
deferred split shrinker memcg aware".

David Rientjes suggested deferred split THP should be accounted into 
available memory since they would be shrunk when memory pressure comes 
in, just like MADV_FREE pages. For the discussion, please refer to: 
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg2010115.html

>
>> Accounted the lazy free pages to NR_LAZYFREE, and show them in meminfo
>> and other places.  With the change the /proc/meminfo would look like:
>> Before put on lazy free list:
> The name is really confusing because I have thought of MADV_FREE immediately.

Yes, I agree. We may use a more specific name, i.e. DeferredSplitTHP.

>
>> +LazyFreePages: Cleanly freeable pages under memory pressure (i.e. deferred
>> +               split THP).
> What does that mean actually? I have hard time imagine what cleanly
> freeable pages mean.

Like deferred split THP and MADV_FREE pages, they could be reclaimed 
during memory pressure.

If you just go with "DeferredSplitTHP", these ambiguity would go away.


