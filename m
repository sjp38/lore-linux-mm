Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 815BBC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 12:37:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4646F27C3C
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 12:37:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RpyhTr7F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4646F27C3C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D21D96B000E; Mon,  3 Jun 2019 08:37:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD32E6B0266; Mon,  3 Jun 2019 08:37:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B99186B0269; Mon,  3 Jun 2019 08:37:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A17A6B000E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 08:37:13 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so13709549ioh.22
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 05:37:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N37Qdwkcyg7EfrQtvP7k2DD+LJdWpMJfet+l9N2pWCw=;
        b=eg/bOR0vZ0ImdV7Egk4KHgWMj+fRgZmgiLi91mplkX9LdvTbkwHAP1k5PBbl+Yia98
         Kb4pfgsqUZ1BFs17fL37ustgS0PVeiCfu/ppP/uCQbU2XQSyjzWBvHMCZ1Ep3iVBZJRx
         C7TkjrckUNUdridFkgQ8bqGla1YHhSy4u7ZsOqHEateahZ5flS5VNpY3pIBuGzuMRHkP
         6XF4jbRNOvQaEpt9AsPziizamjFykfB4/3MjPr1F+zGgequgmuykL9oAa6ceXif2FoP5
         lo2rUE1Eafg9zMlBeQUJHyTBqbVcA0G6fB8y0gw8jEg/BRmgd3tuy3yfQKvodVCqLfix
         2jrg==
X-Gm-Message-State: APjAAAXCcggIbptZn8w9iEZtg0DQlNR4NJUzJWz9/zsOAfDNCzoHUel/
	1QbI4YmpMNqo1jViMmBgHNxixd0SWn0UgC2haqbWS83GYd/xgs4hKdYGcXj5cQIuIdZo6quGFjS
	jKZx1/0aaLHNPtGoCNpKvhvwr2YH7Xvg9aqgY3KQBbQXmbybk/hDEf71GxtOfm9iH1g==
X-Received: by 2002:a02:1986:: with SMTP id b128mr17524061jab.136.1559565433350;
        Mon, 03 Jun 2019 05:37:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxxhdmRJ3YwEJ1Fj0LkQz5NE+PxfNZDGOm1QNFZTjInQTg+RheBTZpJ6TCjY1GjH2ocMvC
X-Received: by 2002:a02:1986:: with SMTP id b128mr17523992jab.136.1559565432264;
        Mon, 03 Jun 2019 05:37:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559565432; cv=none;
        d=google.com; s=arc-20160816;
        b=Qw9ZcBHI7J3fO4uKU6+LBn9JxSNBtFNDHqVPf9/XnqH2V8iogyrjoA4BSmwrbkq2B1
         y8JXutCut9Lc/FmjbQRpi1KH/PjaMBQCW24GjaFFYZmQEqhO/xiTXKB5HiHa8LC9k5dI
         7PQa6gLmLH9HhpSroaCzER5MrPrzo6owYZpmfH/IhNWkwNG4PoS2vBLZ7kCKONTiOZoB
         xO4lNAAPjZ5EFbX9rrfCj7qGIySzYKaPYCoozR/ArGsc+7QSKYV08RLoOYWZVRMDWEjZ
         UBHXJ2BPVwTFv+H7Lbzg5ztRSbX0y5su4uc71SosMqqBEEMrGIsNd+zpbIxPzy5nWfRz
         uTkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N37Qdwkcyg7EfrQtvP7k2DD+LJdWpMJfet+l9N2pWCw=;
        b=OGms87L3M+rQhoDMZ9ApbmSVWMDUtaRV2UAYP0j67fLjoG8jSP02q792bIXP8AFx3d
         nsuZLM+0kMSLcmNdFtDvjAOhY1tNjMTBS3Flj7rPd8goPmb6M6erq1Gsm7xbAPj4arsu
         aVZ6eZEd3ARO+o6gRpD/tjWYtBr7DsE2kwVVBvmWXSQUHHrqbCMSq1IUrIv4Y/HL/wBN
         l/miwlJespc4cgr7S004LAd/nEedPgu3+RN3CzTOyaNRDdgMcBWoC/qKjKpI3Aie1hb/
         jT2TgCyC6PMbe4lA8aWOjHxYVW8r3oIJ02gq6Vg+2rRvqvQxZTMf95W2VfK4Qkl812jG
         YcAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=RpyhTr7F;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e2si8791870jab.98.2019.06.03.05.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 05:37:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=RpyhTr7F;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=N37Qdwkcyg7EfrQtvP7k2DD+LJdWpMJfet+l9N2pWCw=; b=RpyhTr7FxDLVWQbbN8XqrLI0g
	uxTLKDJT9I9RwGqBT/czRJ81DXC43wsY4QZ7eQ9Q2S0WqsyGFqFhFtoKLqoYU7/SDE/nUknk9W/OB
	XF6d+gWiC4Lxi6pOkN/rDEQX2St80wJPmwVdhHC156iTpNa77SkQKbcZdg10kWrgXRpqmsWohHdN5
	5OhFaPwpy7S6fMdjqeRRs/pLPKRHLs+aTfeSxOUXcHRiP5p3Lbw2zG/coThdqDiiBEIsN9P0RJDZS
	dAhaGhrXzP6sW9NnJ7L+aH/A4tEs2cHS1uIfj+azB60BXAxj+bbEopuFgLfNjbIevd3+fttLtpVJl
	/F9/mxeGA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hXmD5-0002tk-JL; Mon, 03 Jun 2019 12:37:07 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 2023D20274AFF; Mon,  3 Jun 2019 14:37:05 +0200 (CEST)
