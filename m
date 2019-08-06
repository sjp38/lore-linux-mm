Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0347C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 965ED208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:09:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jTdOuUxe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 965ED208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 305EF6B0007; Mon,  5 Aug 2019 21:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B6016B0008; Mon,  5 Aug 2019 21:09:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 157D86B000A; Mon,  5 Aug 2019 21:09:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B54E36B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:09:04 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b6so41522944wrp.21
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iVqZVjXC+NUGVfC+h8fgNnfytH+DNTshiUOlL2pd8nw=;
        b=AkM1xmMOObWEwt4X8eWxGpHX8EsHAyhP7fp2tLdWJOnyamUoDk3jDoE4aohZPeg9dy
         EB7ahvqNltxPTf6ptVR/ln7EfoGPKeCRU56RP9DmIL6jqzELb4OUydFXQiL4n51IIM9m
         gXvGWDUPP7fe/btyubLUQdVgCFRs/itJC3t116397h/mv0bAbY8Fdj2hBZgJMR91Y9Ix
         RUoLFXPAdQe3lQVZ8TPtmtVsvAoOuq8JmJJ0DsG1Xrrm+CO2Znn9PQaT9f63wI/7bVRG
         dx3/5fkCeRcZwPdM0Jfe8QIyBAU2FOvzEHrpAfqUuzrWmaYeERXDLTIStyemVaP6njup
         NNqQ==
X-Gm-Message-State: APjAAAWQBq3V3T1Ndv+uS9/FcqEORE/aHANGhfwNulMXKvMbujcHzDWq
	o6MUbM1o4ivrN3vh3jgDk4gkJZkuSAsMO/lmnagU41xBFjnRPGhYELkrF2kuJgp1STcdbVntYx1
	PLAN4GunPj4BPFtJ2YlwpJ4IlDkKVLE0sJmUH5T0AxhgerMo3KeP0X3bPuFuBH/8Vzg==
X-Received: by 2002:a05:6000:11c6:: with SMTP id i6mr631501wrx.193.1565053743995;
        Mon, 05 Aug 2019 18:09:03 -0700 (PDT)
X-Received: by 2002:a05:6000:11c6:: with SMTP id i6mr631413wrx.193.1565053742576;
        Mon, 05 Aug 2019 18:09:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565053742; cv=none;
        d=google.com; s=arc-20160816;
        b=zyX/2PGhYNUAS9b8wgPvHEH24V/OjwMrT04CND0UlVIbIKyJqzFU6pF+I17HnSsxWR
         N+y0SYSEVvNwd8ckiLqA9slVnhIrAjDho2BwTMN4Mt2ypp3xWxsUHEYXEaKiCWgvfEwA
         oFsTSi999s3jxCu0Au7tpwtWaTQy6SW+MeEIyvMU5AIu8gqtAPH4tmeS/phOeUkxIbWo
         Qzt1qOLQnKQ/6gJ8GYQmP7yvc15+qMFMfcQPI1Wkv3+0z6kMgP0Gh/2UkZwsdXKRrEwf
         +Zc0WYyb2k4o88ZWmBd3WsGi/epp/1ZSYVDbOv7YQno2CZI0+SyvsMNLf4ekgN8wnfHy
         SHwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iVqZVjXC+NUGVfC+h8fgNnfytH+DNTshiUOlL2pd8nw=;
        b=SKHMDhvUrJlcfWRrwsqeFQliy7vIgWnKU8UNAz8G0ycGiOsF51Cd+1AVRjtERCzmqT
         slPAfKDVNv38vEJK0h0yPRhOLwF0UZpMb5c/XjS0UYBwTca0w/rjKQxU2ebpLbtknt4h
         NxUA6v2UViBl+UBGIxVlr5UhaBrt79/xVPqYMdGctx0EMWpeO5IhRPtn7EiK/jEbRbkM
         w3kgPtiuec47p2NvAlLXX0mw35wDxnKbpHnZixDCL0FV1Lf0ZjrlwnuqkKANCvjeujjw
         t8rOgjb8hc6NLWf+pQbMgCCofekyvksNCZzuiMAy7RD7OhnfCWaJ5xphHQdQtz5f2DAM
         L0cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jTdOuUxe;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor46801772wma.8.2019.08.05.18.09.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 18:09:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jTdOuUxe;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iVqZVjXC+NUGVfC+h8fgNnfytH+DNTshiUOlL2pd8nw=;
        b=jTdOuUxe4X5DIbTkp7zKbIMXEGHIvKCveM85P/4Vap3UlmOofGxD5bhqh9nC06UTlk
         IVUDJnN5QxrSyfviw57HABanS8nZWMid4b/CAiK5dujQ1T2IlUVrollykWC5KqVc6jo5
         VFBGKpMda6VjCUkXZaDncSCKI5yGAWa6uVXdwub6b4AcBDNbMcv9SWo9XvdXt3tRwALr
         x1Lv7xIpF8b2n6HpqEqYxh3NXnimYRgUuV3XwN/d2ZD+YEZsEJt+BUCrjSZgwaYj+5g/
         XfUoOkUT4F7BtaDRE+/8vw7V2xK1266tqwTsK7Pf9ZiB0kIcUtZ6ZylzX1Xj0M7LZQ8o
         DgfQ==
