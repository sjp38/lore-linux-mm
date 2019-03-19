Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB0B6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E1602183E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tDTLBAGv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E1602183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84436B000E; Tue, 19 Mar 2019 19:56:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0D616B0010; Tue, 19 Mar 2019 19:56:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B899D6B0266; Tue, 19 Mar 2019 19:56:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E00C6B000E
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:48 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r21so395534iod.12
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=rD12kcdJr70evYUchULXAeHxr2qtqjk4mpPoyT7DzFU=;
        b=frwiutCdP4rIs7VzndCw++HxcxANOWIj7MX63sPxLHXva7BJegHFk5E8k0JDBMfd8k
         YfhsbA11AjAFk88MBzxNucffm9oR7nhGY64XelN0klXImZgpi3gn1YJl64ppFNEa15Ft
         PwNo6zYGbcIwbz19c5lMETv6eESaQ6u+O4JfX0aav4ePtpDH4qfQkZYh1n2qBiY41A0m
         4tdgYyWDpjcRAtYyGlhtg2CHAFEqncWEz+4S4PJGm1tRgFprF78z47eiNaSXqNH3TX60
         Tt1TfUqZSi79VzoLqSQU5+2rCzKUFUu8xWmiciVfClkR496RM1Zgu8k9hctzbyGt4+f7
         BYrg==
X-Gm-Message-State: APjAAAV+bspQegUf5KJKgcJPKf6g0LW5QpKJzWzVDulZvE7M6rNbmoLN
	Qf0aslhIBCb1614F4MiVjU6sdGCF5F3wLdd2M75xN35c/ovuv4m5v492iGttkDzEemAWKqzNe0C
	zxQka9DDqQQxZ9Peqck51NIt5U5wzelDAkb5TTfIm3a/zJ5vg798Hdgj8S6iJ2msPVw==
X-Received: by 2002:a5d:93d9:: with SMTP id j25mr3522017ioo.305.1553039808218;
        Tue, 19 Mar 2019 16:56:48 -0700 (PDT)
