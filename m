Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D899C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:51:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C719C217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:51:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="hM0waElW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C719C217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73DD46B0003; Wed,  7 Aug 2019 16:51:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ED126B0006; Wed,  7 Aug 2019 16:51:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B5476B0007; Wed,  7 Aug 2019 16:51:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21DB96B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:51:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y22so54099874plr.20
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:51:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i7ClekkPGepVxD3IJPcd6nXsvOMQkTnLWQBUn/hhYN0=;
        b=ErRzrltR8YxGW0W2IqDb2b/9GfTisml7MWc06WGixEmSCC7i6bEzAR5XcHTppLISOG
         tdK/NaSlQGEjXc76NGZnIWKQHVAbZcFvQOlvnpXpY6tD7tBNJUk40YNO7K7n/AG13j6M
         13Ciq+uZ77LcQuzFAjfcsvYmFEPSen3cvY0y/O1bLFSYXC30Yv842J55LIYo+CIpDIgL
         rVkK2R96R2vpq5br248aP1hg9UnL5dSgZXFxafT9oSrCEIMuwRRfVN1LgzzDOhbtjHdc
         7za1mZYxcBFyeMc+H79Ok3JKlHk9Tfc6JwxXZ4lgX3TERcRAAML93az2ErZ1vnNclM5j
         aSzQ==
X-Gm-Message-State: APjAAAUvgvDZIGyxUv4yxgDYR1zX1Lx/Ldb+AsWUgtjoVPtv4D/bn0Vg
	Z1UHRHtOQuNnrvOizK3FfANfZMHNYR+w31RcasV1aqHABHWYxxaSMVCdVtfx0AmhWyiiE+Dd8dJ
	1JzxhrexNXQ61WZ5Asf2JuIt4Yf5XLvHna/8iF/j5M4b8YPhrJpyrJX2MSvCF1JtDcw==
X-Received: by 2002:a62:16:: with SMTP id 22mr11737679pfa.151.1565211106745;
        Wed, 07 Aug 2019 13:51:46 -0700 (PDT)
X-Received: by 2002:a62:16:: with SMTP id 22mr11737615pfa.151.1565211105635;
        Wed, 07 Aug 2019 13:51:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565211105; cv=none;
        d=google.com; s=arc-20160816;
        b=R6KDZ+uSvtS7sPIn+kroNDjGxCC6SVe7Cb0qpn36KfsCENxkxNvFw+IVIZ0cZ7G5uo
         0TH9Kb7lDY2fnF+IcB26hp44sd5WpK0V9FIH5SZOEJEXaBg1wjbPQYQPWSYQNuiWbjE8
         8SMnu0DvuDPNT7DgZVeRfvkVNyFgxvL/nUG0g/1jM8EQovnNZiR/9PEvFWQr8CJ374gY
         nyYEaquOEUBSoP9ifEFmUAy5d6slvsHE2MUgBu76t+96bQTgeZPkCzbeuNwdYH8Li6J4
         /d5GxbcWekS5U+vQwL9tpvoGzdoA5iWqRNIPvLwj/c1QXs/TB6LIFNy3ge36DXx501v3
         HnBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i7ClekkPGepVxD3IJPcd6nXsvOMQkTnLWQBUn/hhYN0=;
        b=bihKrq4I34lck6jKAkE/swq+PGsXItxJ6+WllPtXRySltvtOAuoExBi2pNao3ApsUv
         /AdC1XsohGH5an/vPTDZVE2jGXPI7NejKUdkjlKFyfmAzOkTmYaslEkR/8wbD+A5hSdS
         EGueBz3Oj0I6lIdBQjBTYS4G2NRaJfgXghtxnqunbrT2PqdGMDxUE+4j4TcVqpsnKl4d
         ZyoH8OzQpr0h2lGbTbBxy+2y6U23ldOLF+eyziOx5UhUhmsjaJvu99m6OUrblxXTZNA5
         ecOVWqQZUc9TuwO3H18MxxABWEB8Mr+yTlzUWxYkbeYsWssWu/tGsan2mANIpgNcHCeo
         UCBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=hM0waElW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck8sor199078pjb.22.2019.08.07.13.51.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 13:51:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=hM0waElW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=i7ClekkPGepVxD3IJPcd6nXsvOMQkTnLWQBUn/hhYN0=;
        b=hM0waElWla1uPDwv/IChB2zxvTbUYV4cxG0+9R8IUeY2a3xnfxRGkrAdRwzRVOqb6t
         A8CPaj+spzqobqkMa+MiKRRm8PZRerrnf8P6eF5TiBzQrOKsuoB/QE21GZHQ/mx1FywY
         fA6rZ+hNtsNb7XIf/mM6h+EZqCCdvYH/CWXx4RAuAE/lGhcN/P73SpHom9u3yr/7xGYJ
         HV4TY/gou3db7NWuKAI+liu2Raw7yu5p+Y/sm9kR9Xrmt0r1KFDBqOOV8/DuR/aL7aGn
         fAJs6u1B2hU6CXxyc5cMGfEgluAMv/t+5EJ9veKzap4BWeOSmLRZqPWhyzgrFxoZu4DI
         U7/w==
