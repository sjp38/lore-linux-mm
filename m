Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D8DFC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:45:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31BCC216C8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:45:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="exjzghzO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31BCC216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9F7F8E0008; Tue, 30 Jul 2019 13:45:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B29898E0001; Tue, 30 Jul 2019 13:45:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F08E8E0008; Tue, 30 Jul 2019 13:45:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5270D8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:45:04 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t76so14970462wmt.9
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:45:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=55SXhObGMSQ3B0w5iMjyyzalfBJzrVOBbclW7iiKCkQ=;
        b=Xb2E+1ERuBNgSTx1vL3Qi6VDskEUgNlYsAurlUAbv9ieqwFvQDF5e3YJnFPvFuHDk6
         kn82kj8VkH3mwYZAnY4aznosYZbCoOveV2sjBKTRz6ASYXlNVk8JdjmT8OO22AGPmfLN
         zYxMC4xFdGlZKC0s17PVrUtcgy5BPS0I4/aqxzRvaJS4hJ3kX8CxFZZ3kE3NCSBYmiy9
         A06+ZvpWN6l1UG0f2Mm8LGQA87NC9nOiLptt53/kwOctCw9WHpZh/0xzuKfpBhXYh8YO
         kdqKh5ADPTdh8iIyzTMSOXAMKS7FaYItxkIlKUWirIlYSHEmGi5eOctwowBYFgiRZ6tn
         HTTA==
X-Gm-Message-State: APjAAAVqKpF2dqAYR3BOWbcfSK2uogVIFihp8D98zLgp94uyl2FbS+Zw
	PJ9VIeW5NlIbigYoELXIrg0G37J7C5E6C/bpYZJZYBWEgaaly8dK0xDzm/8mb8Ff4hhjDYVBEVv
	aoxdxVYMrjLKX82n6vpkHPIdQnfWmpaJr0TSaNk+SOTKTXLtTa0+lLJ0tCPPUJgsrqA==
X-Received: by 2002:a1c:c747:: with SMTP id x68mr106150328wmf.138.1564508703825;
        Tue, 30 Jul 2019 10:45:03 -0700 (PDT)
X-Received: by 2002:a1c:c747:: with SMTP id x68mr106150291wmf.138.1564508703091;
        Tue, 30 Jul 2019 10:45:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564508703; cv=none;
        d=google.com; s=arc-20160816;
        b=k8+kLQfqVLmY3n/643fpaEwABhOiZkRRLRNuwAOp95PTKm8tEjm4/i03k3qVi/IUPx
         LjbZWu4NGYH2KzyFpnjwOYReJsOD+TdJ5Yx2y2z+Z9NE/TiNrFXLFhvtJ7p/uZ+Vx7gS
         S+6XmvooMoUlMLnnu0OynXknacpZPHdaq82my+GiwhnsBy5oVStgcsNP3ZSURWmz4gDG
         5u9ehnJizwr1aywVSgWbStMGNzILjbk/DahuyudHaQ4Ud8zU6XVUMzcqa2NxGM8cahcW
         XG5XWsIsASLuXkornnYFQg1aWADI1uk7xUuvFg78ZUgpAZZiDybh0KCSzSQmzJnTVMAI
         Dy3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=55SXhObGMSQ3B0w5iMjyyzalfBJzrVOBbclW7iiKCkQ=;
        b=tPSK7nC1rRFzmvQsLMfOIdGMc3Kq/43daBpOz9nqX4coXmef29XXwHggFEzsBKARs/
         AsYXNJiAcLWzJQbCFrdtsqlTWCSXcXWSsmRR5MpfuRifvzcccRrcYFu36Zs9Gpumhj9I
         SeWtVMvdoWosNEBGk6Z2piCB/iEtPutDFICKNs4n+fono0gPjcrUPNXN5lEBMZbG0dnf
         t4lcHf2awW49ikhN8TM3Hqcpk2Fm4bPZoQo9q6Syt6F3quXowR/KEg9cNNJ1XE4x4Uye
         v/kB5yVDt19lihFAJWrZ/u/fYzXpqzANh3ZuSqYotpRAEXQAl28oOHutlRhJaTOmpJ+k
         G/DA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=exjzghzO;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s8sor51979677wrp.36.2019.07.30.10.45.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 10:45:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=exjzghzO;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=55SXhObGMSQ3B0w5iMjyyzalfBJzrVOBbclW7iiKCkQ=;
        b=exjzghzO7EhbkTlYRFfZpr6tmrtVXcAc1TUpBd+Kl4u2JUg38zLUxXExvK1XJMeAHr
         SlyxbTxUP2z+uLswK5N+R5aD9XurFsnLC7er31ADmEw6e+cthpO8vgTny/Txh/AaxhZy
         UyP5/EwXK5UjoggTiOow6IAF0r7VTqfO69BIgtbWgyUNP0ncKxhxcQKicE91n2/lV9GL
         ULiImcXpHVtfhBQVZL6kj0KY15jtIpMDwL5j/EdSck5lUOzB7BhcXdADbWAn7+0ox4AY
         clZVy+4OW2s2Mz0wdzzmFCii/R+659YbFBpBorz3TPYwfRJ6Uo8crDJGkNoDfjYysPcj
         PCyg==
