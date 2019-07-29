Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB0F0C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:52:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E834206BA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DhA+b9MJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E834206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 338728E0003; Mon, 29 Jul 2019 04:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C2F68E0002; Mon, 29 Jul 2019 04:52:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18A8D8E0003; Mon, 29 Jul 2019 04:52:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2CCC8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:52:39 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so32746801pld.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:52:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pf+2UYjQfUCcdua9fj0MZ+S5GX0o3D3g2pJePzx5CR0=;
        b=jleUz9UX18qH4gCrth2iPPEcFbHQK/HJmkPVx3eY0xFVH2pJ9B5L7XSN492eje4AO8
         cF4cT7+hnvV/nRWJKw6aoRZtBbciYUBJLokAX+Dg3EqO/tej1KyVQ8inWL3w88fKDDb/
         6tUxGvZ90mvEwhe9I05q792WBoB5dQNMYSFYDTQ3UJPXwJ8ZyW/2YHMSyxS0Lu+5eb1I
         2EZiiio5Chdbt/D1b2jJ/fXMTXWboI+jCv4eEl+rXqESy5aZ7XiqPe6BtnyBdXMsY0O1
         wNMuozH7OFhoPS4qw5zcUNEdPEzKQO++ZTsaczvx+w6Vzg1M9dCsww34dYGKXRkkcZBG
         PgnA==
X-Gm-Message-State: APjAAAVh9WP8JaZTWSq/e5eZgUkQm1XtH0zmdRQTQMbEazmfcjKMBvqa
	OoB3kGMvh1D6de97FMeUOzwq8meeuxr58rc+dRotKBmmJyYUKGnqqgg4hwcnhFYfacBUYSyr7Bb
	HNp5KJk0X6SadKU/YHbvZ38wFBb0+3yaaYJvySkU61MLOCYjI9QqOGEP7vi/tBW8XsA==
X-Received: by 2002:a17:902:5a2:: with SMTP id f31mr106941468plf.72.1564390359426;
        Mon, 29 Jul 2019 01:52:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFdOOm4Nx8n99miLKLoXrAMQXk5dB3Y6Ry/pi9bW+oWl8ukm/BOabyVUNmfYFLge6WHkj8
X-Received: by 2002:a17:902:5a2:: with SMTP id f31mr106941430plf.72.1564390358718;
        Mon, 29 Jul 2019 01:52:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564390358; cv=none;
        d=google.com; s=arc-20160816;
        b=U2i/N+sEx4SEoyaTYFwp97Hik5N2pGIvJjgMcikY7u0cAXaXBc4v7G7zesOSqi4K9O
         LUfIFJIska1hhxMLjh+6VvgJRLJJSyu1NXBgTfaRosMlZ/MAlLSPswX1/r2rCoHMdQnD
         QcNmC+j0dcssOHjqXazDzhJzjA9SMJrmvAQ4T6U0JXEIT7uzUDpcKwPeMy3m4IhAcxIS
         MJKMq7LZNnt4S/8uHQMRB46Yzh1yYhNgm6O88w/0JDRYluj44gM+WD7pbKbPeuSSp/n5
         gak2E5y4xYEkClzab1R+W7CE4c29HG6RHN3xhXqEyGV/2OWmNVfaLXn28sosBsBegvDx
         Wtlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pf+2UYjQfUCcdua9fj0MZ+S5GX0o3D3g2pJePzx5CR0=;
        b=m6/Ice45tIFzdANqvrCknllOPaTTCu4l4H5Sui+NYmCisEEshl7Ev52VQ8ABoBAaFr
         w7JbAffxaUt5STcRtklxsIsVQcPMh+8U25QJfoxcoQ1rj3xka3BpWndROvNFUrG5gND7
         WNkTS66xfxBW/FciHBAu3Xmcr1JUOiq/w59H0g+Dbt5p8JtFq0WNHUSALRTdLkinY2ow
         dEmW8xkXcPZlhqKd83k3ielr24QPB1d5VtHN7TahUssVKm3YCARwYl4c6kkgEEKE94zh
         8KrcbR5Kz5gdvFfYPUosLoSus8Axqx5jsdoFEWB9AEJ1lkyXLZRdaITaWLt5xR5M/7NS
         /+5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DhA+b9MJ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h16si25331497plr.94.2019.07.29.01.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 01:52:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DhA+b9MJ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=pf+2UYjQfUCcdua9fj0MZ+S5GX0o3D3g2pJePzx5CR0=; b=DhA+b9MJh5Ib8+w6zn2x8quHB
	ZyZHgZxgg/XbKrTxiGtCQdpM3cFg4XGuYsMDAYnNrVczBl/2Nv7OFHSh+mcrrbRB3CsZUW9MHNNrt
	hxLc2PPXet0jIl6v/iEkqoNQGqGfjh2y6wIj0U9uL3tu+m+ytwxBJ6GUe3EncfUmZufDkAo9NBGTl
	tk1ndEyADAno6POFOsRX31WBYzBYNw8SnR0TvvLv5MI4xEuVt9ZdiwKIZep53qL6gP/2JyPineZHB
	7mr0SiV2fMHTMuyUrgACn2WQ2kRcORbE35cNGZ0PgwyTi6s5FaS5unCDnbS+bUNiukNg0Fm7iyQvt
	+9mKJQu6w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs1OX-0008Ot-Ss; Mon, 29 Jul 2019 08:52:38 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 5ABA72025E7AD; Mon, 29 Jul 2019 10:52:35 +0200 (CEST)