X-Google-Smtp-Source: APXvYqxA0GLU/h6gpLjrYUOOfUL8MeH0DOteSmOnyr4IKmHoccam/pRYuZp7yfaWkPWiADG/Lajw0w==
X-Received: by 2002:a17:90a:a116:: with SMTP id s22mr309327pjp.47.1565211102350;
        Wed, 07 Aug 2019 13:51:42 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:f7c1])
        by smtp.gmail.com with ESMTPSA id z6sm63165803pgk.18.2019.08.07.13.51.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 13:51:40 -0700 (PDT)
Date: Wed, 7 Aug 2019 16:51:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190807205138.GA24222@cmpxchg.org>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807075927.GO11812@dhcp22.suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 09:59:27AM +0200, Michal Hocko wrote:
> On Tue 06-08-19 18:01:50, Johannes Weiner wrote:
> > On Tue, Aug 06, 2019 at 09:27:05AM -0700, Suren Baghdasaryan wrote:
> [...]
> > > > > I'm not sure 10s is the perfect value here, but I do think the kernel
> > > > > should try to get out of such a state, where interacting with the
> > > > > system is impossible, within a reasonable amount of time.
> > > > >
> > > > > It could be a little too short for non-interactive number-crunching
> > > > > systems...
> > > >
> > > > Would it be possible to have a module with tunning knobs as parameters
> > > > and hook into the PSI infrastructure? People can play with the setting
> > > > to their need, we wouldn't really have think about the user visible API
> > > > for the tuning and this could be easily adopted as an opt-in mechanism
> > > > without a risk of regressions.
> > 
> > It's relatively easy to trigger a livelock that disables the entire
> > system for good, as a regular user. It's a little weird to make the
> > bug fix for that an opt-in with an extensive configuration interface.
> 
> Yes, I definitely do agree that this is a bug fix more than a
> feature. The thing is that we do not know what the proper default is for
> a wide variety of workloads so some way of configurability is needed
> (level and period).  If making this a module would require a lot of
> additional code then we need a kernel command line parameter at least.
> 
> A module would have a nice advantage that you can change your
> configuration without rebooting. The same can be achieved by a sysfs on
> the other hand.

That's reasonable. How about my initial patch, but behind a config
option and the level and period configurable?

---
From 9efda85451062dea4ea287a886e515efefeb1545 Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 5 Aug 2019 13:15:16 -0400
Subject: [PATCH] psi: trigger the OOM killer on severe thrashing

Over the last few years we have had many reports that the kernel can
enter an extended livelock situation under sufficient memory
pressure. The system becomes unresponsive and fully IO bound for
indefinite periods of time, and often the user has no choice but to
reboot. Even though the system is clearly struggling with a shortage
of memory, the OOM killer is not engaging reliably.

The reason is that with bigger RAM, and in particular with faster
SSDs, page reclaim does not necessarily fail in the traditional sense
anymore. In the time it takes the CPU to run through the vast LRU
lists, there are almost always some cache pages that have finished
reading in and can be reclaimed, even before userspace had a chance to
access them. As a result, reclaim is nominally succeeding, but
userspace is refault-bound and not making significant progress.

While this is clearly noticable to human beings, the kernel could not
actually determine this state with the traditional memory event
counters. We might see a certain rate of reclaim activity or refaults,
but how long, or whether at all, userspace is unproductive because of
it depends on IO speed, readahead efficiency, as well as memory access
patterns and concurrency of the userspace applications. The same
number of the VM events could be unnoticed in one system / workload
combination, and result in an indefinite lockup in a different one.

