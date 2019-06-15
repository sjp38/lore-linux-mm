Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D46C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:11:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D9DA2184E
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:11:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ipVwsL7J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D9DA2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 250846B0005; Sat, 15 Jun 2019 12:11:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2009E8E0002; Sat, 15 Jun 2019 12:11:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 116AB8E0001; Sat, 15 Jun 2019 12:11:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E46FC6B0005
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 12:11:50 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id 75so6397613ywb.3
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:11:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XfBQUtQbUflzlL5gXoL56FmCXzvbbHidoYyXkMyKoQc=;
        b=iu2gyLsCbt3x73RpafljiuwlTQQ0H1o5F5oltPBImA/aqoFUahIxIwEgBQHNcaToOD
         ogs5DGmMVDRf6xUaIyYGKWrUeEot4vS/fwc+zkijV1OuAVkjD/T0Uq9kXg+yjs7wW2d9
         c4lFLirbxxQhHAfQbzA9T92NJgpeiO5QVxGfkvxbkuqp7Fd6SXU+t996d8edumIyXKVh
         HQ1y5LWJXzHbkMoWEeR7JwoLvhspZjfSUjX+XPAkoG4CyMpOCm6sslxpjiADfAgwYj3i
         I7o/sWjRiIhgGelvvL3rlOBa73qwAB1jwrxqge+FpKqs6tWhOAulh0/2saNhvt29gn9m
         Gr9g==
X-Gm-Message-State: APjAAAXKUnT4c1HPLx6O9PY8Ph9LApG6oqo7b/7aBNXdD2lS/wmFeHZb
	kq1h1oso1+neX9VV8w95vafjVl/Gjmbx7prtALOFIEIH7ACcce/wwSXdMHPEwJ8nwb4ddsjC7gv
	BLXtYGWkX91XiBwwYsfiknVMNw7jQtFVYhCVHYLWK+ymMoMMwxKliqvRXjM14yhucjw==
X-Received: by 2002:a0d:f587:: with SMTP id e129mr53467144ywf.465.1560615110534;
        Sat, 15 Jun 2019 09:11:50 -0700 (PDT)
X-Received: by 2002:a0d:f587:: with SMTP id e129mr53467086ywf.465.1560615109495;
        Sat, 15 Jun 2019 09:11:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560615109; cv=none;
        d=google.com; s=arc-20160816;
        b=UI/ytggGHFsH0QmD7dGmWDCrASYgnBPrVRtTCEKkwRLoct+1c8ianc70CcoEvD4OrH
         rhJNc9APGhp3HeaMPfXiZUfp4Fk5dZcMiKxmXTEfXggUEjV6S+Qrfp6k5s9T4IReAm7z
         OGoxX7r7NuDkytLMOHcqLgQO8byYebOF6zXD+DDT259aOYJnXXfF5+RkfnRCsjfXxV8N
         WzouOoJMu/OyT0+0QXIa7Duu3qid3DMip7/HrrzVSgy7QxIlUggGalidvK4NbZE1WROB
         rVW88cFYH6JsbbkWyR9xwvH7oSGXWU8hKw59kNfnh4e1QN3yADqVnbUgn12+CFpeJ9zf
         CKgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XfBQUtQbUflzlL5gXoL56FmCXzvbbHidoYyXkMyKoQc=;
        b=FzqVVvp8vZ3nwnzi5ONOr3xtgQQtMCcshrrFCSi/zCikFFx3jALJa7YeP8JHON5rr/
         dosPchbhP7ZO+5m2oq7+En245NKT0dFZZ99DiIiV49leqaJ7k9NW4vYn897/AqIzJ2+k
         Mc0D1CmPrA1DLKdXWW2h1Xhqg6wvdcnN0mJsmvAtJNNoWMNERK0BrzzHKIYlHY/64Mqo
         ZsrIuatYkNE6I+hGm/Tx47ETgVuAsRlNncvekZzqzi9Hgj3NBJBbvxiv2oXYwY/6KybE
         24NjsvRKgCm7sJjjpJu3WmMf4YpE5GJuAlBuKtIe3J5i/hHrrlIuECpe7J2gI1BC4Tgh
         tJOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ipVwsL7J;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184sor3528513ywe.115.2019.06.15.09.11.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 09:11:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ipVwsL7J;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XfBQUtQbUflzlL5gXoL56FmCXzvbbHidoYyXkMyKoQc=;
        b=ipVwsL7JBtwqQ60y57/QQVRgEPGE1O0zywJzxb44QwpSOZglzFLbY6eUJ1uzLB/sB2
         dcawchwcYNXnetJRQcSW8Qk6DyStfIITaWSTIJ7x0exPSGlxcHc8l1U7v2pcu/F1qfAP
         6lw3TEqIImIF2HpRXN0k3FwfDmPk3N1A8U7ErEPKUo7WETp2TI4S2i8bGuDISjPWspdh
         bQipDoDcKLUcRn4D8TaWICJy+BAVPGBPTFDymCrdHaPgXuZ9bC0uylHuqZTiscz2PlEF
         oY9VM5jTAj72SqVWgHNPndgHiKJq6ePR+vv1uaqiZT7sbppP/H7yNF5JNHzRSaBbMXK9
         NwnA==
