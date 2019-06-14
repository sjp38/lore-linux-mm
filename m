Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82337C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 08:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50BB720866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 08:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50BB720866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E51A6B0005; Fri, 14 Jun 2019 04:22:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 096BC6B0006; Fri, 14 Jun 2019 04:22:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E29A86B0007; Fri, 14 Jun 2019 04:22:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9831D6B0005
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:22:01 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c27so2685286edn.8
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:22:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CY2TlXfB8dVsVAp584QN/lYh7FIqH+DAA9aK+ioEtIw=;
        b=svJ+cWM3CiugVtA/7Z8KbbnrxGPh5MMBSFnPiRFYCqnl37taoVkRuAQ7K1QW+hY+l9
         02yub5zTHMJQXR3BIe4aUZilaG68sCJsLk7UQTwXbY2eSOlMsyMHvja809G+0t4BJ/O1
         leWV3Hvl5A50R+v871SZlh4L5xucl0TY5hajHwkI0xcJh4p3kYKl9dKmE7gPMuNZcS94
         ivGDKfVYFiXb27spKY/AtiGpz//UIm5UhG+Y+ChIyS1JSYpDPav9+ogN2Jyju3vaZ0kr
         B6LoUYHiYoopM5NRNYdVtDxqDLzv1/FlC8qsTFgJDrOKTOFZ0op0fNfuOFqDGmI0TDYU
         qfnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUk9BroEtRRUvmlHDGFrjjMuxW27AXeUbkxVGgJM2J2zRdLKGk2
	PDQe4dKISuWLvAedq9uk5c+7KHhUFFZqRdRdumvlKLf25RI+VjkXf+ScVdATNqJlIbpwwmKTTER
	3/P9titaoVJLWEK828HhfIuEHikoidwQC6LJ6o6jPBiK7H9WmbPWRLt8awRwC/jTYtw==
X-Received: by 2002:a50:f599:: with SMTP id u25mr67062021edm.195.1560500521054;
        Fri, 14 Jun 2019 01:22:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfpdCv+b1MvEVXJpeDmYrJlZ7iBceuTp8Zydnwoi2nDHRCrkk2bjATrmXWWxIJBIKeMJsu
X-Received: by 2002:a50:f599:: with SMTP id u25mr67061946edm.195.1560500520109;
        Fri, 14 Jun 2019 01:22:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560500520; cv=none;
        d=google.com; s=arc-20160816;
        b=Z2ailkVsOiuowLtSsQGnbryvH0pRnY4K7lQfAZif+krsTqzXGjLVokEdXqmKWFgY2i
         USKqiy8Bhmwj8rS6mPZdRmZzqzyZXdmi7JXd8B91meLyh1ls3V9SHnC+q3IwgDeYbDHV
         gFWBYQuMpZTsNKMaa2lrQbWI2VAZjgd43pCu/CKE+h4vnEr9UIX209l2s4VIIjCepOhN
         H6xDGMQAx1Op6zgAXOhigjGHkL7svyQhT+FuTi+arvQm5dG/mTYrm0zAi+sjxrfV8wyt
         aBUQb4Qbf5HdKDD/sOQf7iB41hVUp7fnN7RZB8sPrfogcQ6LkhjBFcZBjdIJ5WIyMr2n
         5FRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CY2TlXfB8dVsVAp584QN/lYh7FIqH+DAA9aK+ioEtIw=;
        b=P+SMCitmFvv6kZBoEnWggDoXemIRLKsxyMUw+zsXVU9qTn4udeLWHiM+G7p1JTnoGc
         jbJnDXobf2+fTcYv358Hv3M/WQxM+14daapHT19iM+7EwXXuGeUgYWTUgr+iIdOFpxiu
         0/5ITkQxQcBlfQbswGgUZBj+MBYIJBu05bampXUEzwlAW+C+KSd5yZCgYcDbtKlF7wCs
         ru4PJt70nHawgyA/9a6rsplmswqGa4q9noZmzFULqpGlV3/PUzYc9sI7dHY6Fb4oahGG
         fPDZP+IQZhVqEhgIKlLhxt5Rc3eBLm0dX1vE2YuwCmXeNKdcCaaQM3RWk64oa61BD/7d
         Vlww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h47si1381759ede.173.2019.06.14.01.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 01:21:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4D0A5ADF1;
	Fri, 14 Jun 2019 08:21:59 +0000 (UTC)
