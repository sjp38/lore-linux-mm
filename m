Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E17C2C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:49:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3A2020C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:49:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3A2020C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2248E0042; Wed, 31 Jul 2019 11:49:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 489F68E0012; Wed, 31 Jul 2019 11:49:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3518D8E0042; Wed, 31 Jul 2019 11:49:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 131368E0012
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:49:24 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id v135so29658732vke.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=WaV1Lvzd+MQ8kSHIw2ChDVu4wJFwRVwzL1Sm7201XIs=;
        b=szFRXNx/+VUFOhNlhQ94RbGwPeClZVUADWrzJsTaxjjSNTgIsm6QoRDkYF2Id/NavU
         TAX8twAU2cI2sc+SmUtcfvId3q5RbxHPH1+5W4pVQk6F1+IFLxmqLSHt2naLoY0YpL0K
         nrvWNJZXvNMOoeqRQdvDd1HsjzX6rz17Xs3+s0HYMsy1RPBlO1p+xxVARA755Vr9kiCM
         P0Jx5Yu/6nyL6Lc8dA/YKtG9w9ZRC/OtGqQkeXheo3Y56+lnyHF/0kiLHl11AeqadXJ/
         KlOWY2IOmTWsjP4gs+Dk9MBlfs3yTCcLeuyr33OYOx9kAKlCm4K8zbmptLmZQQC7772V
         Pd6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXyyhJnv130gv8A3LQTntWYsT8UvvJHYp/E8I0DEdpk6LJfQODU
	y11/gFdlV8H/L3g83xrgi58jd2NNUOUnWxIKADzHPDd/4nI2rJQrHMKOGips1Yfn3+3rn+L0O0e
	Wsy90FkeY5x5O+6aXQaOHVcIm1brjUapkK/O7CiB3MF6CjGqNPO9/HeBJGpYn32u+zA==
X-Received: by 2002:ab0:3159:: with SMTP id e25mr27133264uam.81.1564588163762;
        Wed, 31 Jul 2019 08:49:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHiF2DiMuVF8tUNoN9mYB/rGmGVfE8arImbUsWGrVqxXmb8NwWMNjm9Rt1eNaf6WNO7A62
X-Received: by 2002:ab0:3159:: with SMTP id e25mr27133200uam.81.1564588163151;
        Wed, 31 Jul 2019 08:49:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588163; cv=none;
        d=google.com; s=arc-20160816;
        b=JH7kjsu1lZWaPzaQzIM306G5/sXOXIRywP39HQoXnzNOYM9I1tDTEPl8poh887DH0q
         ihiRmMQxoOjK8Ofzk5145+lG1DMmyFaGOHUMKqzcOHOrzMBkzTB2YcAB+nzAVR+7czDK
         na18oFuKAwWMzZM7fdE0+g14fCmip3uQ8fBbRznGdK8/FlOgQyWqylO4KdhcDVAp30cO
         u4tzCZH61G9dstaYSgWxOaHPwHio+YOgaSYyXZWsGh3zL2b7X580vrvAlCbdkhe24+Ix
         8vsuXwQHDEczCbnv87o6w5TDHVJeS2EyghNCH5yhX68TI09Kqxc6LxyZQ5Yhdsk3vMbq
         WGQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=WaV1Lvzd+MQ8kSHIw2ChDVu4wJFwRVwzL1Sm7201XIs=;
        b=ucVm8DWj2Y1M6VNmagX1V+eQ7MQ8nfcredVxjjtjY4AkIiZYFoGYfLOIcBon4ARmfj
         hzYs/IVWYN5wXo+nmSxSgWlF552UnNb4vyuTpfi+ksoToW1eHiphAmMCSZZMUa8A3sRr
         GTKWh8Z5fl05GMoGwFC12r3SdIn6gvKwR3mm0BPQBO4c9YSzT1JvKSm5ojWRaJWRTikk
         tMNH5agRN1sItZZrRXYMA2YJZF9km5bIKpJn97lqlrSsnNgiEv3ShAtzlD1AnBoTPIPE
         CgV5LXUOh+5FjkAqBs29lnCn2lQhjaIn3Qi2SVDVDpCF/vxnti6+LELHjoS6CW6qx5n5
         IqUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a11si134798uah.111.2019.07.31.08.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:49:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5434130C26DA;
	Wed, 31 Jul 2019 15:49:22 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 68AA160852;
	Wed, 31 Jul 2019 15:49:20 +0000 (UTC)
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Rik van Riel <riel@surriel.com>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>,
 Michal Hocko <mhocko@kernel.org>
