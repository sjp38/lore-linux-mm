Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FAB2C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:56:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FE49206C1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:56:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tcH6Or/a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE49206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792706B0005; Thu, 25 Apr 2019 17:56:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 743206B0006; Thu, 25 Apr 2019 17:56:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 657506B0007; Thu, 25 Apr 2019 17:56:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A73A6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:56:30 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id 7so1076789wmj.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:56:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GEgbleUXiftEFa1b6/nUBQ/7QI0Sg4jIX3OywJ4O6ss=;
        b=JNWNUGHkiQzd2v5048iW4cEOcU4u6HG4zgi9r02bU/y5rqgL/iJpF9nL2t0j21kGDb
         Zn/SWUTl0DC0x/2yKbY6wldCmEcoSlY732OjLhdUYcgDw2ijH3eDwSItfPGvVn73u0UX
         khR9iQTlZfvNQXmBZImEsjD8LoEmM+w+2irL575mIj3GSObOh9rUZLLrAsY42T1l3XLV
         fRHMjzgTBllTBRoRfH/vgaKoRdXNTKTVDskA0XRcDUH7AJaFq0k2BZ8SYmDzR/vPPEtM
         aC8a7VOhHy2RMB90yWL4gi/q3YOkCvaIGGp5Faq6Yej9G8Xl5yvOVntesYJQoJVA/7rv
         lypw==
X-Gm-Message-State: APjAAAUZSSJiEcgEVNPf5za1lD/faVH0SknygS/O3QldDEnUv9X++M2i
	qvhVImjByvwc5g7NILP/HCFRtw6CJaFio/BK+Apvi3MLv2OAfklByfvA0iFUeF9qi7MRiG+YlTm
	f8IyS9IPipK9dVyokM2A+kDJrGKYFYQtGHZ7TKaq4dRvhAgMnwHyL4itJ5FrMcJZLlg==
X-Received: by 2002:a7b:c3d7:: with SMTP id t23mr4983554wmj.62.1556229389558;
        Thu, 25 Apr 2019 14:56:29 -0700 (PDT)
X-Received: by 2002:a7b:c3d7:: with SMTP id t23mr4983520wmj.62.1556229388721;
        Thu, 25 Apr 2019 14:56:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556229388; cv=none;
        d=google.com; s=arc-20160816;
        b=QMoV0bhpk57P96S7n0Cl6SSY7Bo2t3p24OgSBNyVlIyXfism1MLU0wuOicux+zQ8Zx
         MGJxgthGr/qB3QM3MW5zTZE2MuYFkVaUj/tSQe96rJzpkIqMPRyccEc6j9987f/1D9l+
         B8j95XFvA0hamFFjAFHMpVocXkf5mnDTBbS0vWK1Pj1m4C1F3LPJ/mU7CwM+DIew/bqJ
         /NW62zJ+Nv6Dby1cC+wb8ZPvKPlxTf5dwX7Ry8509MTgO4rz7/xeiy6NITLUqIpnZ1+1
         qjQkz7MwZh7C4BZr2Q4S/QXhPPcROFjsJYwT/ximCVSfp89AA/aCJvCWn/NWDXRph/3Y
         4pnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GEgbleUXiftEFa1b6/nUBQ/7QI0Sg4jIX3OywJ4O6ss=;
        b=sc5b4MC9Nwgei7FiLongBa21IvGa97oBGInDMF/j9WDZGV4UsWr6vPE04hVBoDV9O0
         6g9YxqU3GOouK+DYo3S2AF+vX2jPmXXRakapE2hjx0GY5ro9Sl/8Qhwpp2QDeutd8Uyd
         eWBDWZEsDT52RIzcexaYRP4nGvPO10atFwkA1JJSnqmJjw2mycJaMwUgjtIKM3nAANI9
         Bus9ToeJGd0ofigjbkZmkxdlpQQ2DMLmZhuiYxNzSibKgonKrBKm743HkXYZx36k4v+c
         q8Ehx8Ognafpad6SEsDWUoaxrSpvltWAIjeJPZpqUC/Ly65mFkW9fFhZ+Q6UYczzTWFc
         SJgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="tcH6Or/a";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5sor13527378wri.42.2019.04.25.14.56.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 14:56:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="tcH6Or/a";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GEgbleUXiftEFa1b6/nUBQ/7QI0Sg4jIX3OywJ4O6ss=;
        b=tcH6Or/aUj2gN2lZ+ilpm9QvEleYeL5nv+beBZyu5quvO7K0VU1A9U3qLFUEluKpEu
         Y1Ll+DSw/qgyJFUAUisuVrVxhkvCTOmW4gJeglXkWJggKF62oymkWwR+Ie5uRSFrjUF2
         k8Wmel3W9KzeQ5RuK/SWkRgsB3pQaIQzk5lLkiKt0yYu3MmIyMK0PuPN0InqZrsKnfzm
         RzMxVSdFj48PUqcTlJgGpZupP3AmqzhLHoMmwN9hoB6LUywsovrRZGD2R53ON8S7GRft
         V+t4nQpJNlvZBhAhgFWaA/9qneaTzyviepc/XTlKG3nrV0j15Rlr0hojFhKsS36Jwl1q
         Iq6A==
