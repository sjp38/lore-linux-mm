Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81896C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D92821655
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:12:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D92821655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF6978E0003; Mon, 29 Jul 2019 17:12:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACD7C8E0002; Mon, 29 Jul 2019 17:12:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BCA18E0003; Mon, 29 Jul 2019 17:12:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 784088E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:12:07 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id g68so23776196vkb.1
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:12:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=XLrigyJDcDPEuCJQMeXHqH1c3+sXMJfjnJ5H9ky2hhY=;
        b=R4saaXQD7e6mej6P81rkNBc09pPdm4YybEAN1srqAtMXVQROJ0G3d9BoLbt7jodR9I
         JmfI2Sl7Sodfn4b4qpVMARAERNxod6PeQTpac8OP6pptF3qlTvMKvYmL5pck7rmVvsgU
         /uLZGlWWc58ZtSq9AzkuQwV8jQpsjDJFbzxA8L+wsu3bpIpEZ0utSjmJVC8qGjFliES+
         VQN+295iW4Vj4ZGCOEYLPiMAMCOuDddagLZAoVhijJojBrrKyfb1k7fUi5SUwOeOYTVr
         x+JwKiwjrEV7wxm9pVnbdPNk4XZcX1uiQe1V3lrrCACafBcrwAMS/zs35XEzxbJG+zqu
         IDpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUJg07YaFdgRd/heDc/x7QKzNPPc9ToOoveyPUV/whXGbT+6zEk
	uMzCdAYQvHtPj/sCq7suBXQ8gLJYHwkmtrue2Jdoi4nS5CmQ8sRka3Q9KfjXzdk6KdxqtyrJbIM
	92w+eQx+qC8ft7TJIGs9Hs3O/yFkQi6cXNXQA+vOQuyrGR1dGJNk5fq2EtDE/vsu36Q==
X-Received: by 2002:a05:6102:105a:: with SMTP id h26mr75811823vsq.185.1564434727207;
        Mon, 29 Jul 2019 14:12:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3yiyarGb66E/QK1NyUFIvaFOhogjjHXsUktDgu4PTfAFkAukUr2Mo4Q1wO1oA6SdfIso/
X-Received: by 2002:a05:6102:105a:: with SMTP id h26mr75811741vsq.185.1564434726610;
        Mon, 29 Jul 2019 14:12:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564434726; cv=none;
        d=google.com; s=arc-20160816;
        b=w7wpHVstKSHoUJwr5lDczpWpaVAPa77Pb9GZUK4xJE+4ybYctn8pTsfGEYNQ1u1YJ1
         NLEfu7aEwMnydFm+V9nC7zlQ9zqKS0EZwLWn1S8mcxrrdamPzwfNqSRKTnAd945eI4b6
         +YCjRLZ3YLvhrb4VI+HwZmfgVe/LiZYYcSuE6A4UTIBBYZO3NC84N4DhQ5/BlhnV3wB2
         uFqxgUIgT9D0JMhLmElPo8Q1Fmi/6J0vPL32PExhBqvI2K22zy3vX0oag7eX8xU8k+fA
         WOO0UhQhWlZIwtyJj8g9fbJPzjckPgMY8Ojfx0q7aQfRR7xBKxZ3vNhpMxLOSPWM+hRe
         XYvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=XLrigyJDcDPEuCJQMeXHqH1c3+sXMJfjnJ5H9ky2hhY=;
        b=M12JCIMF152SMZCZgShkgOnl/v0sOwus/r1IdtzK31H4LhIjebf+1+tyjst7DXuglL
         VqR4CFIi+cmgt55towbnqibUvhcH1X+1u0C4vUOFlBfMB1HxcjrA1a9jElAip1BJOaHZ
         v57BcDNPKkAOa+ig48QNJ5VamW1Ja9MvImre1kJFwreET7LqOYbb0ASsH/5IgPUgHPZG
         yUjx2A2M7iwljRR+MnRbN57dwMAjJhndYzi/TBJ0MoHR9SUCchuKVQ7vEWMxF3y12JnU
         f/IiYNfuJokBITdrvvstl4ngDY9GyLY/sFadmR7AuHHjRyNMj7oRGQ5ATTkpIq90FmHD
         qvow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k22si15757833vsj.46.2019.07.29.14.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 14:12:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B2F848E22B;
	Mon, 29 Jul 2019 21:12:05 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E5326600CC;
	Mon, 29 Jul 2019 21:12:04 +0000 (UTC)
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>,
 Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>