References: <20190729210728.21634-1-longman@redhat.com>
 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
 <8021be4426fdafdce83517194112f43009fb9f6d.camel@surriel.com>
 <b5a462b8-8ef6-6d2c-89aa-b5009c194000@redhat.com>
 <c91e6104acaef118ae09e4b4b0c70232c4583293.camel@surriel.com>
 <01125822-c883-18ce-42e4-942a4f28c128@redhat.com>
 <76dbc397e21d64da75cd07d90b3ca15ca50d6fbb.camel@surriel.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <3307e8f7-4a68-95fc-a5dd-925fd3a5f8d7@redhat.com>
Date: Wed, 31 Jul 2019 11:49:19 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <76dbc397e21d64da75cd07d90b3ca15ca50d6fbb.camel@surriel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Wed, 31 Jul 2019 15:49:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/19 11:07 AM, Rik van Riel wrote:
> On Wed, 2019-07-31 at 10:15 -0400, Waiman Long wrote:
>> On 7/31/19 9:48 AM, Rik van Riel wrote:
>>> On Tue, 2019-07-30 at 17:01 -0400, Waiman Long wrote:
>>>> On 7/29/19 8:26 PM, Rik van Riel wrote:
>>>>> On Mon, 2019-07-29 at 17:42 -0400, Waiman Long wrote:
>>>>>
>>>>>> What I have found is that a long running process on a mostly
>>>>>> idle
>>>>>> system
>>>>>> with many CPUs is likely to cycle through a lot of the CPUs
>>>>>> during
>>>>>> its
>>>>>> lifetime and leave behind its mm in the active_mm of those
>>>>>> CPUs.  My
>>>>>> 2-socket test system have 96 logical CPUs. After running the
>>>>>> test
>>>>>> program for a minute or so, it leaves behind its mm in about
>>>>>> half
>>>>>> of
>>>>>> the
>>>>>> CPUs with a mm_count of 45 after exit. So the dying mm will
>>>>>> stay
>>>>>> until
>>>>>> all those 45 CPUs get new user tasks to run.
>>>>> OK. On what kernel are you seeing this?
>>>>>
>>>>> On current upstream, the code in native_flush_tlb_others()
>>>>> will send a TLB flush to every CPU in mm_cpumask() if page
>>>>> table pages have been freed.
>>>>>
>>>>> That should cause the lazy TLB CPUs to switch to init_mm
>>>>> when the exit->zap_page_range path gets to the point where
>>>>> it frees page tables.
>>>>>
>>>> I was using the latest upstream 5.3-rc2 kernel. It may be the
>>>> case
>>>> that
>>>> the mm has been switched, but the mm_count field of the active_mm
>>>> of
>>>> the
>>>> kthread is not being decremented until a user task runs on a CPU.
>>> Is that something we could fix from the TLB flushing
>>> code?
>>>
>>> When switching to init_mm, drop the refcount on the
>>> lazy mm?
>>>
>>> That way that overhead is not added to the context
>>> switching code.
>> I have thought about that. That will require changing the active_mm
>> of
>> the current task to point to init_mm, for example. Since TLB flush is
>> done in interrupt context, proper coordination between interrupt and
>> process context will require some atomic instruction which will
>> defect
>> the purpose.
> Would it be possible to work around that by scheduling
> a work item that drops the active_mm?
>
> After all, a work item runs in a kernel thread, so by
> the time the work item is run, either the kernel will
> still be running the mm you want to get rid of as
> active_mm, or it will have already gotten rid of it
> earlier.

Yes, that may work.

Thanks,
Longman

