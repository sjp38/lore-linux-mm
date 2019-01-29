Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAD8BC282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:52:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C90721738
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 01:52:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NYCGelSt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C90721738
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D100C8E0003; Mon, 28 Jan 2019 20:52:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9A318E0001; Mon, 28 Jan 2019 20:52:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3BC48E0003; Mon, 28 Jan 2019 20:52:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31E308E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 20:52:57 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id 18so5239192wmw.6
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:52:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HkVjCxb3t6ytaonp3kLCDVbei/+VDHkAiK+AmrSuWOI=;
        b=un52MTua7aIre309Kfnt1vYFZWCDL98ubQNZtlr0JAmEDGKXe2lzwdmRHjKBKweXTk
         tWtNfLvxbAU2QLbDor9qz/Whh9uPQucRvmoopdETja2LzSjy4p7IPjeR2IYHGL7k8NSb
         Lz4hMUc4fxeB0BKSYteEqnfeB4z/g8XR4lVNEwU6sAfP3WQG4bEHEWLD0PcaWPVAT6d6
         iY9xVPpMcFiLWqQppBU0asMJUgQRxH+e0devCBzlr8Q1X3vWZlK54pc067tbe6McUdhT
         6XbKMqnys2/HE0c+yD6IsEaXRt5Ww5eetSkdBWfPSXYulK3KcPsuB8u41X2lhHT33vJn
         taDg==
X-Gm-Message-State: AJcUukcko32GR0P6tzsFe1Dh7j+moQrzVziRAUOZhexYuh4pR0aHHJJU
	z60ywn0fVP9g0tzaYNbiIj6P9zPWE9tLcAIYYT3XdI2UTbzKSTcgiMtEi8D2to1FaaYKoEa9lE4
	wH/MozK6vrCC/5skhVlE/lrGssyZpHxtDOWH9q+0p+i1rAnwSalcDEmS7PJSI8ZpeH0y7Q7w3LH
	DlMOh3sdYh6VqkNXKpfYP/dLcCiugIA6+l43ebPbg7WkGxnOGGkmdQSbUfvwyTg8+rnhB6nevXd
	LEcn6sv3YztfL+kJrRxSqx0v3mtG23rMf1VvPR6gSMuYZylyZYpFrHEs13hH4QiPa+l1FowBLOy
	ZFZJWeFmZV4ZDoRIiFFTigLTA1eiX29bnLuw93byqB0X/ecVC5c4rsK5BW5JhqdPLLHhyOhk9as
	G
X-Received: by 2002:a1c:a4c4:: with SMTP id n187mr19285867wme.15.1548726776488;
        Mon, 28 Jan 2019 17:52:56 -0800 (PST)
X-Received: by 2002:a1c:a4c4:: with SMTP id n187mr19285777wme.15.1548726774213;
        Mon, 28 Jan 2019 17:52:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548726774; cv=none;
        d=google.com; s=arc-20160816;
        b=yQcCuwHYQGIIJU0iNcd8LqhINdAGGcaZolHL98BqXOGeXvab4t2b9QDdb3ZC9DldUT
         mm9KERL73TsnwPBZm4CH9PJ8dQ7Hm3noTnLTCPX368m5lVseI2T5w3+evmEYdEg2H2+7
         /lA9orZnB9GCWoC8axKkNqDXeSyAunq48wg+r2s669CCUjlz7aonCgJdvwC6+3ZzRSXj
         gW9c9XD8u6FEwTRLbzCBs2BrZ7FTsyIR2W1hSHzdddJPnO8Zli6ABfEB7Rf4HD3Y4L2s
         A2XIqEzJzGo3R6MWYVHunuc9u9VX5LZezCMjnXrum1XRvEAbNAVcDyWoW9W0qGJWu0fk
         xdSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HkVjCxb3t6ytaonp3kLCDVbei/+VDHkAiK+AmrSuWOI=;
        b=FYLA7T5hB2hKi730m7sOaeuDklywkRbzleKSK7beRc+X6hr9s6/lW/4RuuIMr9p5M0
         8i7ghXdBMOyM7XkzK+cKPaD8sQvUvEf5TYce5fo7sxUuQVXIyaNbMXE0zk964lH//6GJ
         Zzr1XeYBZoGPB/IY0NZFsu5bhOb+ORpTetS4yjrAdq40lXP06ikwzKkpLUEn6fN1LzBK
         /cch25axTXhu/Bu/j+IDMCsVmHr751F07v+KqIsAD5a70p92NHTKD/9u4K28uY0LyNHA
         RBOzR9fT2YXHAFuDSYWWl9SIoGjFot41H11VzaSE2alZPHglxoaYq13Hx7z3wn4raH8Q
         XajQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NYCGelSt;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor79823894wrj.2.2019.01.28.17.52.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 17:52:54 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NYCGelSt;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HkVjCxb3t6ytaonp3kLCDVbei/+VDHkAiK+AmrSuWOI=;
        b=NYCGelStrQBg6vXy1MgTHTQ68wlUTou+rnxUJ+Gfa5Hzag2YWMCFeZpkGSefgRrR0j
         Twafu7tdGbao19E4qQpGHgmi/phDGBSnPZfGMRKPiXuHlIbcDDJqhGKyBa6h0aefK5NQ
         fpOunwwDo3g+lJr/R835q65Bs9Gbwp+DbRcjEVoYp8myiyaKxtMjQuOpOsqjWQ0uyz8r
         4WGd3gY+z1Ub+N/WoO6Fco+BIqngceXRNj6WULTc8vYNRaTQLUgYfhwnhzVZObLaQlwG
         8g91c2/tfKbxhB/628gujkMMd/2NZXEwxtFzrr7nt/8eCfnD0Lpp1GaazGjD/SC8RKTm
         sRwQ==
X-Google-Smtp-Source: ALg8bN7dJUD3O0zT8z8sjABWjlJGmb8nFioVcF4XxjgvyYuES17zOjpIZGLzXVOZgTlOse4hx0AIhn/4e/zcMeRG540=
X-Received: by 2002:a5d:4e82:: with SMTP id e2mr23322149wru.291.1548726773198;
 Mon, 28 Jan 2019 17:52:53 -0800 (PST)
