Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED09DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:54:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4DC02081B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:54:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4DC02081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57B2D8E00AF; Thu, 21 Feb 2019 14:54:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 529F18E009E; Thu, 21 Feb 2019 14:54:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43F378E00AF; Thu, 21 Feb 2019 14:54:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0434E8E009E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 14:54:57 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o24so11639835pgh.5
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 11:54:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=wB4SX18yKj2OZqs2LeBLT+5cJhYt1dxSO5d2eYYYHPs=;
        b=d5jVIPfRuRx3Dd8cliMaX11H2yj8/WfowbxJxHFQewSW9CAMrMgpOMMeTnMdUbYHNa
         D++y6oMFd4pZtTxb92ng7EPU2SYyO3WE1UCN5vfwPcDR5gsEN7mecaUk2zUtMxNvWI8+
         NQnwCsHejddpoV0CvfeCC28XXFktOB8KGqk8h5YnMEPbxjHcu/LLgTJEs14a3Iu3icef
         FzWX2rW4jUoL2ROJfW4UqRR57FCiXWZiIfu3R97/YQ+9CjaBUCXsSGcr8MV/JGRCo+Yg
         ulR1apjjYQpkVa05JiVKxzdOzArc2OKWnvCPw+QvGMZmBQlWJnRpqBSUi6jWeA0grROM
         janQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AHQUAuZjBuCvMdWLoIuHBSUbTC73VbKuz66QDKlomUP6uT0ItUK8IK90
	/cxWbm4FWeRKIEv0NSdCddR3yFVYfGrA9ajvUaoWkPKQGpMhAVi9vGEKMW82Pz6jbIJGkXVW2e6
	AxgNfNRgTMSa+b8ZnkXmRlHaTT7yIE/kstrwRvwUsSo/6G8Y2/Pzy45F3Df7ksReJ+Q==
X-Received: by 2002:a63:f412:: with SMTP id g18mr224834pgi.444.1550778896673;
        Thu, 21 Feb 2019 11:54:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaFMXRVoqxktYki9G5g/pRNetfNNe6JpsTqlUgRJN6GVMdoBqOzn6tIBxPQwQjaHzzNESFk
X-Received: by 2002:a63:f412:: with SMTP id g18mr224801pgi.444.1550778895906;
        Thu, 21 Feb 2019 11:54:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550778895; cv=none;
        d=google.com; s=arc-20160816;
        b=BIOYcllo+VH6GGJ9VQfhMwicBhiN8iLERkbzzop9R5MRtOrNBefQB4z3Exw36NP8uA
         mO80a+U1mw/nhpiJLW84WUPheFHuw8gYcROWoJfsLoqWJ/Pu8OrIMs8Nta7jX7v0lGIF
         uJnyZPNa014zjLt1jGJJ7A1aFTjA4CWBy4UBDWO2WJXxrbvX4L/833SWeS4ygQI9zj7d
         XYc/lzwqovr2HvtsZ1O02sOHJl31vagZ4+NA9raUJ6IkA7vQUQIaRZ7qDSzs7HjwQ8y6
         O0WuVYk9SDoVD5h3W5vhBb9YF87AFohzOYqFPtIN7MvirNRLXiXRZg4y/y73BCR2kgtX
         eirQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wB4SX18yKj2OZqs2LeBLT+5cJhYt1dxSO5d2eYYYHPs=;
        b=Y19GPDQoNy2SqUR7YW8WAvrIk+41898JjwP82kAlctyfATDktRVPpZwoknqN13ramN
         FrRWBavGCysw2KPa+OweKWVSCoZUEowk9zY3mO5s0DWuMHfo+08bUFm2DsQtgQyPrwMI
         Xq3W2nF97xORzRvi0s0DQBbZZS6T3TOwbqxHFJLLGCS5OIE7uWNBTHz4+V4Kz0uGmI12
         CIHRF9HOrQyUxP1TSlImUJy9xaBT9cQmtBmNxG6Y7EWzYZ3rbZCc8m6UTrji28tTbWbT
         RZ5i3y0YoR/sI6RPo/3gF0q29mHoRA/VxIY0Cw3R718pDxLUnaPn9l34K0oniIi0xd/M
         orXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id f20si23337468plr.419.2019.02.21.11.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 11:54:55 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R551e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TKsBKHK_1550778890;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TKsBKHK_1550778890)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 22 Feb 2019 03:54:52 +0800
Subject: Re: [PATCH] doc: cgroup: correct the wrong information about measure
 of memory pressure
To: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>,
 Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, corbet@lwn.net, cgroups@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1550278564-81540-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190218210504.GT50184@devbig004.ftw2.facebook.com>
 <CAHCio2g-S6snHsh84r0Wp1RQW1CR3t_eyUUjcdDaxnUHWTcdFw@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3edd7008-d568-f9b1-a991-bd0ee88f6c52@linux.alibaba.com>
Date: Thu, 21 Feb 2019 11:54:46 -0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <CAHCio2g-S6snHsh84r0Wp1RQW1CR3t_eyUUjcdDaxnUHWTcdFw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/19/19 2:45 AM, 禹舟键 wrote:
> Hi TeJun
> I've built the 5.0.0-rc6 kernel with psi option, but I cannot find any
> cgroup.controllers when I mounted cgroup2.
>
> [root@bogon /]# uname -r
> [root@bogon /]# 5.0.0-rc6+
> [root@bogon /]# mount -t cgroup2 none cgroup2/
> [root@bogon /]# cat cgroup2/cgroup.controllers
> [root@bogon /]
> [root@bogon /]# cat cgroup2/cgroup.subtree_control
> [root@bogon /]#
>
> What's wrong with this kernel? Or maybe I lost some mount option?

I'm not sure what you did before you mounted cgroup2, but if you have 
legacy controllers mounted, you have to unmount them, otherwise 
cgroup.controllers would show up as empty. Or you can pass 
"cgroup_no_v1=" in your kernel parameter.

Yang

>
> Thanks
> Yuzhoujian
>
> Tejun Heo <tj@kernel.org> 于2019年2月19日周二 上午10:32写道：
>> On Sat, Feb 16, 2019 at 08:56:04AM +0800, Yang Shi wrote:
>>> Since PSI has implemented some kind of measure of memory pressure, the
>>> statement about lack of such measure is not true anymore.
>>>
>>> Cc: Tejun Heo <tj@kernel.org>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Jonathan Corbet <corbet@lwn.net>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>>   Documentation/admin-guide/cgroup-v2.rst | 3 +--
>>>   1 file changed, 1 insertion(+), 2 deletions(-)
>>>
>>> diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
>>> index 7bf3f12..9a92013 100644
>>> --- a/Documentation/admin-guide/cgroup-v2.rst
>>> +++ b/Documentation/admin-guide/cgroup-v2.rst
>>> @@ -1310,8 +1310,7 @@ network to a file can use all available memory but can also operate as
>>>   performant with a small amount of memory.  A measure of memory
>>>   pressure - how much the workload is being impacted due to lack of
>>>   memory - is necessary to determine whether a workload needs more
>>> -memory; unfortunately, memory pressure monitoring mechanism isn't
>>> -implemented yet.
>>> +memory.
>> Maybe refer to PSI?
>>
>> Thanks.
>>
>> --
>> tejun

