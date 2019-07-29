Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D9E2C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:25:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8F25216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:24:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VDIZSjBO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8F25216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 747A78E0005; Mon, 29 Jul 2019 10:24:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F8398E0002; Mon, 29 Jul 2019 10:24:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E6CD8E0005; Mon, 29 Jul 2019 10:24:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F10D8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:24:59 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id x24so67707730ioh.16
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:24:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=r2R3bvPPA7z+Zk5Z5T/eRlqnLR0fPm6kMZLrDw0T1mM=;
        b=XiQRly1tf2Tjs9IuWWeM58TDcU9KpHCL8t2bWY2YyyCzcXfXuPCoMI/7s/QqolONcI
         sWOHmaQbE8mWGcdybE01sPg1jSNsPb6ihdYt3ucab0WoOP0F1MJplf72tWVqax9Llw6O
         +kiYg2JAlj33kbRNwxi1ymbvSzni4OqzfZNyJQVnon64FLh9ahEdjflGi+ql6fLoNXA+
         hsMshQ/pZh1zBysY6PAIYXK9tYdBOd8sQn5kmzTUvDTMLLZ4QYP3nbYb2lfmOxTAMjc6
         JG5S4G8tx0Vr4Z45B+8QjGQIZoLpOy98n3VptxfEoeaeVOQUQ3W9lyd2GJtGkLmwCVXp
         cOOQ==
X-Gm-Message-State: APjAAAVFBUDBe6mhClnjCdQ32vdcUNa+RZDDqxQ2IZB0/bsKqNwJyPBz
	ksvd7Pt42mU04IEpvglxInw5l2b+w5XQIXApMF4EVK7pTD4iqNnoom+OQHio3rSYSL3B53UwZrG
	Tvb4uEvEhNg/ms0NHxjajLpdgadSsVhIZqo8tXNXFnC0I+3yUN90WERfRC5TtGiC+4A==
X-Received: by 2002:a05:6638:303:: with SMTP id w3mr58699489jap.103.1564410298938;
        Mon, 29 Jul 2019 07:24:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0of2YJDgqFnPOhwOnlFFILs7CpuRja6bcVphGYcz32ScCGSNyexI+E6GUiyKXkEpMc6OT
X-Received: by 2002:a05:6638:303:: with SMTP id w3mr58699412jap.103.1564410297981;
        Mon, 29 Jul 2019 07:24:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410297; cv=none;
        d=google.com; s=arc-20160816;
        b=h2MaSlI79R9VMuZVIrv5CST+vjzYF7PGaXKSKzmcMEQQfS1r9bQaDFA4l2ejrD+Srn
         4iBLFliB6+PE54Ed/GTXD7BllyoHEdAAxdry5CjNPOBMzHn00L9AX2xSI/xPb8i82JsM
         JxWTNbu3J1GSQJCAguU10Jnd7c6H20khPEoQsQw5ZQuXKra7/75dhWBWcoduJUV1aGYc
         n9SD/0aG2i0yCwDKdXB6xi3hKE3ZEFmj1Y3bmyQNlVyIREKY7pkUa89wLDj2bYd1NZWb
         mY6HCH6S71n7YrITX+RFTtU/IO2jqGam7bYneYi9r15mOomOXG4Oqz7xheZbMNQCcXA4
         ws5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=r2R3bvPPA7z+Zk5Z5T/eRlqnLR0fPm6kMZLrDw0T1mM=;
        b=ysXLX2I6w+HGrMCNkeQy2TIzz1MjmrV2my1Wli8qRODVjW0IeAHQetSClQED/uB4P4
         qM6HSfb89N2MhLznbqe9tJ7/zmvPj6FkF3J91UGWvBj/BiQH0sHYnJzTWybtSLfMVkbp
         voX5NXmf6rQyXj84yFM1thQboBj8HPpS57SNQTnbtXXdQ0DWlaXfJZOPb6MvlLAAbzby
         lcKJCmWI84LANOKPTXp2nStP121NbbMGoGW5W5doloBYfpyjr+zKIGXTd8eySEykk+mn
         6HfYVHVRtpGxDZDBVXP2qVwPIVBZvBSL8aoKrVhoANFlGS/Y6WnLxY56cbPZk0XUZDVc
         KXJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=VDIZSjBO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c31si92921221jaa.76.2019.07.29.07.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:24:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=VDIZSjBO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=r2R3bvPPA7z+Zk5Z5T/eRlqnLR0fPm6kMZLrDw0T1mM=; b=VDIZSjBOQQ5VujuzGXLUd8ztg
	s9lZP8iQA6DasO0eCjfCdN66UHKmyiRi268O6wWJUP/0aANp/x59QPcYqoSJh4IQgpSRF/DL6KxWH
	0kgwwmK2eRnOAE0i+uA7PqX2cxYVQVHKzmsRWBOClTrWQfNY4Q8lOsTlLHBoT0MAKh23KApH1NXDP
	9wewptlleUm83XE3JiybClJJZMT0obX31Swo2M25QwiC+YOSR2hf83+aWTCGjpQYy0EgbryP7TBgU
	cSenMrQzb/jwtG5VGK6iivMyfYv4imx8GubCaG31CtFlipADI9USL2jpugr46Sz83fOplbiTV39Ir
	/bWQ4t3xA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6a4-0002qo-N7; Mon, 29 Jul 2019 14:24:53 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 130FF20AFFEAD; Mon, 29 Jul 2019 16:24:50 +0200 (CEST)
