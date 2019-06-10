Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29A2FC468C1
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C998020862
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:14:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="K9jH0fpc";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="LEjAjg0a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C998020862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F0656B026A; Mon, 10 Jun 2019 09:14:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37A886B026B; Mon, 10 Jun 2019 09:14:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4476B026C; Mon, 10 Jun 2019 09:14:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D263F6B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:13:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so7200172pfj.4
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 06:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=8/KcZFh0RuyFdR1AzEwbyxZ31aFonV09fItJZZtbacw=;
        b=fFtpOIps9bjPt63qk4FasSQjqu3TkD5Hux6R5y46mCXBSp+dYCq8/WIGnXtw1Xc2V3
         K9O1oMhR5UFHSc5IPcWG98Em5Ahzu1HP3ucmd85ha42vieR3n0A1AYcoV6mpRt6NsQnj
         tIIb7VJWa7CZ/n+k10+VOpsPYbEDpmPXSj8kw5qrJ5zYQu4Rw4mksAN4wii021+eCIHw
         Sqer4J4d8UQG3QSg7hABLL04k0PYJBftdMQjiGRLPiFmsGb4yvuutBXVlGqkTphu4WBb
         3BDWGGUqLhtDX+ZczIvGY4CurTAWTF8tOfguWu8FQAbmUnLJvXovUDH5Cd7vsHX856dG
         AVoQ==
X-Gm-Message-State: APjAAAUCHN3F3KptC35H0TVlmyfIOXwC1spggxFTqkL+WIV0HCDbuSxy
	wGFkBwvWLQcWt8FcjRsCtbfNFNL4FCCKOoeMoEjN/CV0LUBGw3hvLSiPL5gvwPMXRZIhGls5XA4
	BszY2hDF+G+6apsJcjZ2K60sR5yboYEsTURm/NM+CIi79G4SyN13tjSRoUkvP15KwyA==
X-Received: by 2002:a17:902:5ac9:: with SMTP id g9mr71015029plm.134.1560172439350;
        Mon, 10 Jun 2019 06:13:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdmoz9zReqIwq+tYX+WKDhCqOTU6CT3LCuDhhlz1BZU1mAMYyvxX+x9LyJQCuPqHnTGgNZ
