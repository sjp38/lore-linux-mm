Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C535AC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:43:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 763FC206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:43:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="xG7r1Kkm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 763FC206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0677E8E0003; Tue, 30 Jul 2019 04:43:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F334A8E0001; Tue, 30 Jul 2019 04:43:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD4AB8E0003; Tue, 30 Jul 2019 04:43:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7588E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 04:43:26 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j10so28491612wre.18
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:43:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5dtvEs2ayMMPDWlDVD/VDsH5GdZ7NguoxBUGDu1v+1A=;
        b=fiBZiz3bP3zCUBmSycEjBq+o/4eRc9jDE7DGxh3IHUYHali74/43fciHdSlEs5u5AK
         /EnEWVlKCZAi7xYgo0AK37ucKheKFmmMDoNxuU8+DjuhFfY0pvXS02LIKrmX1XnVOBx8
         FNrDuXUQH/8EoA/j8WIujLkUPYHU0cZFYJPGoPnfzsVMp/Ucs7DR3nIO0kjx6dh1FAkJ
         LeGD+NpIy0wiPPqD8jW3Y4xrtZSXjK5uVpjVo6yJTd+pnDm23c8TnIHQxqHFdEY4ZUk+
         1WFjFkBiyJzmpoOzyJupbmhNtx08Aw/RDCAEKwt0Ul4lcz4f48y/oeF7IvInc5fAC6kw
         XA0Q==
X-Gm-Message-State: APjAAAX4KJu16f2gZZKeT23eeh6seH8mjYUOLGzQuQVXnVTEdc32d6/I
	uSQD8XcrmrQ896WctGtjXBVYnp5LsqIBJCA2KajE6dKbpwkzSXIN6wh3BRCx1fr7eimnREIjpXV
	UXpmHEgnoIItNwIH0t0XD1ySyLSdTvI93qjMak50oAKW1k88U4RlRhYw8jzGPvHLIoQ==
X-Received: by 2002:adf:ca0f:: with SMTP id o15mr10140323wrh.135.1564476206097;
        Tue, 30 Jul 2019 01:43:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqww8F4D6HcERY31Dfx8f1OL3IdroGou2bdWo+6135lwO7Z5Hiw7WNtmkif2VVO/Py0LHWxf
X-Received: by 2002:adf:ca0f:: with SMTP id o15mr10140201wrh.135.1564476205234;
        Tue, 30 Jul 2019 01:43:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564476205; cv=none;
        d=google.com; s=arc-20160816;
        b=ZEFO3AxM0GWTTRzQ+KkXvXKGYQnGrMVVHPczlIK7U4asum+b2hDAbHDU6TiU6U5MF4
         /L5GERQgEh6roB6lec3/3fuvb8JGFtr7fSXn3CG8q4dkb1jYCjNRU2wQ/eeUhRulMGXe
         0rnRROaBd6sqPOV+bbVYXiM3okzlQUwapi+ajdhLse221VIUuuV0DG3GNXfVylPM9SLp
         eVlRBMEe6zPgdd+470RMTKocL1V3Com0QGKlaeayaCPKavEVGlESvag/OvCX6QHmVJZb
         +JCm386kjfNu+nvJyT5k1pi1CED0knBaUm8YH8/bMWG38suSfFJboCaPC7yyzfTL91Lt
         WpYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5dtvEs2ayMMPDWlDVD/VDsH5GdZ7NguoxBUGDu1v+1A=;
        b=xm6Tqf8B9dtgTLJfuhhhuzrEBH3QaBzkRt99jDBBO1SDVKj2SUXlKvG+ofHuJG/vbO
         0du9CxQZWtclyNj+z3n0kHV9OaqUfnAbHFykQ2GsvMKMaWYwnXNEP5SXA/CJfdAJH/Ws
         FAM0NPpA9UmGlKuLKXNF9Sk9SfM4Y3ReIRP+ukGCZO2SmeYHEq5fNbhpaa0E+OzMeGWF
         SH3GRZ10st5fowBDl+TDFqYj9bRQdIg2sOOPMA47xZZ0+ca47u0Ck+Z0wFDJVoV71puM
         Y4Jm/nbDwchoooDlw8BLWVGNKFz7LqStUYowBIw+e7sKg1vwUtPmjX1uo/+BWqr0JkIl
         99Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xG7r1Kkm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c18si482493wre.175.2019.07.30.01.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 01:43:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xG7r1Kkm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=5dtvEs2ayMMPDWlDVD/VDsH5GdZ7NguoxBUGDu1v+1A=; b=xG7r1KkmYiasqjaGmGOz72Bvj
	0y27GNWNOy+MpQ4KS37k8JDOY7tYtI8IAqNjYPncukYi7M95ydimStrBb3IpiD/YIKOTorj5dlkW/
	diNd1zqx3gUgaRb8lc8nPTkVsTdY1frc9BUQxXbhADAYnqs+7K/9Caz0prQ0CRz8JZJJ5mQEMVfKU
	bs8EgdLviD8nLA9drj4K+9xd70p5QlYcvdecXAxq07ZZNDeVr1uxRx1RXpFCyLLLpXfug6MwlrklD
	CqSHOGDXKs21BZagSWGc1Ripc5vOQCTL/vcdsMEHwuIuAzFlAZlsmjFVItaBpT0hgmeYaUHpikALG
	94PhG1ZPw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsNj9-0005YZ-KW; Tue, 30 Jul 2019 08:43:23 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id EB84320AFFE9F; Tue, 30 Jul 2019 10:43:21 +0200 (CEST)
Date: Tue, 30 Jul 2019 10:43:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>, Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190730084321.GL31381@hirez.programming.kicks-ass.net>
References: <20190729210728.21634-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729210728.21634-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 05:07:28PM -0400, Waiman Long wrote:
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

So I _really_ hate this complication. I'm thinking if you really care
about this the time is much better spend getting rid of the active_mm
tracking for x86 entirely.