MIME-Version: 1.0
References: <20190124211518.244221-1-surenb@google.com> <20190124211518.244221-6-surenb@google.com>
 <20190128235358.GA211479@google.com>
In-Reply-To: <20190128235358.GA211479@google.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 28 Jan 2019 17:52:42 -0800
Message-ID: <CAJuCfpEUwGQzoKPZy_N1xBsnXKpzyPNMMB4a37pEm2TZvFofcg@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, 
	Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, 
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team@android.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 3:54 PM Minchan Kim <minchan@kernel.org> wrote:
>
> Hi Suren,
>
> When I review first time, it was rather hard to understand due to naming
> so below comments are mostly cleanup or minor.
> I'm not strong against if you don't think it's helpful.
> Feel free to select parts.
>
> Thanks.

Thanks for your input Minchan! This is very timely because I have to
re-post ver 4. Will address your comments before re-posting it.

> On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> > Psi monitor aims to provide a low-latency short-term pressure
> > detection mechanism configurable by users. It allows users to
> > monitor psi metrics growth and trigger events whenever a metric
> > raises above user-defined threshold within user-defined time window.
> >
> > Time window and threshold are both expressed in usecs. Multiple psi
> > resources with different thresholds and window sizes can be monitored
> > concurrently.
> >
> > Psi monitors activate when system enters stall state for the monitored
> > psi metric and deactivate upon exit from the stall state. While system
> > is in the stall state psi signal growth is monitored at a rate of 10 times
> > per tracking window. Min window size is 500ms, therefore the min monitoring
> > interval is 50ms. Max window size is 10s with monitoring interval of 1s.
> >
> > When activated psi monitor stays active for at least the duration of one
> > tracking window to avoid repeated activations/deactivations when psi
> > signal is bouncing.
> >
> > Notifications to the users are rate-limited to one per tracking window.
> >
> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  Documentation/accounting/psi.txt | 104 ++++++
> >  include/linux/psi.h              |  10 +
> >  include/linux/psi_types.h        |  59 ++++
> >  kernel/cgroup/cgroup.c           | 107 +++++-
> >  kernel/sched/psi.c               | 562 +++++++++++++++++++++++++++++--
> >  5 files changed, 808 insertions(+), 34 deletions(-)
> >
> > diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
> > index b8ca28b60215..6b21c72aa87c 100644
> > --- a/Documentation/accounting/psi.txt
> > +++ b/Documentation/accounting/psi.txt
> > @@ -63,6 +63,107 @@ tracked and exported as well, to allow detection of latency spikes
> >  which wouldn't necessarily make a dent in the time averages, or to
> >  average trends over custom time frames.
> >
> > +Monitoring for pressure thresholds
> > +==================================
> > +
> > +Users can register triggers and use poll() to be woken up when resource
> > +pressure exceeds certain thresholds.
> > +
> > +A trigger describes the maximum cumulative stall time over a specific
> > +time window, e.g. 100ms of total stall time within any 500ms window to
> > +generate a wakeup event.
> > +
> > +To register a trigger user has to open psi interface file under
> > +/proc/pressure/ representing the resource to be monitored and write the
> > +desired threshold and time window. The open file descriptor should be
> > +used to wait for trigger events using select(), poll() or epoll().
> > +The following format is used:
> > +
> > +<some|full> <stall amount in us> <time window in us>
> > +
> > +For example writing "some 150000 1000000" into /proc/pressure/memory
> > +would add 150ms threshold for partial memory stall measured within
> > +1sec time window. Writing "full 50000 1000000" into /proc/pressure/io
> > +would add 50ms threshold for full io stall measured within 1sec time window.
> > +
> > +Triggers can be set on more than one psi metric and more than one trigger
> > +for the same psi metric can be specified. However for each trigger a separate
> > +file descriptor is required to be able to poll it separately from others,
> > +therefore for each trigger a separate open() syscall should be made even
> > +when opening the same psi interface file.
> > +
> > +Monitors activate only when system enters stall state for the monitored
> > +psi metric and deactivates upon exit from the stall state. While system is
> > +in the stall state psi signal growth is monitored at a rate of 10 times per
> > +tracking window.
> > +
> > +The kernel accepts window sizes ranging from 500ms to 10s, therefore min
> > +monitoring update interval is 50ms and max is 1s.
>
> Hope to add why we decide these number into min/max.

Will add more explanation. The min limit is important to make sure psi
monitor does not poll too often affecting overall system performance.
Max limit of 10sec was chosen as a big enough limit after which the
monitor is probably not the best choice. 10sec window means that
polling internal is 1sec, so userspace is not concerned about reaction
time to mounting pressure. In such situation it's probably better to
read corresponding psi pressure averages instead of using the
monitors. I might be wrong here but in that case the limit can be
increased.