X-Google-Smtp-Source: APXvYqw7bdW2U1qAn58HfHRrUeJI5mayWPJXnuvI4caiQBk+twxM3cUV7/aucx0o+qhr7HnlZGa3XX7YY+oTszTwMDI=
X-Received: by 2002:adf:e50c:: with SMTP id j12mr45502820wrm.117.1564508702443;
 Tue, 30 Jul 2019 10:45:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190730013310.162367-1-surenb@google.com> <20190730081122.GH31381@hirez.programming.kicks-ass.net>
In-Reply-To: <20190730081122.GH31381@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 30 Jul 2019 10:44:51 -0700
Message-ID: <CAJuCfpH7NpuYKv-B9-27SpQSKhkzraw0LZzpik7_cyNMYcqB2Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, Dennis Zhou <dennis@kernel.org>, 
	Dennis Zhou <dennisszhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>, 
	Nick Kralevich <nnk@google.com>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 1:11 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Mon, Jul 29, 2019 at 06:33:10PM -0700, Suren Baghdasaryan wrote:
> > When a process creates a new trigger by writing into /proc/pressure/*
> > files, permissions to write such a file should be used to determine whether
> > the process is allowed to do so or not. Current implementation would also
> > require such a process to have setsched capability. Setting of psi trigger
> > thread's scheduling policy is an implementation detail and should not be
> > exposed to the user level. Remove the permission check by using _nocheck
> > version of the function.
> >
> > Suggested-by: Nick Kralevich <nnk@google.com>
> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > ---
> >  kernel/sched/psi.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> > index 7acc632c3b82..ed9a1d573cb1 100644
> > --- a/kernel/sched/psi.c
> > +++ b/kernel/sched/psi.c
> > @@ -1061,7 +1061,7 @@ struct psi_trigger *psi_trigger_create(struct psi_group *group,
> >                       mutex_unlock(&group->trigger_lock);
> >                       return ERR_CAST(kworker);
> >               }
> > -             sched_setscheduler(kworker->task, SCHED_FIFO, &param);
> > +             sched_setscheduler_nocheck(kworker->task, SCHED_FIFO, &param);
>
> ARGGH, wtf is there a FIFO-99!! thread here at all !?

We need psi poll_kworker to be an rt-priority thread so that psi
notifications are delivered to the userspace without delay even when
the CPUs are very congested. Otherwise it's easy to delay psi
notifications by running a simple CPU hogger executing "chrt -f 50 dd
if=/dev/zero of=/dev/null". Because these notifications are
time-critical for reacting to memory shortages we can't allow for such
delays.
Notice that this kworker is created only if userspace creates a psi
trigger. So unless you are using psi triggers you will never see this
kthread created.

> >               kthread_init_delayed_work(&group->poll_work,
> >                               psi_poll_work);
> >               rcu_assign_pointer(group->poll_kworker, kworker);
> > --
> > 2.22.0.709.g102302147b-goog
> >
>
> --
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