Date: Mon, 3 Jun 2019 14:37:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
	oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190603123705.GB3419@hirez.programming.kicks-ass.net>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 03:12:13PM -0600, Jens Axboe wrote:
> On 5/30/19 2:03 AM, Peter Zijlstra wrote:

> > What is the purpose of that patch ?! The Changelog doesn't mention any
> > benefit or performance gain. So why not revert that?
> 
> Yeah that is actually pretty weak. There are substantial performance
> gains for small IOs using this trick, the changelog should have
> included those. I guess that was left on the list...

OK. I've looked at the try_to_wake_up() path for these exact
conditions and we're certainly sub-optimal there, and I think we can put
much of this special case in there. Please see below.

> I know it's not super kosher, your patch, but I don't think it's that
> bad hidden in a generic helper.

How about the thing that Oleg proposed? That is, not set a waiter when
we know the loop is polling? That would avoid the need for this
alltogether, it would also avoid any set_current_state() on the wait
side of things.

Anyway, Oleg, do you see anything blatantly buggered with this patch?

(the stats were already dodgy for rq-stats, this patch makes them dodgy
for task-stats too)

---
 kernel/sched/core.c | 38 ++++++++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 102dfcf0a29a..474aa4c8e9d2 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1990,6 +1990,28 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	unsigned long flags;
 	int cpu, success = 0;
 
+	if (p == current) {
+		/*
+		 * We're waking current, this means 'p->on_rq' and 'task_cpu(p)
+		 * == smp_processor_id()'. Together this means we can special
+		 * case the whole 'p->on_rq && ttwu_remote()' case below
+		 * without taking any locks.
+		 *
+		 * In particular:
+		 *  - we rely on Program-Order guarantees for all the ordering,
+		 *  - we're serialized against set_special_state() by virtue of
+		 *    it disabling IRQs (this allows not taking ->pi_lock).
+		 */
+		if (!(p->state & state))
+			goto out;
+
+		success = 1;
+		trace_sched_waking(p);
+		p->state = TASK_RUNNING;
+		trace_sched_woken(p);
+		goto out;
+	}
+
 	/*
 	 * If we are going to wake up a thread waiting for CONDITION we
 	 * need to ensure that CONDITION=1 done by the caller can not be
@@ -1999,7 +2021,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	raw_spin_lock_irqsave(&p->pi_lock, flags);
 	smp_mb__after_spinlock();
 	if (!(p->state & state))
-		goto out;
+		goto unlock;
 
 	trace_sched_waking(p);
 
@@ -2029,7 +2051,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 	 */
 	smp_rmb();
 	if (p->on_rq && ttwu_remote(p, wake_flags))
-		goto stat;
+		goto unlock;
 
 #ifdef CONFIG_SMP
 	/*
@@ -2089,12 +2111,16 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
 #endif /* CONFIG_SMP */
 
 	ttwu_queue(p, cpu, wake_flags);
-stat:
-	ttwu_stat(p, cpu, wake_flags);
-out:
+unlock:
 	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
 
-	return success;
+out:
+	if (success) {
+		ttwu_stat(p, cpu, wake_flags);
+		return true;
+	}
+
+	return false;
 }
 
 /**