> > +
> > +When activated, psi monitor stays active for at least the duration of one
> > +tracking window to avoid repeated activations/deactivations when system is
> > +bouncing in and out of the stall state.
> > +
> > +Notifications to the userspace are rate-limited to one per tracking window.
> > +
> > +The trigger will de-register when the file descriptor used to define the
> > +trigger  is closed.
> > +
> > +Userspace monitor usage example
> > +===============================
> > +
> > +#include <errno.h>
> > +#include <fcntl.h>
> > +#include <stdio.h>
> > +#include <poll.h>
> > +#include <string.h>
> > +#include <unistd.h>
> > +
> > +/*
> > + * Monitor memory partial stall with 1s tracking window size
> > + * and 150ms threshold.
> > + */
> > +int main() {
> > +     const char trig[] = "some 150000 1000000";
> > +     struct pollfd fds;
> > +     int n;
> > +
> > +     fds.fd = open("/proc/pressure/memory", O_RDWR | O_NONBLOCK);
> > +     if (fds.fd < 0) {
> > +             printf("/proc/pressure/memory open error: %s\n",
> > +                     strerror(errno));
> > +             return 1;
> > +     }
> > +     fds.events = POLLPRI;
> > +
> > +     if (write(fds.fd, trig, strlen(trig) + 1) < 0) {
> > +             printf("/proc/pressure/memory write error: %s\n",
> > +                     strerror(errno));
> > +             return 1;
> > +     }
> > +
> > +     printf("waiting for events...\n");
> > +     while (1) {
> > +             n = poll(&fds, 1, -1);
> > +             if (n < 0) {
> > +                     printf("poll error: %s\n", strerror(errno));
> > +                     return 1;
> > +             }
> > +             if (fds.revents & POLLERR) {
> > +                     printf("got POLLERR, event source is gone\n");
> > +                     return 0;
> > +             }
> > +             if (fds.revents & POLLPRI) {
> > +                     printf("event triggered!\n");
> > +             } else {
> > +                     printf("unknown event received: 0x%x\n", fds.revents);
> > +                     return 1;
> > +             }
> > +     }
> > +
> > +     return 0;
> > +}
> > +
> >  Cgroup2 interface
> >  =================
> >
> > @@ -71,3 +172,6 @@ mounted, pressure stall information is also tracked for tasks grouped
> >  into cgroups. Each subdirectory in the cgroupfs mountpoint contains
> >  cpu.pressure, memory.pressure, and io.pressure files; the format is
> >  the same as the /proc/pressure/ files.
> > +
> > +Per-cgroup psi monitors can be specified and used the same way as
> > +system-wide ones.
> > diff --git a/include/linux/psi.h b/include/linux/psi.h
> > index 7006008d5b72..7490f8ef83ac 100644
> > --- a/include/linux/psi.h
> > +++ b/include/linux/psi.h
> > @@ -4,6 +4,7 @@
> >  #include <linux/jump_label.h>
> >  #include <linux/psi_types.h>
> >  #include <linux/sched.h>
> > +#include <linux/poll.h>
> >
> >  struct seq_file;
> >  struct css_set;
> > @@ -26,6 +27,15 @@ int psi_show(struct seq_file *s, struct psi_group *group, enum psi_res res);
> >  int psi_cgroup_alloc(struct cgroup *cgrp);
> >  void psi_cgroup_free(struct cgroup *cgrp);
> >  void cgroup_move_task(struct task_struct *p, struct css_set *to);
> > +
> > +ssize_t psi_trigger_parse(char *buf, size_t nbytes, enum psi_res res,
> > +     enum psi_states *state, u32 *threshold_us, u32 *win_sz_us);
> > +struct psi_trigger *psi_trigger_create(struct psi_group *group,
> > +     enum psi_states state, u32 threshold_us, u32 win_sz_us);
> > +void psi_trigger_destroy(struct psi_trigger *t);
> > +
> > +__poll_t psi_trigger_poll(struct psi_trigger *t, struct file *file,
> > +                     poll_table *wait);
> >  #endif
> >
> >  #else /* CONFIG_PSI */
> > diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
> > index 47757668bdcb..41654473cb69 100644
> > --- a/include/linux/psi_types.h
> > +++ b/include/linux/psi_types.h
> > @@ -3,6 +3,7 @@
> >
> >  #include <linux/seqlock.h>
> >  #include <linux/types.h>
> > +#include <linux/wait.h>
> >
> >  #ifdef CONFIG_PSI
> >
> > @@ -68,6 +69,50 @@ struct psi_group_cpu {
> >       u32 times_prev[NR_PSI_STATES] ____cacheline_aligned_in_smp;
> >  };
> >
> > +/* PSI growth tracking window */
> > +struct psi_window {
> > +     /* Window size in ns */
> > +     u64 size;
>
> As rest of field are time, how about "interval" instead of size?

Sounds reasonable.

> > +
> > +     /* Start time of the current window in ns */
> > +     u64 start_time;
> > +
> > +     /* Value at the start of the window */
> > +     u64 start_value;
>
> "value" is rather vague. starting_stall?
>
> > +
> > +     /* Value growth per previous window(s) */
> > +     u64 per_win_growth;
>
> Rather than per, prev would be more meaninful, I think.
> How about prev_win_stall?

Yes, that sounds better.

> > +};
> > +
> > +struct psi_trigger {
> > +     /* PSI state being monitored by the trigger */
> > +     enum psi_states state;
> > +
> > +     /* User-spacified threshold in ns */
> > +     u64 threshold;
> > +
> > +     /* List node inside triggers list */
> > +     struct list_head node;
> > +
> > +     /* Backpointer needed during trigger destruction */
> > +     struct psi_group *group;
> > +
> > +     /* Wait queue for polling */
> > +     wait_queue_head_t event_wait;
> > +
> > +     /* Pending event flag */
> > +     int event;
> > +
> > +     /* Tracking window */
> > +     struct psi_window win;
> > +
> > +     /*
> > +      * Time last event was generated. Used for rate-limiting
> > +      * events to one per window
> > +      */
> > +     u64 last_event_time;
> > +};
> > +
> >  struct psi_group {
> >       /* Protects data used by the aggregator */
> >       struct mutex update_lock;
> > @@ -75,6 +120,8 @@ struct psi_group {
> >       /* Per-cpu task state & time tracking */
> >       struct psi_group_cpu __percpu *pcpu;
> >
> > +     /* Periodic work control */
> > +     atomic_t polling;
> >       struct delayed_work clock_work;
> >
> >       /* Total stall times observed */
> > @@ -85,6 +132,18 @@ struct psi_group {
> >       u64 avg_last_update;
> >       u64 avg_next_update;
> >       unsigned long avg[NR_PSI_STATES - 1][3];
> > +
> > +     /* Configured polling triggers */
> > +     struct list_head triggers;
> > +     u32 nr_triggers[NR_PSI_STATES - 1];
> > +     u32 trigger_mask;
>
> This is a state we have an interest.
> How about trigger_states?

Will change.

> > +     u64 trigger_min_period;
> > +
> > +     /* Polling state */
> > +     /* Total stall times at the start of monitor activation */
> > +     u64 polling_total[NR_PSI_STATES - 1];
> > +     u64 polling_next_update;
> > +     u64 polling_until;
> >  };
> >
> >  #else /* CONFIG_PSI */
> > diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
> > index e8cd12c6a553..de3ac22a5e23 100644
> > --- a/kernel/cgroup/cgroup.c
> > +++ b/kernel/cgroup/cgroup.c
> > @@ -3464,7 +3464,101 @@ static int cgroup_cpu_pressure_show(struct seq_file *seq, void *v)
> >  {
> >       return psi_show(seq, &seq_css(seq)->cgroup->psi, PSI_CPU);
> >  }
> > -#endif
> > +
> > +static ssize_t cgroup_pressure_write(struct kernfs_open_file *of, char *buf,
> > +                                       size_t nbytes, enum psi_res res)
> > +{
> > +     enum psi_states state;
> > +     struct psi_trigger *old;
> > +     struct psi_trigger *new;
> > +     struct cgroup *cgrp;
> > +     u32 threshold_us;
> > +     u32 win_sz_us;
>
> window_us?

Will change.

> > +     ssize_t ret;
> > +
> > +     cgrp = cgroup_kn_lock_live(of->kn, false);
> > +     if (!cgrp)
> > +             return -ENODEV;
> > +
> > +     cgroup_get(cgrp);
> > +     cgroup_kn_unlock(of->kn);
> > +
> > +     ret = psi_trigger_parse(buf, nbytes, res,
> > +                             &state, &threshold_us, &win_sz_us);
> > +     if (ret) {
> > +             cgroup_put(cgrp);
> > +             return ret;
> > +     }
> > +
> > +     new = psi_trigger_create(&cgrp->psi,
> > +                             state, threshold_us, win_sz_us);
> > +     if (IS_ERR(new)) {
> > +             cgroup_put(cgrp);
> > +             return PTR_ERR(new);
> > +     }
> > +
> > +     old = of->priv;
> > +     rcu_assign_pointer(of->priv, new);
> > +     if (old) {
> > +             synchronize_rcu();
> > +             psi_trigger_destroy(old);
> > +     }
> > +
> > +     cgroup_put(cgrp);
> > +
> > +     return nbytes;
> > +}
> > +
> > +static ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
> > +                                       char *buf, size_t nbytes,
> > +                                       loff_t off)
> > +{
> > +     return cgroup_pressure_write(of, buf, nbytes, PSI_IO);
> > +}
> > +
> > +static ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
> > +                                       char *buf, size_t nbytes,
> > +                                       loff_t off)
> > +{
> > +     return cgroup_pressure_write(of, buf, nbytes, PSI_MEM);
> > +}
> > +
> > +static ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
> > +                                       char *buf, size_t nbytes,
> > +                                       loff_t off)
> > +{
> > +     return cgroup_pressure_write(of, buf, nbytes, PSI_CPU);
> > +}
> > +
> > +static __poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
> > +                                       poll_table *pt)
> > +{
> > +     struct psi_trigger *t;
> > +     __poll_t ret;
> > +
> > +     rcu_read_lock();
> > +     t = rcu_dereference(of->priv);
> > +     if (t)
> > +             ret = psi_trigger_poll(t, of->file, pt);
> > +     else
> > +             ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
> > +     rcu_read_unlock();
> > +
> > +     return ret;
> > +}
> > +
> > +static void cgroup_pressure_release(struct kernfs_open_file *of)
> > +{
> > +     struct psi_trigger *t = of->priv;
> > +
> > +     if (!t)
> > +             return;
> > +
> > +     rcu_assign_pointer(of->priv, NULL);
> > +     synchronize_rcu();
> > +     psi_trigger_destroy(t);
> > +}
> > +#endif /* CONFIG_PSI */
> >
> >  static int cgroup_file_open(struct kernfs_open_file *of)
> >  {
> > @@ -4619,18 +4713,27 @@ static struct cftype cgroup_base_files[] = {
> >               .name = "io.pressure",
> >               .flags = CFTYPE_NOT_ON_ROOT,
> >               .seq_show = cgroup_io_pressure_show,
> > +             .write = cgroup_io_pressure_write,
> > +             .poll = cgroup_pressure_poll,
> > +             .release = cgroup_pressure_release,
> >       },
> >       {
> >               .name = "memory.pressure",
> >               .flags = CFTYPE_NOT_ON_ROOT,
> >               .seq_show = cgroup_memory_pressure_show,
> > +             .write = cgroup_memory_pressure_write,
> > +             .poll = cgroup_pressure_poll,
> > +             .release = cgroup_pressure_release,
> >       },
> >       {
> >               .name = "cpu.pressure",
> >               .flags = CFTYPE_NOT_ON_ROOT,
> >               .seq_show = cgroup_cpu_pressure_show,
> > +             .write = cgroup_cpu_pressure_write,
> > +             .poll = cgroup_pressure_poll,
> > +             .release = cgroup_pressure_release,
> >       },
> > -#endif
> > +#endif /* CONFIG_PSI */
> >       { }     /* terminate */
> >  };
> >
> > diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> > index c366503ba135..fefb98f19a80 100644
> > --- a/kernel/sched/psi.c
> > +++ b/kernel/sched/psi.c
> > @@ -4,6 +4,9 @@
> >   * Copyright (c) 2018 Facebook, Inc.
> >   * Author: Johannes Weiner <hannes@cmpxchg.org>
> >   *
> > + * Polling support by Suren Baghdasaryan <surenb@google.com>
> > + * Copyright (c) 2018 Google, Inc.
> > + *
> >   * When CPU, memory and IO are contended, tasks experience delays that
> >   * reduce throughput and introduce latencies into the workload. Memory
> >   * and IO contention, in addition, can cause a full loss of forward
> > @@ -126,11 +129,16 @@
> >
> >  #include <linux/sched/loadavg.h>
> >  #include <linux/seq_file.h>
> > +#include <linux/eventfd.h>
> >  #include <linux/proc_fs.h>
> >  #include <linux/seqlock.h>
> > +#include <linux/uaccess.h>
> >  #include <linux/cgroup.h>
> >  #include <linux/module.h>
> >  #include <linux/sched.h>
> > +#include <linux/ctype.h>
> > +#include <linux/file.h>
> > +#include <linux/poll.h>
> >  #include <linux/psi.h>
> >  #include "sched.h"
> >
> > @@ -150,11 +158,16 @@ static int __init setup_psi(char *str)
> >  __setup("psi=", setup_psi);
> >
> >  /* Running averages - we need to be higher-res than loadavg */
> > -#define PSI_FREQ     (2*HZ+1)        /* 2 sec intervals */
> > +#define PSI_FREQ     (2*HZ+1UL)      /* 2 sec intervals */
> >  #define EXP_10s              1677            /* 1/exp(2s/10s) as fixed-point */
> >  #define EXP_60s              1981            /* 1/exp(2s/60s) */
> >  #define EXP_300s     2034            /* 1/exp(2s/300s) */
> >
> > +/* PSI trigger definitions */
> > +#define PSI_TRIG_MIN_WIN_US 500000           /* Min window size is 500ms */
> > +#define PSI_TRIG_MAX_WIN_US 10000000 /* Max window size is 10s */
> > +#define PSI_TRIG_UPDATES_PER_WIN 10          /* 10 updates per window */
>
> To me, it's rather long.
> How about WINDOW_MIN_US, WINDOW_MAX_US, UPDATES_PER_WINDOW?

