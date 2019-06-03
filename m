Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FBEC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 12:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FDB427EBE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 12:44:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kNNcDuFg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FDB427EBE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10EE46B0008; Mon,  3 Jun 2019 08:44:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C0666B000D; Mon,  3 Jun 2019 08:44:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F17466B000E; Mon,  3 Jun 2019 08:44:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B79CA6B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 08:44:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so11703573pld.15
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 05:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GNP3D276BFtDK39lLo6rJPWpnwlFMjiWsjF1eSRNq9k=;
        b=MBPtZk2VrL6DIegOLW9J3ti16I1pALAO6DL3wzTVW8U28dTEHl++0Npzs1SoyncTfw
         CuU+ECwbU4iGyH1pj+MMROb2+/HOERUKK/f3uFv0dA9TBkWAOp7kM7HF+GKUF9XET/7e
         MYoxPLkk1OD+w9OTiCND3GnzHM9Jd+ysWpfqIKpc1z83dGwv2/hPV5Be/0vJmGodgmzZ
         Id5WjamShaaPeyLuqd2bAG6CCxEvHrFAxDJYbdmAao+AeyO7jba5X3BnM6WdW9GnNzBM
         Bzm/tOuJA0duoYQ1FRtY9nyg+KTFCnvy35XijjT8reI5gQ4yWDQEDc443wrWIfL0PL+f
         r7ew==
X-Gm-Message-State: APjAAAW9fYp/D3fBwxL7OrcoCoUCl/8F+8fPOVgSfWL+S48rYa9Yn28O
	GXTx6LsjcZ0ETMmuusaE3/Cns94QHOc7qVjfZrObFJUXDe+ev0ZolE41UkBQGIX3+nQxn2qZBpV
	GulQ2aBclGk04YYc5YQXQTBiORQH2ld74DYTIH/8Puu6wmNhtu3HL+UpghqdbnfwW2A==
X-Received: by 2002:a17:90a:240c:: with SMTP id h12mr30120690pje.12.1559565848323;
        Mon, 03 Jun 2019 05:44:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrXlvMnnCaUHP393V+EDTXqhI6ryvDJRwvUbyjfX6369mMZRS7WXy3y6ARx+NvgeauCxV4
X-Received: by 2002:a17:90a:240c:: with SMTP id h12mr30120610pje.12.1559565847436;
        Mon, 03 Jun 2019 05:44:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559565847; cv=none;
        d=google.com; s=arc-20160816;
        b=xOUrBM4ldkqYIRHEHouIVsuIAq6eaJvjSfCdmrMR0/HL+wyb7xIUEj7/1Pi1iNYOad
         FmZ8pPfcX9l8oYL9Qb19OWDfdZ3dWoFm18nro3P/ys2zH7YCldDarZqZYqmp/ETt0AcF
         yqb4DsRBME2ZnjUFL+PLwO5SJf8SelpBu8zxW6KKFItUeCMkACVSW5Vv3sEexN8yPVhc
         c2LjHHi/NNvmsyc0kjLo8meJ8PvLjTTU2YrG9bqlGPtTczfmwS2ewMEblDElFdrmEc/p
         Y4a2PwRCnIFtyy+ckDFz1IxD80Dz5TwUBw3JiWLAeALYGvHYCOXzeTjsKR46cSkVX+Cb
         vOww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GNP3D276BFtDK39lLo6rJPWpnwlFMjiWsjF1eSRNq9k=;
        b=OdmHjEyHR6Mm7ws+33kuPOjRn5k/aA7Xay1VJ57pn2eA2Udz+7Ajj8HBVWQXHlHvbV
         8tTaGQ30oHDbCCBeZV1foTnXd0fzOybvrwMUQLaVJr4g7Or6cXe6X+twtiEF3d1eLzJa
         NC0g7r1mhySW0hH1xo0JdmK6oj+eaxYcnkF00wmHeYjCQ4TWK1cHQBktMX056in057Ml
         PRfu2+TXf9H5qPcDKhKowlP6uV3YRcxzMOwa2nr+qTl5LRDZo+UJo0LznAx254KotE8G
         KZn5xO9DTVyBsTTqhdcjDDUezz0KbMCn39EQ7/4rFWOY9S2rjYLJf4a/8EIjguVkPO4k
         Nn6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kNNcDuFg;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id j1si19436503pld.399.2019.06.03.05.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 05:44:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kNNcDuFg;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=GNP3D276BFtDK39lLo6rJPWpnwlFMjiWsjF1eSRNq9k=; b=kNNcDuFgjSY3vB9kQuAo8Ap2W
	LZjW6ej3axV9mqJfEPOQFrK+BxXkmgewzcyXkXEFQ+hm/CEJTLQGKgVTB5n8CAXGs7hKVoBe6o+pD
	NVaeCspnEij+mfEOtozvjOHEcxOtjBcWqhpbjaxRfUU87KZ+f0jBRMoRfpzzjfMHRhzDmN5dDbvY5
	hlb6vN8a82YFI3+tI26fcMhxrMjTfMYk7TH61euKay+ArCHXVntMUgrvk28lZR4AlDs9wrqOPLlyv
	R4QthQrORiZVlXpb3A5eNEt+oucLFWpIKVIvVP+yiz9BLLHGzskGur/XNFIBDQGswlMoikfSWafKe
	meD4M2llg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hXmJn-0004ug-CU; Mon, 03 Jun 2019 12:44:03 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B738F20274AFF; Mon,  3 Jun 2019 14:44:01 +0200 (CEST)
