Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 574ADC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:54:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 198CF20859
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:54:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 198CF20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DF026B0007; Fri,  9 Aug 2019 19:54:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F816B0008; Fri,  9 Aug 2019 19:54:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67FDD6B000A; Fri,  9 Aug 2019 19:54:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30CC96B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 19:54:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5so60633381pgq.23
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 16:54:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=m6kH5qOp1/oTWqobDbRS/myF91Jk9e/P0jXd/M4Lu2c=;
        b=uXNBieCO2LIBdTyDlwuZAAlc8l16UwsBOhILrzyK1dWuMNnOAdhs+SkWSlVvvjwKRo
         hHkko8+OyqdgOI5RlEUsBqaCaS0+ku2z6jOi9w+KhigR+4K+fRIVI2qIl2Oc4h0Jhqor
         Ug3Mok9NSdaFrZ9qrCkSBcvoBIha3VdArTPvhhC14OFsIlC9TdmIMoGVAQMY04sfnAP7
         cp3f7GUSKNLAtoQRpeg9AmUhyk1uaY+OJ39zY/BVTgBNvT5HYcGDKx0tkVqWMMG1pIN3
         sFKx3uDKVIrFJ72yB9djQTENJNK3TYTNb9hnEvvDaKgjbIUDrRUMYLPoMstPJHi87aP2
         cRMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV2ufwxDFYDE37fURdb07rUf06MjPVBZGz5tu9H4c9HvbkGd31z
	amNIhQLbHhAVh6YSo8vSG2X+ucW9crz/ly/a00pqllGneNPrxJ1BPgMdy5w2YOtCvZ4wqsA7qi1
	JTujhKiTRefEmwZBXK4Xryw66nuAcbBl4PfzXc5ZNEE5BvmbR1vjiNwGY3CKFyJ3org==
X-Received: by 2002:a65:5b8e:: with SMTP id i14mr19634298pgr.188.1565394889770;
        Fri, 09 Aug 2019 16:54:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzV63Yn4cI6LQeftqbrwFoSIkZBhVE+rPLMbzju52OPid0JyOQ5Kvk5CndYyoGv/NjGJCmo
X-Received: by 2002:a65:5b8e:: with SMTP id i14mr19634250pgr.188.1565394888722;
        Fri, 09 Aug 2019 16:54:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565394888; cv=none;
        d=google.com; s=arc-20160816;
        b=aaPEs+2GH4j4cMHsXrx4ZzjwIvxevNvXQZr7KobUCaZ2KUmsGWZ5AhCmb32IWSJwCR
         QjOKNhSpS73lDfNs31oczhCXt6PM7qr7GTbu+s236bZ8KmKZR4jAL9XJL+/6PzfY+wCr
         E/YgFoS2Y0CDEXHIaUx1AKtrPqeYYUzWyicHfd7XgdB0INkHCr/Qdd95U2JU8osEeQwH
         hlMEKNg8ndwivKWybFd+dvhDgoU6M2I+xc4aUoVwWRQpYuyLGAilF4JLoIYbnzcA0gYy
         +5uFn1/KQGDj1EZDC6xtah+nlk170a8tICGuDAnpg7a818chUi5hrWV9b67Oyb1eWYDI
         GRgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=m6kH5qOp1/oTWqobDbRS/myF91Jk9e/P0jXd/M4Lu2c=;
        b=m72ZK5Hldh2+7KtcCGfGG+7c6WokftvU7/NteMZMR79QOrJ8ep1dsNRIzNzpy2cbXE
         DMlmAtwx1dbzIaLWXcnlvJCS5B7MsSH6YS64jP1wjSc4BcyuLkb1uuxeXZoRGZJ91u28
         GalWU4BzFqUOS/j7P4a260WxQsTPg6U5Q6j8JOLQwnMN3uatosasCgfHA3kHhotBn75E
         jATdx9c5ujkrd58DXIJim9LSXoeQN28XLyzCgtA+dqFP/KWLGtDDFMSn07MYw8zlo7hq
         obr1HcDB/yjW+wfjTUmKeDQwaVoe7cLhMmhuP6TRAPNoPf+2eLY9psYh3wLrriJxguE9
         WIGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id j12si24651240pgp.261.2019.08.09.16.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 16:54:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TZ2u7I7_1565394883;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TZ2u7I7_1565394883)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 10 Aug 2019 07:54:46 +0800
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, vbabka@suse.cz,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
 <20190809180238.GS18351@dhcp22.suse.cz>
 <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
