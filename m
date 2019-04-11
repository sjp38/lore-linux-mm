Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECD17C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:18:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 914BE2083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:18:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Yab0OJV0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 914BE2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C9F36B0003; Thu, 11 Apr 2019 11:18:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22BF76B0005; Thu, 11 Apr 2019 11:18:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F8AE6B000D; Thu, 11 Apr 2019 11:18:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id ADA106B0003
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:18:44 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t9so4073104wrs.16
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:18:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xfEK8JoLnvAlTYEmh21BcBw02CXXgGJ+pRY212fyXL4=;
        b=KKuuCoNJ8TItk8bW6Oj1Nw8jNsor6m/Z6JTtfa815f1Dp82v/1LOt7QBAn+GpGYBMi
         MJ4wi5EkANs97V91ZW6Pc0ODlh8PDu0iaLiAEa3CE7WfAeLyPtiYbqy1tGFR/7GXTo20
         d+XjMhPJguddgDFuGbzpuLQUkJynaq9m+7RQ+owYW0dVfHMpvNiDJsTk6meOQ1l3BtLO
         v9WTjKkrB49ZS5UiHwJ6D2KxUzG0uWWeZTDBl2m0QDxYE5Ibub2hOadaWxIDEYdVsR7v
         YL/i23yhb/5u7kAGtUTqUiXGKi64PG2EzFnVBDfp2mVHjru0SyP2bIUY+rBY8qFqXKuv
         wdSA==
X-Gm-Message-State: APjAAAUnzMVDKH9gbkYHBDVRQFhqk/muzl/gOs0DNluzrogmVnhs3ph1
	YBpmMBpWDQjZhyoUylSfsMCU5bJaSJxuNtIRP8deuc+wcDtTZ/fj6JCzsy7GBK3JMGmXjko6B/7
	GK7Rf+vNFvlgrm+Nrv1BC0CC91ocT/Gbsa9vIkqLpbL3scqdPb+4UJ0A+1oVGay5z2A==
X-Received: by 2002:a7b:cf2c:: with SMTP id m12mr7304703wmg.21.1554995924155;
        Thu, 11 Apr 2019 08:18:44 -0700 (PDT)
X-Received: by 2002:a7b:cf2c:: with SMTP id m12mr7304625wmg.21.1554995922847;
        Thu, 11 Apr 2019 08:18:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554995922; cv=none;
        d=google.com; s=arc-20160816;
        b=elAxw+21SdAXSEVtxiLe2KtGotLE1WeJ8lMfYOcEMEs/F1cvm9FG2uwYZQKw6Pob2j
         ejkDi5aoS7R08B637mKP1XBt1YgrXbkz5fPxEdfGRxDMQGdKUUWeD9ZPRRUyOsdAf+vI
         19RaP4dfyixTrxemVyq9UOei1y1H8YAD0zQ93TntVuJ9lbm30tdkN2N+LGeEJVP2kf2M
         3tPj9y26Lpu4r9a9Ecnfba2+8EHnJYMXTLV2J+oImbg2y7MZXwF/Yqaacu1FZULmxvSi
         Ayj+vw51drR2YYi75+iU88yBdGBl0ViaqnlSz6Z3sfcIAPI1YD49L/4WQ7T35Djo9YKz
         qUmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xfEK8JoLnvAlTYEmh21BcBw02CXXgGJ+pRY212fyXL4=;
        b=aSLIEFgVdBR+Rtext0sPI3vwgod+PyJLs53hoPF3xbacNUr1FjOabJYbsCs9wlS6YL
         eTuA4Oo+NKMtUs3IxK6gRsat0kw+BsRXkZyGOTK+w4w8bVyK8pPjacvDPOm3rMvstoUV
         S3juiqjKVB+xchowcQSoHJFNqm5RPpEZUvS8PHX7IP49VzmSF3L62kRlPkyoJwRJKLej
         MRP5p9VirebTHaZkk71LxIfqK4qc/C5P6CBYX2qzsiIm1KjXe3zJZZIwHDsE0qKw+BHp
         kYEUAxJA0LuaZjgWbSGf5Lfq41yw5kkE82MIULMlQuv5XCNboF5eEEmBJ+jlAByjjJkn
         3U7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Yab0OJV0;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor3998187wme.1.2019.04.11.08.18.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 08:18:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Yab0OJV0;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xfEK8JoLnvAlTYEmh21BcBw02CXXgGJ+pRY212fyXL4=;
        b=Yab0OJV0hfZlGhVyhQz2zWocwjswsQTgaw86r5tDsLSMTmwgtOkRI/qA3UFkflzIjy
         gBezNvRpXWgtbn9dFGopyDj+JpT0S/7HQDn0nNsC4tNybXyZlI+l/U7K9CSPgBV9ic+o
         Ld+hPMuncJTInlNHvyGKOQQa5metvW0TK1Z1OdCkcUP0uMW3VURKry6YGh/v61dMdKt1
         riKa0SP8oNoSUbHRwThtjcXZmFrTys2XkCt7BNTrGPOzt6f1UHWbLvbCsxxKqPWYdapH
         n8+hjdawuSnEbuCEYTeKmCrsxkg9KC8MptIXKXzI5LUw//THa2KbIMurdsWBhnmcMmGt
         +yuQ==
