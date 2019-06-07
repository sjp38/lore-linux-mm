Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0C7CC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:23:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BB3F20657
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:23:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IfJh/Lv7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BB3F20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25BD46B000C; Fri,  7 Jun 2019 10:23:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20D496B000E; Fri,  7 Jun 2019 10:23:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D4656B0266; Fri,  7 Jun 2019 10:23:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E35816B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 10:23:40 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r27so1741418iob.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 07:23:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8BZurWN5noKI/9IXnmPT/gb9mEzJQ8dX7lvEoO1HhTU=;
        b=sw1YOEwzRd+9Fgc/gvJMrXL0g8kseK2s6oTUOBkSU61HMSH59iu9ewiz/UTuV/iO5r
         JOmrevBAsIdCz6OVY0f0v+7jrFs+8Z4apW73K0hwK1gg4O/VY74qJ/duTwRX5ZD1sR9+
         /nW7f37ltRjzVQ8IQnla1iGTnO0iYa8i6BXRJIdA/jM6NdkWQnkg+hegmBF1DAAtkp3E
         4t/Fdip6YwM5ycP3cDGsYFb1Y30K8aJYhor6pSNLKszz3WFD20xmrQzrH1dv/FDjcY14
         6SK8Yyj2eEgX9tp+LiINecdIDM3MLxYV1m6+PN2fE5eGirtHjXdnNlZPyC/sq6dqpOtc
         iumg==
X-Gm-Message-State: APjAAAVLibZxoaL1maou0bmI4STRWXOSpHHn+6huRgbjxB7lYOo+8ll0
	g5PEXQ8gGnb6LxP+LcAGIl0/KDvOq9FH0Tt8ZzbXpS1iYLckHBO1pl4ZHBCeL1D2TvT5OSMeF4h
	aHprCha6FYQpmUs0L+sJ01AScwOOIpwUWMfLVhJfPP5pPVz+OcAG3DQRngFB36jSo9Q==
X-Received: by 2002:a5d:97d8:: with SMTP id k24mr6598918ios.84.1559917420617;
        Fri, 07 Jun 2019 07:23:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZS3kXy2PyGhvGMlUteTbcD599MRdbqR0I/RQDnbb7Y8nIK2SiG/sS8pzFgHF/erJaFRoU
X-Received: by 2002:a5d:97d8:: with SMTP id k24mr6598774ios.84.1559917418094;
        Fri, 07 Jun 2019 07:23:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559917418; cv=none;
        d=google.com; s=arc-20160816;
        b=GpuDjqi30modwJadB+GcjuNGfup6EIX7d4fTwn80B5JL60lDQ0UdZuxPQuJQrcmIfV
         CHfS7EY6fJwMlqb05wwQSNCXyOkTu+Gik3K7pu8riwLPnDsnvwQYEPhlExhLvV8xmedE
         WpT8eeIRDxYbWUs3l3XFuaTqsVaJvNU1CE6PRa6o5uGmNBdPfr2QOjD12fUfj0GMOZxu
         K23v/kdh47v4dYVHG2sY+nu13jTMc/31/xqjURHRRQViFES7ni4CWr3p40Mvqd4Xkwdc
         FuuU3ew1YTbfE4XbvvMWV8k0fSRepxo2lCfV18wUjQqw6N2Mg4kGOhRN42EhA+MfM/Av
         6KJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8BZurWN5noKI/9IXnmPT/gb9mEzJQ8dX7lvEoO1HhTU=;
        b=q3pB/yIuPbO6YIWNnz/1mWGKYH3rCF2qXhfIv/VQ5xrGarOfwWCbfszY/wc9ofWwuP
         svuK5fdxzznRcyZXF68Y+ow/EsdotuV1xxHUgUJnh92vSBAp0yfQCO0wXRaQbT8VqtsH
         e1w6f7KVsc2WcnzChLRq9GqqZRepWdKADXY3u3cUhtETyCXwj+APgHIItFc7rH5bswlA
         sqDneayp780pldEazV15DTBKCVGg6Fv/EyrQGvbVN63N8k42bTv7yZUD68yyEsGY01P9
         4UlDoU/Ln7z0n0af8/WaTAtJbzTfFJI3KZ2pFr0nvfxOG5P/YfZX/1RR5sp95+g2+0xU
         ixlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="IfJh/Lv7";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f142si1165888itf.106.2019.06.07.07.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 07:23:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="IfJh/Lv7";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8BZurWN5noKI/9IXnmPT/gb9mEzJQ8dX7lvEoO1HhTU=; b=IfJh/Lv7pwWNCCj3t156wPCtZ
	R4u9ktCYkNG0VPE3JJ0oCDWm6cZbGx6qAT/S5KDdFRg42oxtgcubdJ6UXAh6qJBsgA6WYf+2vYDqi
	A6g6E8rhYByaq2+SiJTPJSEgGYx5jAHaCmliTYMk9wC2JdjxEycTezJ6pydHOXKGMSweMpP7KWW0R
	hfDmdIv7Xa0+V0riPI+Xi7q7eb0GGaqE7DRdYndXS8lF9AbJ5TqDBage5UXo21RZef5RIdU4YmJ5o
	yOaa/SsjedwPYhfSUwF3/wVMAs8C0XMNHDmlUKaf8IzslU8alOFHtsq2IS0E7CGm6jwR8fiecNIKT
	K13hDQNtw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZFmI-0001mu-M0; Fri, 07 Jun 2019 14:23:35 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 03295202CD6B2; Fri,  7 Jun 2019 16:23:32 +0200 (CEST)
