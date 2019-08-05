Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 930DAC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4197320C01
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:31:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="FA0RYGTA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4197320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDBCC6B0005; Mon,  5 Aug 2019 15:31:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8BE16B0006; Mon,  5 Aug 2019 15:31:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B543D6B0007; Mon,  5 Aug 2019 15:31:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD976B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 15:31:53 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h3so53338829pgc.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 12:31:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eCbuKZWx/zyJB5FbKzlPVAGACqMDDRvfK3RIOtVWKfM=;
        b=swVEerjrDH5ZUl121AkL2qZ9KYRK9wkMBn0OnOG/8Od91KNyIK6NPSFYOkn5Zq7lb7
         eEFTae85TWLGkWalj+w+WzVbNENysw+vRj3vL06mk9MJMbW4BKPCq3nxB/knoxHe3YmR
         mStEttchWW4FRT/xdKLRrqLhExpoJGbnGgId4OVKUmoktMn7EiiEWAdtxdaFwudPTV5q
         VrkV8Wg50z9T7W3lxd+NJw3edrT2wcWpDVP829PDVCoyUfgknCh8lS1U3nDx5FvPf3zg
         3fDsOu8zcUEEXEtiuNGuy8Bd6cPND8GgsUzZD+wjN+DFlH0RzSVGXUH4ox3xJ8AFOKP1
         n+Kw==
X-Gm-Message-State: APjAAAU9KtiLoykXLDdq+9KyruDq1VI3tI7jGsXeDKLH1EU4hkaOOkq0
	l2A2DVgCYoX0dJU3A+Ar67OYA2WaFMGLoHzV5d1vahlJ0WfnGCiY8jZsY3Kj/+ffS3I0kw27MrK
	yNCqZqhp3Fc+WF6ZQzjlYKSJOoxhP8IMi5noZW5l5zLFUM0nP3Kn6uRBVEJrytZG8hQ==
X-Received: by 2002:aa7:934f:: with SMTP id 15mr7771366pfn.22.1565033513065;
        Mon, 05 Aug 2019 12:31:53 -0700 (PDT)
X-Received: by 2002:aa7:934f:: with SMTP id 15mr7771309pfn.22.1565033512123;
        Mon, 05 Aug 2019 12:31:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565033512; cv=none;
        d=google.com; s=arc-20160816;
        b=AB3XzP/Gb07oco+8eFM9mZpWCD4AidBfzdqbPkY7FUvkMelbW3UNolORt5geA8dVdu
         xsiZo+jShIz2d3ln3bz5vfUSWphIiSYqg77eAQvpzd0cin7isWHISJ+TzfO5c16Lu9LW
         VnZ/0HGxfVhn1iKQ0b6iHVDWcfRKZ4nTXzrh9XdCw72Q6S6s/TwWn8Eb7/sNceRsBjKc
         zHPU5CaoMSvHGqOZOZBuarvuyEFqM1q/tnbPFLU5pyeRysgAesEjY7LqM5O4SrtXxfUY
         1BhZUMzr4uSafZVVuzlep2sovRhvo9XFAPcS9wcMTPtw0UsyLogNYytrSR0SO/AGmG4v
         9Flg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eCbuKZWx/zyJB5FbKzlPVAGACqMDDRvfK3RIOtVWKfM=;
        b=PiUPtdlJvFvv09e2cdsqLRwiD0qA9EdraLDXx5XgSrGUWgmgyDzEl3OWcHgQE0WZ45
         V08ZwXZdGc/21kj9eJiLiKec6XCXvv0Zwl/2Mx8KFE3/ukSsAK+6AcS93eZTMJ/rRGgs
         PEbmY6lYTPIETe+ThJOGNHzaSxfkADEwy4wEBt0fnX55bTkHXwRkBpeEfA36OgkFSe9Y
         ShZkYdHk5S27bMpyamsDawH+PmIB3+LnoiWtnzx0F+/N/Bsfgbdt0rS54r+5Jm/w8LdW
         ibqRlPQIZVt/9KTy9DEP3Aj3Z+cR0XMlFm7xRMIHSUsNXiNTnS2mLNJyKd7uX96Vn8JU
         eULg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FA0RYGTA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q39sor21761863pjb.7.2019.08.05.12.31.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 12:31:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FA0RYGTA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eCbuKZWx/zyJB5FbKzlPVAGACqMDDRvfK3RIOtVWKfM=;
        b=FA0RYGTAI7RkctuMZEW0VnXt8iDjVIsujQH8I9pwFC97A4MGxP4BGNnscKnpIQ5UC5
         H03Ze+qXaUKG6hoSOYWBYWt27ZIXizDdy8tHBJfmVgrblSY7UIkDS6EqJAelmt4EzkGD
         W202gTZP9tsOQKF+PF9f53ofQgDxDexVaiXO109Dh1fZR4dRkscZkFkISrkJytnitq1Q
         t0j1YPiuBitjNMOKYDUjGOdKs/cyEPxmW/3fto48nSrzKta/FPABN1P+FjuJ3OtBBTUV
         n8Ngg1vuF8p5KSS82oH7/62rHchajjjKJMvIyMQv9GXRrDgQBiQTFHfilOTiQC+LogRq
         bE6Q==