Will change.

> > +
> >  /* Sampling frequency in nanoseconds */
> >  static u64 psi_period __read_mostly;
> >
> > @@ -173,8 +186,17 @@ static void group_init(struct psi_group *group)
> >       for_each_possible_cpu(cpu)
> >               seqcount_init(&per_cpu_ptr(group->pcpu, cpu)->seq);
> >       group->avg_next_update = sched_clock() + psi_period;
> > +     atomic_set(&group->polling, 0);
> >       INIT_DELAYED_WORK(&group->clock_work, psi_update_work);
> >       mutex_init(&group->update_lock);
> > +     /* Init trigger-related members */
> > +     INIT_LIST_HEAD(&group->triggers);
> > +     memset(group->nr_triggers, 0, sizeof(group->nr_triggers));
> > +     group->trigger_mask = 0;
> > +     group->trigger_min_period = U32_MAX;
> > +     memset(group->polling_total, 0, sizeof(group->polling_total));
> > +     group->polling_next_update = ULLONG_MAX;
> > +     group->polling_until = 0;
> >  }
> >
> >  void __init psi_init(void)
> > @@ -209,10 +231,11 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
> >       }
> >  }
> >
> > -static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
> > +static u32 get_recent_times(struct psi_group *group, int cpu, u32 *times)
>
> Rather awkward to return change_mask when we consider function name as
> get_recent_times It would be better to add additional parameter
> instead of return value.

