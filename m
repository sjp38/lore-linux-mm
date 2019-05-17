Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C698C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:00:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 047C62087E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:00:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tmGIcEYD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 047C62087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 940B16B0272; Fri, 17 May 2019 09:00:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F1006B0273; Fri, 17 May 2019 09:00:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E30A6B0274; Fri, 17 May 2019 09:00:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4906B0272
	for <linux-mm@kvack.org>; Fri, 17 May 2019 09:00:26 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id z186so5990563ybz.10
        for <linux-mm@kvack.org>; Fri, 17 May 2019 06:00:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mDBqFBnl/mI/vA3sOLAkfmwTmcprIuj4fUiqGFg5fUQ=;
        b=gC8wgt+BiKmADbt06uqThX/VJcGM77+le7EAz0qPgEqXnIvyRJzS4wGyRpinyEVERc
         vDHk/R0ajcRqiMIzcj2/2GrNXDG+/z2XeQGqbl2Xbt7Hk+ASb6N7/HoeX2mCXmieebG8
         4yChewPaFw9CN177hH9Y0favOYiFETi2Tte83uU65xOVv0OnmoLz3YZuoszsnfPUTpCI
         7ueJukQbnQLmeCUCDsUZ0qh16STPfyRswq5w9P5r7uie4eaRgwvcgwlo0ODnRNl7apb2
         xJ351OkrVIx1ojwWanYlis5sMrNDiIYeR+pTSkOiHBuIO2R/qZO1zMcR+DQTLg8z6g1Z
         ABeg==
X-Gm-Message-State: APjAAAVXHw468JWdl2WF4W+iklwTFEFzJ5r6FwxShtQan6d7NGMAHnQW
	eB0N7gDvTp1BaOZESOpENLqgiaii3gmWYHie5nf64UAva2IKvCPzSVdWK4lRKeSiOzjmtjHWCV+
	CmF17mxt6ePFIt7d6MqbP+aEg7I62Ax8vDw3QBigtWQ6Uci9XE0y7zx4tCekZRxZlwg==
X-Received: by 2002:a81:9855:: with SMTP id p82mr23233244ywg.498.1558098025437;
        Fri, 17 May 2019 06:00:25 -0700 (PDT)
X-Received: by 2002:a81:9855:: with SMTP id p82mr23233199ywg.498.1558098024720;
        Fri, 17 May 2019 06:00:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558098024; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCymCd2SLhPg64ZGoaLfFgAtaA9/JSQ8BonnMIXcDDfX+HyxXUSZpXHXCSWTbIfY2I
         elCXFZ5WawCBseWMyl4nYSZNqfwFVlCpIgG808QzXP/QgE0oR7l3wBgT99G51Gq989c7
         93Nd46TB8JLyj+3eXawyJEhnUNcQSZayP4eeruGi/vRHb8qmU3V3t+9Cvnj1oZmts5y+
         P0vpnFYE5sqrPzi+8AkVvkMveEZtFvgEMoD0mNxwhKDX4Vg2Wbj7NCPSMNrm2B6e4xmf
         xoVaEsIbg2h5dYctnd8s29gf3icy7iSuIdLNpOES/MfAKcHqRjvhGiLj6+9MNIlw1Jek
         VoiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mDBqFBnl/mI/vA3sOLAkfmwTmcprIuj4fUiqGFg5fUQ=;
        b=DmnO5mjSaE3StJqnEoSjpbxiLemQEQkpedoiCVilhIJ7WKF/rodt0Hd6puezgdqXJ/
         1zNRj3NJwckwqYLbIDGbMQqlTI3B6toNpG/D6JjHprPup/4x+y8dKLlZaGP3T4+bPS5A
         NbatrbZPzLGsAkI3/qR16TRYSMKZf4z2j4mYsv0D/LKJKbIYTJUTz7NdPW9YLPzHXtHJ
         Dinv+Kql6Dsl7DqyJ1StMmIryJwPUPUdqbYn+vgzoRfaDY4tLCwLg4ujmCTU1Pvwg+tD
         aIDuj5WOlfiPIIR0IAjzdL0sF4LEL5agZjTfNLMdD3d0LX3LMjQCanSjTlo02EhwTMP4
         nSwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tmGIcEYD;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 206sor4583134ywt.112.2019.05.17.06.00.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 06:00:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tmGIcEYD;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mDBqFBnl/mI/vA3sOLAkfmwTmcprIuj4fUiqGFg5fUQ=;
        b=tmGIcEYDsmmvl9XBybk5bCehHqiVVamJ8va4etFKHZ+lDkqBz+2JQZW7OePPW+YTOM
         4cJIKLGBXwew6qb4mO8Wb4dWB90d4W7I4geWBSf1RV88cJ5ntccC63fLGlpNdcB4yunn
         kZkbCLCEkXdMGgPVpXmzoaZU/LgMOFy4NjWqteigLQlWTmDd/Eito4YMjHDUws6wkcQi
         3PKyTpuX6qbMzeRFxX1F+XxnjD6Z6ylU3XB5wNAU3ng609iWWzc1dqIBF6Pr4OuMUH3y
         5dHg5pluezmDHv5ViNtLaOXrg9mdvy/A64t84bBLOOmoIIvmnif+XiOkb3hejZwksNDP
         H+1A==