X-Google-Smtp-Source: APXvYqxgwhh6Ilq1Gzk+Epc1PEfJ7MQCK3+a4sQ3CiEMsHNi3JYN+Vwpu+IVK0w7A7m04j95OQzTSqlHn+u52Wgcm8k=
X-Received: by 2002:a1c:9a4b:: with SMTP id c72mr788952wme.102.1565053741788;
 Mon, 05 Aug 2019 18:09:01 -0700 (PDT)
MIME-Version: 1.0
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com> <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
In-Reply-To: <20190805193148.GB4128@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 5 Aug 2019 18:08:50 -0700
Message-ID: <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Artem S. Tashkinov" <aros@gmx.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 5, 2019 at 12:31 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Mon, Aug 05, 2019 at 02:13:16PM +0200, Vlastimil Babka wrote:
> > On 8/4/19 11:23 AM, Artem S. Tashkinov wrote:
> > > Hello,
> > >
> > > There's this bug which has been bugging many people for many years
> > > already and which is reproducible in less than a few minutes under the
> > > latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> > > defaults.
> > >
> > > Steps to reproduce:
> > >
> > > 1) Boot with mem=4G
> > > 2) Disable swap to make everything faster (sudo swapoff -a)
> > > 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> > > 4) Start opening tabs in either of them and watch your free RAM decrease
> > >
> > > Once you hit a situation when opening a new tab requires more RAM than
> > > is currently available, the system will stall hard. You will barely  be
> > > able to move the mouse pointer. Your disk LED will be flashing
> > > incessantly (I'm not entirely sure why). You will not be able to run new
> > > applications or close currently running ones.
> >
> > > This little crisis may continue for minutes or even longer. I think
> > > that's not how the system should behave in this situation. I believe
> > > something must be done about that to avoid this stall.
> >
> > Yeah that's a known problem, made worse SSD's in fact, as they are able
> > to keep refaulting the last remaining file pages fast enough, so there
> > is still apparent progress in reclaim and OOM doesn't kick in.
> >
> > At this point, the likely solution will be probably based on pressure
> > stall monitoring (PSI). I don't know how far we are from a built-in
> > monitor with reasonable defaults for a desktop workload, so CCing
> > relevant folks.
>
> Yes, psi was specifically developed to address this problem. Before
> it, the kernel had to make all decisions based on relative event rates
> but had no notion of time. Whereas to the user, time is clearly an
> issue, and in fact makes all the difference. So psi quantifies the
> time the workload spends executing vs. spinning its wheels.
>
> But choosing a universal cutoff for killing is not possible, since it
> depends on the workload and the user's expectation: GUI and other
> latency-sensitive applications care way before a compile job or video
> encoding would care.
>
> Because of that, there are things like oomd and lmkd as mentioned, to
> leave the exact policy decision to userspace.
>
> That being said, I think we should be able to provide a bare minimum
> inside the kernel to avoid complete livelocks where the user does not
> believe the machine would be able to recover without a reboot.
>
> The goal wouldn't be a glitch-free user experience - the kernel does
> not know enough about the applications to even attempt that. It should
> just not hang indefinitely. Maybe similar to the hung task detector.
>
> How about something like the below patch? With that, the kernel
> catches excessive thrashing that happens before reclaim fails:
>
> [root@ham ~]# stress -d 128 -m 5
> stress: info: [344] dispatching hogs: 0 cpu, 0 io, 5 vm, 128 hdd
> Excessive and sustained system-wide memory pressure!
> kworker/1:2 invoked oom-killer: gfp_mask=0x0(), order=0, oom_score_adj=0
> CPU: 1 PID: 77 Comm: kworker/1:2 Not tainted 5.3.0-rc1-mm1-00121-ge34a5cf28771 #142
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.12.0-20181126_142135-anatol 04/01/2014
> Workqueue: events psi_avgs_work
> Call Trace:
>  dump_stack+0x46/0x60
>  dump_header+0x5c/0x3d5
>  ? irq_work_queue+0x46/0x50
>  ? wake_up_klogd+0x2b/0x30
>  ? vprintk_emit+0xe5/0x190
>  oom_kill_process.cold.10+0xb/0x10
>  out_of_memory+0x1ea/0x260
>  update_averages.cold.8+0x14/0x25
>  ? collect_percpu_times+0x84/0x1f0
>  psi_avgs_work+0x80/0xc0
>  process_one_work+0x1bb/0x310
>  worker_thread+0x28/0x3c0
>  ? process_one_work+0x310/0x310
>  kthread+0x108/0x120
>  ? __kthread_create_on_node+0x170/0x170
>  ret_from_fork+0x35/0x40
> Mem-Info:
> active_anon:109463 inactive_anon:109564 isolated_anon:298
>  active_file:4676 inactive_file:4073 isolated_file:455
>  unevictable:0 dirty:8475 writeback:8 unstable:0
>  slab_reclaimable:2585 slab_unreclaimable:4932
>  mapped:413 shmem:2 pagetables:1747 bounce:0
>  free:13472 free_pcp:17 free_cma:0
>
> Possible snags and questions:
>
> 1. psi is an optional feature right now, but these livelocks commonly
>    affect desktop users. What should be the default behavior?
>
> 2. Should we make the pressure cutoff and time period configurable?
>
>    I fear we would open a can of worms similar to the existing OOM
>    killer, where users are trying to use a kernel self-protection
>    mechanism to implement workload QoS and priorities - things that
>    should firmly be kept in userspace.
>
> 3. swapoff annotation. Due to the swapin annotation, swapoff currently
>    raises memory pressure. It probably shouldn't. But this will be a
>    bigger problem if we trigger the oom killer based on it.
>
> 4. Killing once every 10s assumes basically one big culprit. If the
>    pressure is created by many different processes, fixing the
>    situation could take quite a while.
>
>    What oomd does to solve this is to monitor the PGSCAN counters
>    after a kill, to tell whether pressure is persisting, or just from
>    residual refaults after the culprit has been dealt with.
>
>    We may need to do something similar here. Or find a solution to
>    encode that distinction into psi itself, and it would also take
>    care of the swapoff problem, since it's basically the same thing -
>    residual refaults without any reclaim pressure to sustain them.
>
> Anyway, here is the draft patch:
>
> From e34a5cf28771d69f13faa0e933adeae44b26b8aa Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 5 Aug 2019 13:15:16 -0400
> Subject: [PATCH] psi oom
>
> ---
>  include/linux/psi_types.h |  4 +++
>  kernel/sched/psi.c        | 52 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 56 insertions(+)
>
> diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
> index 07aaf9b82241..390446b07ac7 100644
> --- a/include/linux/psi_types.h
> +++ b/include/linux/psi_types.h
> @@ -162,6 +162,10 @@ struct psi_group {
>         u64 polling_total[NR_PSI_STATES - 1];
>         u64 polling_next_update;
>         u64 polling_until;
> +
> +       /* Out-of-memory situation tracking */
> +       bool oom_pressure;
> +       u64 oom_pressure_start;
>  };
>
>  #else /* CONFIG_PSI */
> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> index f28342dc65ec..1027b6611ec2 100644
> --- a/kernel/sched/psi.c
> +++ b/kernel/sched/psi.c
> @@ -139,6 +139,7 @@
>  #include <linux/ctype.h>
>  #include <linux/file.h>
>  #include <linux/poll.h>
> +#include <linux/oom.h>
>  #include <linux/psi.h>
>  #include "sched.h"
>
> @@ -177,6 +178,8 @@ struct psi_group psi_system = {
>         .pcpu = &system_group_pcpu,
>  };
>
> +static void psi_oom_tick(struct psi_group *group, u64 now);
> +
>  static void psi_avgs_work(struct work_struct *work);
>
>  static void group_init(struct psi_group *group)
> @@ -403,6 +406,8 @@ static u64 update_averages(struct psi_group *group, u64 now)
>                 calc_avgs(group->avg[s], missed_periods, sample, period);
>         }
>
> +       psi_oom_tick(group, now);
> +
>         return avg_next_update;
>  }
>
> @@ -1280,3 +1285,50 @@ static int __init psi_proc_init(void)
>         return 0;
>  }
>  module_init(psi_proc_init);
> +
> +#define OOM_PRESSURE_LEVEL     80
> +#define OOM_PRESSURE_PERIOD    (10 * NSEC_PER_SEC)

