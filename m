Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42E10C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD8B920657
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:51:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UluEH/75"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD8B920657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61BE98E000A; Thu,  1 Aug 2019 05:51:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F2928E0001; Thu,  1 Aug 2019 05:51:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E1C38E000A; Thu,  1 Aug 2019 05:51:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 143F78E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 05:51:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 21so45337864pfu.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 02:51:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/RCQXkoLdx1Dap2zHV/paZLxYVJHeWju5RP8ynoxTPI=;
        b=Unhm2Vz6FW9hm6XhEhUEk0VZYAmpKz0+0lSNulIbx69LeToylysallgeXtpQQa99l2
         EA37IhhOnqiMxrSHgUXv1JExUBQjrYsB9eP6L25qfKeB2YaSKYfNfn8FNRiUngAHEEUq
         qe0DJlRMdJS6suDE5nUupKnxgJgOO/clZvlY6EgjI17Bzk2njbtG2+RrCCgpmJtqMdCu
         QJAQo0tO0bGH9luPv8DtgYKegH3LpN/ZNIWnF8Sud+nKGcxmnj2HVaFc+AKslTGBQ03a
         xy1eraZph2VhoxqT6y2cxJRrVsD6iNoufiOSmw+wauiDR/cTDT6VekiMSmtSDSjuk6lT
         bwug==
X-Gm-Message-State: APjAAAVx3r7sr1Dn0rBrQMg0z4mcNy2w3tyEs1AHe+SHT69po1j/ndXx
	z5BJx+9ycap2OLScKWlRJ7QW7hS74yrOXirEbtPSwC2BcIL4eQWIqEgPD54XjbKdby998lIEt2F
	TQBh7PdabDzxLzgCCFNVVH5Vk6CF33TogCbQJaynswzOOT2nxNtu+rOkAnxU9tgdc2g==
X-Received: by 2002:a63:dd16:: with SMTP id t22mr86857496pgg.140.1564653084526;
        Thu, 01 Aug 2019 02:51:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhByWGtY7dkynJYrnn8txFtde3SuI8NsY+rkwmaITNBwo5uVjFJ6sL2nxeJIYq/QCKO9xM
X-Received: by 2002:a63:dd16:: with SMTP id t22mr86857396pgg.140.1564653083262;
        Thu, 01 Aug 2019 02:51:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564653083; cv=none;
        d=google.com; s=arc-20160816;
        b=zH9LOKcXVYUJ+H302rMyDZBToPjhznFMvnz2C/Dig9v/yzMgmm3dRZBV/8xFEQGT3p
         jYI8KXBR3T7FSXK6LAF5xQ0IQGJz+0667MiakscMohLGKEvQMPtaOuMDdkBxhnV2FD8q
         hoElWfmfGap+r6DGuJCgxfaBLg+V4nwXmGNLC9izT2l0fZEGPmhpJmcfPWTFWzmTbXU6
         4bCDe231K02P3o6S+1fPuhrpD5HZrEQ8LCcO/KH3t7upBxRXz3Qz8N7iFPa7Qsk3GE7T
         XZmku6aDZHGgymnVGGPv0TDe1wN0PoBX+bhg+xJVhZwnAuapB6gklQe6A3+IH+Ct4oea
         Qg9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/RCQXkoLdx1Dap2zHV/paZLxYVJHeWju5RP8ynoxTPI=;
        b=1EE9OsP7bA8yhtJKD9mGP8AsAyR6v+OcrXiQQ3C4mNHzRRkvC02lPuo3287mGBjEIt
         Aiwb2+4WeDxNcnmiLRrsGGCKP8orRmcpt3s21IcRMTysqDGD8LbTfUY3swOVm/s8Fsjc
         ehsgG8ttkxcXDh8E7WxmNajoDvsElQHhv8cZ3P4p1wUKqSprH1rkO0EgyccdtbKfMR5T
         REmL7urrxFFXySmAS5S7r1rC76xp/A58wQCJqO7Rr1CW55UFbWqfJL/1lySHflIAkcLD
         Siplg2d/9CcWtg48BmzeoFkZOQCqVmidBfhWmSI4cThi9mGszEVlnH2WGT8JYdzQ1r7i
         uMMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="UluEH/75";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d8si37682434pfr.182.2019.08.01.02.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 02:51:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="UluEH/75";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/RCQXkoLdx1Dap2zHV/paZLxYVJHeWju5RP8ynoxTPI=; b=UluEH/75fC5+qgudhOiGsRDkg
	Dmv3F33wa/UY2uDdoFibQqQZ/AqqbiXyF/wqMePOsemH4nmb1rKJpHHfYVfEv3f3ai4nBEp7Ug+sL
	SWzd5y8YOKyQ/tSuRq0AiUJXLq4NeSuDbMiZURN9ycAr1WLCUOUT5OizKLOhC9xB/AVC02rjw3CtK
	Wax8iH9jNoLz0U6pypJXmZ8HPc5NNfEIKf4EOPSG1OTeIXbzBGbcVP41xY+kvR+e+I/f8rggEFydN
	eqt4MyjaUuiqqF6LW21UPHkR1sy64DUUDe4i1To53kp8ma1FLTaZT+7cLoi8LygcrYfmuoqz0PCAh
	nXgvvDuHQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1ht7ju-0003e9-F5; Thu, 01 Aug 2019 09:51:14 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 149A52029F4CD; Thu,  1 Aug 2019 11:51:12 +0200 (CEST)
