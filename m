Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C78EC3A589
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:04:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29EBF21773
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:04:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l5TlKx89"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29EBF21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 850306B0006; Sun, 18 Aug 2019 21:04:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 803166B0007; Sun, 18 Aug 2019 21:04:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EFF66B0008; Sun, 18 Aug 2019 21:04:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7C86B0006
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 21:04:02 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 01FCC181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:04:02 +0000 (UTC)
X-FDA: 75837380724.29.chess66_5d5cd297bac18
X-HE-Tag: chess66_5d5cd297bac18
X-Filterd-Recvd-Size: 8133
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:04:01 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id j4so400954iop.11
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 18:04:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HfoJAGWrkH4NewW4DlsdlbUgbyny21NhOFSwRgWC5kk=;
        b=l5TlKx89kwvRJPQ/VmDep65V8RWifCA4DafQ/RxMEA3HZ6kGuj1k+rZq8+3kV4Sxek
         rimTVBRean8D64xtq7IYawdoR654L6Mjj5ajJImEYVyf9K8FL7GyVb1A12NyoqBC5Qlh
         SN5zW5AcOqe98/DYVxuuiosh7d3Y5asLAM5E+4ITPmxrBAobke0icEpj1KdmcEepjIT+
         9zuJ9yTUXMATycXnyDDKAiQfCbShsqhr9prLrgswRz0Zq1hZlrI1M8+KUJyK2SCL4XFz
         Q7ir9nhTNtIQxR+ELxnf/Y9LVkep6z2h+3Ta/qrO7UE5js+tTluG59RQxWt2cJe6kgZL
         Dchw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=HfoJAGWrkH4NewW4DlsdlbUgbyny21NhOFSwRgWC5kk=;
        b=ZusdKWTdVMu0wYibhSHT/+EeXBeQ0gg9ldpHr88Wr4Nn8vXFyPTkAFcDFrScm21uQ3
         8B/Kvx/liQ8AIriChuZC9Fn0Jj1TDNbSmFT0c3kW48cfgORzYJ7FctXkDhtz8tBbcMHu
         pVZ2kyQIQ4YHvAmLsEjZxmsYE2uXFRrIYpCk3Yoq2E81qiJmCb9hYIePwkYGY7WugdNv
         Qf2PimI6vpDDWps2i9e0qRIIMj4xt1mJyhMNWqaDiz5vXeyZjMLyt5L5P2h0vvv4Vh0C
         6XAYpeEQYf+25mKfQzq7d7fe4k03UdkfWIhLkFiQg+wxzY0ub5XMKkt7hIMrQ3WVil/0
         RQNw==
X-Gm-Message-State: APjAAAWvxU6GlefYIpSJolNDUR5DSjv6lbXHcxVwPMGVgBdPDL/HMBT5
	vgNnG25Kdb3sthhH0bn4xxyI7QdGWp4hfX/HGbA=
X-Google-Smtp-Source: APXvYqxIyriG1MrrZIwF4GcFOYZhzUGz1ZZzuWu+gudX+QF3zPaECOwyHamvKPmAjFLuxRTvWi0WD+BXRc/Q9nWVKoc=
X-Received: by 2002:a5e:8a46:: with SMTP id o6mr10564003iom.36.1566176640856;
 Sun, 18 Aug 2019 18:04:00 -0700 (PDT)