References: <20190729210728.21634-1-longman@redhat.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <33039acf-b0c8-9888-9d47-85ff152fd31f@redhat.com>
Date: Mon, 29 Jul 2019 17:12:04 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729210728.21634-1-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 29 Jul 2019 21:12:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 5:07 PM, Waiman Long wrote:
> It was found that a dying mm_struct where the owning task has exited
> can stay on as active_mm of kernel threads as long as no other user
> tasks run on those CPUs that use it as active_mm. This prolongs the
> life time of dying mm holding up some resources that cannot be freed
> on a mostly idle system.
>
> Fix that by forcing the kernel threads to use init_mm as the active_mm
> during a kernel thread to kernel thread transition if the previous
> active_mm is dying (!mm_users). This will allows the freeing of resources
> associated with the dying mm ASAP.
>
> The presence of a kernel-to-kernel thread transition indicates that
> the cpu is probably idling with no higher priority user task to run.
> So the overhead of loading the mm_users cacheline should not really
> matter in this case.
>
> My testing on an x86 system showed that the mm_struct was freed within
> seconds after the task exited instead of staying alive for minutes or
> even longer on a mostly idle system before this patch.
>
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  kernel/sched/core.c | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 795077af4f1a..41997e676251 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3214,6 +3214,8 @@ static __always_inline struct rq *
>  context_switch(struct rq *rq, struct task_struct *prev,
>  	       struct task_struct *next, struct rq_flags *rf)
>  {
> +	struct mm_struct *next_mm = next->mm;
> +
>  	prepare_task_switch(rq, prev, next);
>  
>  	/*
> @@ -3229,8 +3231,22 @@ context_switch(struct rq *rq, struct task_struct *prev,
>  	 *
>  	 * kernel ->   user   switch + mmdrop() active
>  	 *   user ->   user   switch
> +	 *
> +	 * kernel -> kernel and !prev->active_mm->mm_users:
> +	 *   switch to init_mm + mmgrab() + mmdrop()
>  	 */
> -	if (!next->mm) {                                // to kernel
> +	if (!next_mm) {					// to kernel
> +		/*
> +		 * Checking is only done on kernel -> kernel transition
> +		 * to avoid any performance overhead while user tasks
> +		 * are running.
> +		 */
> +		if (unlikely(!prev->mm &&
> +			     !atomic_read(&prev->active_mm->mm_users))) {
> +			next_mm = next->active_mm = &init_mm;
> +			mmgrab(next_mm);
> +			goto mm_switch;
> +		}
>  		enter_lazy_tlb(prev->active_mm, next);
>  
>  		next->active_mm = prev->active_mm;
> @@ -3239,6 +3255,7 @@ context_switch(struct rq *rq, struct task_struct *prev,
>  		else
>  			prev->active_mm = NULL;
>  	} else {                                        // to user
> +mm_switch:
>  		/*
>  		 * sys_membarrier() requires an smp_mb() between setting
>  		 * rq->curr and returning to userspace.
> @@ -3248,7 +3265,7 @@ context_switch(struct rq *rq, struct task_struct *prev,
>  		 * finish_task_switch()'s mmdrop().
>  		 */
>  
> -		switch_mm_irqs_off(prev->active_mm, next->mm, next);
> +		switch_mm_irqs_off(prev->active_mm, next_mm, next);
>  
>  		if (!prev->mm) {                        // from kernel
>  			/* will mmdrop() in finish_task_switch(). */

OK, this is my final push.

My previous statements are not totally correct. Many of the resources
are indeed freed when mm_users reaches 0. However, I still think it is
an issue to let the a dying mm structure to stay alive for minutes or
even longer. I am totally fine if you think it is not worth doing.

Thanks,
Longman