Date: Fri, 7 Jun 2019 16:23:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
	oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190607142332.GF3463@hirez.programming.kicks-ass.net>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <20190607133541.GJ3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607133541.GJ3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 03:35:41PM +0200, Peter Zijlstra wrote:
> On Wed, Jun 05, 2019 at 09:04:02AM -0600, Jens Axboe wrote:
> > How about the following plan - if folks are happy with this sched patch,
> > we can queue it up for 5.3. Once that is in, I'll kill the block change
> > that special cases the polled task wakeup. For 5.2, we go with Oleg's
> > patch for the swap case.
> 
> OK, works for me. I'll go write a proper patch.

I now have the below; I'll queue that after the long weekend and let
0-day chew on it for a while and then push it out to tip or something.


---
Subject: sched: Optimize try_to_wake_up() for local wakeups
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri Jun 7 15:39:49 CEST 2019

Jens reported that significant performance can be had on some block
workloads (XXX numbers?) by special casing local wakeups. That is,
wakeups on the current task before it schedules out. Given something
like the normal wait pattern:

	for (;;) {
		set_current_state(TASK_UNINTERRUPTIBLE);

		if (cond)
			break;

		schedule();
	}
	__set_current_state(TASK_RUNNING);

Any wakeup (on this CPU) after set_current_state() and before
schedule() would benefit from this.

Normal wakeups take p->pi_lock, which serializes wakeups to the same
task. By eliding that we gain concurrency on:

 - ttwu_stat(); we already had concurrency on rq stats, this now also
   brings it to task stats. -ENOCARE

 - tracepoints; it is now possible to get multiple instances of
   trace_sched_waking() (and possibly trace_sched_wakeup()) for the
   same task. Tracers will have to learn to cope.

Furthermore, p->pi_lock is used by set_special_state(), to order
against TASK_RUNNING stores from other CPUs. But since this is
strictly CPU local, we don't need the lock, and set_special_state()'s
disabling of IRQs is sufficient.

After the normal wakeup takes p->pi_lock it issues
smp_mb__after_spinlock(), in order to ensure the woken task must
observe prior stores before we observe the p->state. If this is CPU
local, this will be satisfied with a compiler barrier, and we rely on
try_to_wake_up() being a funcation call, which implies such.

Since, when 'p == current', 'p->on_rq' must be true, the normal wakeup
would continue into the ttwu_remote() branch, which normally is
concerned with exactly this wakeup scenario, except from a remote CPU.
IOW we're waking a task that is still running. In this case, we can
trivially avoid taking rq->lock, all that's left from this is to set
p->state.

This then yields an extremely simple and fast path for 'p == current'.

Cc: Qian Cai <cai@lca.pw>
Cc: mingo@redhat.com
Cc: akpm@linux-foundation.org
Cc: hch@lst.de
Cc: gkohli@codeaurora.org
Cc: oleg@redhat.com
Reported-by: Jens Axboe <axboe@kernel.dk>
Tested-by: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 kernel/sched/core.c |   33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1991,6 +1991,28 @@ try_to_wake_up(struct task_struct *p, un
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
+			return false;
+
+		success = 1;
+		trace_sched_waking(p);
+		p->state = TASK_RUNNING;
+		trace_sched_wakeup(p);
+		goto out;
+	}
+
 	/*
 	 * If we are going to wake up a thread waiting for CONDITION we
 	 * need to ensure that CONDITION=1 done by the caller can not be
@@ -2000,7 +2022,7 @@ try_to_wake_up(struct task_struct *p, un
 	raw_spin_lock_irqsave(&p->pi_lock, flags);
 	smp_mb__after_spinlock();
 	if (!(p->state & state))
-		goto out;
+		goto unlock;
 
 	trace_sched_waking(p);
 
@@ -2030,7 +2052,7 @@ try_to_wake_up(struct task_struct *p, un
 	 */
 	smp_rmb();
 	if (p->on_rq && ttwu_remote(p, wake_flags))
-		goto stat;
+		goto unlock;
 
 #ifdef CONFIG_SMP
 	/*
@@ -2090,10 +2112,11 @@ try_to_wake_up(struct task_struct *p, un
 #endif /* CONFIG_SMP */
 
 	ttwu_queue(p, cpu, wake_flags);
-stat:
-	ttwu_stat(p, cpu, wake_flags);
-out:
+unlock:
 	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
+out:
+	if (success)
+		ttwu_stat(p, cpu, wake_flags);
 
 	return success;
 }

