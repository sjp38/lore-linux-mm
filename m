Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D60A3C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:47:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A46182085A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 14:47:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A46182085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35BDA6B0266; Mon, 10 Jun 2019 10:47:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30CDA6B0269; Mon, 10 Jun 2019 10:47:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FC3B6B026A; Mon, 10 Jun 2019 10:47:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEF1D6B0266
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:47:04 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id v9so3127426vsq.7
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:47:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6Rivltd3iQp6h6PX6R3TLyxDppckQbVvcajOcBycdtc=;
        b=BQ0t3oroW+nd4h3990+clynl5p3p6aBdcwOlum9iVLUkjbCle9B7r8Ey1PH99VcMRq
         xh95TtdAjZpPC7vqK3SomjnjlPIx77wwJsNmPc5bC2WSlLVSARXBj2C+gySDDGqcthxw
         pyQFfMIO7SZPMNi7vKApPbsn7gC6BtQWF+eGCh6DcLsd2IVFDFulowpvKlaZgrT4VXuH
         rF9/TmiAJ/ddBJmqSGNOcRaqXbjwlwptW0ufnEToXNqbua6+ZVcrDmMD3y52etJ5/fS3
         eb01OKErVwYpDAFgdx1OJisr+JDHmH/vHMFmZz04c44FeoDTclzj9JHKP/pD8F11d9UC
         LVzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWBufrdVpYxxRAsdx4hzoD9KjdF/k8qa42QzA3kZxHZrMRVr+DP
	Ipx9Iy+wOdeb1uDu/eW/ymD197p2q7AEreGXMXMk/5BshPLNHx6kNpZBBbPf0oSY/7vAddiZBgY
	Cot+EjQj0BjZLFQTgP7ywLt91XzoYZe0rApF2z9FrHvlqAbcTgC1pAQS5ie1tOjYciQ==
X-Received: by 2002:a67:6b43:: with SMTP id g64mr25993034vsc.183.1560178024699;
        Mon, 10 Jun 2019 07:47:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZhlvCf1jA16L+SVJVcHJso2W0snZMxXR83+83Cd1Gia6rXi/pozxtWXGykXUdn4gxNqWK
X-Received: by 2002:a67:6b43:: with SMTP id g64mr25992969vsc.183.1560178024081;
        Mon, 10 Jun 2019 07:47:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560178024; cv=none;
        d=google.com; s=arc-20160816;
        b=F7w+pSrXB+uUP6BOPJ4zqHazXiKpjkvS/fKZ2sVCByEXFHLPdywZFBSVWUD6vA3JcF
         nD7vD1ih76IZy8CUhAkZIuEbVlTCZ1HFllXTqC/LwsBjMsVmzlR0L+Dcby2QZeoRIdWq
         vaZ40hBxXqEKgAYeo3Ywa/8ovWQPzh9MXJUsPQdTjR70aLkSW73wZIpS2xuaLGN/V8OO
         HP9YS/A2yBidf389lac4rE8Pf2eC2tHZMjCUX2ZRsZ1q8njwyA/REOZ56v0YCR7EKcCV
         rUq5opGY6zc+aki/ZEHnA8fGV8C8FX6wvje0ISl2trIWxM2ZTA8nIuKTf0jOhgxV7G6J
         /QHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6Rivltd3iQp6h6PX6R3TLyxDppckQbVvcajOcBycdtc=;
        b=ZmoGQ/GzIjP8B9s7GFUeWJML5fzDOd9G6+upnE+6DuGvgpQB1HSAuxEytvjCLH2i6p
         wRT9//OchNTwZHmylUDOzK07IFGsUXgTYPXl/9cPh45I2EFrqBk3R4C+Y4Y//ETba0l7
         Fhh/xx/A5kYbwKQft7PJ3Xlz+HTEJedEHwRGRJc/mR/KerXf3QPo5QPj5E6+2+Z+gsUH
         WoOXU1DMkPQJlVzLMQZridO6wzg5qEcKJeWMN2eAzJYxogBcoPSQl4RPfI6pxJh2i0zM
         ARWLQVs3hQCPglP7qb1hgo7wGoB1Y1olgRnPLtOlmaYIsY+pz1qvBYYZxj6VZoCXfIN/
         9grg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 60si2096515uas.11.2019.06.10.07.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 07:47:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1C59AD56EF;
	Mon, 10 Jun 2019 14:46:47 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id EB5FD5DD63;
	Mon, 10 Jun 2019 14:46:44 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Mon, 10 Jun 2019 16:46:44 +0200 (CEST)
Date: Mon, 10 Jun 2019 16:46:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Gaurav Kohli <gkohli@codeaurora.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Jens Axboe <axboe@kernel.dk>,
	Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
	mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190610144641.GA8127@redhat.com>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <20190607133541.GJ3436@hirez.programming.kicks-ass.net>
 <20190607142332.GF3463@hirez.programming.kicks-ass.net>
 <16419960-3703-5988-e7ea-9d3a439f8b05@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16419960-3703-5988-e7ea-9d3a439f8b05@codeaurora.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 10 Jun 2019 14:47:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/10, Gaurav Kohli wrote:
>
> >@@ -1991,6 +1991,28 @@ try_to_wake_up(struct task_struct *p, un
> >  	unsigned long flags;
> >  	int cpu, success = 0;
> >+	if (p == current) {
> >+		/*
> >+		 * We're waking current, this means 'p->on_rq' and 'task_cpu(p)
> >+		 * == smp_processor_id()'. Together this means we can special
> >+		 * case the whole 'p->on_rq && ttwu_remote()' case below
> >+		 * without taking any locks.
> >+		 *
> >+		 * In particular:
> >+		 *  - we rely on Program-Order guarantees for all the ordering,
> >+		 *  - we're serialized against set_special_state() by virtue of
> >+		 *    it disabling IRQs (this allows not taking ->pi_lock).
> >+		 */
> >+		if (!(p->state & state))
> >+			return false;
> >+
>
> Hi Peter, Jen,
>
> As we are not taking pi_lock here , is there possibility of same task dead
> call comes as this point of time for current thread, bcoz of which we have
> seen earlier issue after this commit 0619317ff8ba
> [T114538]  do_task_dead+0xf0/0xf8
> [T114538]  do_exit+0xd5c/0x10fc
> [T114538]  do_group_exit+0xf4/0x110
> [T114538]  get_signal+0x280/0xdd8
> [T114538]  do_notify_resume+0x720/0x968
> [T114538]  work_pending+0x8/0x10
>
> Is there a chance of TASK_DEAD set at this point of time?

In this case try_to_wake_up(current, TASK_NORMAL) will do nothing, see the
if (!(p->state & state)) above.

See also the comment about set_special_state() above. It disables irqs and
this is enough to ensure that try_to_wake_up(current) from irq can't race
with set_special_state(TASK_DEAD).

Oleg.

