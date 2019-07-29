Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DCAFC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:22:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC678206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:22:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC678206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9655D8E0005; Mon, 29 Jul 2019 11:22:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 916528E0002; Mon, 29 Jul 2019 11:22:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 806208E0005; Mon, 29 Jul 2019 11:22:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4BA8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:22:19 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id x83so26540080vkx.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:22:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=4IjsqtjQCWeJkRMu8+GmBdYpmkxRimt1RfXx+3B80zk=;
        b=c6joRINNRgNbaLL7rOicwJtwiht3CIoWbi6BHvLTT+YAoO/poYxp/0tE92hsmBjPXQ
         zEYM4m+6nmNg7ybK4MlEm8J/9knW0RT81i/QiEgSytqh5U/cokJNdXUXWeJExkUwOBlA
         Qc3Mj3R0DuP7wFlq/qH9DXPoJ0Gq1uU0kfUaSQ75a0SZt6CWxZ1t2YfnC4ObESE4e808
         mZ4QbQxqXClu5wHso+sh+fLPe81CxL4QV69YuZ7gx/FN5g3Kt+wpeLe2MuwxurUM2m9j
         Jftg5Wd1mmVSpe4q6AbGTxZGhfrE2phLV8HZQjERxRMp5R6HTdWTqpIKT9H2VtSe7Si5
         tbWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXcVf5dKRhW/5ti0GUMPCiciJIqZ0Mq4eaAXJIjifZWZywa8fPq
	c7ZQmNucJEaVXLpQVUY+GFGpDxkmvgbyDQoSfVp1xDBnE8vgVElxPH+uuR4pl7i+91obwQ2px2F
	LTqJlHGiqAA+MEZGBBYruWM/E9Z30I1iyq4rY+u6rDyGpFJLxlOMwefCrUgRihwquJw==
X-Received: by 2002:a67:ec42:: with SMTP id z2mr67936291vso.218.1564413739118;
        Mon, 29 Jul 2019 08:22:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPhKAWaQyjuewMkze6Mlp3xmXWbmtvjikp9uzNv607XHWo1+0D1MQPadX9zHhKz2+ejhn+
X-Received: by 2002:a67:ec42:: with SMTP id z2mr67936215vso.218.1564413738431;
        Mon, 29 Jul 2019 08:22:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564413738; cv=none;
        d=google.com; s=arc-20160816;
        b=Tg4Hv9701t/P48EDsidDs30p/kijz7nfjOlYF8rDJAQ+eCHlArKbZHyBTgZkIRDhfA
         oxEFEAXK8/hVa4YZcCZr9s4fUql0uSNiaBA5MqztbPB0dKSXYVsT2OMkDkRiZufclPL1
         hCUBPR2l5zw4LPqEZjiDH+Ztciiz2Hv7Vy4tx69fMJ2XTU9YOpY/XBqR1m208ppRCg9P
         HPNd3h4WVU6nhSVizzpLsETS1CfT+4sSEPJhHUFoAW4x7M3byZ6nJtTj4W2sp1xnxlcy
         YXyXLy8j5BBzuLBVgsJFvIykJS3XU4j+d2ms5W3NpTCxsJlJrigSUu5w2qe3mOTu4aYn
         5aBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=4IjsqtjQCWeJkRMu8+GmBdYpmkxRimt1RfXx+3B80zk=;
        b=Fh/hznh1vI4582tWBI/3XDVRjV7WvH2B3o0n6T9k2M8KQBer5gyMUYA1/otDJIye7D
         CNNwHTWP04fItRGOcncoSpHEnvH0FurI1Ix7KzC/Xc6aaD7TeUwQD0WnG4aHZ1RxV+6m
         YWL12tTmUig/Pd/w1pk0hNDWKqZKj2B2wVL1gHg/IuAzntVq/UZvRt2FY7MHTEpwIIRZ
         g7lqDpCyIJ8PZNY4hNwmj2tWWv0UkpoUU2y4d0d/bBGEm5BOZLN0ybqWV7opBOxafCCw
         hg+tfwJcTxDqwqyLMYiplXQ8Lutdm+PMu7PSb0D9miL1c4BM26LrWdhlRO3uYQazizlJ
         02qA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p12si9104016vsn.368.2019.07.29.08.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 08:22:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9F24B882EA;
	Mon, 29 Jul 2019 15:22:17 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 017A85D6A0;
	Mon, 29 Jul 2019 15:22:16 +0000 (UTC)
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Phil Auld <pauld@redhat.com>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <20190729142756.GF31425@hirez.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <2bc722b9-3eff-6d99-4ee7-1f4cab8b6c21@redhat.com>
Date: Mon, 29 Jul 2019 11:22:16 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729142756.GF31425@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 29 Jul 2019 15:22:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 10:27 AM, Peter Zijlstra wrote:
> On Mon, Jul 29, 2019 at 10:52:35AM +0200, Peter Zijlstra wrote:
>> On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
>>> It was found that a dying mm_struct where the owning task has exited
>>> can stay on as active_mm of kernel threads as long as no other user
>>> tasks run on those CPUs that use it as active_mm. This prolongs the
>>> life time of dying mm holding up memory and other resources like swap
>>> space that cannot be freed.
>> Sure, but this has been so 'forever', why is it a problem now?
>>
>>> Fix that by forcing the kernel threads to use init_mm as the active_mm
>>> if the previous active_mm is dying.
>>>
>>> The determination of a dying mm is based on the absence of an owning
>>> task. The selection of the owning task only happens with the CONFIG_MEMCG
>>> option. Without that, there is no simple way to determine the life span
>>> of a given mm. So it falls back to the old behavior.
>>>
>>> Signed-off-by: Waiman Long <longman@redhat.com>
>>> ---
>>>  include/linux/mm_types.h | 15 +++++++++++++++
>>>  kernel/sched/core.c      | 13 +++++++++++--
>>>  mm/init-mm.c             |  4 ++++
>>>  3 files changed, 30 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>> index 3a37a89eb7a7..32712e78763c 100644
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -623,6 +623,21 @@ static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
>>>  	return atomic_read(&mm->tlb_flush_pending) > 1;
>>>  }
>>>  
>>> +#ifdef CONFIG_MEMCG
>>> +/*
>>> + * A mm is considered dying if there is no owning task.
>>> + */
>>> +static inline bool mm_dying(struct mm_struct *mm)
>>> +{
>>> +	return !mm->owner;
>>> +}
>>> +#else
>>> +static inline bool mm_dying(struct mm_struct *mm)
>>> +{
>>> +	return false;
>>> +}
>>> +#endif
>>> +
>>>  struct vm_fault;
>> Yuck. So people without memcg will still suffer the terrible 'whatever
>> it is this patch fixes'.
> Also; why then not key off that owner tracking to free the resources
> (and leave the struct mm around) and avoid touching this scheduling
> hot-path ?

The resources are pinned by the reference count. Making a special case
will certainly mess up the existing code.

It is actually a problem for systems that are mostly idle. Only the
kernel->kernel case needs to be updated. If the CPUs isn't busy running
user tasks, a little bit more overhead shouldn't really hurt IMHO.

Cheers,
Longman