X-Received: by 2002:a17:902:5ac9:: with SMTP id g9mr71014948plm.134.1560172438390;
        Mon, 10 Jun 2019 06:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560172438; cv=none;
        d=google.com; s=arc-20160816;
        b=pWU6Z89cWt8N+6CiEQzZN0my/hEiii8YrHnoK0425Nqvq03PUiAD3gQfmng6P0fMVb
         6uE8FvuKxprIKKNdVXkC2lT+iv/KgqcYWlHgWWDJyN1BfOL9dsutwYvsEBweXl3cfsgb
         AmxpP4/b1Yfx2XMey1gQ3na+fJazmrlAHiD7+yxbGllTjNgncRhwMShDXglV1issnnoa
         8ONAuMXtQoe5NbAwwHP7JpU2PSEBL98yYctoNhDbtiYB7DUxWcCd/4QrDtqbpZ0SqSJG
         5f1lXY4YXr0PSNi/FTiVZcS92rUy4bO+QveUbax7MvRlCovv9AdaegAVi1YX1B9tHSsQ
         ySnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=8/KcZFh0RuyFdR1AzEwbyxZ31aFonV09fItJZZtbacw=;
        b=QMYlctsfTVr3MJ1V7+RVcxmXqpdyycJF6yfUC7/CC6e3BqcpPd/gCHfrCqKADC7soe
         3vXDBuYDnrnFgCz0zBbNO6i+5sSiBxd5DnSXvGq+kXk8zlnRiuKGVE+899oae/Bizqnh
         Swr8SBM73I5p1mud9+YDHR9R1UTLDU1y/Y1GJarRMiZMeDnUSsYnPmc/wst/TPB7fLAI
         7i33iCvrArW+jLn3xoxLN1FhdBwioyEBYrfuFBpu6KZp1jIIx8XAxStqtPoRLH+mLesU
         UKrGTRBdeD5kUqX/4K7fSCRTu4P0wPERx+GRlKlZGtH8fQoafIOdsp4S93Blv4mRFUuH
         aP+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=K9jH0fpc;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=LEjAjg0a;
       spf=pass (google.com: domain of gkohli@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=gkohli@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id r9si3098185pgv.272.2019.06.10.06.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 06:13:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of gkohli@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=K9jH0fpc;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=LEjAjg0a;
       spf=pass (google.com: domain of gkohli@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=gkohli@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 101C860721; Mon, 10 Jun 2019 13:13:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1560172438;
	bh=LwAgGkchs/Fzdy3FLqNUXNaSYeJqLqml87Nmc/rgzcM=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=K9jH0fpc+XRcZ9zuxXDIa339uRa0nRf5EhBK+/kmJVcRugToXwb1UqzFvoJcH4U3K
	 N5TDkchZacjwtbOwOP6QQu+un0FqniD977J/liGt+8x5TB7DZ01w52gvLQwbHPsWSv
	 QIa83N0giedoYvQp7sfy3S3/rIGD4cMTq6gnTLh0=
Received: from [10.204.79.142] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: gkohli@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 46AF260261;
	Mon, 10 Jun 2019 13:13:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1560172436;
	bh=LwAgGkchs/Fzdy3FLqNUXNaSYeJqLqml87Nmc/rgzcM=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=LEjAjg0aQZqM1UUurRbp+XQjiq2Wm3NTju0vra1LPjDw7qNC3eS7qx//GRxamW0jM
	 dLtr1FOdSG8Jmk20uzL3WugAw+2j2A5vt144CEowkphY+ICsSveoVghM/7NX4eAXZ1
	 Io8d0WWgCM04TVwGUA/P0J/OEd+OLYXSNs0GqKxE=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 46AF260261
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=gkohli@codeaurora.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Peter Zijlstra <peterz@infradead.org>, Jens Axboe <axboe@kernel.dk>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
 oleg@redhat.com, mingo@redhat.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <20190607133541.GJ3436@hirez.programming.kicks-ass.net>
 <20190607142332.GF3463@hirez.programming.kicks-ass.net>
From: Gaurav Kohli <gkohli@codeaurora.org>
Message-ID: <16419960-3703-5988-e7ea-9d3a439f8b05@codeaurora.org>
Date: Mon, 10 Jun 2019 18:43:51 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190607142332.GF3463@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/7/2019 7:53 PM, Peter Zijlstra wrote:
> On Fri, Jun 07, 2019 at 03:35:41PM +0200, Peter Zijlstra wrote:
>> On Wed, Jun 05, 2019 at 09:04:02AM -0600, Jens Axboe wrote:
>>> How about the following plan - if folks are happy with this sched patch,
>>> we can queue it up for 5.3. Once that is in, I'll kill the block change
>>> that special cases the polled task wakeup. For 5.2, we go with Oleg's
>>> patch for the swap case.
>>
>> OK, works for me. I'll go write a proper patch.
> 
> I now have the below; I'll queue that after the long weekend and let
> 0-day chew on it for a while and then push it out to tip or something.
> 
> 
> ---
> Subject: sched: Optimize try_to_wake_up() for local wakeups
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Fri Jun 7 15:39:49 CEST 2019
> 
> Jens reported that significant performance can be had on some block
> workloads (XXX numbers?) by special casing local wakeups. That is,
> wakeups on the current task before it schedules out. Given something
> like the normal wait pattern:
> 
> 	for (;;) {
> 		set_current_state(TASK_UNINTERRUPTIBLE);
> 
> 		if (cond)
> 			break;
> 
> 		schedule();
> 	}
> 	__set_current_state(TASK_RUNNING);
> 
> Any wakeup (on this CPU) after set_current_state() and before
> schedule() would benefit from this.
> 
> Normal wakeups take p->pi_lock, which serializes wakeups to the same
> task. By eliding that we gain concurrency on:
> 
>   - ttwu_stat(); we already had concurrency on rq stats, this now also
>     brings it to task stats. -ENOCARE
> 
>   - tracepoints; it is now possible to get multiple instances of
>     trace_sched_waking() (and possibly trace_sched_wakeup()) for the
>     same task. Tracers will have to learn to cope.
> 
> Furthermore, p->pi_lock is used by set_special_state(), to order
> against TASK_RUNNING stores from other CPUs. But since this is
> strictly CPU local, we don't need the lock, and set_special_state()'s
> disabling of IRQs is sufficient.
> 
> After the normal wakeup takes p->pi_lock it issues
> smp_mb__after_spinlock(), in order to ensure the woken task must
> observe prior stores before we observe the p->state. If this is CPU
> local, this will be satisfied with a compiler barrier, and we rely on
> try_to_wake_up() being a funcation call, which implies such.
> 
> Since, when 'p == current', 'p->on_rq' must be true, the normal wakeup
> would continue into the ttwu_remote() branch, which normally is
> concerned with exactly this wakeup scenario, except from a remote CPU.
> IOW we're waking a task that is still running. In this case, we can
> trivially avoid taking rq->lock, all that's left from this is to set
> p->state.
> 
> This then yields an extremely simple and fast path for 'p == current'.
> 
> Cc: Qian Cai <cai@lca.pw>
> Cc: mingo@redhat.com
> Cc: akpm@linux-foundation.org
> Cc: hch@lst.de
> Cc: gkohli@codeaurora.org
> Cc: oleg@redhat.com
> Reported-by: Jens Axboe <axboe@kernel.dk>
> Tested-by: Jens Axboe <axboe@kernel.dk>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>   kernel/sched/core.c |   33 ++++++++++++++++++++++++++++-----
>   1 file changed, 28 insertions(+), 5 deletions(-)
> 
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1991,6 +1991,28 @@ try_to_wake_up(struct task_struct *p, un
>   	unsigned long flags;
>   	int cpu, success = 0;
>   
> +	if (p == current) {
> +		/*
> +		 * We're waking current, this means 'p->on_rq' and 'task_cpu(p)
> +		 * == smp_processor_id()'. Together this means we can special
> +		 * case the whole 'p->on_rq && ttwu_remote()' case below
> +		 * without taking any locks.
> +		 *
> +		 * In particular:
> +		 *  - we rely on Program-Order guarantees for all the ordering,
> +		 *  - we're serialized against set_special_state() by virtue of
> +		 *    it disabling IRQs (this allows not taking ->pi_lock).
> +		 */
> +		if (!(p->state & state))
> +			return false;
> +

Hi Peter, Jen,

As we are not taking pi_lock here , is there possibility of same task 
dead call comes as this point of time for current thread, bcoz of which 
we have seen earlier issue after this commit 0619317ff8ba
[T114538]  do_task_dead+0xf0/0xf8
[T114538]  do_exit+0xd5c/0x10fc
[T114538]  do_group_exit+0xf4/0x110
[T114538]  get_signal+0x280/0xdd8
[T114538]  do_notify_resume+0x720/0x968
[T114538]  work_pending+0x8/0x10

Is there a chance of TASK_DEAD set at this point of time?


> +		success = 1;
> +		trace_sched_waking(p);
> +		p->state = TASK_RUNNING;
> +		trace_sched_wakeup(p);
> +		goto out;
> +	}
> +
>   	/*
>   	 * If we are going to wake up a thread waiting for CONDITION we
>   	 * need to ensure that CONDITION=1 done by the caller can not be
> @@ -2000,7 +2022,7 @@ try_to_wake_up(struct task_struct *p, un
>   	raw_spin_lock_irqsave(&p->pi_lock, flags);
>   	smp_mb__after_spinlock();
>   	if (!(p->state & state))
> -		goto out;
> +		goto unlock;
>   
>   	trace_sched_waking(p);
>   
> @@ -2030,7 +2052,7 @@ try_to_wake_up(struct task_struct *p, un
>   	 */
>   	smp_rmb();
>   	if (p->on_rq && ttwu_remote(p, wake_flags))
> -		goto stat;
> +		goto unlock;
>   
>   #ifdef CONFIG_SMP
>   	/*
> @@ -2090,10 +2112,11 @@ try_to_wake_up(struct task_struct *p, un
>   #endif /* CONFIG_SMP */
>   
>   	ttwu_queue(p, cpu, wake_flags);
> -stat:
> -	ttwu_stat(p, cpu, wake_flags);
> -out:
> +unlock:
>   	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
> +out:
> +	if (success)
> +		ttwu_stat(p, cpu, wake_flags);
>   
>   	return success;
>   }
> 

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.