X-Google-Smtp-Source: APXvYqzVkxohvmLgYdxtnp100ETiwaEEDr41+8+sim9opTYa3QaZVHQuZX47VsNFpVHxoAy8nHFcOQ==
X-Received: by 2002:a17:90a:974b:: with SMTP id i11mr19489708pjw.21.1565033511226;
        Mon, 05 Aug 2019 12:31:51 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::26a1])
        by smtp.gmail.com with ESMTPSA id i9sm95905352pgg.38.2019.08.05.12.31.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 12:31:50 -0700 (PDT)
Date: Mon, 5 Aug 2019 15:31:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Artem S. Tashkinov" <aros@gmx.com>, linux-kernel@vger.kernel.org,
	linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190805193148.GB4128@cmpxchg.org>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 02:13:16PM +0200, Vlastimil Babka wrote:
> On 8/4/19 11:23 AM, Artem S. Tashkinov wrote:
> > Hello,
> > 
> > There's this bug which has been bugging many people for many years
> > already and which is reproducible in less than a few minutes under the
> > latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> > defaults.
> > 
> > Steps to reproduce:
> > 
> > 1) Boot with mem=4G
> > 2) Disable swap to make everything faster (sudo swapoff -a)
> > 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> > 4) Start opening tabs in either of them and watch your free RAM decrease
> > 
> > Once you hit a situation when opening a new tab requires more RAM than
> > is currently available, the system will stall hard. You will barely  be
> > able to move the mouse pointer. Your disk LED will be flashing
> > incessantly (I'm not entirely sure why). You will not be able to run new
> > applications or close currently running ones.
> 
> > This little crisis may continue for minutes or even longer. I think
> > that's not how the system should behave in this situation. I believe
> > something must be done about that to avoid this stall.
> 
> Yeah that's a known problem, made worse SSD's in fact, as they are able
> to keep refaulting the last remaining file pages fast enough, so there
> is still apparent progress in reclaim and OOM doesn't kick in.
> 
> At this point, the likely solution will be probably based on pressure
> stall monitoring (PSI). I don't know how far we are from a built-in
> monitor with reasonable defaults for a desktop workload, so CCing
> relevant folks.

Yes, psi was specifically developed to address this problem. Before
it, the kernel had to make all decisions based on relative event rates
but had no notion of time. Whereas to the user, time is clearly an
issue, and in fact makes all the difference. So psi quantifies the
time the workload spends executing vs. spinning its wheels.

But choosing a universal cutoff for killing is not possible, since it
depends on the workload and the user's expectation: GUI and other
latency-sensitive applications care way before a compile job or video
encoding would care.

Because of that, there are things like oomd and lmkd as mentioned, to
leave the exact policy decision to userspace.

That being said, I think we should be able to provide a bare minimum
inside the kernel to avoid complete livelocks where the user does not
believe the machine would be able to recover without a reboot.

The goal wouldn't be a glitch-free user experience - the kernel does
not know enough about the applications to even attempt that. It should
just not hang indefinitely. Maybe similar to the hung task detector.

How about something like the below patch? With that, the kernel
catches excessive thrashing that happens before reclaim fails:

[root@ham ~]# stress -d 128 -m 5
stress: info: [344] dispatching hogs: 0 cpu, 0 io, 5 vm, 128 hdd
Excessive and sustained system-wide memory pressure!
kworker/1:2 invoked oom-killer: gfp_mask=0x0(), order=0, oom_score_adj=0
CPU: 1 PID: 77 Comm: kworker/1:2 Not tainted 5.3.0-rc1-mm1-00121-ge34a5cf28771 #142
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.12.0-20181126_142135-anatol 04/01/2014
Workqueue: events psi_avgs_work
Call Trace:
 dump_stack+0x46/0x60
 dump_header+0x5c/0x3d5
 ? irq_work_queue+0x46/0x50
 ? wake_up_klogd+0x2b/0x30
 ? vprintk_emit+0xe5/0x190
 oom_kill_process.cold.10+0xb/0x10
 out_of_memory+0x1ea/0x260
 update_averages.cold.8+0x14/0x25
 ? collect_percpu_times+0x84/0x1f0
 psi_avgs_work+0x80/0xc0
 process_one_work+0x1bb/0x310
 worker_thread+0x28/0x3c0
 ? process_one_work+0x310/0x310
 kthread+0x108/0x120
 ? __kthread_create_on_node+0x170/0x170
 ret_from_fork+0x35/0x40
Mem-Info:
active_anon:109463 inactive_anon:109564 isolated_anon:298
 active_file:4676 inactive_file:4073 isolated_file:455
 unevictable:0 dirty:8475 writeback:8 unstable:0
 slab_reclaimable:2585 slab_unreclaimable:4932
 mapped:413 shmem:2 pagetables:1747 bounce:0
 free:13472 free_pcp:17 free_cma:0

Possible snags and questions:

1. psi is an optional feature right now, but these livelocks commonly
   affect desktop users. What should be the default behavior?

2. Should we make the pressure cutoff and time period configurable?

   I fear we would open a can of worms similar to the existing OOM
   killer, where users are trying to use a kernel self-protection
   mechanism to implement workload QoS and priorities - things that
   should firmly be kept in userspace.

3. swapoff annotation. Due to the swapin annotation, swapoff currently
   raises memory pressure. It probably shouldn't. But this will be a
   bigger problem if we trigger the oom killer based on it.

4. Killing once every 10s assumes basically one big culprit. If the
   pressure is created by many different processes, fixing the
   situation could take quite a while.

   What oomd does to solve this is to monitor the PGSCAN counters
   after a kill, to tell whether pressure is persisting, or just from
   residual refaults after the culprit has been dealt with.

   We may need to do something similar here. Or find a solution to
   encode that distinction into psi itself, and it would also take
   care of the swapoff problem, since it's basically the same thing -
   residual refaults without any reclaim pressure to sustain them.

Anyway, here is the draft patch:

From e34a5cf28771d69f13faa0e933adeae44b26b8aa Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 5 Aug 2019 13:15:16 -0400
Subject: [PATCH] psi oom

---
 include/linux/psi_types.h |  4 +++
 kernel/sched/psi.c        | 52 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 07aaf9b82241..390446b07ac7 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -162,6 +162,10 @@ struct psi_group {
 	u64 polling_total[NR_PSI_STATES - 1];
 	u64 polling_next_update;
 	u64 polling_until;
+
+	/* Out-of-memory situation tracking */
+	bool oom_pressure;
+	u64 oom_pressure_start;
 };
 
 #else /* CONFIG_PSI */
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index f28342dc65ec..1027b6611ec2 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -139,6 +139,7 @@
 #include <linux/ctype.h>
 #include <linux/file.h>
 #include <linux/poll.h>
+#include <linux/oom.h>
 #include <linux/psi.h>
 #include "sched.h"
 
@@ -177,6 +178,8 @@ struct psi_group psi_system = {
 	.pcpu = &system_group_pcpu,
 };
 
+static void psi_oom_tick(struct psi_group *group, u64 now);
+
 static void psi_avgs_work(struct work_struct *work);
 
 static void group_init(struct psi_group *group)
@@ -403,6 +406,8 @@ static u64 update_averages(struct psi_group *group, u64 now)
 		calc_avgs(group->avg[s], missed_periods, sample, period);
 	}
 
