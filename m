Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8797BC31681
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 18:17:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38BCB2085A
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 18:17:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="k9q2rpu+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38BCB2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C06C78E0005; Mon, 21 Jan 2019 13:16:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB5D68E0001; Mon, 21 Jan 2019 13:16:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA63B8E0005; Mon, 21 Jan 2019 13:16:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7808F8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:16:59 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id l7so11604538ywh.16
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:16:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yqWAy9Z9opyx6z4Tb1LRzCzNVLXkkyvInsVgcl7h00E=;
        b=qG5cvFa1Gg+9nQhmn8knJrE6TjZJW48gRn4VPjJiMmbrD5IF6RcvydhadLZHKZiysO
         e6IgRTBTgEJ2SsHjB0btP/SC320YVE8nYDlgvvPs5mIIT1fCdhLMtbW6Yy7zrTBDDpIy
         RtIPjm4DVq3ewvHTv9qgUJhlJxmp5nQ6Gy4ThwJpmTLscxBa1FKkMPo8tMJaq+Coa2d4
         SPglp+gr5PS+UqQH6rwuzvoDwf8rfDDbO2dJkd9NAn5tT5UyYtGzMjLfWmJ6gbq+g8pn
         Mee6kxC3b3W45OB6ZSkcHoKwjhkgxuFcMKcjpa5BP2xeGGuU7OBzcekApF9FAkZaYBI9
         9Qfg==
X-Gm-Message-State: AJcUukc7GfyWME4Ps3dwh/PAMoslizYdYEqnLM7bC1aUN4z/Pxsqtd+C
	XZ3phW4PayogyTBKvi19ji7vFG7NdQxqzGVoZ3GObSKz48ilWSrfuEcQwIC1r/Uv0aghCZB4Ou8
	RcYpATWQIG8ATgBD7Lm70s1shaV5inBv5QvzCiBjb0dVOMZH0MVsgqaRSzRYccn0cAWbEAtHx+B
	qH8lmvdxe1DnTtXZvqMvcvpal1DI7JT1+8uaekcZaIGKT586wFsLlrRwB9ujaqmqw4uOKdEHXiI
	8RC+DP+8iejXN8W/RYf9ncR0U2kUpkiGe5upr07OahlyEC0EasYbR1aJ9w8Ot/r5SPqLkNLGzbx
	aP0AbY97aMWGiRqYh1K39Ixm9mGnIHFYKsi/FY15U4oCrRR0dD562B17USg4yl3qpkBC4gcNBVE
	q
X-Received: by 2002:a5b:1d1:: with SMTP id f17mr17849310ybp.413.1548094619188;
        Mon, 21 Jan 2019 10:16:59 -0800 (PST)
X-Received: by 2002:a5b:1d1:: with SMTP id f17mr17849261ybp.413.1548094618467;
        Mon, 21 Jan 2019 10:16:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548094618; cv=none;
        d=google.com; s=arc-20160816;
        b=tzXWps/FlfPou3mt6Kbv83/WEIs7zfKdvOHmSttAKxEzdKAp0MVY/mFeYHWHty8uQM
         PEcJRSfUFUWeCTeJb8o576LQ7psq//mQWlBXRALYpv0x+b6AIIJSvsvWGTLRw3moj25k
         HoyPj1IMBuNMN/o8yTZ0ZKuynzTLGeO8ZHOEn388RCvJ4P/YqOUTycc7SW791izjd1v/
         +7yX9hdKhTHJ95qUUK72SGUJoixjPrGtnd6BpiaP2kuY7w9uEUOgneYepsMjL+OWt53c
         KBJTIuA+uyBKEpSFns8ydSfTdfsSPMqO2u4j5dMoNtN+pTF/my9fJ811p4ehsO/+J/hj
         B94A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yqWAy9Z9opyx6z4Tb1LRzCzNVLXkkyvInsVgcl7h00E=;
        b=iLIYiXXXWApisCjO8SRaI6fLpdi9urPTrrLaZUEsuSd+lyU8PleeUjdKoAzTkTpsHs
         9e0aEwpwOXTggwBc7Z09xEOAI7nqDsu6hzEerLRlbD7BIRG2umzAGfhtAC/Kq6rrX0QZ
         WEN83zd2UPU3TwQZ94qHpeKczdQFSisrm4gN0pdEYqf5KHPExstJry3FEL7BKP3kolaO
         UMBQQyzB5wo07AMN7RE0Nz4QbaIW66KUMwM8AIgZzm6QvnjJEBm88upiXOgFDY+R7fYx
         7MB6UvqWuNwno1e9If6UAZVGe/wVfxISBYBZAXHmWfegpi+XnWnQb22P/C5RRWBFw1EZ
         am1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=k9q2rpu+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1sor5805725ybe.26.2019.01.21.10.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:16:58 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=k9q2rpu+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yqWAy9Z9opyx6z4Tb1LRzCzNVLXkkyvInsVgcl7h00E=;
        b=k9q2rpu+CziuO2sZ88V02gPiunwNegCSfruPvj/IYCJ36M5JJck244BbMFrmiw4aiD
         nxGV/R3ewy7FYfAXBcHal1+++S8W4mXgkU2WONeNHdHOrFd5H0e5HLE0iFTzzTGreT0r
         sxlJMiUcxhl2mV9ruX2UZm0CutfFY4hDrmBEZXqdSqjcDvpQLLEg98yyeQ0kFjHY43n7
         XI7wjEBlbaY0a2gQTh5sKIV7c8ysw08A6nhbxmu5HjxHDpSyH7eRbjZmBKYnHZhworfQ
         C0UNWIrLlDYoLHlevygU62R0Qm4pgI3uqdI4T5tbH32hG/ZVmshsUCy0iGFw1N9nMQaB
         fzyg==