X-Google-Smtp-Source: APXvYqwXz2rkMapEv1YNphBoRYrg5AYN2B8owq1UP/71hpxEPcnWFIDc4qPw2tlXxwP3LIM7mt4qTdXlcor5Gl8qzFg=
X-Received: by 2002:a1c:4102:: with SMTP id o2mr6956266wma.91.1554995921942;
 Thu, 11 Apr 2019 08:18:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411103018.tcsinifuj7klh6rp@brauner.io>
In-Reply-To: <20190411103018.tcsinifuj7klh6rp@brauner.io>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 11 Apr 2019 08:18:30 -0700
Message-ID: <CAJuCfpE4BsUHUZp_5XzSYrXbampFwOZoJ-XYp2iZtT6vqSEruQ@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Christian Brauner <christian@brauner.io>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, 
	David Rientjes <rientjes@google.com>, Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, ebiederm@xmission.com, 
	Shakeel Butt <shakeelb@google.com>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Daniel Colascione <dancol@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, 
	lsf-pc@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for the feedback!
Just to be clear, this implementation is used in this RFC as a
reference to explain the intent. To be honest I don't think it will be
adopted as is even if the idea survives scrutiny.

On Thu, Apr 11, 2019 at 3:30 AM Christian Brauner <christian@brauner.io> wrote:
>
> On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > victim process. The usage of this flag is currently limited to SIGKILL
> > signal and only to privileged users.
> >
> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > ---
> >  include/linux/sched/signal.h |  3 ++-
> >  include/linux/signal.h       | 11 ++++++++++-
> >  ipc/mqueue.c                 |  2 +-
> >  kernel/signal.c              | 37 ++++++++++++++++++++++++++++--------
> >  kernel/time/itimer.c         |  2 +-
> >  5 files changed, 43 insertions(+), 12 deletions(-)
> >
> > diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
> > index e412c092c1e8..8a227633a058 100644
> > --- a/include/linux/sched/signal.h
> > +++ b/include/linux/sched/signal.h
> > @@ -327,7 +327,8 @@ extern int send_sig_info(int, struct kernel_siginfo *, struct task_struct *);
> >  extern void force_sigsegv(int sig, struct task_struct *p);
> >  extern int force_sig_info(int, struct kernel_siginfo *, struct task_struct *);
> >  extern int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp);
> > -extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid);
> > +extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
> > +                             bool expedite);
> >  extern int kill_pid_info_as_cred(int, struct kernel_siginfo *, struct pid *,
> >                               const struct cred *);
> >  extern int kill_pgrp(struct pid *pid, int sig, int priv);
> > diff --git a/include/linux/signal.h b/include/linux/signal.h
> > index 9702016734b1..34b7852aa4a0 100644
> > --- a/include/linux/signal.h
> > +++ b/include/linux/signal.h
> > @@ -446,8 +446,17 @@ int __save_altstack(stack_t __user *, unsigned long);
> >  } while (0);
> >
> >  #ifdef CONFIG_PROC_FS
> > +
> > +/*
> > + * SS_FLAGS values used in pidfd_send_signal:
> > + *
> > + * SS_EXPEDITE indicates desire to expedite the operation.
> > + */
> > +#define SS_EXPEDITE  0x00000001
>
> Does this make sense as an SS_* flag?
> How does this relate to the signal stack?

It doesn't, so I agree that the name should be changed.
PIDFD_SIGNAL_EXPEDITE_MM_RECLAIM would seem appropriate.

