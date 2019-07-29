Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0487AC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB123206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:51:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB123206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C1E08E0008; Mon, 29 Jul 2019 10:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 472F78E0007; Mon, 29 Jul 2019 10:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 339DF8E0008; Mon, 29 Jul 2019 10:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6CB8E0007
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:51:55 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id k1so15936995vsq.8
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=QqjI33qHunUur1nhhQVkdmvFOLNf0wM7HpSER3n3VLc=;
        b=POtDSshPGBH7nzv37QOgVJywwJstyh3IzS6x7JfAbPghWxyFKKgKeZI3wOXeyEJydM
         FtlhIRvka60iLCs97I21fBHzl6VSGSEHv7zITjL/8yYOGbhL9huw3kAakVb+9iUEe79O
         2qRCz86Ut8nj8ccd/i13ALVzfyd/6KOEFmd0ZOtjWaMm4N/8g4UNTahmsxpQklTUvvNn
         /BSrwjM/7zDQsdznWQSzdy4PZKBScsjM3IVfH8gPY1qW4t2iIqeE3nlp+/qmC0ZmHTZq
         Tfw5U5m+u0HX1xI18Z1RYXma2pj+CyM/hIP9YnIwDAmwi1wnKKkHJeJWWhmathWZPpiM
         gYMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUVywCjLDOS3TtV/ZgMgWEkMSXJ/GTZGn9yZjlj/TcyMFdZUGo4
	uXADhss6iL3KtlQx2VhQi9O8dgOT1/SRqgFebpZRYFcCnP4pi8R0FfMQCISldncyUgGVpy2bSBE
	HTCYVX/yvtVtz82Adm4ZjuIJfpO34+ywF11crWWNWf5lKKxO4tfH1zC5lD2ja2HjQ2A==
X-Received: by 2002:ab0:2a90:: with SMTP id h16mr57016312uar.57.1564411914731;
        Mon, 29 Jul 2019 07:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPNeLNYNv/qFZQy9ojNGNSneaUWNrwckdGNteanvUcCAgYCVK9zm6elMS9XLlGRO+jGgCy
X-Received: by 2002:ab0:2a90:: with SMTP id h16mr57016243uar.57.1564411913914;
        Mon, 29 Jul 2019 07:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564411913; cv=none;
        d=google.com; s=arc-20160816;
        b=f4koKOltgB9dgKZ4JZQTjNEjWae1vhuG9N2zVa6Iiu7zFyuCArS4F1JSVVXG2ngdAg
         VslGDXOT5yJdV6k1zKyLOD29iJkKQwB6jn+FjfnIxo2mWiia54UkOe7ZCyOUaM9IkGIx
         /Vr8UClqDyKw8dh3s4xvKshF78heQLXSZjBA/bAnwinz8XqasHoEDzHHTPxnI+A2TF5e
         +6K9l4oqUs2pt82gLvuuGkmkXEWf7wSScz7Q1lf/dSLXNzGutUze6liljblCtu5mtDr5
         JwlJmtZNdnjUfX/7pN0jrF6tChrqxxyrBdeFi5q5fqtddABJioLoGBpZwRS9CknWW5bx
         a9gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=QqjI33qHunUur1nhhQVkdmvFOLNf0wM7HpSER3n3VLc=;
        b=oUFkuW7T+duq1UmvYA+13i5jeV0M5we2UCWAq3gWrMX6A0lOi0gPUpbdHupvbnQlVf
         uhjzYaycnhZA6682cGa4JIlSfc/gRAfOUjAw3SGkGXejYKjVtKDMT3sjRMwX7RfYkgM8
         LHwxlfo6FXMCi90iHTkimCvYRulmqMzBCKqK1fui9QauxEfy6LXDxRxRkzj5AzxPDvm0
         uOelrDe1a6bUUfIIJ8msnKsTB5qrhh0PWUQHuhTzMRHTRIN3N354i0JlShsDv8YVo8YD
         a9FVD/sFrnK/onp3aSbpmoFT/2ypnJaVVlhJ3qkVT9AFukolSi2KS+FyUGfZ1SvjJagE
         30xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d89si13625379uad.242.2019.07.29.07.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 07:51:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 07480C057E9F;
	Mon, 29 Jul 2019 14:51:53 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 479A55D6A0;
	Mon, 29 Jul 2019 14:51:52 +0000 (UTC)
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Phil Auld <pauld@redhat.com>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
Date: Mon, 29 Jul 2019 10:51:51 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729085235.GT31381@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 29 Jul 2019 14:51:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 4:52 AM, Peter Zijlstra wrote:
> On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
>> It was found that a dying mm_struct where the owning task has exited
>> can stay on as active_mm of kernel threads as long as no other user
>> tasks run on those CPUs that use it as active_mm. This prolongs the
>> life time of dying mm holding up memory and other resources like swap
>> space that cannot be freed.
> Sure, but this has been so 'forever', why is it a problem now?