X-Google-Smtp-Source: ALg8bN7Yd6u8G+XkZK/u9Y7F0bKJZN4uJSK6xVQ0zkB1uvEob12BxJRDrIjA2AQdImzqxPAoAz/5wSQF6buIeLq3EPQ=
X-Received: by 2002:a25:6f8b:: with SMTP id k133mr6385877ybc.496.1548094617882;
 Mon, 21 Jan 2019 10:16:57 -0800 (PST)
MIME-Version: 1.0
References: <20190120215059.183552-1-shakeelb@google.com> <20190121091933.GL4087@dhcp22.suse.cz>
In-Reply-To: <20190121091933.GL4087@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 21 Jan 2019 10:16:47 -0800
Message-ID:
 <CALvZod7PaFzTkHmE2Vz06jrfWK3owo098+OUW55dfh1i=d39pA@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: remove 'prefer children over parent' heuristic
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121181647.kbCJA8P2RhimIgYGWfOvmRefORrO-y3CThRR4DqNleI@z>

On Mon, Jan 21, 2019 at 1:19 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sun 20-01-19 13:50:59, Shakeel Butt wrote:
> > >From the start of the git history of Linux, the kernel after selecting
> > the worst process to be oom-killed, prefer to kill its child (if the
> > child does not share mm with the parent). Later it was changed to prefer
> > to kill a child who is worst. If the parent is still the worst then the
> > parent will be killed.
> >
> > This heuristic assumes that the children did less work than their parent
> > and by killing one of them, the work lost will be less. However this is
> > very workload dependent. If there is a workload which can benefit from
> > this heuristic, can use oom_score_adj to prefer children to be killed
> > before the parent.
> >
> > The select_bad_process() has already selected the worst process in the
> > system/memcg. There is no need to recheck the badness of its children
> > and hoping to find a worse candidate. That's a lot of unneeded racy
> > work. So, let's remove this whole heuristic.
>
> Yes, I agree with this direction. Let's try it and see whether there is
> anything really depending on the heuristic. I hope that is not the case
> but at least we will hear about it and the reasoning behind.
>
> I think the changelog should also mension that the heuristic is
> dangerous because it make fork bomb like workloads to recover much later
> because we constantly pick and kill processes which are not memory hogs.
>
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> Appart from the nit in the printk output
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> Also I would prefer s@p@victim@ because it makes the code more readable
>
> I pressume you are going to send this along with the fix for the
> use-after-free in one series.
>
> Thanks.

Yes, I will resend the series after incorporating the feedback.

>
> > ---
> >  mm/oom_kill.c | 49 ++++---------------------------------------------
> >  1 file changed, 4 insertions(+), 45 deletions(-)
> >
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 1a007dae1e8f..6cee185dc147 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -944,12 +944,7 @@ static int oom_kill_memcg_member(struct task_struct *task, void *unused)
> >  static void oom_kill_process(struct oom_control *oc, const char *message)
> >  {
> >       struct task_struct *p = oc->chosen;
> > -     unsigned int points = oc->chosen_points;
> > -     struct task_struct *victim = p;
> > -     struct task_struct *child;
> > -     struct task_struct *t;
> >       struct mem_cgroup *oom_group;
> > -     unsigned int victim_points = 0;
> >       static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> >                                             DEFAULT_RATELIMIT_BURST);
> >
> > @@ -971,53 +966,17 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >       if (__ratelimit(&oom_rs))
> >               dump_header(oc, p);
> >
> > -     pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
> > -             message, task_pid_nr(p), p->comm, points);
> > -
> > -     /*
> > -      * If any of p's children has a different mm and is eligible for kill,
> > -      * the one with the highest oom_badness() score is sacrificed for its
> > -      * parent.  This attempts to lose the minimal amount of work done while
> > -      * still freeing memory.
> > -      */
> > -     read_lock(&tasklist_lock);
> > -
> > -     /*
> > -      * The task 'p' might have already exited before reaching here. The
> > -      * put_task_struct() will free task_struct 'p' while the loop still try
> > -      * to access the field of 'p', so, get an extra reference.
> > -      */
> > -     get_task_struct(p);
> > -     for_each_thread(p, t) {
> > -             list_for_each_entry(child, &t->children, sibling) {
> > -                     unsigned int child_points;
> > -
> > -                     if (process_shares_mm(child, p->mm))
> > -                             continue;
> > -                     /*
> > -                      * oom_badness() returns 0 if the thread is unkillable
> > -                      */
> > -                     child_points = oom_badness(child,
> > -                             oc->memcg, oc->nodemask, oc->totalpages);
> > -                     if (child_points > victim_points) {
> > -                             put_task_struct(victim);
> > -                             victim = child;
> > -                             victim_points = child_points;
> > -                             get_task_struct(victim);
> > -                     }
> > -             }
> > -     }
> > -     put_task_struct(p);
> > -     read_unlock(&tasklist_lock);
> > +     pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> > +             message, task_pid_nr(p), p->comm, oc->chosen_points);
> >
> >       /*
> >        * Do we need to kill the entire memory cgroup?
> >        * Or even one of the ancestor memory cgroups?
> >        * Check this out before killing the victim task.
> >        */
> > -     oom_group = mem_cgroup_get_oom_group(victim, oc->memcg);
> > +     oom_group = mem_cgroup_get_oom_group(p, oc->memcg);
> >
> > -     __oom_kill_process(victim);
> > +     __oom_kill_process(p);
> >
> >       /*
> >        * If necessary, kill all tasks in the selected memory cgroup.
> > --
> > 2.20.1.321.g9e740568ce-goog
>
> --
> Michal Hocko
> SUSE Labs