> Is there any intention to ever use this flag with stack_t?
>
> New flags should be PIDFD_SIGNAL_*. (E.g. the thread flag will be
> PIDFD_SIGNAL_THREAD.)
> And since this is exposed to userspace in contrast to the mm internal
> naming it should be something more easily understandable like
> PIDFD_SIGNAL_MM_RECLAIM{_FASTER} or something.
>
> > +
> >  struct seq_file;
> >  extern void render_sigset_t(struct seq_file *, const char *, sigset_t *);
> > -#endif
> > +
> > +#endif /* CONFIG_PROC_FS */
> >
> >  #endif /* _LINUX_SIGNAL_H */
> > diff --git a/ipc/mqueue.c b/ipc/mqueue.c
> > index aea30530c472..27c66296e08e 100644
> > --- a/ipc/mqueue.c
> > +++ b/ipc/mqueue.c
> > @@ -720,7 +720,7 @@ static void __do_notify(struct mqueue_inode_info *info)
> >                       rcu_read_unlock();
> >
> >                       kill_pid_info(info->notify.sigev_signo,
> > -                                   &sig_i, info->notify_owner);
> > +                                   &sig_i, info->notify_owner, false);
> >                       break;
> >               case SIGEV_THREAD:
> >                       set_cookie(info->notify_cookie, NOTIFY_WOKENUP);
> > diff --git a/kernel/signal.c b/kernel/signal.c
> > index f98448cf2def..02ed4332d17c 100644
> > --- a/kernel/signal.c
> > +++ b/kernel/signal.c
> > @@ -43,6 +43,7 @@
> >  #include <linux/compiler.h>
> >  #include <linux/posix-timers.h>
> >  #include <linux/livepatch.h>
> > +#include <linux/oom.h>
> >
> >  #define CREATE_TRACE_POINTS
> >  #include <trace/events/signal.h>
> > @@ -1394,7 +1395,8 @@ int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp)
> >       return success ? 0 : retval;
> >  }
> >
> > -int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
> > +int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
> > +                               bool expedite)
> >  {
> >       int error = -ESRCH;
> >       struct task_struct *p;
> > @@ -1402,8 +1404,17 @@ int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
> >       for (;;) {
> >               rcu_read_lock();
> >               p = pid_task(pid, PIDTYPE_PID);
> > -             if (p)
> > +             if (p) {
> >                       error = group_send_sig_info(sig, info, p, PIDTYPE_TGID);
> > +
> > +                     /*
> > +                      * Ignore expedite_reclaim return value, it is best
> > +                      * effort only.
> > +                      */
> > +                     if (!error && expedite)
> > +                             expedite_reclaim(p);
>
> SIGKILL will take the whole thread group down so the reclaim should make
> sense here.
>

This sounds like confirmation. I hope I'm not missing some flaw that
you are trying to point out.

> > +             }
> > +
> >               rcu_read_unlock();
> >               if (likely(!p || error != -ESRCH))
> >                       return error;
> > @@ -1420,7 +1431,7 @@ static int kill_proc_info(int sig, struct kernel_siginfo *info, pid_t pid)
> >  {
> >       int error;
> >       rcu_read_lock();
> > -     error = kill_pid_info(sig, info, find_vpid(pid));
> > +     error = kill_pid_info(sig, info, find_vpid(pid), false);
> >       rcu_read_unlock();
> >       return error;
> >  }
> > @@ -1487,7 +1498,7 @@ static int kill_something_info(int sig, struct kernel_siginfo *info, pid_t pid)
> >
> >       if (pid > 0) {
> >               rcu_read_lock();
> > -             ret = kill_pid_info(sig, info, find_vpid(pid));
> > +             ret = kill_pid_info(sig, info, find_vpid(pid), false);
> >               rcu_read_unlock();
> >               return ret;
> >       }
> > @@ -1704,7 +1715,7 @@ EXPORT_SYMBOL(kill_pgrp);
> >
> >  int kill_pid(struct pid *pid, int sig, int priv)
> >  {
> > -     return kill_pid_info(sig, __si_special(priv), pid);
> > +     return kill_pid_info(sig, __si_special(priv), pid, false);
> >  }
> >  EXPORT_SYMBOL(kill_pid);
> >
> > @@ -3577,10 +3588,20 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
> >       struct pid *pid;
> >       kernel_siginfo_t kinfo;
> >
> > -     /* Enforce flags be set to 0 until we add an extension. */
> > -     if (flags)
> > +     /* Enforce no unknown flags. */
> > +     if (flags & ~SS_EXPEDITE)
> >               return -EINVAL;
> >
> > +     if (flags & SS_EXPEDITE) {
> > +             /* Enforce SS_EXPEDITE to be used with SIGKILL only. */
> > +             if (sig != SIGKILL)
> > +                     return -EINVAL;
>
> Not super fond of this being a SIGKILL specific flag but I get why.

Understood. I was thinking that EXPEDITE flag might make sense for
other signals in the future but from internal feedback sounds like if
we go this way the flag name should be more specific.

> > +
> > +             /* Limit expedited killing to privileged users only. */
> > +             if (!capable(CAP_SYS_NICE))
> > +                     return -EPERM;
>
> Do you have a specific (DOS or other) attack vector in mind that renders
> ns_capable unsuitable?
>
> > +     }
> > +
> >       f = fdget_raw(pidfd);
> >       if (!f.file)
> >               return -EBADF;
> > @@ -3614,7 +3635,7 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
> >               prepare_kill_siginfo(sig, &kinfo);
> >       }
> >
> > -     ret = kill_pid_info(sig, &kinfo, pid);
> > +     ret = kill_pid_info(sig, &kinfo, pid, (flags & SS_EXPEDITE) != 0);
> >
> >  err:
> >       fdput(f);
> > diff --git a/kernel/time/itimer.c b/kernel/time/itimer.c
> > index 02068b2d5862..c926483cdb53 100644
> > --- a/kernel/time/itimer.c
> > +++ b/kernel/time/itimer.c
> > @@ -140,7 +140,7 @@ enum hrtimer_restart it_real_fn(struct hrtimer *timer)
> >       struct pid *leader_pid = sig->pids[PIDTYPE_TGID];
> >
> >       trace_itimer_expire(ITIMER_REAL, leader_pid, 0);
> > -     kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid);
> > +     kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid, false);
> >
> >       return HRTIMER_NORESTART;
> >  }
> > --
> > 2.21.0.392.gf8f6787159e-goog
> >