However, eb414681d5a0 ("psi: pressure stall information for CPU,
memory, and IO") introduced a memory pressure metric that quantifies
the share of wallclock time in which userspace waits on reclaim,
refaults, swapins. By using absolute time, it encodes all the above
mentioned variables of hardware capacity and workload behavior. When
memory pressure is 40%, it means that 40% of the time the workload is
stalled on memory, period. This is the actual measure for the lack of
forward progress that users can experience. It's also something they
expect the kernel to manage and remedy if it becomes non-existent.

To accomplish this, this patch implements a thrashing cutoff for the
OOM killer. If the kernel determines a sustained high level of memory
pressure, and thus a lack of forward progress in userspace, it will
trigger the OOM killer to reduce memory contention.

Per default, the OOM killer will engage after 15 seconds of at least
80% memory pressure. These values are tunable via sysctls
vm.thrashing_oom_period and vm.thrashing_oom_level.

Ideally, this would be standard behavior for the kernel, but since it
involves a new metric and OOM killing, let's be safe and make it an
opt-in via CONFIG_THRASHING_OOM. Setting vm.thrashing_oom_level to 0
also disables the feature at runtime.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: "Artem S. Tashkinov" <aros@gmx.com>
---
 Documentation/admin-guide/sysctl/vm.rst | 24 ++++++++
 include/linux/psi.h                     |  5 ++
 include/linux/psi_types.h               |  6 ++
 kernel/sched/psi.c                      | 74 +++++++++++++++++++++++++
 kernel/sysctl.c                         | 20 +++++++
 mm/Kconfig                              | 20 +++++++
 6 files changed, 149 insertions(+)

diff --git a/Documentation/admin-guide/sysctl/vm.rst b/Documentation/admin-guide/sysctl/vm.rst
index 64aeee1009ca..0332cb52bcfc 100644
--- a/Documentation/admin-guide/sysctl/vm.rst
+++ b/Documentation/admin-guide/sysctl/vm.rst
@@ -66,6 +66,8 @@ files can be found in mm/swap.c.
 - stat_interval
 - stat_refresh
 - numa_stat
+- thrashing_oom_level
+- thrashing_oom_period
 - swappiness
 - unprivileged_userfaultfd
 - user_reserve_kbytes
@@ -825,6 +827,28 @@ When page allocation performance is not a bottleneck and you want all
 	echo 1 > /proc/sys/vm/numa_stat
 
 
+thrashing_oom_level
+===================
+
+This defines the memory pressure level for severe thrashing at which
+the OOM killer will be engaged.
+
+The default is 80. This means the system is considered to be thrashing
+severely when all active tasks are collectively stalled on memory
+(waiting for page reclaim, refaults, swapins etc) for 80% of the time.
+
+A setting of 0 will disable thrashing-based OOM killing.
+
+
+thrashing_oom_period
+===================
+
+This defines the number of seconds the system must sustain severe
+thrashing at thrashing_oom_level before the OOM killer is invoked.
+
+The default is 15.
+
+
 swappiness
 ==========
 
diff --git a/include/linux/psi.h b/include/linux/psi.h
index 7b3de7321219..661ce45900f9 100644
--- a/include/linux/psi.h
+++ b/include/linux/psi.h
@@ -37,6 +37,11 @@ __poll_t psi_trigger_poll(void **trigger_ptr, struct file *file,
 			poll_table *wait);
 #endif
 
+#ifdef CONFIG_THRASHING_OOM
+extern unsigned int sysctl_thrashing_oom_level;
+extern unsigned int sysctl_thrashing_oom_period;
+#endif
+
 #else /* CONFIG_PSI */
 
 static inline void psi_init(void) {}
diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 07aaf9b82241..7c57d7e5627e 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -162,6 +162,12 @@ struct psi_group {
 	u64 polling_total[NR_PSI_STATES - 1];
 	u64 polling_next_update;
 	u64 polling_until;
+
+#ifdef CONFIG_THRASHING_OOM
+	/* Severe thrashing state tracking */
+	bool oom_pressure;
+	u64 oom_pressure_start;
+#endif
 };
 
 #else /* CONFIG_PSI */
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index f28342dc65ec..4b1b620d6359 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -139,6 +139,7 @@
 #include <linux/ctype.h>
 #include <linux/file.h>
 #include <linux/poll.h>
+#include <linux/oom.h>
 #include <linux/psi.h>
 #include "sched.h"
 
@@ -177,6 +178,14 @@ struct psi_group psi_system = {
 	.pcpu = &system_group_pcpu,
 };
 
+#ifdef CONFIG_THRASHING_OOM
+static void psi_oom_tick(struct psi_group *group, u64 now);
+#else
+static inline void psi_oom_tick(struct psi_group *group, u64 now)
+{
+}
+#endif
+
 static void psi_avgs_work(struct work_struct *work);
 
 static void group_init(struct psi_group *group)
@@ -403,6 +412,8 @@ static u64 update_averages(struct psi_group *group, u64 now)
 		calc_avgs(group->avg[s], missed_periods, sample, period);
 	}
 