Date: Thu, 1 Aug 2019 11:51:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, lizefan@huawei.com,
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk,
	Dennis Zhou <dennis@kernel.org>,
	Dennis Zhou <dennisszhou@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@android.com>,
	Nick Kralevich <nnk@google.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
Message-ID: <20190801095112.GA31381@hirez.programming.kicks-ass.net>
References: <20190730013310.162367-1-surenb@google.com>
 <20190730081122.GH31381@hirez.programming.kicks-ass.net>
 <CAJuCfpH7NpuYKv-B9-27SpQSKhkzraw0LZzpik7_cyNMYcqB2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpH7NpuYKv-B9-27SpQSKhkzraw0LZzpik7_cyNMYcqB2Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 10:44:51AM -0700, Suren Baghdasaryan wrote:
> On Tue, Jul 30, 2019 at 1:11 AM Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > On Mon, Jul 29, 2019 at 06:33:10PM -0700, Suren Baghdasaryan wrote:
> > > When a process creates a new trigger by writing into /proc/pressure/*
> > > files, permissions to write such a file should be used to determine whether
> > > the process is allowed to do so or not. Current implementation would also
> > > require such a process to have setsched capability. Setting of psi trigger
> > > thread's scheduling policy is an implementation detail and should not be
> > > exposed to the user level. Remove the permission check by using _nocheck
> > > version of the function.
> > >
> > > Suggested-by: Nick Kralevich <nnk@google.com>
> > > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > > ---
> > >  kernel/sched/psi.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > >
> > > diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> > > index 7acc632c3b82..ed9a1d573cb1 100644
> > > --- a/kernel/sched/psi.c
> > > +++ b/kernel/sched/psi.c
> > > @@ -1061,7 +1061,7 @@ struct psi_trigger *psi_trigger_create(struct psi_group *group,
> > >                       mutex_unlock(&group->trigger_lock);
> > >                       return ERR_CAST(kworker);
> > >               }
> > > -             sched_setscheduler(kworker->task, SCHED_FIFO, &param);
> > > +             sched_setscheduler_nocheck(kworker->task, SCHED_FIFO, &param);
> >
> > ARGGH, wtf is there a FIFO-99!! thread here at all !?
> 
> We need psi poll_kworker to be an rt-priority thread so that psi

There is a giant difference between 'needs to be higher than OTHER' and
FIFO-99.

> notifications are delivered to the userspace without delay even when
> the CPUs are very congested. Otherwise it's easy to delay psi
> notifications by running a simple CPU hogger executing "chrt -f 50 dd
> if=/dev/zero of=/dev/null". Because these notifications are

So what; at that point that's exactly what you're asking for. Using RT
is for those who know what they're doing.

> time-critical for reacting to memory shortages we can't allow for such
> delays.

Furthermore, actual RT programs will have pre-allocated and locked any
memory they rely on. They don't give a crap about your pressure
nonsense.

> Notice that this kworker is created only if userspace creates a psi
> trigger. So unless you are using psi triggers you will never see this
> kthread created.

By marking it FIFO-99 you're in effect saying that your stupid
statistics gathering is more important than your life. It will preempt
the task that's in control of the band-saw emergency break, it will
preempt the task that's adjusting the electromagnetic field containing
this plasma flow.

That's insane.

I'm going to queue a patch to reduce this to FIFO-1, that will preempt
regular OTHER tasks but will not perturb (much) actual RT bits.

