Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77A38C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 374292081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:41:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 374292081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B23F68E0003; Thu,  7 Mar 2019 21:41:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD2258E0002; Thu,  7 Mar 2019 21:41:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972E48E0003; Thu,  7 Mar 2019 21:41:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 532BF8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:41:31 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id v68so18552412pgb.23
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:41:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=t6RAlWXvpFRLf+UmW5gw5Un6fU3E0O31z/ontdDqNPI=;
        b=ARFE7pJWzdq28Tor+maucY5In/UPtctZ8RyAPeDP9Hb53unfZyly/7HUUjGjcgCrIx
         M4szmtrqNWTyCgwqt8l0kbeON3pV2I0VAR+slXm299PpzxeNIH3C+fJPGZVVEPAFzH4o
         qkvyXe5jUZKsKnJfAz4ig44cnsrH4qby+de5etRj+YH0mcj0u32kH7yx6E+xUW7K02PU
         0/WLebDRH9L/wqUfEsHN5xOKXz+U2l5lMsqH4csZpg5s0aPIZpvkc9x7jeWCgEsGOOhM
         ElzlaWtSUIf35ycLWP8MEsJxW6Y8uFgPxP85lNOmwJPcDStVH2TgkPm2BLdeelwnQq+i
         DdSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXem6hJ/C5KPrWjnSVY0eHerzfw+cHQKjLwUJbYpeHYBD/HGAY6
	wf76Xo+g4qBj0BTQoI5NTBNgb8WHOnkr3fpBT01SDe7RvdchXpYLa5ws9bRAYQfgX1dIbprUyqM
	9qS6BTmE/PKK3rovJvk4iBPqAVQzPjaFbMBeNWJeoWzv1XvkgROGkS/63kQTIFBuAWA==
X-Received: by 2002:aa7:87c6:: with SMTP id i6mr15870170pfo.208.1552012890972;
        Thu, 07 Mar 2019 18:41:30 -0800 (PST)
X-Google-Smtp-Source: APXvYqwEoTwzCiEoC7qDNENJdkIZyauQOJGXEJzJYUA75aJowNh6kroiLUoe6ZxtwzNVvuE1GO7a
X-Received: by 2002:aa7:87c6:: with SMTP id i6mr15870108pfo.208.1552012889737;
        Thu, 07 Mar 2019 18:41:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552012889; cv=none;
        d=google.com; s=arc-20160816;
        b=bap9FwP6xTwYsKpFVM862eNFnSb2al2JJvPRhJC1Qh6rbMmmOUDJoMlVDFE3n6CMrv
         geHFG1phZN5IVFTxoYcU+2Km3KP815Px3bsLFFMfWyQqJ4f/Er9ooghQRS/FCAjn1DKr
         iPyTH1hSEKSmJAAKNqHDXdaaC86LFo3JEybR502xaUc2hchgb26FHNzr9AUkE1OHKDhS
         ZVxCbTcqekWHP6kJWd6CKbcBhrrQwYoSaB08dFwgo/9VwjTl+CSNyxCoTllQjLlacWzZ
         Vqw7W2iKB3V88iEGro25HZAtXEmyt3gqTLjoVbegJgMdGmAVLgi4/U6gYk+vm7dDVy8K
         4WXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=t6RAlWXvpFRLf+UmW5gw5Un6fU3E0O31z/ontdDqNPI=;
        b=TpglS/5L9Lj2FrBQDdWLbI3zgnWw1s+woq1w8ZZ4mz8y+n6mdNIZVj+CuBwQtHNbnI
         zKXd4RJ27v09oXgOn0cj7Mpj1zBHnCCmxgr92SeMr9OCtBWETy7+kKC6JvlKi27M81zS
         MW3Rwc94v0+8fLm4iEc+RVCcp0S5642gT5+qFcpJriIXoCONaPOvHlUHQV7uQiKOWtlt
         ZgQrMJi/6+ecX+y9BeBOAEyJbH9FopSxYmNkgDNnwTh9CIu45nImoGqX6j9S3WIics7C
         2g695F6QZCMeNYTIKANMSHvEgD/T5LM/ZqcBx2EBlJFj2jUBAtb1EwjmS8AAXwcvRdOq
         TieA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id x12si5287907pgp.286.2019.03.07.18.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 18:41:29 -0800 (PST)
