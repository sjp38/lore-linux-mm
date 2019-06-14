Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5746C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:46:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48B4D2084E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:46:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g3SNP0/H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48B4D2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CD246B0007; Fri, 14 Jun 2019 05:46:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97DE46B0008; Fri, 14 Jun 2019 05:46:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8447D6B000A; Fri, 14 Jun 2019 05:46:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65C056B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:46:49 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id b197so2081107iof.12
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:46:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZwJ9Jl7JONCrJ6awI6i86cD9093PN6AfQk6ccDOxxGg=;
        b=WpuHtMFrI4Sa9vpNWqejMl2RARS9pfGMuQk5ditTT7h9R83ADmKLS3zk2IGRSouuHU
         2XpzCApYPgniHiNNX+gLeBDvHgeVm08uBmh8T+YqbIUFFnJ3qebwKWgAFChBTGcfBxMm
         j1X1dgRWhymUvuFH8gZxQJIVExOfMwlzwDkyBJG8dwro4+c2FtotKKB34+nsa4BkNaPs
         nsEBT2YglfOj8cB0PsoG4C6KcW+/8iTGg3JzZSSjkhnnR53uKsB4r8BwMYeYUiNiodST
         tW3tW7QPseKzcDP+gmI4GcD9do8ZSOIUZ0hvfu/A2QmRLvcYZbcRldjVBz81ubfIfcI4
         Bkzg==
X-Gm-Message-State: APjAAAVGJr3f7ilXqhbijD7erd3swnvxKN76BUf+m11kAFw7xa2HZpB6
	rC4/BYjwFWMASLff0DWWnYAq9I0H0rWT96r7Q/cPD26jDzAfaHVUZ6tjLRMmUR4miA9rUWu/avU
	a/d8Hp/gG1kiqjDzcC+CYLYFsofvAoopa40fJEDLfmNPwVsoWtnslarjt1AI8Rw5cNQ==
X-Received: by 2002:a05:6638:201:: with SMTP id e1mr46711460jaq.45.1560505608878;
        Fri, 14 Jun 2019 02:46:48 -0700 (PDT)
X-Received: by 2002:a05:6638:201:: with SMTP id e1mr46711409jaq.45.1560505608252;
        Fri, 14 Jun 2019 02:46:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560505608; cv=none;
        d=google.com; s=arc-20160816;
        b=RjDWYSC5Mw1AopDmcQZWoCFmaQs4JVkTCKlvKyo6dKz90n/4MlCCOVc5mhk7LtG3Dn
         sAUg/D7GqAJ+lgOa5H85x89gEkyV5dbABQZML54qjW9pdSxANQ70kyznndFvUZ3rtwCe
         nniJrkQHgAWlliKom+GRWfBDAk75vTmeZlSM7Ni07SfNqBxRI9G+XMFXtB7iJ3vM42pj
         ZGlFoulg6lubc1jze+Fg56DpW2J7W9i37on6kPBJz4TOagyoR+yTMTg7HNNpxEbbKEDH
         Arsyxbn6YFVjP7NvNdP12wHK1Fb12sIr4ekWcU7hCOAVbfCFlduxaKSCo7/lTOjEx3Mt
         eWYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZwJ9Jl7JONCrJ6awI6i86cD9093PN6AfQk6ccDOxxGg=;
        b=qSMgxooXjRvuT7vpLbz4ObCGf6TwyGrkuk0Aed2Gwl39pnJWZaDukEUSbmHKGA3lBo
         5+/0QC1D/2JMvv5aR3EHR2dLIHBt2W38rf7pllruouOGIC8LW50jo48EuHv9q42hWhNv
         dDU2QyvSQEyQq52nf7OL1iHY+Uzwj/6GA1p4Vdul4PGOdl3verqUk5s+8/wV8m6qUSTd
         M1+M7VPu8MP9tVOFN80c5Ph6n+WtpNq82dNJqVurpPw1Nd1fYNbig6s6eX8p9rA4/Gl7
         nWwhhW5j32YKLv3p6/zTrtAL/jDBFIE5zDtyxrhGP1OmXxUrKZUpYVURDdOHa89Svj0u
         WMSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="g3SNP0/H";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor1953181iol.1.2019.06.14.02.46.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 02:46:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="g3SNP0/H";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZwJ9Jl7JONCrJ6awI6i86cD9093PN6AfQk6ccDOxxGg=;
        b=g3SNP0/HSAlXf6ZbaUBEfEUQqzWh7aIpyj70Y6d90AAVC88cfVeMh/+rwRLokwpLkh
         5TfnnfApdSUQAbuqjY9B6jw2dycUjmdXYna0xC/yBgy2pLNadqrUNaexAio95xaY55c7
         gvEqz4YF7RaiyPRDB4kIuzJx5GhabkbOFuHhfxVb9zFBNAfpUIgkuAR9AtqnQ1GU5XXi
         K6PC1cDoRkTIV0IaCRis50mysDPSuIIxqhFJHKciWX4Ib57439vrqCU68Nb/Z07WYJyL
         jv7tRwBsJ2jIjDi+iuVTtOUe33yf9BcJ6i58siybQCFjNr1Sno68bG0qdrsYiR8/zICa
         CudA==