X-Google-Smtp-Source: APXvYqzQOIOtCID+VCkG+VZb7AruxteQ8MXssMpwcpwMTvfbPNANGegyfISxapmR+WPOt8VUxXdgNHQj9TCGVgTjjbE=
X-Received: by 2002:a0d:d9d7:: with SMTP id b206mr7055421ywe.398.1558098022392;
 Fri, 17 May 2019 06:00:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190212224542.ZW63a%akpm@linux-foundation.org> <20190213124729.GI4525@dhcp22.suse.cz>
In-Reply-To: <20190213124729.GI4525@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 17 May 2019 06:00:11 -0700
Message-ID: <CALvZod6c9OCy9p79hTgByjn+_BmnQ6p216kD9dgEhCSNFzpeKw@mail.gmail.com>
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, 
	Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, 
	Dennis Zhou <dennis@kernel.org>, Chris Down <chris@chrisdown.name>, 
	cgroups mailinglist <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 4:47 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 12-02-19 14:45:42, Andrew Morton wrote:
> [...]
> > From: Chris Down <chris@chrisdown.name>
> > Subject: mm, memcg: consider subtrees in memory.events
> >
> > memory.stat and other files already consider subtrees in their output, and
> > we should too in order to not present an inconsistent interface.
> >
> > The current situation is fairly confusing, because people interacting with
> > cgroups expect hierarchical behaviour in the vein of memory.stat,
> > cgroup.events, and other files.  For example, this causes confusion when
> > debugging reclaim events under low, as currently these always read "0" at
> > non-leaf memcg nodes, which frequently causes people to misdiagnose breach
> > behaviour.  The same confusion applies to other counters in this file when
> > debugging issues.
> >
> > Aggregation is done at write time instead of at read-time since these
> > counters aren't hot (unlike memory.stat which is per-page, so it does it
> > at read time), and it makes sense to bundle this with the file

I think the above statement (memory.stat read-time aggregation) need
to be fixed due to the latest changes.