X-Received: by 2002:a5d:93d9:: with SMTP id j25mr3521943ioo.305.1553039805942;
        Tue, 19 Mar 2019 16:56:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039805; cv=none;
        d=google.com; s=arc-20160816;
        b=gU2WDh6/44ojjesOApS0R+q5hRWUFCnVJu7yeJ2kCw5u6XxLV+dmKcWW6A+o/vcXc+
         DyFeCHhH8IyBnNiKzSdJz6VWUKaB6/5CB9goSrE3bO7h5KxOUW92wSZq+yGWwjcBmP3n
         djiILftpS3cGRN9HjilnkQAGDa0rnkjNEq/JX0QdTVCSnGC3PTvz7pNmf8hTcVZW6W8a
         FF8Pi4V4pT0Ec3JBrLL7L+9jPCMxfeT913+T4IZ4wDxq6FhGE6qiNloYZJ/IS+4+TqeP
         tcesvB03fPWkYL8DIbZcjOOup/QI7+4zT5yik5HGWObsnbXvxVBMX6ZgLWmfbk4qlht1
         VRpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=rD12kcdJr70evYUchULXAeHxr2qtqjk4mpPoyT7DzFU=;
        b=G/8yf8ZH6IhtnJY5Nr+21G/lg9StD5xPeQYUEqsSwjYsQTkPXEYM7rsQWy8nA8zcE/
         IJlyXlkVly6mbKqb5T12J9MUWRrsAVjYrjZadoaiHYM5zCdll6wi0e62MRRZQVKeu089
         LzZmFADUSBdKx9OISTHuJhcuJxsZpWZnFR0hKaix26aLqmcG87s6RA+ToLMXCHLO6zQD
         e2ffe8qpd9XrONq/lWDu7dyxMFt4AW7ESi0trQkoOVifctYvWkAYaGHrMyqD4UBz0RR/
         uwKClPICRgkuQ07wV0DV8k53fw7aA5NrnC/6DiQIvJbk0SiZq5N2+YT7+tGo9Vboz4Wv
         WZ7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tDTLBAGv;
       spf=pass (google.com: domain of 3vygrxaykcpakmjwftyggydw.ugedafmp-eecnsuc.gjy@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vYGRXAYKCPAkmjWfTYggYdW.Ugedafmp-eecnSUc.gjY@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id q67sor568684ita.3.2019.03.19.16.56.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vygrxaykcpakmjwftyggydw.ugedafmp-eecnsuc.gjy@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tDTLBAGv;
       spf=pass (google.com: domain of 3vygrxaykcpakmjwftyggydw.ugedafmp-eecnsuc.gjy@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vYGRXAYKCPAkmjWfTYggYdW.Ugedafmp-eecnSUc.gjY@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=rD12kcdJr70evYUchULXAeHxr2qtqjk4mpPoyT7DzFU=;
        b=tDTLBAGvjP1aWgYAToI0jrG0Ojb4KLFuFfahjHLMvszYkeiDWwjY8SDWm8y8Y6WwEs
         bBCOKw2P63Q8prUZUD8b3ryydHwgB97IFkWB7kzy0bZoIBMU+NvZSonG+RJ2DUKznRWn
         z3umqoYZGp6l8nguV4DH/oDPrhh1yVkqukzZYMR+pU4Lx4uYvNrSKP1Q4uygTaAfk0mJ
         wYHGTXwAcx9775B0pBTXyPbYgC2IXzIHF4Wiua/7EQBM+74psKEm1ZwRZYfJca+EUvUk
         INuX2eRdG1lW7MPgHg/NuMNtdgrYvjehTAQH2Uwp/DjwxIl1uiP95K1uhpcM9XPynU/t
         TXrg==
X-Google-Smtp-Source: APXvYqyeblFB8b2GIjj6UvR07OrEL8oGXI1Wd4F+PP4czPiRT2vkBl2eKgsnemwdtOo2inYGl/8y5CuGRR0=
X-Received: by 2002:a24:7d8a:: with SMTP id b132mr3009072itc.20.1553039805672;
 Tue, 19 Mar 2019 16:56:45 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:19 -0700
In-Reply-To: <20190319235619.260832-1-surenb@google.com>
Message-Id: <20190319235619.260832-8-surenb@google.com>
Mime-Version: 1.0
References: <20190319235619.260832-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 7/7] psi: introduce psi monitor
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Psi monitor aims to provide a low-latency short-term pressure
detection mechanism configurable by users. It allows users to
monitor psi metrics growth and trigger events whenever a metric
raises above user-defined threshold within user-defined time window.

Time window and threshold are both expressed in usecs. Multiple psi
resources with different thresholds and window sizes can be monitored
concurrently.

Psi monitors activate when system enters stall state for the monitored
psi metric and deactivate upon exit from the stall state. While system
is in the stall state psi signal growth is monitored at a rate of 10 times
per tracking window. Min window size is 500ms, therefore the min monitoring
interval is 50ms. Max window size is 10s with monitoring interval of 1s.

When activated psi monitor stays active for at least the duration of one
tracking window to avoid repeated activations/deactivations when psi
signal is bouncing.

Notifications to the users are rate-limited to one per tracking window.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/accounting/psi.txt | 107 +++++++
 include/linux/psi.h              |   8 +
 include/linux/psi_types.h        |  82 ++++-
 kernel/cgroup/cgroup.c           |  71 ++++-
 kernel/sched/psi.c               | 494 ++++++++++++++++++++++++++++++-
 5 files changed, 742 insertions(+), 20 deletions(-)

diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
index b8ca28b60215..4fb40fe94828 100644
--- a/Documentation/accounting/psi.txt
+++ b/Documentation/accounting/psi.txt
@@ -63,6 +63,110 @@ tracked and exported as well, to allow detection of latency spikes
 which wouldn't necessarily make a dent in the time averages, or to
 average trends over custom time frames.
 
+Monitoring for pressure thresholds
+==================================
+
+Users can register triggers and use poll() to be woken up when resource
+pressure exceeds certain thresholds.
+
+A trigger describes the maximum cumulative stall time over a specific
+time window, e.g. 100ms of total stall time within any 500ms window to
+generate a wakeup event.
+
+To register a trigger user has to open psi interface file under
+/proc/pressure/ representing the resource to be monitored and write the
+desired threshold and time window. The open file descriptor should be
+used to wait for trigger events using select(), poll() or epoll().
+The following format is used:
+
+<some|full> <stall amount in us> <time window in us>
+
+For example writing "some 150000 1000000" into /proc/pressure/memory
+would add 150ms threshold for partial memory stall measured within
+1sec time window. Writing "full 50000 1000000" into /proc/pressure/io
+would add 50ms threshold for full io stall measured within 1sec time window.
+
+Triggers can be set on more than one psi metric and more than one trigger
+for the same psi metric can be specified. However for each trigger a separate
+file descriptor is required to be able to poll it separately from others,
+therefore for each trigger a separate open() syscall should be made even
+when opening the same psi interface file.
+
+Monitors activate only when system enters stall state for the monitored
+psi metric and deactivates upon exit from the stall state. While system is
+in the stall state psi signal growth is monitored at a rate of 10 times per
+tracking window.
+
+The kernel accepts window sizes ranging from 500ms to 10s, therefore min
+monitoring update interval is 50ms and max is 1s. Min limit is set to
+prevent overly frequent polling. Max limit is chosen as a high enough number
+after which monitors are most likely not needed and psi averages can be used
+instead.
+
+When activated, psi monitor stays active for at least the duration of one
+tracking window to avoid repeated activations/deactivations when system is
+bouncing in and out of the stall state.
+
+Notifications to the userspace are rate-limited to one per tracking window.
+
+The trigger will de-register when the file descriptor used to define the
+trigger  is closed.
+
+Userspace monitor usage example
+===============================
+
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <poll.h>
+#include <string.h>
+#include <unistd.h>
+
+/*
+ * Monitor memory partial stall with 1s tracking window size
+ * and 150ms threshold.
+ */
+int main() {
+	const char trig[] = "some 150000 1000000";
+	struct pollfd fds;
+	int n;
+
+	fds.fd = open("/proc/pressure/memory", O_RDWR | O_NONBLOCK);
+	if (fds.fd < 0) {
+		printf("/proc/pressure/memory open error: %s\n",
+			strerror(errno));
+		return 1;
+	}
+	fds.events = POLLPRI;
+
+	if (write(fds.fd, trig, strlen(trig) + 1) < 0) {
+		printf("/proc/pressure/memory write error: %s\n",
+			strerror(errno));
+		return 1;
+	}
+
+	printf("waiting for events...\n");
+	while (1) {
+		n = poll(&fds, 1, -1);
+		if (n < 0) {
+			printf("poll error: %s\n", strerror(errno));
+			return 1;
+		}
+		if (fds.revents & POLLERR) {
+			printf("got POLLERR, event source is gone\n");
+			return 0;
+		}
+		if (fds.revents & POLLPRI) {
+			printf("event triggered!\n");
+		} else {
+			printf("unknown event received: 0x%x\n", fds.revents);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 Cgroup2 interface
 =================
 
@@ -71,3 +175,6 @@ mounted, pressure stall information is also tracked for tasks grouped
 into cgroups. Each subdirectory in the cgroupfs mountpoint contains
 cpu.pressure, memory.pressure, and io.pressure files; the format is
 the same as the /proc/pressure/ files.
+
+Per-cgroup psi monitors can be specified and used the same way as
+system-wide ones.
diff --git a/include/linux/psi.h b/include/linux/psi.h
index 7006008d5b72..af892c290116 100644
--- a/include/linux/psi.h
+++ b/include/linux/psi.h
@@ -4,6 +4,7 @@
 #include <linux/jump_label.h>
 #include <linux/psi_types.h>
 #include <linux/sched.h>
+#include <linux/poll.h>
 
 struct seq_file;
 struct css_set;
@@ -26,6 +27,13 @@ int psi_show(struct seq_file *s, struct psi_group *group, enum psi_res res);
 int psi_cgroup_alloc(struct cgroup *cgrp);
 void psi_cgroup_free(struct cgroup *cgrp);
 void cgroup_move_task(struct task_struct *p, struct css_set *to);
+
+struct psi_trigger *psi_trigger_create(struct psi_group *group,
+			char *buf, size_t nbytes, enum psi_res res);
+void psi_trigger_replace(void **trigger_ptr, struct psi_trigger *t);
+
+__poll_t psi_trigger_poll(void **trigger_ptr, struct file *file,
+			poll_table *wait);
 #endif
 
 #else /* CONFIG_PSI */
diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 4d1c1f67be18..07aaf9b82241 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -1,8 +1,11 @@
 #ifndef _LINUX_PSI_TYPES_H
 #define _LINUX_PSI_TYPES_H
 
+#include <linux/kthread.h>
 #include <linux/seqlock.h>
 #include <linux/types.h>
+#include <linux/kref.h>
+#include <linux/wait.h>
 
 #ifdef CONFIG_PSI
 
@@ -44,6 +47,12 @@ enum psi_states {
 	NR_PSI_STATES = 6,
 };
 
+enum psi_aggregators {
+	PSI_AVGS = 0,
+	PSI_POLL,
+	NR_PSI_AGGREGATORS,
+};
+
 struct psi_group_cpu {
 	/* 1st cacheline updated by the scheduler */
 
@@ -65,7 +74,55 @@ struct psi_group_cpu {
 	/* 2nd cacheline updated by the aggregator */
 
 	/* Delta detection against the sampling buckets */
-	u32 times_prev[NR_PSI_STATES] ____cacheline_aligned_in_smp;
+	u32 times_prev[NR_PSI_AGGREGATORS][NR_PSI_STATES]
+			____cacheline_aligned_in_smp;
+};
+
+/* PSI growth tracking window */
+struct psi_window {
+	/* Window size in ns */
+	u64 size;
+
+	/* Start time of the current window in ns */
+	u64 start_time;
+
+	/* Value at the start of the window */
+	u64 start_value;
+
+	/* Value growth in the previous window */
+	u64 prev_growth;
+};
+
+struct psi_trigger {
+	/* PSI state being monitored by the trigger */
+	enum psi_states state;
+
+	/* User-spacified threshold in ns */
+	u64 threshold;
+
+	/* List node inside triggers list */
+	struct list_head node;
+
+	/* Backpointer needed during trigger destruction */
+	struct psi_group *group;
+
+	/* Wait queue for polling */
+	wait_queue_head_t event_wait;
+
+	/* Pending event flag */
+	int event;
+
+	/* Tracking window */
+	struct psi_window win;
+
+	/*
+	 * Time last event was generated. Used for rate-limiting
+	 * events to one per window
+	 */
+	u64 last_event_time;
+
+	/* Refcounting to prevent premature destruction */
+	struct kref refcount;
 };
 
 struct psi_group {
@@ -79,11 +136,32 @@ struct psi_group {
 	u64 avg_total[NR_PSI_STATES - 1];
 	u64 avg_last_update;
 	u64 avg_next_update;
+
+	/* Aggregator work control */
 	struct delayed_work avgs_work;
 
 	/* Total stall times and sampled pressure averages */
-	u64 total[NR_PSI_STATES - 1];
+	u64 total[NR_PSI_AGGREGATORS][NR_PSI_STATES - 1];
 	unsigned long avg[NR_PSI_STATES - 1][3];
+
+	/* Monitor work control */
+	atomic_t poll_scheduled;
+	struct kthread_worker __rcu *poll_kworker;
+	struct kthread_delayed_work poll_work;
+
+	/* Protects data used by the monitor */
+	struct mutex trigger_lock;
+
+	/* Configured polling triggers */
+	struct list_head triggers;
+	u32 nr_triggers[NR_PSI_STATES - 1];
+	u32 poll_states;
+	u64 poll_min_period;
+
+	/* Total stall times at the start of monitor activation */
+	u64 polling_total[NR_PSI_STATES - 1];
+	u64 polling_next_update;
+	u64 polling_until;
 };
 
 #else /* CONFIG_PSI */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 3f2b4bde0f9c..acee7f364f34 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -3508,7 +3508,65 @@ static int cgroup_cpu_pressure_show(struct seq_file *seq, void *v)
 {
 	return psi_show(seq, &seq_css(seq)->cgroup->psi, PSI_CPU);
 }
-#endif
+
+static ssize_t cgroup_pressure_write(struct kernfs_open_file *of, char *buf,
+					  size_t nbytes, enum psi_res res)
+{
+	struct psi_trigger *new;
+	struct cgroup *cgrp;
+
+	cgrp = cgroup_kn_lock_live(of->kn, false);
+	if (!cgrp)
+		return -ENODEV;
+
+	cgroup_get(cgrp);
+	cgroup_kn_unlock(of->kn);
+
+	new = psi_trigger_create(&cgrp->psi, buf, nbytes, res);
+	if (IS_ERR(new)) {
+		cgroup_put(cgrp);
+		return PTR_ERR(new);
+	}
+
+	psi_trigger_replace(&of->priv, new);
+
+	cgroup_put(cgrp);
+
+	return nbytes;
+}
+
+static ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_IO);
+}
+
+static ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_MEM);
+}
+
+static ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_CPU);
+}
+
+static __poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
+					  poll_table *pt)
+{
+	return psi_trigger_poll(&of->priv, of->file, pt);
+}
+
+static void cgroup_pressure_release(struct kernfs_open_file *of)
+{
+	psi_trigger_replace(&of->priv, NULL);
+}
+#endif /* CONFIG_PSI */
 
 static int cgroup_file_open(struct kernfs_open_file *of)
 {
@@ -4663,18 +4721,27 @@ static struct cftype cgroup_base_files[] = {
 		.name = "io.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_io_pressure_show,
+		.write = cgroup_io_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
 	{
 		.name = "memory.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_memory_pressure_show,
+		.write = cgroup_memory_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
 	{
 		.name = "cpu.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_cpu_pressure_show,
+		.write = cgroup_cpu_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
-#endif
+#endif /* CONFIG_PSI */
 	{ }	/* terminate */
 };
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 1b99eeffaa25..e88918e0bb6d 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -4,6 +4,9 @@
  * Copyright (c) 2018 Facebook, Inc.
  * Author: Johannes Weiner <hannes@cmpxchg.org>
  *
+ * Polling support by Suren Baghdasaryan <surenb@google.com>
+ * Copyright (c) 2018 Google, Inc.
+ *
  * When CPU, memory and IO are contended, tasks experience delays that
  * reduce throughput and introduce latencies into the workload. Memory
  * and IO contention, in addition, can cause a full loss of forward
@@ -129,9 +132,13 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/seqlock.h>
+#include <linux/uaccess.h>
 #include <linux/cgroup.h>
 #include <linux/module.h>
 #include <linux/sched.h>
+#include <linux/ctype.h>
+#include <linux/file.h>
+#include <linux/poll.h>
 #include <linux/psi.h>
 #include "sched.h"
 
@@ -156,6 +163,11 @@ __setup("psi=", setup_psi);
 #define EXP_60s		1981		/* 1/exp(2s/60s) */
 #define EXP_300s	2034		/* 1/exp(2s/300s) */
 
+/* PSI trigger definitions */
+#define WINDOW_MIN_US 500000	/* Min window size is 500ms */
+#define WINDOW_MAX_US 10000000	/* Max window size is 10s */
+#define UPDATES_PER_WINDOW 10	/* 10 updates per window */
+
 /* Sampling frequency in nanoseconds */
 static u64 psi_period __read_mostly;
 
@@ -176,6 +188,17 @@ static void group_init(struct psi_group *group)
 	group->avg_next_update = sched_clock() + psi_period;
 	INIT_DELAYED_WORK(&group->avgs_work, psi_avgs_work);
 	mutex_init(&group->avgs_lock);
+	/* Init trigger-related members */
+	atomic_set(&group->poll_scheduled, 0);
+	mutex_init(&group->trigger_lock);
+	INIT_LIST_HEAD(&group->triggers);
+	memset(group->nr_triggers, 0, sizeof(group->nr_triggers));
+	group->poll_states = 0;
+	group->poll_min_period = U32_MAX;
+	memset(group->polling_total, 0, sizeof(group->polling_total));
+	group->polling_next_update = ULLONG_MAX;
+	group->polling_until = 0;
+	rcu_assign_pointer(group->poll_kworker, NULL);
 }
 
 void __init psi_init(void)
@@ -210,7 +233,8 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
 	}
 }
 