80% of the last 10 seconds spent in full stall would definitely be a
problem. If the system was already low on memory (which it probably
is, or we would not be reclaiming so hard and registering such a big
stall) then oom-killer would probably kill something before 8 seconds
are passed. If my line of thinking is correct, then do we really
benefit from such additional protection mechanism? I might be wrong
here because my experience is limited to embedded systems with
relatively small amounts of memory.

> +
> +static void psi_oom_tick(struct psi_group *group, u64 now)
> +{
> +       struct oom_control oc = {
> +               .order = 0,
> +       };
> +       unsigned long pressure;
> +       bool high;
> +
> +       /*
> +        * Protect the system from livelocking due to thrashing. Leave
> +        * per-cgroup policies to oomd, lmkd etc.
> +        */
> +       if (group != &psi_system)
> +               return;
> +
> +       pressure = LOAD_INT(group->avg[PSI_MEM_FULL][0]);
> +       high = pressure >= OOM_PRESSURE_LEVEL;
> +
> +       if (!group->oom_pressure && !high)
> +               return;
> +
> +       if (!group->oom_pressure && high) {
> +               group->oom_pressure = true;
> +               group->oom_pressure_start = now;
> +               return;
> +       }
> +
> +       if (group->oom_pressure && !high) {
> +               group->oom_pressure = false;
> +               return;
> +       }
> +
> +       if (now < group->oom_pressure_start + OOM_PRESSURE_PERIOD)
> +               return;
> +
> +       group->oom_pressure = false;
> +
> +       if (!mutex_trylock(&oom_lock))
> +               return;
> +       pr_warn("Excessive and sustained system-wide memory pressure!\n");
> +       out_of_memory(&oc);
> +       mutex_unlock(&oom_lock);
> +}
> --
> 2.22.0
>