X-Google-Smtp-Source: APXvYqziAJFTItVszN2Xc4saSrUssELXbO/Tke5qbCkm1CvAOG7dtd/W1HM2MFqTeikhRjgCBmZa4Jp6w63oaGzR8MU=
X-Received: by 2002:a5d:8702:: with SMTP id u2mr56464340iom.228.1560505607934;
 Fri, 14 Jun 2019 02:46:47 -0700 (PDT)
MIME-Version: 1.0
References: <1560434150-13626-1-git-send-email-laoar.shao@gmail.com>
 <20190613185640.GA1405@dhcp22.suse.cz> <CALOAHbB=sd0y53Tr6b7C41-bF+k1v292ULss64BrdCEySxTRiA@mail.gmail.com>
 <20190614082130.GA28901@dhcp22.suse.cz>
In-Reply-To: <20190614082130.GA28901@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 14 Jun 2019 17:46:11 +0800
Message-ID: <CALOAHbCsAhGM_6BB2aENUmqo9L-wip3L9tcbcYhm4c4z=tk8wg@mail.gmail.com>
Subject: Re: [PATCH] mm/oom_kill: set oc->constraint in constrained_alloc()
To: Michal Hocko <mhocko@suse.com>
Cc: yuzhoujian <yuzhoujian@didichuxing.com>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 4:22 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Fri 14-06-19 13:58:11, Yafang Shao wrote:
> > On Fri, Jun 14, 2019 at 2:56 AM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Thu 13-06-19 21:55:50, Yafang Shao wrote:
> > > > In dump_oom_summary() oc->constraint is used to show
> > > > oom_constraint_text, but it hasn't been set before.
> > > > So the value of it is always the default value 0.
> > > > We should set it in constrained_alloc().
> > >
> > > Thanks for catching that.
> > >
> > > > Bellow is the output when memcg oom occurs,
> > > >
> > > > before this patch:
> > > > [  133.078102] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),
> > > > cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=7997,uid=0
> > > >
> > > > after this patch:
> > > > [  952.977946] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),
> > > > cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=13681,uid=0
> > > >
> > >
> > > unless I am missing something
> > > Fixes: ef8444ea01d7 ("mm, oom: reorganize the oom report in dump_header")
> > >
> > > The patch looks correct but I think it is more complicated than it needs
> > > to be. Can we do the following instead?
> > >
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 5a58778c91d4..f719b64741d6 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -987,8 +987,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> > >  /*
> > >   * Determines whether the kernel must panic because of the panic_on_oom sysctl.
> > >   */
> > > -static void check_panic_on_oom(struct oom_control *oc,
> > > -                              enum oom_constraint constraint)
> > > +static void check_panic_on_oom(struct oom_control *oc)
> > >  {
> > >         if (likely(!sysctl_panic_on_oom))
> > >                 return;
> > > @@ -998,7 +997,7 @@ static void check_panic_on_oom(struct oom_control *oc,
> > >                  * does not panic for cpuset, mempolicy, or memcg allocation
> > >                  * failures.
> > >                  */
> > > -               if (constraint != CONSTRAINT_NONE)
> > > +               if (oc->constraint != CONSTRAINT_NONE)
> > >                         return;
> > >         }
> > >         /* Do not panic for oom kills triggered by sysrq */
> > > @@ -1035,7 +1034,6 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
> > >  bool out_of_memory(struct oom_control *oc)
> > >  {
> > >         unsigned long freed = 0;
> > > -       enum oom_constraint constraint = CONSTRAINT_NONE;
> > >
> > >         if (oom_killer_disabled)
> > >                 return false;
> > > @@ -1071,10 +1069,10 @@ bool out_of_memory(struct oom_control *oc)
> > >          * Check if there were limitations on the allocation (only relevant for
> > >          * NUMA and memcg) that may require different handling.
> > >          */
> > > -       constraint = constrained_alloc(oc);
> > > -       if (constraint != CONSTRAINT_MEMORY_POLICY)
> > > +       oc->constraint = constrained_alloc(oc);
> > > +       if (oc->constraint != CONSTRAINT_MEMORY_POLICY)
> > >                 oc->nodemask = NULL;
> > > -       check_panic_on_oom(oc, constraint);
> > > +       check_panic_on_oom(oc);
> > >
> > >         if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
> > >             current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
> > >
> > > I guess the current confusion comes from the fact that we have
> > > constraint both in the oom_control and a local variable so I would
> > > rather remove that. What do you think?
> >
> > Remove the local variable is fine by me.
>
> Could you repost the patch with the changelog mentioning Fixes and the
> simpler diff please?
>
> You can then add
> Acked-by: Michal Hocko <mhocko@suse.com>
>

Sure, I will.

Thanks

Yafang

