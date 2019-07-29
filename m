Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8436C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:16:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC30621655
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:16:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC30621655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43A818E0005; Mon, 29 Jul 2019 11:16:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C45D8E0002; Mon, 29 Jul 2019 11:16:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B2488E0005; Mon, 29 Jul 2019 11:16:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03F498E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:16:59 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id x83so26534774vkx.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:16:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=mDumN3GTZOafh435bIVGipJDQPGTZMvMftQensVFAnE=;
        b=PmsQIhR8vo8aU3y1gm9e6aDsPCd/zzmSrnuhiE5ggARSIPtxGQSXUBzCBACq2arOl1
         I3FbQoUiO3/XMlY7AXtvWNFYHTM05keaH9rhISzsTgAwfPMo2zWxV6UdM2zcV4vn+y6a
         NQIJdMA1S030zyDVyBMkw33gb/SMk9YHCO5p1J+A7x46FB3ou0S9EshLCNqGCYW1PwVm
         7JrUchTNAtRGaS1du/8BkCUMuig7tuz/fOhugLFvdnLw0rS4wlWtDhicIl13HFse47wV
         bwoLCnQcEqrx8XODgUJKN1eiic6dtLpsPiLdt+RvxaKY8EYcFCliVoSc4YfNftFOdhqg
         FXvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV3AHWibOHLBwZpt0gwbwHAuTSddDYChvOnwJAOdl6QOUfIaj6g
	WkdCplRjJSbI3fWtWS/Yf3j6H2CWm0wdhHnrzyop5T6bYbiPeElxHdd5yz0wogvqNP3tfTFwzDP
	Narlle+RIUCG6rDvT3camTAqaCv5ONf/MrnRiJWiiYDfzmBkAkIZqnoKV0HuaHSlNAQ==
X-Received: by 2002:a1f:2e56:: with SMTP id u83mr619908vku.68.1564413418674;
        Mon, 29 Jul 2019 08:16:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2XNIb+Yo5SspzKsX41Eak8H/Dm8IFSQDGnHpkpR8BJyenhRrPzjslLvw7PbLIEGexuAB5
X-Received: by 2002:a1f:2e56:: with SMTP id u83mr619852vku.68.1564413418046;
        Mon, 29 Jul 2019 08:16:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564413418; cv=none;
        d=google.com; s=arc-20160816;
        b=n2xwp64zqNr7+y3tGO3Vewr32OyGooUXhNNUB7aHQOW/OwexHDiKF0TMi8g5QO6xEc
         /f+ybBMml0PB38H98a3dvp0119VdOTMDKydRSmVaR/U4R62nrAQFG3Upv3t6xNr9oV6U
         zs7PyIFpCVuAEFpn0BIe8dfAMZciS2F9sYMl9LgHfIZKyzfgjMkiZNk1pRvI+qRhh/OV
         yIqzyAjoPvMYLIeTLwnAIMkOYRsKTeEJRGwCHLc3lyORUocYduGIpYAY2o43mjRxRHZA
         riPNPjmbMKmjsm7n6F4LJCjYv1QDP1Cvf4ZfLn/JJlWx+LEg02yxSAHFSsQ4zN6S7XoQ
         1Xrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=mDumN3GTZOafh435bIVGipJDQPGTZMvMftQensVFAnE=;
        b=Qo+LVrJjlC4kB84ptMQ0yISR7//EKAZB/uwUYpiwJ/i5ia82riMmET7FyiDywHSv+l
         OBXWH2VpISrh+Duc5rCpIp0ujg6GO6vv8aBHhO05mBK8BN3zfPFqGx8DiJih+lRqjtGH
         Mm2XTkOeDmFBZOG+DiaKMb8/JIw/7slXxJ6bX4+zim0/C2/AqiYrZse5iVj/wzeDeTeI
         CRGP4rJxdqd0mVVs53QqQCKo6dWz9rXzPTYu2U16UEJUODWXPbP1DYOu4lBCA+VwQIfQ
         3TDD+Tt06ksfHgR5BsVHVdKJUaXGq0Q6DeR8KG0Tr7qPmfJwi2k3Y6dGvUQjdDZMLeLR
         nNiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e65si14111197vkf.42.2019.07.29.08.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 08:16:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E43B0307D868;
	Mon, 29 Jul 2019 15:16:56 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9B84710016E9;
	Mon, 29 Jul 2019 15:16:55 +0000 (UTC)