I ran into this probem when running a test program that keeps on
allocating and touch memory and it eventually fails as the swap space is
full. After the failure, I could not rerun the test program again
because the swap space remained full. I finally track it down to the
fact that the mm stayed on as active_mm of kernel threads. I have to
make sure that all the idle cpus get a user task to run to bump the
dying mm off the active_mm of those cpus, but this is just a workaround,
not a solution to this problem.

>
>> Fix that by forcing the kernel threads to use init_mm as the active_mm
>> if the previous active_mm is dying.
>>
>> The determination of a dying mm is based on the absence of an owning
>> task. The selection of the owning task only happens with the CONFIG_MEMCG
>> option. Without that, there is no simple way to determine the life span
>> of a given mm. So it falls back to the old behavior.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
>> ---
>>  include/linux/mm_types.h | 15 +++++++++++++++
>>  kernel/sched/core.c      | 13 +++++++++++--
>>  mm/init-mm.c             |  4 ++++
>>  3 files changed, 30 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 3a37a89eb7a7..32712e78763c 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -623,6 +623,21 @@ static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
>>  	return atomic_read(&mm->tlb_flush_pending) > 1;
>>  }
>>  
>> +#ifdef CONFIG_MEMCG
>> +/*
>> + * A mm is considered dying if there is no owning task.
>> + */
>> +static inline bool mm_dying(struct mm_struct *mm)
>> +{
>> +	return !mm->owner;
>> +}
>> +#else
>> +static inline bool mm_dying(struct mm_struct *mm)
>> +{
>> +	return false;
>> +}
>> +#endif
>> +
>>  struct vm_fault;
> Yuck. So people without memcg will still suffer the terrible 'whatever
> it is this patch fixes'.
>
That is true.
>>  /**
>> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
>> index 2b037f195473..923a63262dfd 100644
>> --- a/kernel/sched/core.c
>> +++ b/kernel/sched/core.c
>> @@ -3233,13 +3233,22 @@ context_switch(struct rq *rq, struct task_struct *prev,
>>  	 * Both of these contain the full memory barrier required by
>>  	 * membarrier after storing to rq->curr, before returning to
>>  	 * user-space.
>> +	 *
>> +	 * If mm is NULL and oldmm is dying (!owner), we switch to
>> +	 * init_mm instead to make sure that oldmm can be freed ASAP.
>>  	 */
>> -	if (!mm) {
>> +	if (!mm && !mm_dying(oldmm)) {
>>  		next->active_mm = oldmm;
>>  		mmgrab(oldmm);
>>  		enter_lazy_tlb(oldmm, next);
>> -	} else
>> +	} else {
>> +		if (!mm) {
>> +			mm = &init_mm;
>> +			next->active_mm = mm;
>> +			mmgrab(mm);
>> +		}
>>  		switch_mm_irqs_off(oldmm, mm, next);
>> +	}
>>  
>>  	if (!prev->mm) {
>>  		prev->active_mm = NULL;
> Bah, I see we _still_ haven't 'fixed' that code. And you're making an
> even bigger mess of it.
>
> Let me go find where that cleanup went.

It would be nice if there is a better solution.

Cheers,
Longman