Received-SPF: pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=aaron.lu@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TMDnijS_1552012885;
Received: from 30.17.232.221(mailfrom:aaron.lu@linux.alibaba.com fp:SMTPD_---0TMDnijS_1552012885)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 08 Mar 2019 10:41:26 +0800
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Yang Shi <shy828301@gmail.com>, Jiufei Xue <jiufei.xue@linux.alibaba.com>,
 Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com,
 Linus Torvalds <torvalds@linux-foundation.org>
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
 <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
 <20190307144329.GA124730@h07e11201.sqa.eu95>
 <647c164c-6726-13d8-bffc-be366fba0004@virtuozzo.com>
 <20190307152446.GA37687@h07e11201.sqa.eu95>
 <afce7abf-dbc3-3b3e-9b61-a8de96fcaa2d@virtuozzo.com>
From: Aaron Lu <aaron.lu@linux.alibaba.com>
Message-ID: <cb0e29fb-76c7-ff8a-abe0-9e5ecd089798@linux.alibaba.com>
Date: Fri, 8 Mar 2019 10:41:25 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <afce7abf-dbc3-3b3e-9b61-a8de96fcaa2d@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/8 0:33, Andrey Ryabinin wrote:
> 
> 
> On 3/7/19 6:24 PM, Aaron Lu wrote:
>> On Thu, Mar 07, 2019 at 05:47:13PM +0300, Andrey Ryabinin wrote:
>>>
>>>
>>> On 3/7/19 5:43 PM, Aaron Lu wrote:
>>>> On Tue, Jan 29, 2019 at 05:01:50PM -0800, Andrew Morton wrote:
>>>>> On Wed, 30 Jan 2019 09:42:06 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>>>>
>>>>>>>>
>>>>>>>> If we want to allow vfree() to sleep, at least we need to test with
>>>>>>>> kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
>>>>>>>> vmalloc()/vfree() path). For now, reverting the
>>>>>>>> "Context: Either preemptible task context or not-NMI interrupt." change
>>>>>>>> will be needed for stable kernels.
>>>>>>>
>>>>>>> So, the comment for vfree "May sleep if called *not* from interrupt
>>>>>>> context." is wrong?
>>>>>>
>>>>>> Commit bf22e37a641327e3 ("mm: add vfree_atomic()") says
>>>>>>
>>>>>>     We are going to use sleeping lock for freeing vmap.  However some
>>>>>>     vfree() users want to free memory from atomic (but not from interrupt)
>>>>>>     context.  For this we add vfree_atomic() - deferred variation of vfree()
>>>>>>     which can be used in any atomic context (except NMIs).
>>>>>>
>>>>>> and commit 52414d3302577bb6 ("kvfree(): fix misleading comment") made
>>>>>>
>>>>>>     - * Context: Any context except NMI.
>>>>>>     + * Context: Either preemptible task context or not-NMI interrupt.
>>>>>>
>>>>>> change. But I think that we converted kmalloc() to kvmalloc() without checking
>>>>>> context of kvfree() callers. Therefore, I think that kvfree() needs to use
>>>>>> vfree_atomic() rather than just saying "vfree() might sleep if called not in
>>>>>> interrupt context."...
>>>>>
>>>>> Whereabouts in the vfree() path can the kernel sleep?
>>>>
>>>> (Sorry for the late reply.)
>>>>
>>>> Adding Andrey Ryabinin, author of commit 52414d3302577bb6
>>>> ("kvfree(): fix misleading comment"), maybe Andrey remembers
>>>> where vfree() can sleep.
>>>>
>>>> In the meantime, does "cond_resched_lock(&vmap_area_lock);" in
>>>> __purge_vmap_area_lazy() count as a sleep point?
>>>
>>> Yes, this is the place (the only one) where vfree() can sleep.
>>
>> OK, thanks for the quick confirm.
>>
>> So what about this: use __vfree_deferred() when:
>>  - in_interrupt(), because we can't use mutex_trylock() as pointed out
>>    by Tetsuo;
>>  - in_atomic(), because cond_resched_lock();
>>  - irqs_disabled(), as smp_call_function_many() will deadlock.
>>
>> An untested diff to show the idea(not sure if warn is needed):
>>
> 
> It was discussed before. You're not the first one suggesting something like this.
> There is the comment near in_atomic() explaining  well why and when your patch won't work.

Thanks for the info.

> The easiest way of making vfree() to be safe in atomic contexts is this patch:
> http://lkml.kernel.org/r/20170330102719.13119-1-aryabinin@virtuozzo.com
> 
> But the final decision at that time was to fix caller so the call vfree from sleepable context instead:
>  http://lkml.kernel.org/r/20170330152229.f2108e718114ed77acae7405@linux-foundation.org

OK, if that is the final decision, then I think Jiufei's patch that
moves kvfree() out of the locked region is the right thing to do for
this issue here.