X-Google-Smtp-Source: APXvYqxqCQwnTjswkopI4Ctw1mHXH/vjwmIBUTDY33SGw8OLfcEmXYLIjHt/aW2ylM/efT8mCZZXjs/edDhY0sis1II=
X-Received: by 2002:a81:90e:: with SMTP id 14mr13071232ywj.4.1560615108857;
 Sat, 15 Jun 2019 09:11:48 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004143a5058b526503@google.com> <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz>
In-Reply-To: <20190615134955.GA28441@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 15 Jun 2019 09:11:37 -0700
Message-ID: <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
Subject: Re: general protection fault in oom_unkillable_task
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yuzhoujian@didichuxing.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 6:50 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 14-06-19 20:15:31, Shakeel Butt wrote:
> > On Fri, Jun 14, 2019 at 6:08 PM syzbot
> > <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com> wrote:
> > >
> > > Hello,
> > >
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    3f310e51 Add linux-next specific files for 20190607
> > > git tree:       linux-next
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=15ab8771a00000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=5d176e1849bbc45
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=d0fc9d3c166bc5e4a94b
> > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > >
> > > Unfortunately, I don't have any reproducer for this crash yet.
> > >
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
> > >
> > > kasan: CONFIG_KASAN_INLINE enabled
> > > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > > general protection fault: 0000 [#1] PREEMPT SMP KASAN
> > > CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-20190607
> > > #11
> > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > Google 01/01/2011
> > > RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> > > RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> >
> > It seems like oom_unkillable_task() is broken for memcg OOMs. It
> > should not be calling has_intersects_mems_allowed() for memcg OOMs.
>
> You are right. It doesn't really make much sense to check for the NUMA
> policy/cpusets when the memcg oom is NUMA agnostic. Now that I am
> looking at the code then I am really wondering why do we even call
> oom_unkillable_task from oom_badness. proc_oom_score shouldn't care
> about NUMA either.
>
> In other words the following should fix this unless I am missing
> something (task_in_mem_cgroup seems to be a relict from before the group
> oom handling). But please note that I am still not fully operation and
> laying in the bed.
>

Yes, we need something like this but not exactly.

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5a58778c91d4..43eb479a5dc7 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
>                 return true;
>
>         /* When mem_cgroup_out_of_memory() and p is not member of the group */
> -       if (memcg && !task_in_mem_cgroup(p, memcg))
> -               return true;
> +       if (memcg)
> +               return false;

This will break the dump_tasks() usage of oom_unkillable_task(). We
can change dump_tasks() to traverse processes like
mem_cgroup_scan_tasks() for memcg OOMs.

>
>         /* p may not have freeable memory in nodemask */
>         if (!has_intersects_mems_allowed(p, nodemask))
> @@ -318,7 +318,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>         struct oom_control *oc = arg;
>         unsigned long points;
>
> -       if (oom_unkillable_task(task, NULL, oc->nodemask))
> +       if (oom_unkillable_task(task, oc->memcg, oc->nodemask))
>                 goto next;
>
> --
> Michal Hocko
> SUSE Labs