Date: Fri, 14 Jun 2019 10:21:57 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: yuzhoujian <yuzhoujian@didichuxing.com>, Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/oom_kill: set oc->constraint in constrained_alloc()
Message-ID: <20190614082130.GA28901@dhcp22.suse.cz>
References: <1560434150-13626-1-git-send-email-laoar.shao@gmail.com>
 <20190613185640.GA1405@dhcp22.suse.cz>
 <CALOAHbB=sd0y53Tr6b7C41-bF+k1v292ULss64BrdCEySxTRiA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbB=sd0y53Tr6b7C41-bF+k1v292ULss64BrdCEySxTRiA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 14-06-19 13:58:11, Yafang Shao wrote:
> On Fri, Jun 14, 2019 at 2:56 AM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Thu 13-06-19 21:55:50, Yafang Shao wrote:
> > > In dump_oom_summary() oc->constraint is used to show
> > > oom_constraint_text, but it hasn't been set before.
> > > So the value of it is always the default value 0.
> > > We should set it in constrained_alloc().
> >
> > Thanks for catching that.
> >
> > > Bellow is the output when memcg oom occurs,
> > >
> > > before this patch:
> > > [  133.078102] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),
> > > cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=7997,uid=0
> > >
> > > after this patch:
> > > [  952.977946] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),
> > > cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=13681,uid=0
> > >
> >
> > unless I am missing something
> > Fixes: ef8444ea01d7 ("mm, oom: reorganize the oom report in dump_header")
> >
> > The patch looks correct but I think it is more complicated than it needs
> > to be. Can we do the following instead?
> >
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 5a58778c91d4..f719b64741d6 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -987,8 +987,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >  /*
> >   * Determines whether the kernel must panic because of the panic_on_oom sysctl.
> >   */
> > -static void check_panic_on_oom(struct oom_control *oc,
> > -                              enum oom_constraint constraint)
> > +static void check_panic_on_oom(struct oom_control *oc)
> >  {
> >         if (likely(!sysctl_panic_on_oom))
> >                 return;
> > @@ -998,7 +997,7 @@ static void check_panic_on_oom(struct oom_control *oc,
> >                  * does not panic for cpuset, mempolicy, or memcg allocation
> >                  * failures.
> >                  */
> > -               if (constraint != CONSTRAINT_NONE)
> > +               if (oc->constraint != CONSTRAINT_NONE)
> >                         return;
> >         }
> >         /* Do not panic for oom kills triggered by sysrq */
> > @@ -1035,7 +1034,6 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
> >  bool out_of_memory(struct oom_control *oc)
> >  {
> >         unsigned long freed = 0;
> > -       enum oom_constraint constraint = CONSTRAINT_NONE;
> >
> >         if (oom_killer_disabled)
> >                 return false;
> > @@ -1071,10 +1069,10 @@ bool out_of_memory(struct oom_control *oc)
> >          * Check if there were limitations on the allocation (only relevant for
> >          * NUMA and memcg) that may require different handling.
> >          */
> > -       constraint = constrained_alloc(oc);
> > -       if (constraint != CONSTRAINT_MEMORY_POLICY)
> > +       oc->constraint = constrained_alloc(oc);
> > +       if (oc->constraint != CONSTRAINT_MEMORY_POLICY)
> >                 oc->nodemask = NULL;
> > -       check_panic_on_oom(oc, constraint);
> > +       check_panic_on_oom(oc);
> >
> >         if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
> >             current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
> >
> > I guess the current confusion comes from the fact that we have
> > constraint both in the oom_control and a local variable so I would
> > rather remove that. What do you think?
> 
> Remove the local variable is fine by me.

Could you repost the patch with the changelog mentioning Fixes and the
simpler diff please?

You can then add
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