+	psi_oom_tick(group, now);
+
 	return avg_next_update;
 }
 
@@ -1280,3 +1291,66 @@ static int __init psi_proc_init(void)
 	return 0;
 }
 module_init(psi_proc_init);
+
+#ifdef CONFIG_THRASHING_OOM
+/*
+ * Trigger the OOM killer when detecting severe thrashing.
+ *
+ * Per default we define severe thrashing as 15 seconds of 80% memory
+ * pressure (i.e. all active tasks are collectively stalled on memory
+ * 80% of the time).
+ */
+unsigned int sysctl_thrashing_oom_level = 80;
+unsigned int sysctl_thrashing_oom_period = 15;
+
+static void psi_oom_tick(struct psi_group *group, u64 now)
+{
+	struct oom_control oc = {
+		.order = 0,
+	};
+	unsigned long pressure;
+	bool high;
+
+	/* Disabled at runtime */
+	if (!sysctl_thrashing_oom_level)
+		return;
+
+	/*
+	 * Protect the system from livelocking due to thrashing. Leave
+	 * per-cgroup policies to oomd, lmkd etc.
+	 */
+	if (group != &psi_system)
+		return;
+
+	pressure = LOAD_INT(group->avg[PSI_MEM_FULL][0]);
+	high = pressure >= sysctl_thrashing_oom_level;
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
+	if (now < group->oom_pressure_start +
+	    (u64)sysctl_thrashing_oom_period * NSEC_PER_SEC)
+		return;
+
+	pr_warn("Severe thrashing detected! (%ds of %d%% memory pressure)\n",
+		sysctl_thrashing_oom_period, sysctl_thrashing_oom_level);
+
+	group->oom_pressure = false;
+
+	if (!mutex_trylock(&oom_lock))
+		return;
+	out_of_memory(&oc);
+	mutex_unlock(&oom_lock);
+}
+#endif /* CONFIG_THRASHING_OOM */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f12888971d66..3b9b3deb1836 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -68,6 +68,7 @@
 #include <linux/bpf.h>
 #include <linux/mount.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/psi.h>
 
 #include "../lib/kstrtox.h"
 
@@ -1746,6 +1747,25 @@ static struct ctl_table vm_table[] = {
 		.extra1		= SYSCTL_ZERO,
 		.extra2		= SYSCTL_ONE,
 	},
+#endif
+#ifdef CONFIG_THRASHING_OOM
+	{
+		.procname	= "thrashing_oom_level",
+		.data		= &sysctl_thrashing_oom_level,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= SYSCTL_ZERO,
+		.extra2		= &one_hundred,
+	},
+	{
+		.procname	= "thrashing_oom_period",
+		.data		= &sysctl_thrashing_oom_period,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= SYSCTL_ZERO,
+	},
 #endif
 	{ }
 };
diff --git a/mm/Kconfig b/mm/Kconfig
index 56cec636a1fc..cef13b423beb 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -736,4 +736,24 @@ config ARCH_HAS_PTE_SPECIAL
 config ARCH_HAS_HUGEPD
 	bool
 
+config THRASHING_OOM
+	bool "Trigger the OOM killer on severe thrashing"
+	select PSI
+	help
+	  Under memory pressure, the kernel can enter severe thrashing
+	  or swap storms during which the system is fully IO-bound and
+	  does not respond to any user input. The OOM killer does not
+	  always engage because page reclaim manages to make nominal
+	  forward progress, but the system is effectively livelocked.
+
+	  This feature uses pressure stall information (PSI) to detect
+	  severe thrashing and trigger the OOM killer.
+
+	  The OOM killer will be engaged when the system sustains a
+	  memory pressure level of 80% for 15 seconds. This can be
+	  adjusted using the vm.thrashing_oom_[level|period] sysctls.
+
+	  Say Y if you have observed your system becoming unresponsive
+	  for extended periods under memory pressure.
+
 endmenu
-- 
2.22.0

