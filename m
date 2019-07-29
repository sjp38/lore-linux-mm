Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC2F1C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:01:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 943C22067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:01:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=efficios.com header.i=@efficios.com header.b="d4dImQ21"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 943C22067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=efficios.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EAF98E0003; Mon, 29 Jul 2019 11:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99BB68E0002; Mon, 29 Jul 2019 11:01:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83CB18E0003; Mon, 29 Jul 2019 11:01:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC9D8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:01:13 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id b85so26585207vke.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:date:from:to:cc
         :message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=T1o1f5qyUGZ4OxJpsco35EOtJ06NPoEJpztYQZO6L04=;
        b=iiTllEDNCDCKU86wJjKH86i6bnPWST/FRZ0sD21JPhttLh9SbM6N7annMOyu0lRKYb
         sDCBap8v2CH9ZEjeTGkzFxT+1kI/PtbMCEn19yDzVBaLeuFf7WJi8J00uGvENIEl0leH
         u8aMBkoO32jkvp1U487Bt01Vl3zB60r6fArcc1qxVBzcUlkiUcJz/MZ6ppzciz50u5/o
         pUfYjXN9BBCif9Hj2ofiSLgLvz/eBrWSyxwVEcXUdcR8H4HKXb0kVGCYIy4pB+/6S+Yp
         I6yjoPkN4U8AutrGwFfwycZ8q7m5pBl+xYWEKzK0bzmc4Jp8z6yuUw8yfZdIeVeNx9kl
         jn7g==
X-Gm-Message-State: APjAAAVd/53K66EpGMI1Ca/vrgah2o1lfz3X2NwB4YRs85AFuu7+jw22
	RrTte51o7L7ymoC1DEYDkESul8PmzuUqYtYZVRPWZXG1IAjt3tilF6Xh05JAsrq+Uta1cPKAqJ9
	Q+VRlGwRvK+qZFJ3X/BpWlNZf8pmGLBHlm6t6uvatkPtkL8/pSQBvOs047BJKe3dNbw==
X-Received: by 2002:a9f:28e4:: with SMTP id d91mr67815236uad.30.1564412473074;
        Mon, 29 Jul 2019 08:01:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6KMuaszvqjeCmCjExCHgQDcw1bD4EPHVViP4J62v4uYuPgXKXK7joYatqrJHN+vKNKKtK
X-Received: by 2002:a9f:28e4:: with SMTP id d91mr67815100uad.30.1564412471773;
        Mon, 29 Jul 2019 08:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564412471; cv=none;
        d=google.com; s=arc-20160816;
        b=jbHIlzclV/2/NIF/sr4wXn9iKbeHTjjewllAIKLQCqNhRTMF8JPnSXVhBoFYuQWFPj
         s+dSeF0WDhtTMB+bIjIdTP1wn+ymsKV4WPx+rb/mz2aouvJr0yWxymZHTW/cZC+8U4mq
         +tjo0wn+E0oGA+TupKwWKB8gokxkfk13OJiZdPVyyRbx3AUKVlaYpPdrOSYYlhEmfuLy
         wLZi9IRoNC5WEyRD0uiW+hot62i3IRBda0iLMxOizrwg04jRFBUz1lkgXAh0wi30ups0
         e63Qk/DyUz3ot3YhhPN/srFFm1pPVaMXcdTLSQn7iwJ5pZuxm7rHCYtCuqox6rrN3e+N
         sbxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date
         :dkim-signature:dkim-filter;
        bh=T1o1f5qyUGZ4OxJpsco35EOtJ06NPoEJpztYQZO6L04=;
        b=IlYCbzKNya99qrWc5cmZcRM8L+qCoZ5ecWdsn2Esx/AYetW2p4BIlCeaTFMJZ8t4ml
         oYK4kPNE8DhDuk58FKhR/RyD1GaxH5vQidpYz3Wr99TDifFGO96X5dqWYU0aZmFtgxVa
         RcHLrClQ2MCeYnmfYPbDLL0wo8G5SFKatq8xFX615Ze9VJpHAP0Doo9MiPSipMwNHG1w
         r4dtJ5AdyU8gMH2Bc0IM6iAx2aMV65yty21FtqXNZnoKfoGefgDJpDoLTDuvbTQfp5gS
         0MYJk5yMsI0RfI7hV4Usj3uFPEndodUAIdxhDHGpPoFhNzfNw5YcCr3vTtHT1r/LsG+C
         BErw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=d4dImQ21;
       spf=pass (google.com: domain of compudj@efficios.com designates 167.114.142.138 as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from mail.efficios.com (mail.efficios.com. [167.114.142.138])
        by mx.google.com with ESMTPS id y13si22986486vsy.234.2019.07.29.08.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 08:01:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of compudj@efficios.com designates 167.114.142.138 as permitted sender) client-ip=167.114.142.138;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@efficios.com header.s=default header.b=d4dImQ21;
       spf=pass (google.com: domain of compudj@efficios.com designates 167.114.142.138 as permitted sender) smtp.mailfrom=compudj@efficios.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=efficios.com
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id DF34625EAA1;
	Mon, 29 Jul 2019 11:01:10 -0400 (EDT)
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10032)
	with ESMTP id uZtBMiAE7-Yk; Mon, 29 Jul 2019 11:01:10 -0400 (EDT)