X-Google-Smtp-Source: APXvYqyMwEjv55C5T76qTTC8HI998zMaiRIQFxwC2X83mO0xhC+T72nf95L5ZLJIS/AdipIWQnRCB4DsPuraplN4L08=
X-Received: by 2002:adf:9144:: with SMTP id j62mr29511655wrj.320.1556229387867;
 Thu, 25 Apr 2019 14:56:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-2-surenb@google.com>
 <c745df86-b95c-e82b-42ba-519da4f448ab@i-love.sakura.ne.jp>
In-Reply-To: <c745df86-b95c-e82b-42ba-519da4f448ab@i-love.sakura.ne.jp>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 25 Apr 2019 14:56:16 -0700
Message-ID: <CAJuCfpH-SnFQT=3qy3VANsgJsxK+vV6=G=WPkt11qG_2RpYAcQ@mail.gmail.com>
Subject: Re: [RFC 1/2] mm: oom: expose expedite_reclaim to use oom_reaper
 outside of oom_kill.c
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	David Rientjes <rientjes@google.com>, Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Daniel Colascione <dancol@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, 
	lsf-pc@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 2:13 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/04/11 10:43, Suren Baghdasaryan wrote:
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 3a2484884cfd..6449710c8a06 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -1102,6 +1102,21 @@ bool out_of_memory(struct oom_control *oc)
> >       return !!oc->chosen;
> >  }
> >
> > +bool expedite_reclaim(struct task_struct *task)
> > +{
> > +     bool res = false;
> > +
> > +     task_lock(task);
> > +     if (task_will_free_mem(task)) {
>
> mark_oom_victim() needs to be called under oom_lock mutex after
> checking that oom_killer_disabled == false. Since you are trying
> to trigger this function from signal handler, you might want to
> defer until e.g. WQ context.

Thanks for the tip! I'll take this into account in the new design.
Just thinking out loud... AFAIU oom_lock is there to protect against
multiple concurrent out_of_memory calls from different contexts and
prevent overly-aggressive process killing. For my purposes when
reaping memory of a killed process we don't have this concern (we did
not initiate the killing, SIGKILL was explicitly requested). I'll
probably need some synchronization there but not for purposes of
preventing multiple concurrent reapers. In any case, thank you for the
feedback!

>
> > +             mark_oom_victim(task);
> > +             wake_oom_reaper(task);
> > +             res = true;
> > +     }
> > +     task_unlock(task);
> > +
> > +     return res;
> > +}
> > +
> >  /*
> >   * The pagefault handler calls here because it is out of memory, so kill a
> >   * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
> >

