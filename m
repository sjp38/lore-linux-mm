Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC1AAC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:10:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B6A5276CC
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:10:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B6A5276CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E4946B0007; Mon,  3 Jun 2019 12:10:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26E906B000A; Mon,  3 Jun 2019 12:10:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 143306B000C; Mon,  3 Jun 2019 12:10:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id D931C6B0007
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:10:14 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id m19so9151265otl.9
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:10:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1f2/iXjYVl1js7QqV+W9VyJHnQCC2V4df+O1eM3UWYw=;
        b=muWFt1gv7REvXoH4H4fBTMD+PhO8r+wIdqVT81LwpfLkA0NbN7VV0Uimuwez9q93I8
         knufmb3mlsEmXpbMkFVHauykElGNM9DMEqJ1pGt22vw32Ce/CIw6KtmPlER2yGIsxppM
         R5yxcK3CgsE1PVz+zaQdX0ezt8Jt1c9AGeGkRJ/3i7z4RbGwZc8J9gw3eqitrjKEM404
         h/69sOALIj0Kap4Z4Ndu21HLTkyDwPW5/LsKYi/1pJL2MQvid72mdL9vTs6IzFpN2+02
         dlCbUv5GLk7sOtJB/irdRQuMkCYcdmCcDw280AKlzwRuLKv3EypbJV0kMlnuUA88C0WK
         5P5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUDhR59+4X1AQ+gFlNVUv1Dtjn0lIJaRDnXu8PbxeWD3KnjtObe
	joqCuH1opWvFcXamSUshz1GXv3Ir0sP3OxPCFWH41WxdJlPkv2X8BO32i4YJjrsrErXZh0dQPn5
	djjGPw6mhJlkOnFhtW1OS/qcpwE2MdLkhx3p9+7Wj4hChcGzzn+U9PKr+D8xfNZdW1Q==
X-Received: by 2002:a9d:3de1:: with SMTP id l88mr446226otc.222.1559578214372;
        Mon, 03 Jun 2019 09:10:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkKA05bIFvYYBSZeuezSyPvvRzoF0pYC0pXYRVnQkLIc3nT751u9b1Env0uDdiKrsO9JtT
X-Received: by 2002:a9d:3de1:: with SMTP id l88mr446157otc.222.1559578213278;
        Mon, 03 Jun 2019 09:10:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559578213; cv=none;
        d=google.com; s=arc-20160816;
        b=iNzSh24QTQeWjsplHUm8/35NgPwb35W+uWc9kBsFUqYUp+4pdkoHzisMn49oNqPEHk
         vwxWykgkmroqAXgEg1mDwl3dJwULU/q86d9liCCLPLQOM1wCGr+C6WvZLFLBoYr6FaI4
         TSUuqtw/9I27M+2fA2U1fMGJa5S6P+yiJfagUbqwdnOk2eLyLQ3pBXtmb5NBDtNOFPDr
         REbQPit/Ruoq1MipSDngksepvUwHf2nREBaYucbh0GXmMIbG8/b10NzHtVDpxTsQVEHC
         OEu3J4AZwr0a8RsGs8TXMyBinjpByY50NgFDIwx2McgjyGnmVXmlDTT6l2V/fMFWOWOv
         6aew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1f2/iXjYVl1js7QqV+W9VyJHnQCC2V4df+O1eM3UWYw=;
        b=H/zCx2to8+S8Y1w8Q+Y80DY1ihoygR1lzrmasxdE28Coz2UcVLXAKFmBBIPslPOOnK
         TeSCdHUOzfN/f8EsTvAOsQG45vrdfqozegIflhqbSkFX50Tz+J3RwxTm7bnbC1ulXmoU
         0FWorMfOoD9tKZEdGshbFcQBhTmzsDd1Rjrth/TOqlzjLSQIIVQ0N7UzXWPlb3G1vRXM
         CwgevxKA5XVVrbAbb2XIxpJI2HWbmpfecNIjT3xIzlq8Zh+ITAmLalVE4wtn0eRh8jyy
         1edF6QxB6uAfxs1Rde87oRLwAB+OT/U9r4Ifj/zGR4k6cxsm7yuCLhfU3Acj01zpB+Pf
         l56Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o4si7883638oif.39.2019.06.03.09.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 09:10:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 38B0731628E3;
	Mon,  3 Jun 2019 16:10:00 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 0B0785D6A9;
	Mon,  3 Jun 2019 16:09:55 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Mon,  3 Jun 2019 18:09:58 +0200 (CEST)
Date: Mon, 3 Jun 2019 18:09:53 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, hch@lst.de, gkohli@codeaurora.org,
	mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190603160953.GA15244@redhat.com>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <20190603124401.GB3463@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603124401.GB3463@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 03 Jun 2019 16:10:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/03, Peter Zijlstra wrote:
>
> It now also has concurrency on wakeup; but afaict that's harmless, we'll
> get racing stores of p->state = TASK_RUNNING, much the same as if there
> was a remote wakeup vs a wait-loop terminating early.
>
> I suppose the tracepoint consumers might have to deal with some
> artifacts there, but that's their problem.

I guess you mean that trace_sched_waking/wakeup can be reported twice if
try_to_wake_up(current) races with ttwu_remote(). And ttwu_stat().

> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -1990,6 +1990,28 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
> >  	unsigned long flags;
> >  	int cpu, success = 0;
> >  
> > +	if (p == current) {
> > +		/*
> > +		 * We're waking current, this means 'p->on_rq' and 'task_cpu(p)
> > +		 * == smp_processor_id()'. Together this means we can special
> > +		 * case the whole 'p->on_rq && ttwu_remote()' case below
> > +		 * without taking any locks.
> > +		 *
> > +		 * In particular:
> > +		 *  - we rely on Program-Order guarantees for all the ordering,
> > +		 *  - we're serialized against set_special_state() by virtue of
> > +		 *    it disabling IRQs (this allows not taking ->pi_lock).
> > +		 */
> > +		if (!(p->state & state))
> > +			goto out;
> > +
> > +		success = 1;
> > +		trace_sched_waking(p);
> > +		p->state = TASK_RUNNING;
> > +		trace_sched_woken(p);
                ^^^^^^^^^^^^^^^^^
trace_sched_wakeup(p) ?

I see nothing wrong... but probably this is because I don't fully understand
this change. In particular, I don't really understand who else can benefit from
this optimization...

Oleg.