Received: from localhost (ip6-localhost [IPv6:::1])
	by mail.efficios.com (Postfix) with ESMTP id 537C825EA96;
	Mon, 29 Jul 2019 11:01:10 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.10.3 mail.efficios.com 537C825EA96
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=efficios.com;
	s=default; t=1564412470;
	bh=T1o1f5qyUGZ4OxJpsco35EOtJ06NPoEJpztYQZO6L04=;
	h=Date:From:To:Message-ID:MIME-Version;
	b=d4dImQ217cWJ00CBcqnCBqusCNu+/jyoFvzhoW6B3xgTA0DlDtqc9ruN+GbPcUXRs
	 aHgjC5k/3s7aefn7c0J1q+AjuYtHgNKTHK1n6MWh8uXgRWBuSHKWkC/4h8pSnvopKN
	 j9fFh8Ap+k8f37Sr0N42AMlNZn/vkKrFi2WOjRyHtQnComrf9RrGxx+52e//3hlH4v
	 II1FSQCIySt0ihVv2/RyyZq0nyeOrQmhjbZqpbkKlqqE6RGG9bcMwu0KHqtqEoCX0o
	 H/k3jIPiO953SVYVLei9xA8iCTXOlSn6SRfCprAUZUROQb5mKmf9NlAIq9oJWcEnfX
	 ij1lsuocpqIFA==
X-Virus-Scanned: amavisd-new at efficios.com
Received: from mail.efficios.com ([IPv6:::1])
	by localhost (mail02.efficios.com [IPv6:::1]) (amavisd-new, port 10026)
	with ESMTP id 1_BK-N8dSJnX; Mon, 29 Jul 2019 11:01:10 -0400 (EDT)
Received: from mail02.efficios.com (mail02.efficios.com [167.114.142.138])
	by mail.efficios.com (Postfix) with ESMTP id 3BE7025EA90;
	Mon, 29 Jul 2019 11:01:10 -0400 (EDT)
Date: Mon, 29 Jul 2019 11:01:10 -0400 (EDT)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Phil Auld <pauld@redhat.com>, riel@surriel.com, 
	Andy Lutomirski <luto@kernel.org>
Message-ID: <1705885422.1640.1564412470005.JavaMail.zimbra@efficios.com>
In-Reply-To: <20190729142450.GE31425@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com> <20190729085235.GT31381@hirez.programming.kicks-ass.net> <20190729142450.GE31425@hirez.programming.kicks-ass.net>
Subject: Re: [PATCH] sched: Clean up active_mm reference counting
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [167.114.142.138]
X-Mailer: Zimbra 8.8.12_GA_3817 (ZimbraWebClient - FF67 (Linux)/8.8.12_GA_3817)
Thread-Topic: sched: Clean up active_mm reference counting
Thread-Index: 0iasEWZrmzJZc53BFxqKkneJHIUbdQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

----- On Jul 29, 2019, at 10:24 AM, Peter Zijlstra peterz@infradead.org wrote:
[...]
> ---
> Subject: sched: Clean up active_mm reference counting
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Mon Jul 29 16:05:15 CEST 2019
> 
> The current active_mm reference counting is confusing and sub-optimal.
> 
> Rewrite the code to explicitly consider the 4 separate cases:
> 
>    user -> user
> 
>	When switching between two user tasks, all we need to consider
>	is switch_mm().
> 
>    user -> kernel
> 
>	When switching from a user task to a kernel task (which
>	doesn't have an associated mm) we retain the last mm in our
>	active_mm. Increment a reference count on active_mm.
> 
>  kernel -> kernel
> 
>	When switching between kernel threads, all we need to do is
>	pass along the active_mm reference.
> 
>  kernel -> user
> 
>	When switching between a kernel and user task, we must switch
>	from the last active_mm to the next mm, hoping of course that
>	these are the same. Decrement a reference on the active_mm.
> 
> The code keeps a different order, because as you'll note, both 'to
> user' cases require switch_mm().
> 
> And where the old code would increment/decrement for the 'kernel ->
> kernel' case, the new code observes this is a neutral operation and
> avoids touching the reference count.

Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

> 
> Cc: riel@surriel.com
> Cc: luto@kernel.org
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
> kernel/sched/core.c |   49 ++++++++++++++++++++++++++++++-------------------
> 1 file changed, 30 insertions(+), 19 deletions(-)
> 
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3214,12 +3214,8 @@ static __always_inline struct rq *
> context_switch(struct rq *rq, struct task_struct *prev,
> 	       struct task_struct *next, struct rq_flags *rf)
> {
> -	struct mm_struct *mm, *oldmm;
> -
> 	prepare_task_switch(rq, prev, next);
> 
> -	mm = next->mm;
> -	oldmm = prev->active_mm;
> 	/*
> 	 * For paravirt, this is coupled with an exit in switch_to to
> 	 * combine the page table reload and the switch backend into
> @@ -3228,22 +3224,37 @@ context_switch(struct rq *rq, struct tas
> 	arch_start_context_switch(prev);
> 
> 	/*
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
> 	 */
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
> 	}
> 
>  	rq->clock_update_flags &= ~(RQCF_ACT_SKIP|RQCF_REQ_SKIP);

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