> > notifications.
> >
> > After this patch, events are propagated up the hierarchy:
> >
> >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> >     low 0
> >     high 0
> >     max 0
> >     oom 0
> >     oom_kill 0
> >     [root@ktst ~]# systemd-run -p MemoryMax=1 true
> >     Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
> >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> >     low 0
> >     high 0
> >     max 7
> >     oom 1
> >     oom_kill 1
> >
> > As this is a change in behaviour, this can be reverted to the old
> > behaviour by mounting with the `memory_localevents' flag set.  However, we
> > use the new behaviour by default as there's a lack of evidence that there
> > are any current users of memory.events that would find this change
> > undesirable.
> >
> > Link: http://lkml.kernel.org/r/20190208224419.GA24772@chrisdown.name
> > Signed-off-by: Chris Down <chris@chrisdown.name>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

However can we please have memory.events.local merged along with this one?

> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Roman Gushchin <guro@fb.com>
> > Cc: Dennis Zhou <dennis@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
> FTR: As I've already said here [1] I can live with this change as long
> as there is a larger consensus among cgroup v2 users. So let's give this
> some more time before merging to see whether there is such a consensus.
>
> [1] http://lkml.kernel.org/r/20190201102515.GK11599@dhcp22.suse.cz
>
> > ---
> >
> >  Documentation/admin-guide/cgroup-v2.rst |    9 +++++++++
> >  include/linux/cgroup-defs.h             |    5 +++++
> >  include/linux/memcontrol.h              |   10 ++++++++--
> >  kernel/cgroup/cgroup.c                  |   16 ++++++++++++++--
> >  4 files changed, 36 insertions(+), 4 deletions(-)
> >
> > --- a/Documentation/admin-guide/cgroup-v2.rst~mm-consider-subtrees-in-memoryevents
> > +++ a/Documentation/admin-guide/cgroup-v2.rst
> > @@ -177,6 +177,15 @@ cgroup v2 currently supports the followi
> >       ignored on non-init namespace mounts.  Please refer to the
> >       Delegation section for details.
> >
> > +  memory_localevents
> > +
> > +        Only populate memory.events with data for the current cgroup,
> > +        and not any subtrees. This is legacy behaviour, the default
> > +        behaviour without this option is to include subtree counts.
> > +        This option is system wide and can only be set on mount or
> > +        modified through remount from the init namespace. The mount
> > +        option is ignored on non-init namespace mounts.
> > +
> >
> >  Organizing Processes and Threads
> >  --------------------------------
> > --- a/include/linux/cgroup-defs.h~mm-consider-subtrees-in-memoryevents
> > +++ a/include/linux/cgroup-defs.h
> > @@ -83,6 +83,11 @@ enum {
> >        * Enable cpuset controller in v1 cgroup to use v2 behavior.
> >        */
> >       CGRP_ROOT_CPUSET_V2_MODE = (1 << 4),
> > +
> > +     /*
> > +      * Enable legacy local memory.events.
> > +      */
> > +     CGRP_ROOT_MEMORY_LOCAL_EVENTS = (1 << 5),
> >  };
> >
> >  /* cftype->flags */
> > --- a/include/linux/memcontrol.h~mm-consider-subtrees-in-memoryevents
> > +++ a/include/linux/memcontrol.h
> > @@ -789,8 +789,14 @@ static inline void count_memcg_event_mm(
> >  static inline void memcg_memory_event(struct mem_cgroup *memcg,
> >                                     enum memcg_memory_event event)
> >  {
> > -     atomic_long_inc(&memcg->memory_events[event]);
> > -     cgroup_file_notify(&memcg->events_file);
> > +     do {
> > +             atomic_long_inc(&memcg->memory_events[event]);
> > +             cgroup_file_notify(&memcg->events_file);
> > +
> > +             if (cgrp_dfl_root.flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
> > +                     break;
> > +     } while ((memcg = parent_mem_cgroup(memcg)) &&
> > +              !mem_cgroup_is_root(memcg));
> >  }
> >
> >  static inline void memcg_memory_event_mm(struct mm_struct *mm,
> > --- a/kernel/cgroup/cgroup.c~mm-consider-subtrees-in-memoryevents
> > +++ a/kernel/cgroup/cgroup.c
> > @@ -1775,11 +1775,13 @@ int cgroup_show_path(struct seq_file *sf
> >
> >  enum cgroup2_param {
> >       Opt_nsdelegate,
> > +     Opt_memory_localevents,
> >       nr__cgroup2_params
> >  };
> >
> >  static const struct fs_parameter_spec cgroup2_param_specs[] = {
> > -     fsparam_flag  ("nsdelegate",            Opt_nsdelegate),
> > +     fsparam_flag("nsdelegate",              Opt_nsdelegate),
> > +     fsparam_flag("memory_localevents",      Opt_memory_localevents),
> >       {}
> >  };
> >
> > @@ -1802,6 +1804,9 @@ static int cgroup2_parse_param(struct fs
> >       case Opt_nsdelegate:
> >               ctx->flags |= CGRP_ROOT_NS_DELEGATE;
> >               return 0;
> > +     case Opt_memory_localevents:
> > +             ctx->flags |= CGRP_ROOT_MEMORY_LOCAL_EVENTS;
> > +             return 0;
> >       }
> >       return -EINVAL;
> >  }
> > @@ -1813,6 +1818,11 @@ static void apply_cgroup_root_flags(unsi
> >                       cgrp_dfl_root.flags |= CGRP_ROOT_NS_DELEGATE;
> >               else
> >                       cgrp_dfl_root.flags &= ~CGRP_ROOT_NS_DELEGATE;
> > +
> > +             if (root_flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
> > +                     cgrp_dfl_root.flags |= CGRP_ROOT_MEMORY_LOCAL_EVENTS;
> > +             else
> > +                     cgrp_dfl_root.flags &= ~CGRP_ROOT_MEMORY_LOCAL_EVENTS;
> >       }
> >  }
> >
> > @@ -1820,6 +1830,8 @@ static int cgroup_show_options(struct se
> >  {
> >       if (cgrp_dfl_root.flags & CGRP_ROOT_NS_DELEGATE)
> >               seq_puts(seq, ",nsdelegate");
> > +     if (cgrp_dfl_root.flags & CGRP_ROOT_MEMORY_LOCAL_EVENTS)
> > +             seq_puts(seq, ",memory_localevents");
> >       return 0;
> >  }
> >
> > @@ -6207,7 +6219,7 @@ static struct kobj_attribute cgroup_dele
> >  static ssize_t features_show(struct kobject *kobj, struct kobj_attribute *attr,
> >                            char *buf)
> >  {
> > -     return snprintf(buf, PAGE_SIZE, "nsdelegate\n");
> > +     return snprintf(buf, PAGE_SIZE, "nsdelegate\nmemory_localevents\n");
> >  }
> >  static struct kobj_attribute cgroup_features_attr = __ATTR_RO(features);
> >
> > _
> >
> > Patches currently in -mm which might be from chris@chrisdown.name are
> >
> > mm-create-mem_cgroup_from_seq.patch
> > mm-extract-memcg-maxable-seq_file-logic-to-seq_show_memcg_tunable.patch
> > mm-proportional-memorylowmin-reclaim.patch
> > mm-proportional-memorylowmin-reclaim-fix.patch
> > mm-memcontrol-expose-thp-events-on-a-per-memcg-basis.patch
> > mm-memcontrol-expose-thp-events-on-a-per-memcg-basis-fix-2.patch
> > mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
> > mm-rename-ambiguously-named-memorystat-counters-and-functions.patch
> > mm-consider-subtrees-in-memoryevents.patch
>
> --
> Michal Hocko
> SUSE Labs