+	psi_oom_tick(group, now);
+
 	return avg_next_update;
 }
 
@@ -1280,3 +1285,50 @@ static int __init psi_proc_init(void)
 	return 0;
 }
 module_init(psi_proc_init);
+
+#define OOM_PRESSURE_LEVEL	80
+#define OOM_PRESSURE_PERIOD	(10 * NSEC_PER_SEC)
+
+static void psi_oom_tick(struct psi_group *group, u64 now)
+{
+	struct oom_control oc = {
+		.order = 0,
+	};
+	unsigned long pressure;
+	bool high;
+
+	/*
+	 * Protect the system from livelocking due to thrashing. Leave
+	 * per-cgroup policies to oomd, lmkd etc.
+	 */
+	if (group != &psi_system)
+		return;
+
+	pressure = LOAD_INT(group->avg[PSI_MEM_FULL][0]);
+	high = pressure >= OOM_PRESSURE_LEVEL;
+
+	if (!group->oom_pressure && !high)
+		return;
+
+	if (!group->oom_pressure && high) {
+		group->oom_pressure = true;
+		group->oom_pressure_start = now;
+		return;
+	}
+
+	if (group->oom_pressure && !high) {
+		group->oom_pressure = false;
+		return;
+	}
+
+	if (now < group->oom_pressure_start + OOM_PRESSURE_PERIOD)
+		return;
+
+	group->oom_pressure = false;
+
+	if (!mutex_trylock(&oom_lock))
+		return;
+	pr_warn("Excessive and sustained system-wide memory pressure!\n");
+	out_of_memory(&oc);
+	mutex_unlock(&oom_lock);
+}
-- 
2.22.0

