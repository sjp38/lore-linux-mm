Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA814C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:59:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A7A1208E3
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:59:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A7A1208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14D928E0005; Tue, 30 Jul 2019 09:59:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1260A8E0001; Tue, 30 Jul 2019 09:59:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A8C8E0005; Tue, 30 Jul 2019 09:59:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D65CC8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:59:55 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x7so58483833qtp.15
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:59:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=QrdKLx16jdQnHYfi4CV/rTDye/uzMWi4mZ1JzH117/s=;
        b=hBJ5H2SwPPzBx8zWL/JlVjc+9aj7GuAxXZo+Vy7Pl3tTOkjuJxr/u8rLTFjfL3GgoA
         jNQT6Eq9DgiSG5cbYLPoi7lIfiziZcwAEWddV8Wm2a/Rw3WFJ8hLj6eu5kb9AOx4GGJJ
         I+38FIH+zbBmKjEeEZXRrIgwhP1uVJh8Dm4UgPmKoyJfhbn5Xgp5zfUE7SsLMB1wb5y7
         rDTCSkFultIweQoyZqEKBG5HWxNZks9qB3pUvMUO3s41qFNsDNFlRehy+0MgW741k9fV
         VnOl+RsxcxntCLWPTzy67iQTlBuG992SPWbWDBQaO+UfwE6gu3l2IhB4fs1ExTQtsViI
         u6eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTjvx7Ve4BHrcLQ9T7uQtSCwWCjGa376kUMVVGP/56DtB+SLLR
	rnZS7xwkFvrnr/3ocd/vTAyxQkQhJWPQzdAWNycHwgT2zu+5fZuoQTt/htn+qWXyfg44umiCjRA
	Zsg2FtLKALMZIBg93TEEiaSSd329fSMP/E8SVnBpAh7Z62QXwOBUnIR9TDcXo21d/GQ==
X-Received: by 2002:a37:6646:: with SMTP id a67mr78328943qkc.216.1564495195628;
        Tue, 30 Jul 2019 06:59:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+YCUByfCusWJ692TwaE6TpK0MMe6L40yN4nHZ0ERGbQazGboguO6t75q2icyrTZ9VjAER
X-Received: by 2002:a37:6646:: with SMTP id a67mr78328898qkc.216.1564495194869;
        Tue, 30 Jul 2019 06:59:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564495194; cv=none;
        d=google.com; s=arc-20160816;
        b=pie49yBm3e333niGDyDWHJLTT5o0AZDEM7uXy0KvMTX8vD1dVFCQ4rqJu3U5o/pvkP
         /fO4IylWYg27+SIS43FlsZl4P5IX3aJmn7hc9tvVmzLtVxDTEMEdnrLrdq1GR63n+wOw
         E7fOtT089z5nyWKt+m7A/wEDjxE5yaox7fIceTHLemhHsC6DZOV5E+1I0sUBr2Igoji5
         n8Z+iBhnRso0shBCOjRNs22CgOL5p/LdKc0Wr00vemNdFP6Ec7z1cgFnVGkNsmHyaY4p
         ypwSFj2/y64TUXR9i+rO8EH9Ao5rW0nJ5OeTSOhoLJ/1WGv/TRlRnnvNg1krJO22p8LW
         oA5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=QrdKLx16jdQnHYfi4CV/rTDye/uzMWi4mZ1JzH117/s=;
        b=1D1QK5kDifRDrBas6eSNtfKNmwrfGIIUixwQ0otI5pf33MfvEfyTNysYjb8gy26AWy
         fo46pXfUrsnv1XmRsOLMdGfwIG936U/0BtHOkpifCsI9LR3Z8yhEx0gbYc/7BLLVVCtd
         lrlNZ4qmNmJNp8E5bTUZILU4jaoyKZU3nRsiOfcz1uWlDkHnT+EJJUdGgE6XUUk8q/78
         X990tirO7LbIa/GzTvwPV/8xXYmOq5mVtpEeQfwCOfyEvtMnTE0ojFqbl+QBrZfZke0O
         9diV5WjHHriga+lWWYexO+5qB12UngJLQNmGtYzPmNzzPVlLEaaKjObOJi4viKFiifAC
         Ir/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d124si36625463qkb.151.2019.07.30.06.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 06:59:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0BE5D81F0E;
	Tue, 30 Jul 2019 13:59:54 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 208BA60856;
	Tue, 30 Jul 2019 13:59:53 +0000 (UTC)
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Phil Auld <pauld@redhat.com>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>
References: <20190729210728.21634-1-longman@redhat.com>
 <20190730084321.GL31381@hirez.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <396ac6c6-6c99-3cb8-6ff7-106c82df29ab@redhat.com>