Date: Mon, 3 Jun 2019 14:44:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
	oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190603124401.GB3463@hirez.programming.kicks-ass.net>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603123705.GB3419@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 02:37:05PM +0200, Peter Zijlstra wrote:

> Anyway, Oleg, do you see anything blatantly buggered with this patch?
> 
> (the stats were already dodgy for rq-stats, this patch makes them dodgy
> for task-stats too)

It now also has concurrency on wakeup; but afaict that's harmless, we'll
get racing stores of p->state = TASK_RUNNING, much the same as if there
was a remote wakeup vs a wait-loop terminating early.

I suppose the tracepoint consumers might have to deal with some
artifacts there, but that's their problem.

> ---
>  kernel/sched/core.c | 38 ++++++++++++++++++++++++++++++++------
>  1 file changed, 32 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 102dfcf0a29a..474aa4c8e9d2 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1990,6 +1990,28 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>  	unsigned long flags;
>  	int cpu, success = 0;
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
> +			goto out;
> +
> +		success = 1;
> +		trace_sched_waking(p);
> +		p->state = TASK_RUNNING;
> +		trace_sched_woken(p);
> +		goto out;
> +	}
> +
>  	/*
>  	 * If we are going to wake up a thread waiting for CONDITION we
>  	 * need to ensure that CONDITION=1 done by the caller can not be
> @@ -1999,7 +2021,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>  	raw_spin_lock_irqsave(&p->pi_lock, flags);
>  	smp_mb__after_spinlock();
>  	if (!(p->state & state))
> -		goto out;
> +		goto unlock;
>  
>  	trace_sched_waking(p);
>  
> @@ -2029,7 +2051,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>  	 */
>  	smp_rmb();
>  	if (p->on_rq && ttwu_remote(p, wake_flags))
> -		goto stat;
> +		goto unlock;
>  
>  #ifdef CONFIG_SMP
>  	/*
> @@ -2089,12 +2111,16 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>  #endif /* CONFIG_SMP */
>  
>  	ttwu_queue(p, cpu, wake_flags);
> -stat:
> -	ttwu_stat(p, cpu, wake_flags);
> -out:
> +unlock:
>  	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
>  
> -	return success;
> +out:
> +	if (success) {
> +		ttwu_stat(p, cpu, wake_flags);
> +		return true;
> +	}
> +
> +	return false;
>  }
>  
>  /**