SGTM. Will double-check with Johannes and if he agrees will change.


> >  {
> >       struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
> >       u64 now, state_start;
> > +     u32 change_mask = 0;
> >       enum psi_states s;
> >       unsigned int seq;
> >       u32 state_mask;
> > @@ -245,7 +268,11 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
> >               groupc->times_prev[s] = times[s];
> >
> >               times[s] = delta;
> > +             if (delta)
> > +                     change_mask |= (1 << s);
> >       }
> > +
> > +     return change_mask;
> >  }
> >
> >  static void calc_avgs(unsigned long avg[3], int missed_periods,
> > @@ -268,17 +295,14 @@ static void calc_avgs(unsigned long avg[3], int missed_periods,
> >       avg[2] = calc_load(avg[2], EXP_300s, pct);
> >  }
> >
> > -static bool update_stats(struct psi_group *group)
> > +static u32 collect_percpu_times(struct psi_group *group)
>
> Not sure it's a good idea to add "implementation facility" in here.
> How about update_stall_time with additional parameter of
> "[changed|updated]_states?
>
> IOW,
> static void update_stall_times(struct psi_group *group, u32 *changed_states)

SGTM. Will double-check with Johannes and if he agrees will change.

> >  {
> >       u64 deltas[NR_PSI_STATES - 1] = { 0, };
> > -     unsigned long missed_periods = 0;
> >       unsigned long nonidle_total = 0;
> > -     u64 now, expires, period;
> > +     u32 change_mask = 0;
> >       int cpu;
> >       int s;
> >
> > -     mutex_lock(&group->update_lock);
> > -
> >       /*
> >        * Collect the per-cpu time buckets and average them into a
> >        * single time sample that is normalized to wallclock time.
> > @@ -291,7 +315,7 @@ static bool update_stats(struct psi_group *group)
> >               u32 times[NR_PSI_STATES];
> >               u32 nonidle;
> >
> > -             get_recent_times(group, cpu, times);
> > +             change_mask |= get_recent_times(group, cpu, times);
> >
> >               nonidle = nsecs_to_jiffies(times[PSI_NONIDLE]);
> >               nonidle_total += nonidle;
> > @@ -316,11 +340,18 @@ static bool update_stats(struct psi_group *group)
> >       for (s = 0; s < NR_PSI_STATES - 1; s++)
> >               group->total[s] += div_u64(deltas[s], max(nonidle_total, 1UL));
> >
> > +     return change_mask;
> > +}
> > +
> > +static u64 calculate_averages(struct psi_group *group, u64 now)
>
>                                                               time?
>
> The function name is still awkward to me.
> If someone see this function, he will expect return value as "average", not next_update.
> If we want to have next_update as return value, it would better to rename *update_avgs*.
>

Ok. If we change this to update_avgs() I think it also makes sense to
change poll_triggers() into update_triggers(). That way in the
psi_update_work() we will have:

next_avg = update_avgs()
if polling:
    next_poll = update_triggers()
mod_delayed_work(min(next_avg, next_poll))

> > +{
> > +     unsigned long missed_periods = 0;
> > +     u64 expires, period;
> > +     u64 avg_next_update;
> > +     int s;
> > +
> >       /* avgX= */
> > -     now = sched_clock();
> >       expires = group->avg_next_update;
> > -     if (now < expires)
> > -             goto out;
> >       if (now - expires > psi_period)
> >               missed_periods = div_u64(now - expires, psi_period);
> >
> > @@ -331,7 +362,7 @@ static bool update_stats(struct psi_group *group)
> >        * But the deltas we sample out of the per-cpu buckets above
> >        * are based on the actual time elapsing between clock ticks.
> >        */
> > -     group->avg_next_update = expires + ((1 + missed_periods) * psi_period);
> > +     avg_next_update = expires + ((1 + missed_periods) * psi_period);
> >       period = now - (group->avg_last_update + (missed_periods * psi_period));
> >       group->avg_last_update = now;
> >
> > @@ -361,20 +392,237 @@ static bool update_stats(struct psi_group *group)
> >               group->avg_total[s] += sample;
> >               calc_avgs(group->avg[s], missed_periods, sample, period);
> >       }
> > -out:
> > -     mutex_unlock(&group->update_lock);
> > -     return nonidle_total;
> > +
> > +     return avg_next_update;
> > +}
> > +
> > +/* Trigger tracking window manupulations */
> > +static void window_init(struct psi_window *win, u64 now, u64 value)
> > +{
> > +     win->start_value = value;
> > +     win->start_time = now;
> > +     win->per_win_growth = 0;
> > +}
> > +
> > +/*
> > + * PSI growth tracking window update and growth calculation routine.
>
> Let's add empty line here.

Will do.

> > + * This approximates a sliding tracking window by interpolating
> > + * partially elapsed windows using historical growth data from the
> > + * previous intervals. This minimizes memory requirements (by not storing
> > + * all the intermediate values in the previous window) and simplifies
> > + * the calculations. It works well because PSI signal changes only in
> > + * positive direction and over relatively small window sizes the growth
> > + * is close to linear.
> > + */
> > +static u64 window_update(struct psi_window *win, u64 now, u64 value)
>
> Hope to change now as just time for function.
>
> Insetad of value, couldn't we use more concrete naming?
> Maybe stall_time or just stall?