Date: Mon, 29 Jul 2019 10:52:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729085235.GT31381@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190727171047.31610-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
> It was found that a dying mm_struct where the owning task has exited
> can stay on as active_mm of kernel threads as long as no other user
> tasks run on those CPUs that use it as active_mm. This prolongs the
> life time of dying mm holding up memory and other resources like swap
> space that cannot be freed.

Sure, but this has been so 'forever', why is it a problem now?

> Fix that by forcing the kernel threads to use init_mm as the active_mm
> if the previous active_mm is dying.
> 
> The determination of a dying mm is based on the absence of an owning
> task. The selection of the owning task only happens with the CONFIG_MEMCG
> option. Without that, there is no simple way to determine the life span
> of a given mm. So it falls back to the old behavior.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  include/linux/mm_types.h | 15 +++++++++++++++
>  kernel/sched/core.c      | 13 +++++++++++--
>  mm/init-mm.c             |  4 ++++
>  3 files changed, 30 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3a37a89eb7a7..32712e78763c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -623,6 +623,21 @@ static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
>  	return atomic_read(&mm->tlb_flush_pending) > 1;
>  }
>  
> +#ifdef CONFIG_MEMCG
> +/*
> + * A mm is considered dying if there is no owning task.
> + */
> +static inline bool mm_dying(struct mm_struct *mm)
> +{
> +	return !mm->owner;
> +}
> +#else
> +static inline bool mm_dying(struct mm_struct *mm)
> +{
> +	return false;
> +}
> +#endif
> +
>  struct vm_fault;

Yuck. So people without memcg will still suffer the terrible 'whatever
it is this patch fixes'.

>  /**
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 2b037f195473..923a63262dfd 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3233,13 +3233,22 @@ context_switch(struct rq *rq, struct task_struct *prev,
>  	 * Both of these contain the full memory barrier required by
>  	 * membarrier after storing to rq->curr, before returning to
>  	 * user-space.
> +	 *
> +	 * If mm is NULL and oldmm is dying (!owner), we switch to
> +	 * init_mm instead to make sure that oldmm can be freed ASAP.
>  	 */
> -	if (!mm) {
> +	if (!mm && !mm_dying(oldmm)) {
>  		next->active_mm = oldmm;
>  		mmgrab(oldmm);
>  		enter_lazy_tlb(oldmm, next);
> -	} else
> +	} else {
> +		if (!mm) {
> +			mm = &init_mm;
> +			next->active_mm = mm;
> +			mmgrab(mm);
> +		}
>  		switch_mm_irqs_off(oldmm, mm, next);
> +	}
>  
>  	if (!prev->mm) {
>  		prev->active_mm = NULL;

Bah, I see we _still_ haven't 'fixed' that code. And you're making an
even bigger mess of it.

Let me go find where that cleanup went.