-static void get_recent_times(struct psi_group *group, int cpu, u32 *times,
+static void get_recent_times(struct psi_group *group, int cpu,
+			     enum psi_aggregators aggregator, u32 *times,
 			     u32 *pchanged_states)
 {
 	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
@@ -245,8 +269,8 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times,
 		if (state_mask & (1 << s))
 			times[s] += now - state_start;
 
-		delta = times[s] - groupc->times_prev[s];
-		groupc->times_prev[s] = times[s];
+		delta = times[s] - groupc->times_prev[aggregator][s];
+		groupc->times_prev[aggregator][s] = times[s];
 
 		times[s] = delta;
 		if (delta)
@@ -274,7 +298,9 @@ static void calc_avgs(unsigned long avg[3], int missed_periods,
 	avg[2] = calc_load(avg[2], EXP_300s, pct);
 }
 
-static void collect_percpu_times(struct psi_group *group, u32 *pchanged_states)
+static void collect_percpu_times(struct psi_group *group,
+				 enum psi_aggregators aggregator,
+				 u32 *pchanged_states)
 {
 	u64 deltas[NR_PSI_STATES - 1] = { 0, };
 	unsigned long nonidle_total = 0;
@@ -295,7 +321,7 @@ static void collect_percpu_times(struct psi_group *group, u32 *pchanged_states)
 		u32 nonidle;
 		u32 cpu_changed_states;
 
-		get_recent_times(group, cpu, times,
+		get_recent_times(group, cpu, aggregator, times,
 				&cpu_changed_states);
 		changed_states |= cpu_changed_states;
 
@@ -320,7 +346,8 @@ static void collect_percpu_times(struct psi_group *group, u32 *pchanged_states)
 
 	/* total= */
 	for (s = 0; s < NR_PSI_STATES - 1; s++)
-		group->total[s] += div_u64(deltas[s], max(nonidle_total, 1UL));
+		group->total[aggregator][s] +=
+				div_u64(deltas[s], max(nonidle_total, 1UL));
 
 	if (pchanged_states)
 		*pchanged_states = changed_states;
@@ -352,7 +379,7 @@ static u64 update_averages(struct psi_group *group, u64 now)
 	for (s = 0; s < NR_PSI_STATES - 1; s++) {
 		u32 sample;
 
-		sample = group->total[s] - group->avg_total[s];
+		sample = group->total[PSI_AVGS][s] - group->avg_total[s];
 		/*
 		 * Due to the lockless sampling of the time buckets,
 		 * recorded time deltas can slip into the next period,
@@ -394,7 +421,7 @@ static void psi_avgs_work(struct work_struct *work)
 
 	now = sched_clock();
 
-	collect_percpu_times(group, &changed_states);
+	collect_percpu_times(group, PSI_AVGS, &changed_states);
 	nonidle = changed_states & (1 << PSI_NONIDLE);
 	/*
 	 * If there is task activity, periodically fold the per-cpu
@@ -414,6 +441,187 @@ static void psi_avgs_work(struct work_struct *work)
 	mutex_unlock(&group->avgs_lock);
 }
 
+/* Trigger tracking window manupulations */
+static void window_reset(struct psi_window *win, u64 now, u64 value,
+			 u64 prev_growth)
+{
+	win->start_time = now;
+	win->start_value = value;
+	win->prev_growth = prev_growth;
+}
+
+/*
+ * PSI growth tracking window update and growth calculation routine.
+ *
+ * This approximates a sliding tracking window by interpolating
+ * partially elapsed windows using historical growth data from the
+ * previous intervals. This minimizes memory requirements (by not storing
+ * all the intermediate values in the previous window) and simplifies
+ * the calculations. It works well because PSI signal changes only in
+ * positive direction and over relatively small window sizes the growth
+ * is close to linear.
+ */
+static u64 window_update(struct psi_window *win, u64 now, u64 value)
+{
+	u64 elapsed;
+	u64 growth;
+
+	elapsed = now - win->start_time;
+	growth = value - win->start_value;
+	/*
+	 * After each tracking window passes win->start_value and
+	 * win->start_time get reset and win->prev_growth stores
+	 * the average per-window growth of the previous window.
+	 * win->prev_growth is then used to interpolate additional
+	 * growth from the previous window assuming it was linear.
+	 */
+	if (elapsed > win->size)
+		window_reset(win, now, value, growth);
+	else {
+		u32 remaining;
+
+		remaining = win->size - elapsed;
+		growth += div_u64(win->prev_growth * remaining, win->size);
+	}
+
+	return growth;
+}
+
+static void init_triggers(struct psi_group *group, u64 now)
+{
+	struct psi_trigger *t;
+
+	list_for_each_entry(t, &group->triggers, node)
+		window_reset(&t->win, now,
+				group->total[PSI_POLL][t->state], 0);
+	memcpy(group->polling_total, group->total[PSI_POLL],
+		   sizeof(group->polling_total));
+	group->polling_next_update = now + group->poll_min_period;
+}
+
+static u64 update_triggers(struct psi_group *group, u64 now)
+{
+	struct psi_trigger *t;
+	bool new_stall = false;
+	u64 *total = group->total[PSI_POLL];
+
+	/*
+	 * On subsequent updates, calculate growth deltas and let
+	 * watchers know when their specified thresholds are exceeded.
+	 */
+	list_for_each_entry(t, &group->triggers, node) {
+		u64 growth;
+
+		/* Check for stall activity */
+		if (group->polling_total[t->state] == total[t->state])
+			continue;
+
+		/*
+		 * Multiple triggers might be looking at the same state,
+		 * remember to update group->polling_total[] once we've
+		 * been through all of them. Also remember to extend the
+		 * polling time if we see new stall activity.
+		 */
+		new_stall = true;
+
+		/* Calculate growth since last update */
+		growth = window_update(&t->win, now, total[t->state]);
+		if (growth < t->threshold)
+			continue;
+
+		/* Limit event signaling to once per window */
+		if (now < t->last_event_time + t->win.size)
+			continue;
+
+		/* Generate an event */
+		if (cmpxchg(&t->event, 0, 1) == 0)
+			wake_up_interruptible(&t->event_wait);
+		t->last_event_time = now;
+	}
+
+	if (new_stall)
+		memcpy(group->polling_total, total,
+				sizeof(group->polling_total));
+
+	return now + group->poll_min_period;
+}
+
+/*
+ * Schedule polling if it's not already scheduled. It's safe to call even from
+ * hotpath because even though kthread_queue_delayed_work takes worker->lock
+ * spinlock that spinlock is never contended due to poll_scheduled atomic
+ * preventing such competition.
+ */
+static void psi_schedule_poll_work(struct psi_group *group, unsigned long delay)
+{
+	struct kthread_worker *kworker;
+
+	/* Do not reschedule if already scheduled */
+	if (atomic_cmpxchg(&group->poll_scheduled, 0, 1) != 0)
+		return;
+
+	rcu_read_lock();
+
+	kworker = rcu_dereference(group->poll_kworker);
+	/*
+	 * kworker might be NULL in case psi_trigger_destroy races with
+	 * psi_task_change (hotpath) which can't use locks
+	 */
+	if (likely(kworker))
+		kthread_queue_delayed_work(kworker, &group->poll_work, delay);
+	else
+		atomic_set(&group->poll_scheduled, 0);
+
+	rcu_read_unlock();
+}
+
+static void psi_poll_work(struct kthread_work *work)
+{
+	struct kthread_delayed_work *dwork;
+	struct psi_group *group;
+	u32 changed_states;
+	u64 now;
+
+	dwork = container_of(work, struct kthread_delayed_work, work);
+	group = container_of(dwork, struct psi_group, poll_work);
+
+	atomic_set(&group->poll_scheduled, 0);
+
+	mutex_lock(&group->trigger_lock);
+
+	now = sched_clock();
+
+	collect_percpu_times(group, PSI_POLL, &changed_states);
+
+	if (changed_states & group->poll_states) {
+		/* Initialize trigger windows when entering polling mode */
+		if (now > group->polling_until)
+			init_triggers(group, now);
+
+		/*
+		 * Keep the monitor active for at least the duration of the
+		 * minimum tracking window as long as monitor states are
+		 * changing.
+		 */
+		group->polling_until = now +
+			group->poll_min_period * UPDATES_PER_WINDOW;
+	}
+
+	if (now > group->polling_until) {
+		group->polling_next_update = ULLONG_MAX;
+		goto out;
+	}
+
+	if (now >= group->polling_next_update)
+		group->polling_next_update = update_triggers(group, now);
+
+	psi_schedule_poll_work(group,
+		nsecs_to_jiffies(group->polling_next_update - now) + 1);
+
+out:
+	mutex_unlock(&group->trigger_lock);
+}
+
 static void record_times(struct psi_group_cpu *groupc, int cpu,
 			 bool memstall_tick)
 {
@@ -460,8 +668,8 @@ static void record_times(struct psi_group_cpu *groupc, int cpu,
 		groupc->times[PSI_NONIDLE] += delta;
 }
 
-static void psi_group_change(struct psi_group *group, int cpu,
-			     unsigned int clear, unsigned int set)
+static u32 psi_group_change(struct psi_group *group, int cpu,
+			    unsigned int clear, unsigned int set)
 {
 	struct psi_group_cpu *groupc;
 	unsigned int t, m;
@@ -507,6 +715,8 @@ static void psi_group_change(struct psi_group *group, int cpu,
 	groupc->state_mask = state_mask;
 
 	write_seqcount_end(&groupc->seq);
+
+	return state_mask;
 }
 
 static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
@@ -567,7 +777,11 @@ void psi_task_change(struct task_struct *task, int clear, int set)
 		wake_clock = false;
 
 	while ((group = iterate_groups(task, &iter))) {
-		psi_group_change(group, cpu, clear, set);
+		u32 state_mask = psi_group_change(group, cpu, clear, set);
+
+		if (state_mask & group->poll_states)
+			psi_schedule_poll_work(group, 1);
+
 		if (wake_clock && !delayed_work_pending(&group->avgs_work))
 			schedule_delayed_work(&group->avgs_work, PSI_FREQ);
 	}
@@ -668,6 +882,8 @@ void psi_cgroup_free(struct cgroup *cgroup)
 
 	cancel_delayed_work_sync(&cgroup->psi.avgs_work);
 	free_percpu(cgroup->psi.pcpu);
+	/* All triggers must be removed by now */
+	WARN_ONCE(cgroup->psi.poll_states, "psi: trigger leak\n");
 }
 
 /**
@@ -731,7 +947,7 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 	/* Update averages before reporting them */
 	mutex_lock(&group->avgs_lock);
 	now = sched_clock();
-	collect_percpu_times(group, NULL);
+	collect_percpu_times(group, PSI_AVGS, NULL);
 	if (now >= group->avg_next_update)
 		group->avg_next_update = update_averages(group, now);
 	mutex_unlock(&group->avgs_lock);
@@ -743,7 +959,8 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 
 		for (w = 0; w < 3; w++)
 			avg[w] = group->avg[res * 2 + full][w];
-		total = div_u64(group->total[res * 2 + full], NSEC_PER_USEC);
+		total = div_u64(group->total[PSI_AVGS][res * 2 + full],
+				NSEC_PER_USEC);
 
 		seq_printf(m, "%s avg10=%lu.%02lu avg60=%lu.%02lu avg300=%lu.%02lu total=%llu\n",
 			   full ? "full" : "some",
@@ -786,25 +1003,270 @@ static int psi_cpu_open(struct inode *inode, struct file *file)
 	return single_open(file, psi_cpu_show, NULL);
 }
 
+struct psi_trigger *psi_trigger_create(struct psi_group *group,
+			char *buf, size_t nbytes, enum psi_res res)
+{
+	struct psi_trigger *t;
+	enum psi_states state;
+	u32 threshold_us;
+	u32 window_us;
+
+	if (static_branch_likely(&psi_disabled))
+		return ERR_PTR(-EOPNOTSUPP);
+
+	if (sscanf(buf, "some %u %u", &threshold_us, &window_us) == 2)
+		state = PSI_IO_SOME + res * 2;
+	else if (sscanf(buf, "full %u %u", &threshold_us, &window_us) == 2)
+		state = PSI_IO_FULL + res * 2;
+	else
+		return ERR_PTR(-EINVAL);
+
+	if (state >= PSI_NONIDLE)
+		return ERR_PTR(-EINVAL);
+
+	if (window_us < WINDOW_MIN_US ||
+		window_us > WINDOW_MAX_US)
+		return ERR_PTR(-EINVAL);
+
+	/* Check threshold */
+	if (threshold_us == 0 || threshold_us > window_us)
+		return ERR_PTR(-EINVAL);
+
+	t = kmalloc(sizeof(*t), GFP_KERNEL);
+	if (!t)
+		return ERR_PTR(-ENOMEM);
+
+	t->group = group;
+	t->state = state;
+	t->threshold = threshold_us * NSEC_PER_USEC;
+	t->win.size = window_us * NSEC_PER_USEC;
+	window_reset(&t->win, 0, 0, 0);
+
+	t->event = 0;
+	t->last_event_time = 0;
+	init_waitqueue_head(&t->event_wait);
+	kref_init(&t->refcount);
+
+	mutex_lock(&group->trigger_lock);
+
+	if (!rcu_access_pointer(group->poll_kworker)) {
+		struct sched_param param = {
+			.sched_priority = MAX_RT_PRIO - 1,
+		};
+		struct kthread_worker *kworker;
+
+		kworker = kthread_create_worker(0, "psimon");
+		if (IS_ERR(kworker)) {
+			kfree(t);
+			mutex_unlock(&group->trigger_lock);
+			return ERR_CAST(kworker);
+		}
+		sched_setscheduler(kworker->task, SCHED_FIFO, &param);
+		kthread_init_delayed_work(&group->poll_work,
+				psi_poll_work);
+		rcu_assign_pointer(group->poll_kworker, kworker);
+	}
+
+	list_add(&t->node, &group->triggers);
+	group->poll_min_period = min(group->poll_min_period,
+		div_u64(t->win.size, UPDATES_PER_WINDOW));
+	group->nr_triggers[t->state]++;
+	group->poll_states |= (1 << t->state);
+
+	mutex_unlock(&group->trigger_lock);
+
+	return t;
+}
+
+static void psi_trigger_destroy(struct kref *ref)
+{
+	struct psi_trigger *t = container_of(ref, struct psi_trigger, refcount);
+	struct psi_group *group = t->group;
+	struct kthread_worker *kworker_to_destroy = NULL;
+
+	if (static_branch_likely(&psi_disabled))
+		return;
+
+	/*
+	 * Wakeup waiters to stop polling. Can happen if cgroup is deleted
+	 * from under a polling process.
+	 */
+	wake_up_interruptible(&t->event_wait);
+
+	mutex_lock(&group->trigger_lock);
+
+	if (!list_empty(&t->node)) {
+		struct psi_trigger *tmp;
+		u64 period = ULLONG_MAX;
+
+		list_del(&t->node);
+		group->nr_triggers[t->state]--;
+		if (!group->nr_triggers[t->state])
+			group->poll_states &= ~(1 << t->state);
+		/* reset min update period for the remaining triggers */
+		list_for_each_entry(tmp, &group->triggers, node)
+			period = min(period, div_u64(tmp->win.size,
+					UPDATES_PER_WINDOW));
+		group->poll_min_period = period;
+		/* Destroy poll_kworker when the last trigger is destroyed */
+		if (group->poll_states == 0) {
+			group->polling_until = 0;
+			kworker_to_destroy = rcu_dereference_protected(
+					group->poll_kworker,
+					lockdep_is_held(&group->trigger_lock));
+			rcu_assign_pointer(group->poll_kworker, NULL);
+		}
+	}
+
+	mutex_unlock(&group->trigger_lock);
+
+	/*
+	 * Wait for both *trigger_ptr from psi_trigger_replace and
+	 * poll_kworker RCUs to complete their read-side critical sections
+	 * before destroying the trigger and optionally the poll_kworker
+	 */
+	synchronize_rcu();
+	/*
+	 * Destroy the kworker after releasing trigger_lock to prevent a
+	 * deadlock while waiting for psi_poll_work to acquire trigger_lock
+	 */
+	if (kworker_to_destroy) {
+		kthread_cancel_delayed_work_sync(&group->poll_work);
+		kthread_destroy_worker(kworker_to_destroy);
+	}
+	kfree(t);
+}
+
+void psi_trigger_replace(void **trigger_ptr, struct psi_trigger *new)
+{
+	struct psi_trigger *old = *trigger_ptr;
+
+	if (static_branch_likely(&psi_disabled))
+		return;
+
+	rcu_assign_pointer(*trigger_ptr, new);
+	if (old)
+		kref_put(&old->refcount, psi_trigger_destroy);
+}
+
+__poll_t psi_trigger_poll(void **trigger_ptr,
+				struct file *file, poll_table *wait)
+{
+	__poll_t ret = DEFAULT_POLLMASK;
+	struct psi_trigger *t;
+
+	if (static_branch_likely(&psi_disabled))
+		return DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+
+	rcu_read_lock();
+
+	t = rcu_dereference(*(void __rcu __force **)trigger_ptr);
+	if (!t) {
+		rcu_read_unlock();
+		return DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+	}
+	kref_get(&t->refcount);
+
+	rcu_read_unlock();
+
+	poll_wait(file, &t->event_wait, wait);
+
+	if (cmpxchg(&t->event, 1, 0) == 1)
+		ret |= EPOLLPRI;
+
+	kref_put(&t->refcount, psi_trigger_destroy);
+
+	return ret;
+}
+
+static ssize_t psi_write(struct file *file, const char __user *user_buf,
+			 size_t nbytes, enum psi_res res)
+{
+	char buf[32];
+	size_t buf_size;
+	struct seq_file *seq;
+	struct psi_trigger *new;
+
+	if (static_branch_likely(&psi_disabled))
+		return -EOPNOTSUPP;
+
+	buf_size = min(nbytes, (sizeof(buf) - 1));
+	if (copy_from_user(buf, user_buf, buf_size))
+		return -EFAULT;
+
+	buf[buf_size - 1] = '\0';
+
+	new = psi_trigger_create(&psi_system, buf, nbytes, res);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+
+	seq = file->private_data;
+	/* Take seq->lock to protect seq->private from concurrent writes */
+	mutex_lock(&seq->lock);
+	psi_trigger_replace(&seq->private, new);
+	mutex_unlock(&seq->lock);
+
+	return nbytes;
+}
+
+static ssize_t psi_io_write(struct file *file, const char __user *user_buf,
+			    size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_IO);
+}
+
+static ssize_t psi_memory_write(struct file *file, const char __user *user_buf,
+				size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_MEM);
+}
+
+static ssize_t psi_cpu_write(struct file *file, const char __user *user_buf,
+			     size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_CPU);
+}
+
+static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
+{
+	struct seq_file *seq = file->private_data;
+
+	return psi_trigger_poll(&seq->private, file, wait);
+}
+
+static int psi_fop_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+
+	psi_trigger_replace(&seq->private, NULL);
+	return single_release(inode, file);
+}
+
 static const struct file_operations psi_io_fops = {
 	.open           = psi_io_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_io_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static const struct file_operations psi_memory_fops = {
 	.open           = psi_memory_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_memory_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static const struct file_operations psi_cpu_fops = {
 	.open           = psi_cpu_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_cpu_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static int __init psi_proc_init(void)
-- 
2.21.0.225.g810b269d1ac-goog