Will do.

> > +{
> > +     u64 interval;
>
> elapsed?

SGTM

> > +     u64 growth;
> > +
> > +     interval = now - win->start_time;
> > +     growth = value - win->start_value;
> > +     /*
> > +      * After each tracking window passes win->start_value and
> > +      * win->start_time get reset and win->per_win_growth stores
> > +      * the average per-window growth of the previous window.
> > +      * win->per_win_growth is then used to interpolate additional
> > +      * growth from the previous window assuming it was linear.
> > +      */
> > +     if (interval > win->size) {
> > +             win->per_win_growth = growth;
> > +             win->start_value = value;
> > +             win->start_time = now;
>
> We can use window_init via adding per_win_growth in the function
> parameter. Maybe, window_reset would be better function name.

Good idea, will do.

> > +     } else {
> > +             u32 unelapsed;
>
> remaining? remained?

SGTM

> > +
> > +             unelapsed = win->size - interval;
> > +             growth += div_u64(win->per_win_growth * unelapsed, win->size);
> > +     }
> > +
> > +     return growth;
> > +}
> > +
> > +static void init_triggers(struct psi_group *group, u64 now)
> > +{
> > +     struct psi_trigger *t;
> > +
> > +     list_for_each_entry(t, &group->triggers, node)
> > +             window_init(&t->win, now, group->total[t->state]);
> > +     memcpy(group->polling_total, group->total,
> > +                sizeof(group->polling_total));
> > +     group->polling_next_update = now + group->trigger_min_period;
> > +}
> > +
> > +static u64 poll_triggers(struct psi_group *group, u64 now)
>
> How about update_[poll|trigger]_stat?

update_triggers()  to be symmetric with update_avgs() as I suggested
in an earlier comment?