Message-ID: <fb1f4958-5147-2fab-531f-d234806c2f37@linux.alibaba.com>
Date: Fri, 9 Aug 2019 16:54:43 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/9/19 11:26 AM, Yang Shi wrote:
>
>
> On 8/9/19 11:02 AM, Michal Hocko wrote:
>> On Fri 09-08-19 09:19:13, Yang Shi wrote:
>>>
>>> On 8/9/19 1:32 AM, Michal Hocko wrote:
>>>> On Fri 09-08-19 07:57:44, Yang Shi wrote:
>>>>> When doing partial unmap to THP, the pages in the affected range 
>>>>> would
>>>>> be considered to be reclaimable when memory pressure comes in.  And,
>>>>> such pages would be put on deferred split queue and get minus from 
>>>>> the
>>>>> memory statistics (i.e. /proc/meminfo).
>>>>>
>>>>> For example, when doing THP split test, /proc/meminfo would show:
>>>>>
>>>>> Before put on lazy free list:
>>>>> MemTotal:       45288336 kB
>>>>> MemFree:        43281376 kB
>>>>> MemAvailable:   43254048 kB
>>>>> ...
>>>>> Active(anon):    1096296 kB
>>>>> Inactive(anon):     8372 kB
>>>>> ...
>>>>> AnonPages:       1096264 kB
>>>>> ...
>>>>> AnonHugePages:   1056768 kB
>>>>>
>>>>> After put on lazy free list:
>>>>> MemTotal:       45288336 kB
>>>>> MemFree:        43282612 kB
>>>>> MemAvailable:   43255284 kB
>>>>> ...
>>>>> Active(anon):    1094228 kB
>>>>> Inactive(anon):     8372 kB
>>>>> ...
>>>>> AnonPages:         49668 kB
>>>>> ...
>>>>> AnonHugePages:     10240 kB
>>>>>
>>>>> The THPs confusingly look disappeared although they are still on 
>>>>> LRU if
>>>>> you are not familair the tricks done by kernel.
>>>> Is this a fallout of the recent deferred freeing work?
>>> This series follows up the discussion happened when reviewing "Make 
>>> deferred
>>> split shrinker memcg aware".
>> OK, so it is a pre-existing problem. Thanks!
>>
>>> David Rientjes suggested deferred split THP should be accounted into
>>> available memory since they would be shrunk when memory pressure 
>>> comes in,
>>> just like MADV_FREE pages. For the discussion, please refer to:
>>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg2010115.html 
>>>
>> Thanks for the reference.
>>
>>>>> Accounted the lazy free pages to NR_LAZYFREE, and show them in 
>>>>> meminfo
>>>>> and other places.  With the change the /proc/meminfo would look like:
>>>>> Before put on lazy free list:
>>>> The name is really confusing because I have thought of MADV_FREE 
>>>> immediately.
>>> Yes, I agree. We may use a more specific name, i.e. DeferredSplitTHP.
>>>
>>>>> +LazyFreePages: Cleanly freeable pages under memory pressure (i.e. 
>>>>> deferred
>>>>> +               split THP).
>>>> What does that mean actually? I have hard time imagine what cleanly
>>>> freeable pages mean.
>>> Like deferred split THP and MADV_FREE pages, they could be reclaimed 
>>> during
>>> memory pressure.
>>>
>>> If you just go with "DeferredSplitTHP", these ambiguity would go away.
>> I have to study the code some more but is there any reason why those
>> pages are not accounted as proper THPs anymore? Sure they are partially
>> unmaped but they are still THPs so why cannot we keep them accounted
>> like that. Having a new counter to reflect that sounds like papering
>> over the problem to me. But as I've said I might be missing something
>> important here.
>
> I think we could keep those pages accounted for NR_ANON_THPS since 
> they are still THP although they are unmapped as you mentioned if we 
> just want to fix the improper accounting.

By double checking what NR_ANON_THPS really means, 
Documentation/filesystems/proc.txt says "Non-file backed huge pages 
mapped into userspace page tables". Then it makes some sense to dec 
NR_ANON_THPS when removing rmap even though they are still THPs.

I don't think we would like to change the definition, if so a new 
counter may make more sense.

>
> Here the new counter is introduced for patch 2/2 to account deferred 
> split THPs into available memory since NR_ANON_THPS may contain 
> non-deferred split THPs.
>
> I could use an internal counter for deferred split THPs, but if it is 
> accounted by mod_node_page_state, why not just show it in 
> /proc/meminfo? Or we fix NR_ANON_THPS and show deferred split THPs in 
> /proc/meminfo?
>
>>
>