Subject: Re: [PATCH] sched: Clean up active_mm reference counting
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Phil Auld <pauld@redhat.com>, riel@surriel.com, luto@kernel.org,
 mathieu.desnoyers@efficios.com
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <20190729142450.GE31425@hirez.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <45546d31-4efb-c303-deae-7c866b0071a9@redhat.com>
Date: Mon, 29 Jul 2019 11:16:55 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729142450.GE31425@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 29 Jul 2019 15:16:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 10:24 AM, Peter Zijlstra wrote:
> On Mon, Jul 29, 2019 at 10:52:35AM +0200, Peter Zijlstra wrote:
>
> ---
> Subject: sched: Clean up active_mm reference counting
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Mon Jul 29 16:05:15 CEST 2019
>
> The current active_mm reference counting is confusing and sub-optimal.
>
> Rewrite the code to explicitly consider the 4 separate cases:
>
>     user -> user
>
> 	When switching between two user tasks, all we need to consider
> 	is switch_mm().
>
>     user -> kernel
>
> 	When switching from a user task to a kernel task (which
> 	doesn't have an associated mm) we retain the last mm in our
> 	active_mm. Increment a reference count on active_mm.
>
>   kernel -> kernel
>
> 	When switching between kernel threads, all we need to do is
> 	pass along the active_mm reference.
>
>   kernel -> user
>
> 	When switching between a kernel and user task, we must switch
> 	from the last active_mm to the next mm, hoping of course that
> 	these are the same. Decrement a reference on the active_mm.
>
> The code keeps a different order, because as you'll note, both 'to
> user' cases require switch_mm().
>
> And where the old code would increment/decrement for the 'kernel ->
> kernel' case, the new code observes this is a neutral operation and
> avoids touching the reference count.

I am aware of that behavior which is indeed redundant, but it is not
what I am trying to fix and so I kind of leave it alone in my patch.


>
> Cc: riel@surriel.com
> Cc: luto@kernel.org
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  kernel/sched/core.c |   49 ++++++++++++++++++++++++++++++-------------------
>  1 file changed, 30 insertions(+), 19 deletions(-)
>
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3214,12 +3214,8 @@ static __always_inline struct rq *
>  context_switch(struct rq *rq, struct task_struct *prev,
>  	       struct task_struct *next, struct rq_flags *rf)
>  {
> -	struct mm_struct *mm, *oldmm;
> -
>  	prepare_task_switch(rq, prev, next);
>  
> -	mm = next->mm;
> -	oldmm = prev->active_mm;
>  	/*
>  	 * For paravirt, this is coupled with an exit in switch_to to
>  	 * combine the page table reload and the switch backend into
> @@ -3228,22 +3224,37 @@ context_switch(struct rq *rq, struct tas
>  	arch_start_context_switch(prev);
>  
>  	/*
> -	 * If mm is non-NULL, we pass through switch_mm(). If mm is
> -	 * NULL, we will pass through mmdrop() in finish_task_switch().
> -	 * Both of these contain the full memory barrier required by
> -	 * membarrier after storing to rq->curr, before returning to
> -	 * user-space.
> +	 * kernel -> kernel   lazy + transfer active
> +	 *   user -> kernel   lazy + mmgrab() active
> +	 *
> +	 * kernel ->   user   switch + mmdrop() active
> +	 *   user ->   user   switch
>  	 */
> -	if (!mm) {
> -		next->active_mm = oldmm;
> -		mmgrab(oldmm);
> -		enter_lazy_tlb(oldmm, next);
> -	} else
> -		switch_mm_irqs_off(oldmm, mm, next);
> -
> -	if (!prev->mm) {
> -		prev->active_mm = NULL;
> -		rq->prev_mm = oldmm;
> +	if (!next->mm) {                                // to kernel
> +		enter_lazy_tlb(prev->active_mm, next);
> +
> +		next->active_mm = prev->active_mm;
> +		if (prev->mm)                           // from user
> +			mmgrab(prev->active_mm);
> +		else
> +			prev->active_mm = NULL;
> +	} else {                                        // to user
> +		/*
> +		 * sys_membarrier() requires an smp_mb() between setting
> +		 * rq->curr and returning to userspace.
> +		 *
> +		 * The below provides this either through switch_mm(), or in
> +		 * case 'prev->active_mm == next->mm' through
> +		 * finish_task_switch()'s mmdrop().
> +		 */
> +
> +		switch_mm_irqs_off(prev->active_mm, next->mm, next);
> +
> +		if (!prev->mm) {                        // from kernel
> +			/* will mmdrop() in finish_task_switch(). */
> +			rq->prev_mm = prev->active_mm;
> +			prev->active_mm = NULL;
> +		}
>  	}
>  
>  	rq->clock_update_flags &= ~(RQCF_ACT_SKIP|RQCF_REQ_SKIP);

This patch looks fine to me, I don't see any problem in its logic.

Acked-by: Waiman Long <longman@redhat.com>

The problem that I am trying to fix is in the kernel->kernel case where
the active_mm just get passed along. I would like to just bump the
active_mm off if it is dying. I will see what I can do to make it work
even with !CONFIG_MEMCG.

Cheers,
Longman