Date: Tue, 30 Jul 2019 09:59:52 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190730084321.GL31381@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 30 Jul 2019 13:59:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/30/19 4:43 AM, Peter Zijlstra wrote:
> On Mon, Jul 29, 2019 at 05:07:28PM -0400, Waiman Long wrote:
>> It was found that a dying mm_struct where the owning task has exited
>> can stay on as active_mm of kernel threads as long as no other user
>> tasks run on those CPUs that use it as active_mm. This prolongs the
>> life time of dying mm holding up some resources that cannot be freed
>> on a mostly idle system.
>>
>> Fix that by forcing the kernel threads to use init_mm as the active_mm
>> during a kernel thread to kernel thread transition if the previous
>> active_mm is dying (!mm_users). This will allows the freeing of resources
>> associated with the dying mm ASAP.
>>
>> The presence of a kernel-to-kernel thread transition indicates that
>> the cpu is probably idling with no higher priority user task to run.
>> So the overhead of loading the mm_users cacheline should not really
>> matter in this case.
>>
>> My testing on an x86 system showed that the mm_struct was freed within
>> seconds after the task exited instead of staying alive for minutes or
>> even longer on a mostly idle system before this patch.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
>> ---
>>  kernel/sched/core.c | 21 +++++++++++++++++++--
>>  1 file changed, 19 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
>> index 795077af4f1a..41997e676251 100644
>> --- a/kernel/sched/core.c
>> +++ b/kernel/sched/core.c
>> @@ -3214,6 +3214,8 @@ static __always_inline struct rq *
>>  context_switch(struct rq *rq, struct task_struct *prev,
>>  	       struct task_struct *next, struct rq_flags *rf)
>>  {
>> +	struct mm_struct *next_mm = next->mm;
>> +
>>  	prepare_task_switch(rq, prev, next);
>>  
>>  	/*
>> @@ -3229,8 +3231,22 @@ context_switch(struct rq *rq, struct task_struct *prev,
>>  	 *
>>  	 * kernel ->   user   switch + mmdrop() active
>>  	 *   user ->   user   switch
>> +	 *
>> +	 * kernel -> kernel and !prev->active_mm->mm_users:
>> +	 *   switch to init_mm + mmgrab() + mmdrop()
>>  	 */
>> -	if (!next->mm) {                                // to kernel
>> +	if (!next_mm) {					// to kernel
>> +		/*
>> +		 * Checking is only done on kernel -> kernel transition
>> +		 * to avoid any performance overhead while user tasks
>> +		 * are running.
>> +		 */
>> +		if (unlikely(!prev->mm &&
>> +			     !atomic_read(&prev->active_mm->mm_users))) {
>> +			next_mm = next->active_mm = &init_mm;
>> +			mmgrab(next_mm);
>> +			goto mm_switch;
>> +		}
>>  		enter_lazy_tlb(prev->active_mm, next);
>>  
>>  		next->active_mm = prev->active_mm;
> So I _really_ hate this complication. I'm thinking if you really care
> about this the time is much better spend getting rid of the active_mm
> tracking for x86 entirely.
>
That is fine. I won't pursue further. I will take a look at your
suggestion when I have time, but it will probably be a while :-)

Cheers,
Longman