MIME-Version: 1.0
References: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com> <CAFqt6zZOeoK0s6gP_-me1fJ_ymRN=QXj3mfKXNQ-i5_coK21iQ@mail.gmail.com>
In-Reply-To: <CAFqt6zZOeoK0s6gP_-me1fJ_ymRN=QXj3mfKXNQ-i5_coK21iQ@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 19 Aug 2019 09:03:23 +0800
Message-ID: <CALOAHbDOqU=LZ6aaiiaJCob-uMQG2NQ_8BL8upQcN-kB0f01XQ@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: skip killing processes under memcg protection
 at first scan
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	Roman Gushchin <guro@fb.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 1:11 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> On Sun, Aug 18, 2019 at 9:55 AM Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> > In the current memory.min design, the system is going to do OOM instead
> > of reclaiming the reclaimable pages protected by memory.min if the
> > system is lack of free memory. While under this condition, the OOM
> > killer may kill the processes in the memcg protected by memory.min.
> > This behavior is very weird.
> > In order to make it more reasonable, I make some changes in the OOM
> > killer. In this patch, the OOM killer will do two-round scan. It will
> > skip the processes under memcg protection at the first scan, and if it
> > can't kill any processes it will rescan all the processes.
> >
> > Regarding the overhead this change may takes, I don't think it will be a
> > problem because this only happens under system  memory pressure and
> > the OOM killer can't find any proper victims which are not under memcg
> > protection.
> >
> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: Roman Gushchin <guro@fb.com>
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > ---
> >  include/linux/memcontrol.h |  6 ++++++
> >  mm/memcontrol.c            | 16 ++++++++++++++++
> >  mm/oom_kill.c              | 23 +++++++++++++++++++++--
> >  3 files changed, 43 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 44c4146..58bd86b 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -337,6 +337,7 @@ static inline bool mem_cgroup_disabled(void)
> >
> >  enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
> >                                                 struct mem_cgroup *memcg);
> > +int task_under_memcg_protection(struct task_struct *p);
> >
> >  int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
> >                           gfp_t gfp_mask, struct mem_cgroup **memcgp,
> > @@ -813,6 +814,11 @@ static inline enum mem_cgroup_protection mem_cgroup_protected(
> >         return MEMCG_PROT_NONE;
> >  }
> >
> > +int task_under_memcg_protection(struct task_struct *p)
> > +{
> > +       return 0;
> > +}
> > +
> >  static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
> >                                         gfp_t gfp_mask,
> >                                         struct mem_cgroup **memcgp,
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index cdbb7a8..c4d8e53 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -6030,6 +6030,22 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
> >                 return MEMCG_PROT_NONE;
> >  }
> >
> > +int task_under_memcg_protection(struct task_struct *p)
> > +{
> > +       struct mem_cgroup *memcg;
> > +       int protected;
> > +
> > +       rcu_read_lock();
> > +       memcg = mem_cgroup_from_task(p);
> > +       if (memcg != root_mem_cgroup && memcg->memory.min)
> > +               protected = 1;
> > +       else
> > +               protected = 0;
> > +       rcu_read_unlock();
> > +
> > +       return protected;
>
> I think returning a bool type would be more appropriate.
>

Sure. Will change it.

> > +}
> > +
> >  /**
> >   * mem_cgroup_try_charge - try charging a page
> >   * @page: page to charge
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index eda2e2a..259dd2c 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -368,11 +368,30 @@ static void select_bad_process(struct oom_control *oc)
> >                 mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
> >         else {
> >                 struct task_struct *p;
> > +               int memcg_check = 0;
> > +               int memcg_skip = 0;
> > +               int selected = 0;
> >
> >                 rcu_read_lock();
> > -               for_each_process(p)
> > -                       if (oom_evaluate_task(p, oc))
> > +retry:
> > +               for_each_process(p) {
> > +                       if (!memcg_check && task_under_memcg_protection(p)) {
> > +                               memcg_skip = 1;
> > +                               continue;
> > +                       }
> > +                       selected = oom_evaluate_task(p, oc);
> > +                       if (selected)
> >                                 break;
> > +               }
> > +
> > +               if (!selected) {
> > +                       if (memcg_skip) {
> > +                               if (!oc->chosen || oc->chosen == (void *)-1UL) {
> > +                                       memcg_check = 1;
> > +                                       goto retry;
> > +                               }
> > +                       }
> > +               }
> >                 rcu_read_unlock();
> >         }
> >  }
> > --
> > 1.8.3.1
> >
> >