> > +{
> > +     struct psi_trigger *t;
> > +     bool new_stall = false;
> > +
> > +     /*
> > +      * On subsequent updates, calculate growth deltas and let
> > +      * watchers know when their specified thresholds are exceeded.
> > +      */
> > +     list_for_each_entry(t, &group->triggers, node) {
> > +             u64 growth;
> > +
> > +             /* Check for stall activity */
> > +             if (group->polling_total[t->state] == group->total[t->state])
> > +                     continue;
> > +
> > +             /*
> > +              * Multiple triggers might be looking at the same state,
> > +              * remember to update group->polling_total[] once we've
> > +              * been through all of them. Also remember to extend the
> > +              * polling time if we see new stall activity.
> > +              */
> > +             new_stall = true;
> > +
> > +             /* Calculate growth since last update */
> > +             growth = window_update(&t->win, now, group->total[t->state]);
> > +             if (growth < t->threshold)
> > +                     continue;
> > +
> > +             /* Limit event signaling to once per window */
> > +             if (now < t->last_event_time + t->win.size)
> > +                     continue;
> > +
> > +             /* Generate an event */
> > +             if (cmpxchg(&t->event, 0, 1) == 0)
> > +                     wake_up_interruptible(&t->event_wait);
> > +             t->last_event_time = now;
> > +     }
> > +
> > +     if (new_stall) {
> > +             memcpy(group->polling_total, group->total,
> > +                        sizeof(group->polling_total));
> > +     }
> > +
> > +     return now + group->trigger_min_period;
> >  }
> >
> > +/*
> > + * psi_update_work represents slowpath accounting part while psi_group_change
> > + * represents hotpath part. There are two potential races between them:
> > + * 1. Changes to group->polling when slowpath checks for new stall, then hotpath
> > + *    records new stall and then slowpath resets group->polling flag. This leads
> > + *    to the exit from the polling mode while monitored state is still changing.
> > + * 2. Slowpath overwriting an immediate update scheduled from the hotpath with
> > + *    a regular update further in the future and missing the immediate update.
> > + * Both races are handled with a retry cycle in the slowpath:
> > + *
> > + *    HOTPATH:                         |    SLOWPATH:
> > + *                                     |
> > + * A) times[cpu] += delta              | E) delta = times[*]
> > + * B) start_poll = (delta[poll_mask] &&|    if delta[poll_mask]:
> > + *      cmpxchg(g->polling, 0, 1) == 0)| F)   polling_until = now + grace_period
> > + *    if start_poll:                   |    if now > polling_until:
> > + * C)   mod_delayed_work(1)            |      if g->polling:
> > + *     else if !delayed_work_pending():| G)     g->polling = polling = 0
> > + * D)   schedule_delayed_work(PSI_FREQ)|        smp_mb
> > + *                                     | H)     goto SLOWPATH
> > + *                                     |    else:
> > + *                                     |      if !g->polling:
> > + *                                     | I)     g->polling = polling = 1
> > + *                                     | J) if delta && first_pass:
> > + *                                     |      next_avg = calculate_averages()
> > + *                                     |      if polling:
> > + *                                     |        next_poll = poll_triggers()
> > + *                                     |    if (delta && first_pass) || polling:
> > + *                                     | K)   mod_delayed_work(
> > + *                                     |          min(next_avg, next_poll))
> > + *                                     |      if !polling:
> > + *                                     |        first_pass = false
> > + *                                     | L)     goto SLOWPATH
> > + *
> > + * Race #1 is represented by (EABGD) sequence in which case slowpath deactivates
> > + * polling mode because it misses new monitored stall and hotpath doesn't
> > + * activate it because at (B) g->polling is not yet reset by slowpath in (G).
> > + * This race is handled by the (H) retry, which in the race described above
> > + * results in the new sequence of (EABGDHEIK) that reactivates polling mode.
> > + *
> > + * Race #2 is represented by polling==false && (JABCK) sequence which overwrites
> > + * immediate update scheduled at (C) with a later (next_avg) update scheduled at
> > + * (K). This race is handled by the (L) retry which results in the new sequence
> > + * of polling==false && (JABCKLEIK) that reactivates polling mode and
> > + * reschedules the next polling update (next_poll).
> > + *
> > + * Note that retries can't result in an infinite loop because retry #1 happens
> > + * only during polling reactivation and retry #2 happens only on the first pass.
> > + * Constant reactivations are impossible because polling will stay active for at
> > + * least grace_period. Worst case scenario involves two retries (HEJKLE)
> > + */
> >  static void psi_update_work(struct work_struct *work)
> >  {
> >       struct delayed_work *dwork;
> >       struct psi_group *group;
> > +     bool first_pass = true;
> > +     u64 next_update;
> > +     u32 change_mask;
>
> How about [changed|updated]_states?

Will do.

> > +     int polling;
> >       bool nonidle;
> > +     u64 now;
> >
> >       dwork = to_delayed_work(work);
> >       group = container_of(dwork, struct psi_group, clock_work);
> >
> > +     now = sched_clock();
> > +
> > +     mutex_lock(&group->update_lock);
> > +
> > +retry:
> > +     change_mask = collect_percpu_times(group);
> > +     polling = atomic_read(&group->polling);
> > +
> > +     if (change_mask & group->trigger_mask) {
> > +             /* Initialize trigger windows when entering polling mode */
> > +             if (now > group->polling_until)
> > +                     init_triggers(group, now);
> > +
> > +             /*
> > +              * Keep the monitor active for at least the duration of the
> > +              * minimum tracking window as long as monitor states are
> > +              * changing. This prevents frequent changes to polling flag
> > +              * when system bounces in and out of stall states.
> > +              */
> > +             group->polling_until = now +
> > +                     group->trigger_min_period * PSI_TRIG_UPDATES_PER_WIN;
> > +     }
> > +
> > +     /* Handle polling flag transitions */
> > +     if (now > group->polling_until) {
> > +             if (polling) {
> > +                     group->polling_next_update = ULLONG_MAX;
> > +                     polling = 0;
> > +                     atomic_set(&group->polling, polling);
> > +                     /*
> > +                      * Memory barrier is needed to order group->polling
> > +                      * write before times[] read in collect_percpu_times()
> > +                      */
> > +                     smp_mb__after_atomic();
> > +                     /*
> > +                      * Check if we missed stall recorded by hotpath while
> > +                      * polling flag was set to 1 causing hotpath to skip
> > +                      * entering polling mode
> > +                      */
> > +                     goto retry;
> > +             }
> > +     } else {
> > +             if (!polling) {
> > +                     /*
> > +                      * This can happen as a fixup in the retry cycle after
> > +                      * new stall is discovered
> > +                      */
> > +                     polling = 1;
> > +                     atomic_set(&group->polling, polling);
> > +             }
> > +     }
> > +     /*
> > +      * At this point group->polling race with hotpath is resolved and
> > +      * we rely on local polling flag ignoring possible further changes
> > +      * to group->polling
> > +      */
> > +
> > +     nonidle = (change_mask & (1 << PSI_NONIDLE));
> >       /*
> >        * If there is task activity, periodically fold the per-cpu
> >        * times and feed samples into the running averages. If things
> > @@ -382,20 +630,32 @@ static void psi_update_work(struct work_struct *work)
> >        * Once restarted, we'll catch up the running averages in one
> >        * go - see calc_avgs() and missed_periods.
> >        */
> > +     if (nonidle && first_pass) {
> > +             if (now >= group->avg_next_update)
> > +                     group->avg_next_update = calculate_averages(group, now);
> >
> > -     nonidle = update_stats(group);
> > -
> > -     if (nonidle) {
> > -             unsigned long delay = 0;
> > -             u64 now;
> > -
> > -             now = sched_clock();
> > -             if (group->avg_next_update > now) {
> > -                     delay = nsecs_to_jiffies(
> > -                             group->avg_next_update - now) + 1;
> > +             if (now >= group->polling_next_update)
> > +                     group->polling_next_update = poll_triggers(group, now);
> > +     }
> > +     if ((nonidle && first_pass) || polling) {
> > +             /* Calculate closest update time */
> > +             next_update = min(group->polling_next_update,
> > +                                     group->avg_next_update);
> > +             mod_delayed_work(system_wq, dwork, nsecs_to_jiffies(
> > +                             next_update - now) + 1);
> > +             if (!polling) {
> > +                     /*
> > +                      * We might have overwritten an immediate update
> > +                      * scheduled from the hotpath with a longer regular
> > +                      * update (group->avg_next_update). Execute second pass
> > +                      * retry to discover that and resume polling.
> > +                      */
> > +                     first_pass = false;
> > +                     goto retry;
> >               }
> > -             schedule_delayed_work(dwork, delay);
> >       }
> > +
> > +     mutex_unlock(&group->update_lock);
> >  }
> >
> >  static void record_times(struct psi_group_cpu *groupc, int cpu,
> > @@ -492,8 +752,25 @@ static void psi_group_change(struct psi_group *group, int cpu,
> >
> >       write_seqcount_end(&groupc->seq);
> >
> > -     if (!delayed_work_pending(&group->clock_work))
> > -             schedule_delayed_work(&group->clock_work, PSI_FREQ);
> > +     /*
> > +      * Polling flag resets to 0 at the max rate of once per update window
> > +      * (at least 500ms interval). smp_wmb is required after group->polling
> > +      * 0-to-1 transition to order groupc->times and group->polling writes
> > +      * because stall detection logic in the slowpath relies on groupc->times
> > +      * changing before group->polling. Explicit smp_wmb is missing because
> > +      * cmpxchg() implies smp_mb.
> > +      */
> > +     if ((state_mask & group->trigger_mask) &&
> > +             atomic_cmpxchg(&group->polling, 0, 1) == 0) {
> > +             /*
> > +              * Start polling immediately even if the work is already
> > +              * scheduled
> > +              */
> > +             mod_delayed_work(system_wq, &group->clock_work, 1);
> > +     } else {
> > +             if (!delayed_work_pending(&group->clock_work))
> > +                     schedule_delayed_work(&group->clock_work, PSI_FREQ);
> > +     }
> >  }
> >
> >  static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
> > @@ -640,6 +917,8 @@ void psi_cgroup_free(struct cgroup *cgroup)
> >
> >       cancel_delayed_work_sync(&cgroup->psi.clock_work);
> >       free_percpu(cgroup->psi.pcpu);
> > +     /* All triggers must be removed by now by psi_trigger_destroy */
> > +     WARN_ONCE(cgroup->psi.trigger_mask, "psi: trigger leak\n");
> >  }
> >
> >  /**
> > @@ -699,7 +978,11 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
> >       if (static_branch_likely(&psi_disabled))
> >               return -EOPNOTSUPP;
> >
> > -     update_stats(group);
> > +     /* Update averages before reporting them */
> > +     mutex_lock(&group->update_lock);
> > +     collect_percpu_times(group);
> > +     calculate_averages(group, sched_clock());
> > +     mutex_unlock(&group->update_lock);
> >
> >       for (full = 0; full < 2 - (res == PSI_CPU); full++) {
> >               unsigned long avg[3];
> > @@ -751,25 +1034,240 @@ static int psi_cpu_open(struct inode *inode, struct file *file)
> >       return single_open(file, psi_cpu_show, NULL);
> >  }
> >
> > +ssize_t psi_trigger_parse(char *buf, size_t nbytes, enum psi_res res,
> > +     enum psi_states *pstate, u32 *pthreshold_us, u32 *pwin_sz_us)
> > +{
> > +     enum psi_states state;
> > +     u32 threshold_us;
> > +     u32 win_sz_us;
> > +
> > +     if (sscanf(buf, "some %u %u", &threshold_us, &win_sz_us) == 2)
> > +             state = PSI_IO_SOME + res * 2;
> > +     else if (sscanf(buf, "full %u %u", &threshold_us, &win_sz_us) == 2)
> > +             state = PSI_IO_FULL + res * 2;
> > +     else
> > +             return -EINVAL;
> > +
> > +     if (state >= PSI_NONIDLE)
> > +             return -EINVAL;
> > +
> > +     if (win_sz_us < PSI_TRIG_MIN_WIN_US ||
> > +             win_sz_us > PSI_TRIG_MAX_WIN_US)
> > +             return -EINVAL;
> > +
> > +     /* Check threshold */
> > +     if (threshold_us == 0 || threshold_us > win_sz_us)
> > +             return -EINVAL;
> > +
> > +     *pstate = state;
> > +     *pthreshold_us = threshold_us;
> > +     *pwin_sz_us = win_sz_us;
> > +     return 0;
> > +}
> > +
> > +struct psi_trigger *psi_trigger_create(struct psi_group *group,
> > +             enum psi_states state, u32 threshold_us, u32 win_sz_us)
> > +{
> > +     struct psi_trigger *t;
> > +
> > +     if (static_branch_likely(&psi_disabled))
> > +             return ERR_PTR(-EOPNOTSUPP);
> > +
> > +     t = kzalloc(sizeof(*t), GFP_KERNEL);
>
> You reset most of field again in here. Then, I think we don't need to use
> kzalloc in here. let's use kmalloc and initialize other field, too.

SGTM.

> > +     if (!t)
> > +             return ERR_PTR(-ENOMEM);
> > +
> > +     t->group = group;
> > +     t->state = state;
> > +     t->threshold = threshold_us * NSEC_PER_USEC;
> > +     t->win.size = win_sz_us * NSEC_PER_USEC;
> > +     t->event = 0;
> > +     init_waitqueue_head(&t->event_wait);
> > +
> > +     mutex_lock(&group->update_lock);
> > +
> > +     list_add(&t->node, &group->triggers);
> > +     group->trigger_min_period = min(group->trigger_min_period,
> > +             div_u64(t->win.size, PSI_TRIG_UPDATES_PER_WIN));
> > +     group->nr_triggers[t->state]++;
> > +     group->trigger_mask |= (1 << t->state);
> > +
> > +     mutex_unlock(&group->update_lock);
> > +
> > +     return t;
> > +}
> > +
>
> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