Date: Mon, 29 Jul 2019 16:24:50 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>, riel@surriel.com, luto@kernel.org,
	mathieu.desnoyers@efficios.com
Subject: [PATCH] sched: Clean up active_mm reference counting
Message-ID: <20190729142450.GE31425@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729085235.GT31381@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 10:52:35AM +0200, Peter Zijlstra wrote:
> On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:

> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index 2b037f195473..923a63262dfd 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -3233,13 +3233,22 @@ context_switch(struct rq *rq, struct task_struct *prev,
> >  	 * Both of these contain the full memory barrier required by
> >  	 * membarrier after storing to rq->curr, before returning to
> >  	 * user-space.
> > +	 *
> > +	 * If mm is NULL and oldmm is dying (!owner), we switch to
> > +	 * init_mm instead to make sure that oldmm can be freed ASAP.
> >  	 */
> > -	if (!mm) {
> > +	if (!mm && !mm_dying(oldmm)) {
> >  		next->active_mm = oldmm;
> >  		mmgrab(oldmm);
> >  		enter_lazy_tlb(oldmm, next);
> > -	} else
> > +	} else {
> > +		if (!mm) {
> > +			mm = &init_mm;
> > +			next->active_mm = mm;
> > +			mmgrab(mm);
> > +		}
> >  		switch_mm_irqs_off(oldmm, mm, next);
> > +	}
> >  
> >  	if (!prev->mm) {
> >  		prev->active_mm = NULL;
> 
> Bah, I see we _still_ haven't 'fixed' that code. And you're making an
> even bigger mess of it.
> 
> Let me go find where that cleanup went.

---
Subject: sched: Clean up active_mm reference counting
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon Jul 29 16:05:15 CEST 2019

The current active_mm reference counting is confusing and sub-optimal.

Rewrite the code to explicitly consider the 4 separate cases:

    user -> user

	When switching between two user tasks, all we need to consider
	is switch_mm().

    user -> kernel

	When switching from a user task to a kernel task (which
	doesn't have an associated mm) we retain the last mm in our
	active_mm. Increment a reference count on active_mm.

  kernel -> kernel

	When switching between kernel threads, all we need to do is
	pass along the active_mm reference.

  kernel -> user

	When switching between a kernel and user task, we must switch
	from the last active_mm to the next mm, hoping of course that
	these are the same. Decrement a reference on the active_mm.

The code keeps a different order, because as you'll note, both 'to
user' cases require switch_mm().

And where the old code would increment/decrement for the 'kernel ->
kernel' case, the new code observes this is a neutral operation and
avoids touching the reference count.

Cc: riel@surriel.com
Cc: luto@kernel.org
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 kernel/sched/core.c |   49 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 30 insertions(+), 19 deletions(-)

--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3214,12 +3214,8 @@ static __always_inline struct rq *
 context_switch(struct rq *rq, struct task_struct *prev,
 	       struct task_struct *next, struct rq_flags *rf)
 {
-	struct mm_struct *mm, *oldmm;
-
 	prepare_task_switch(rq, prev, next);
 
-	mm = next->mm;
-	oldmm = prev->active_mm;
 	/*
 	 * For paravirt, this is coupled with an exit in switch_to to
 	 * combine the page table reload and the switch backend into
@@ -3228,22 +3224,37 @@ context_switch(struct rq *rq, struct tas
 	arch_start_context_switch(prev);
 
 	/*
-	 * If mm is non-NULL, we pass through switch_mm(). If mm is
-	 * NULL, we will pass through mmdrop() in finish_task_switch().
-	 * Both of these contain the full memory barrier required by
-	 * membarrier after storing to rq->curr, before returning to
-	 * user-space.
+	 * kernel -> kernel   lazy + transfer active
+	 *   user -> kernel   lazy + mmgrab() active
+	 *
+	 * kernel ->   user   switch + mmdrop() active
+	 *   user ->   user   switch
 	 */
-	if (!mm) {
-		next->active_mm = oldmm;
-		mmgrab(oldmm);
-		enter_lazy_tlb(oldmm, next);
-	} else
-		switch_mm_irqs_off(oldmm, mm, next);
-
-	if (!prev->mm) {
-		prev->active_mm = NULL;
-		rq->prev_mm = oldmm;
+	if (!next->mm) {                                // to kernel
+		enter_lazy_tlb(prev->active_mm, next);
+
+		next->active_mm = prev->active_mm;
+		if (prev->mm)                           // from user
+			mmgrab(prev->active_mm);
+		else
+			prev->active_mm = NULL;
+	} else {                                        // to user
+		/*
+		 * sys_membarrier() requires an smp_mb() between setting
+		 * rq->curr and returning to userspace.
+		 *
+		 * The below provides this either through switch_mm(), or in
+		 * case 'prev->active_mm == next->mm' through
+		 * finish_task_switch()'s mmdrop().
+		 */
+
+		switch_mm_irqs_off(prev->active_mm, next->mm, next);
+
+		if (!prev->mm) {                        // from kernel
+			/* will mmdrop() in finish_task_switch(). */
+			rq->prev_mm = prev->active_mm;
+			prev->active_mm = NULL;
+		}
 	}
 
 	rq->clock_update_flags &= ~(RQCF_ACT_SKIP|RQCF_REQ_SKIP);

