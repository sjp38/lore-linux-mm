Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77C4CC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:35:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AC6720856
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:35:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="BbU4HeLE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AC6720856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABB9A8E0002; Tue, 29 Jan 2019 13:35:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1CB78E0001; Tue, 29 Jan 2019 13:35:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 898EB8E0002; Tue, 29 Jan 2019 13:35:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52D648E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:35:40 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id o200so10678373ybc.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:35:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FTv/ayI6eNRu9V59TgMNsy0y0Pdy4VkeVoplB/wraOE=;
        b=jF2r6XhtF+xEul6nefdOU5Rv4L48daiZW50QL/0CMk+8y89tNHjMUGa74QVQS7hcat
         oU8ZJUqL3eQ7lnrN95Rg+a/ihJgzjKuv6/HlUyxlW6gHprWAGLfFjJqkxQjK2wxBLPsX
         yUyS+GeWUBvtSOWRn8MWNt32qTsWdKZ9EmgVTnyRUQs0lCKHKwLD2HGCsnlJ2iB4nIeg
         3qD9Agc92VoH0gcZPV2rFAVoF87BL3rqtQUUfWajreQx8dPHrJVjNlG/Co8jSCT15kpA
         GjyA8VBlCajMneuTdEY0JXomO9WlFN1tCdwwl+HmQPKQxBcoX/s9EzDhVjpTKoJ5OY8v
         PSDw==
X-Gm-Message-State: AHQUAua1kh1v9NHp5g6ssWByfSx4K8NJPS3rrXvrOne2ZAfA3goSJWH8
	0WfNJir0sXSIwiMFy/FKuQfJQ8TDvQvdxjJOKEtb+oujER4to/06J7ZmdPRYVgMgmrjMZhnZGC7
	R5y+fmXP2XpGBScchUahR5LS1AmO4JalDPryEsB7Vf+8chpVj91S5RrhOB5OYVJJqKiiA10EuFY
	wU7KMIaN2wKTpIRJlnAb9hr4z9N7G4x/j9TI2LcvnV+MVtWJgC2ulA1m8LZsQqH3RUZyUAvUdQ2
	ve8zx/gQ+MyzY5SboYtrcSkqMmVtB3EN+DfCXsEBbxCRyaF5FcN1+pxnLCJAxWKh/78Tru3yayW
	1PbcQPw1JMsnX58agyl7XE+JwThtsZBsjeSm/llPMg+1QVlts7hI0TyXc/N92GCTp5G6z8PQSno
	3
X-Received: by 2002:a25:9944:: with SMTP id n4mr5162506ybo.84.1548786939862;
        Tue, 29 Jan 2019 10:35:39 -0800 (PST)
X-Received: by 2002:a25:9944:: with SMTP id n4mr5162429ybo.84.1548786938374;
        Tue, 29 Jan 2019 10:35:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786938; cv=none;
        d=google.com; s=arc-20160816;
        b=juLSCMDJJZ0W4VWZl1b0FcFuDS2SNfZPFr79LPBLFMS9RDc1a39D1V1YrG1WpT7caH
         zUsAASwUAAu61RX/uXloUBb93GPLrUILFXvkuCrrhqTFpeCNBw+X/Rlrv59YeK6rMq2X
         R5gytbLTIYEcDxNEkvCqP1L8HkWEnnYpsMmno3n/MYEZw4ai4IOaESjDOV8mNH9oFmdG
         iSukgsP+vIKo2lNkb0uOUjK7VpIjVPcsW7Q8atWOEzWOQ8P3x6EgdpYx7ClQdPkTPedq
         QbCmDHFI6O52qEZKpkp2SUPhsjGdaU4i3k0gPrp4nRNAhCnyvyNWRp//CA2MELh4mtfD
         gq2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FTv/ayI6eNRu9V59TgMNsy0y0Pdy4VkeVoplB/wraOE=;
        b=owLl1CVrWXP56S/xciSK9Wc821X6BJe1VAdFJEerzWD3AP4XL5w5cgbjzAKRr+iK28
         PsJ6DjLoRZbL5F3ElYx5zcIFZ9J3ZCRkA8Z4WeRQ7VT/ohJ6MkJo9SKRIJPtSSui0SHw
         t/yPBEIBfOaqekZKwuzoneDWKlAg+nykM+/Amnl7vkTuZwxsMHct3W9hJwEDkmpQjzcE
         j7WqTlDX/DI9XaN/q256YAp6R0RfvZu+Hg5gXYMh7HBhrTbo0R3csHgdxA9NknOmNz6R
         CsZLNVHKy3xaaAKOSvYQoZySohQ6KZ1jxRL5TC6rH3Bf3Vw9rXLbfpSzaoMGYMQa/9w1
         7U6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=BbU4HeLE;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor16072594ybg.187.2019.01.29.10.35.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:35:38 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=BbU4HeLE;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FTv/ayI6eNRu9V59TgMNsy0y0Pdy4VkeVoplB/wraOE=;
        b=BbU4HeLEGzf5EgjgZ3+Iqx4Yxa8riC1V+8GhlnLnbuEjbEBSmUHXArX0d5/+nSF3we
         8J+kefO1e3dc4M64/cXl90OL9BjQzjAtd0bgLVnxtwIq/mFZ0SimTJsykuIKKlsc8Cyu
         1rGT9omA2Wl3AgBiS2mWLZnkxL1bSCZm/oW+v6iLx1biir6x7NPhFG1DLFRo5DI3bH72
         4wav23ri+61Ie7zxGHWhxSCJyeuNSyY6SzShzEGFWnerkgrToUI3JL7ZQWBHXBoPyyuA
         JLx8Hv7LFNSJkxCKgqDdNPd4rrGown3ozJCI0WdLNLAnhYM4tsVeFXb2nO5Tops8jiwJ
         Rw4A==
X-Google-Smtp-Source: ALg8bN4wF13z1kBa+gPhI4fAKj4abbx6h9bme5Z9tivunJ4hJTnfr16r4q0FPv8qyNxhjhw+J8X9qw==
X-Received: by 2002:a25:3292:: with SMTP id y140mr16143456yby.45.1548786937499;
        Tue, 29 Jan 2019 10:35:37 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:1d25])
        by smtp.gmail.com with ESMTPSA id x133sm18913944ywg.57.2019.01.29.10.35.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 10:35:36 -0800 (PST)
Date: Tue, 29 Jan 2019 13:35:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>, gregkh@linuxfoundation.org,
	tj@kernel.org, lizefan@huawei.com, axboe@kernel.dk,
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com,
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net,
	cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
Message-ID: <20190129183535.GB7871@cmpxchg.org>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-6-surenb@google.com>
 <20190128235358.GA211479@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128235358.GA211479@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Minchan,

good to see your name on the lists again :)

On Tue, Jan 29, 2019 at 08:53:58AM +0900, Minchan Kim wrote:
> On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> > @@ -68,6 +69,50 @@ struct psi_group_cpu {
> >  	u32 times_prev[NR_PSI_STATES] ____cacheline_aligned_in_smp;
> >  };
> >  
> > +/* PSI growth tracking window */
> > +struct psi_window {
> > +	/* Window size in ns */
> > +	u64 size;
> 
> As rest of field are time, how about "interval" instead of size?

If it were "size" on its own, I would agree, but "window size" is an
existing term that works pretty well here. "window interval" wouldn't.

> > +	/* Start time of the current window in ns */
> > +	u64 start_time;
> > +
> > +	/* Value at the start of the window */
> > +	u64 start_value;
> 
> "value" is rather vague. starting_stall?

I'm not a fan of using stall here, because it reads like an event,
when it's really a time interval we're interested in.

For an abstraction that samples time intervals, value seems like a
pretty good, straight-forward name...

> > +
> > +	/* Value growth per previous window(s) */
> > +	u64 per_win_growth;
> 
> Rather than per, prev would be more meaninful, I think.
> How about prev_win_stall?

Agreed on the "per", but still not loving the stall. How about
prev_delta? prev_growth?

> > +struct psi_trigger {
> > +	/* PSI state being monitored by the trigger */
> > +	enum psi_states state;
> > +
> > +	/* User-spacified threshold in ns */
> > +	u64 threshold;
> > +
> > +	/* List node inside triggers list */
> > +	struct list_head node;
> > +
> > +	/* Backpointer needed during trigger destruction */
> > +	struct psi_group *group;
> > +
> > +	/* Wait queue for polling */
> > +	wait_queue_head_t event_wait;
> > +
> > +	/* Pending event flag */
> > +	int event;
> > +
> > +	/* Tracking window */
> > +	struct psi_window win;
> > +
> > +	/*
> > +	 * Time last event was generated. Used for rate-limiting
> > +	 * events to one per window
> > +	 */
> > +	u64 last_event_time;
> > +};
> > +
> >  struct psi_group {
> >  	/* Protects data used by the aggregator */
> >  	struct mutex update_lock;
> > @@ -75,6 +120,8 @@ struct psi_group {
> >  	/* Per-cpu task state & time tracking */
> >  	struct psi_group_cpu __percpu *pcpu;
> >  
> > +	/* Periodic work control */
> > +	atomic_t polling;
> >  	struct delayed_work clock_work;
> >  
> >  	/* Total stall times observed */
> > @@ -85,6 +132,18 @@ struct psi_group {
> >  	u64 avg_last_update;
> >  	u64 avg_next_update;
> >  	unsigned long avg[NR_PSI_STATES - 1][3];
> > +
> > +	/* Configured polling triggers */
> > +	struct list_head triggers;
> > +	u32 nr_triggers[NR_PSI_STATES - 1];
> > +	u32 trigger_mask;
> 
> This is a state we have an interest.
> How about trigger_states?

Sounds good to me, I'd also switch change_mask below to
changed_states:

	if (changed_states & trigger_states)
		/* engage! */

[ After reading the rest, I see Minchan proposed the same. ]

> > +	u64 trigger_min_period;
> > +
> > +	/* Polling state */
> > +	/* Total stall times at the start of monitor activation */
> > +	u64 polling_total[NR_PSI_STATES - 1];
> > +	u64 polling_next_update;
> > +	u64 polling_until;
> >  };
> >  
> >  #else /* CONFIG_PSI */
> > diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
> > index e8cd12c6a553..de3ac22a5e23 100644
> > --- a/kernel/cgroup/cgroup.c
> > +++ b/kernel/cgroup/cgroup.c
> > @@ -3464,7 +3464,101 @@ static int cgroup_cpu_pressure_show(struct seq_file *seq, void *v)
> >  {
> >  	return psi_show(seq, &seq_css(seq)->cgroup->psi, PSI_CPU);
> >  }
> > -#endif
> > +
> > +static ssize_t cgroup_pressure_write(struct kernfs_open_file *of, char *buf,
> > +					  size_t nbytes, enum psi_res res)
> > +{
> > +	enum psi_states state;
> > +	struct psi_trigger *old;
> > +	struct psi_trigger *new;
> > +	struct cgroup *cgrp;
> > +	u32 threshold_us;
> > +	u32 win_sz_us;
> 
> window_us?

We don't really encode units in variables in the rest of the code,
maybe we can drop it here as well.

Btw, it looks like the original reason for splitting up trigger_parse
and trigger_create seems gone from the code. Can we merge them again
and keep all those details out of the filesystem ->write methods?

	new = psi_trigger_create(group, buf, nbytes, res);

> > +	ssize_t ret;
> > +
> > +	cgrp = cgroup_kn_lock_live(of->kn, false);
> > +	if (!cgrp)
> > +		return -ENODEV;
> > +
> > +	cgroup_get(cgrp);
> > +	cgroup_kn_unlock(of->kn);
> > +
> > +	ret = psi_trigger_parse(buf, nbytes, res,
> > +				&state, &threshold_us, &win_sz_us);
> > +	if (ret) {
> > +		cgroup_put(cgrp);
> > +		return ret;
> > +	}
> > +
> > +	new = psi_trigger_create(&cgrp->psi,
> > +				state, threshold_us, win_sz_us);
> > +	if (IS_ERR(new)) {
> > +		cgroup_put(cgrp);
> > +		return PTR_ERR(new);
> > +	}
> > +
> > +	old = of->priv;
> > +	rcu_assign_pointer(of->priv, new);
> > +	if (old) {
> > +		synchronize_rcu();
> > +		psi_trigger_destroy(old);
> > +	}
> > +
> > +	cgroup_put(cgrp);
> > +
> > +	return nbytes;
> > +}
> > +
> > +static ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
> > +					  char *buf, size_t nbytes,
> > +					  loff_t off)
> > +{
> > +	return cgroup_pressure_write(of, buf, nbytes, PSI_IO);
> > +}
> > +
> > +static ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
> > +					  char *buf, size_t nbytes,
> > +					  loff_t off)
> > +{
> > +	return cgroup_pressure_write(of, buf, nbytes, PSI_MEM);
> > +}
> > +
> > +static ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
> > +					  char *buf, size_t nbytes,
> > +					  loff_t off)
> > +{
> > +	return cgroup_pressure_write(of, buf, nbytes, PSI_CPU);
> > +}
> > +
> > +static __poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
> > +					  poll_table *pt)
> > +{
> > +	struct psi_trigger *t;
> > +	__poll_t ret;
> > +
> > +	rcu_read_lock();
> > +	t = rcu_dereference(of->priv);
> > +	if (t)
> > +		ret = psi_trigger_poll(t, of->file, pt);
> > +	else
> > +		ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
> > +	rcu_read_unlock();
> > +
> > +	return ret;
> > +}
> > +
> > +static void cgroup_pressure_release(struct kernfs_open_file *of)
> > +{
> > +	struct psi_trigger *t = of->priv;
> > +
> > +	if (!t)
> > +		return;
> > +
> > +	rcu_assign_pointer(of->priv, NULL);
> > +	synchronize_rcu();
> > +	psi_trigger_destroy(t);
> > +}
> > +#endif /* CONFIG_PSI */
> >  
> >  static int cgroup_file_open(struct kernfs_open_file *of)
> >  {
> > @@ -4619,18 +4713,27 @@ static struct cftype cgroup_base_files[] = {
> >  		.name = "io.pressure",
> >  		.flags = CFTYPE_NOT_ON_ROOT,
> >  		.seq_show = cgroup_io_pressure_show,
> > +		.write = cgroup_io_pressure_write,
> > +		.poll = cgroup_pressure_poll,
> > +		.release = cgroup_pressure_release,
> >  	},
> >  	{
> >  		.name = "memory.pressure",
> >  		.flags = CFTYPE_NOT_ON_ROOT,
> >  		.seq_show = cgroup_memory_pressure_show,
> > +		.write = cgroup_memory_pressure_write,
> > +		.poll = cgroup_pressure_poll,
> > +		.release = cgroup_pressure_release,
> >  	},
> >  	{
> >  		.name = "cpu.pressure",
> >  		.flags = CFTYPE_NOT_ON_ROOT,
> >  		.seq_show = cgroup_cpu_pressure_show,
> > +		.write = cgroup_cpu_pressure_write,
> > +		.poll = cgroup_pressure_poll,
> > +		.release = cgroup_pressure_release,
> >  	},
> > -#endif
> > +#endif /* CONFIG_PSI */
> >  	{ }	/* terminate */
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
> > -#define PSI_FREQ	(2*HZ+1)	/* 2 sec intervals */
> > +#define PSI_FREQ	(2*HZ+1UL)	/* 2 sec intervals */
> >  #define EXP_10s		1677		/* 1/exp(2s/10s) as fixed-point */
> >  #define EXP_60s		1981		/* 1/exp(2s/60s) */
> >  #define EXP_300s	2034		/* 1/exp(2s/300s) */
> >  
> > +/* PSI trigger definitions */
> > +#define PSI_TRIG_MIN_WIN_US 500000		/* Min window size is 500ms */
> > +#define PSI_TRIG_MAX_WIN_US 10000000	/* Max window size is 10s */
> > +#define PSI_TRIG_UPDATES_PER_WIN 10		/* 10 updates per window */
> 
> To me, it's rather long.
> How about WINDOW_MIN_US, WINDOW_MAX_US, UPDATES_PER_WINDOW?

Sounds good to me too. I'm just ambivalent on the _US suffix. Dealer's
choice, though.

> > +
> >  /* Sampling frequency in nanoseconds */
> >  static u64 psi_period __read_mostly;
> >  
> > @@ -173,8 +186,17 @@ static void group_init(struct psi_group *group)
> >  	for_each_possible_cpu(cpu)
> >  		seqcount_init(&per_cpu_ptr(group->pcpu, cpu)->seq);
> >  	group->avg_next_update = sched_clock() + psi_period;
> > +	atomic_set(&group->polling, 0);
> >  	INIT_DELAYED_WORK(&group->clock_work, psi_update_work);
> >  	mutex_init(&group->update_lock);
> > +	/* Init trigger-related members */
> > +	INIT_LIST_HEAD(&group->triggers);
> > +	memset(group->nr_triggers, 0, sizeof(group->nr_triggers));
> > +	group->trigger_mask = 0;
> > +	group->trigger_min_period = U32_MAX;
> > +	memset(group->polling_total, 0, sizeof(group->polling_total));
> > +	group->polling_next_update = ULLONG_MAX;
> > +	group->polling_until = 0;
> >  }
> >  
> >  void __init psi_init(void)
> > @@ -209,10 +231,11 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
> >  	}
> >  }
> >  
> > -static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
> > +static u32 get_recent_times(struct psi_group *group, int cpu, u32 *times)
> 
> Rather awkward to return change_mask when we consider function name as
> get_recent_times It would be better to add additional parameter
> instead of return value.

Good suggestion, I have to agree this would be nicer.

> >  {
> >  	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
> >  	u64 now, state_start;
> > +	u32 change_mask = 0;
> >  	enum psi_states s;
> >  	unsigned int seq;
> >  	u32 state_mask;
> > @@ -245,7 +268,11 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
> >  		groupc->times_prev[s] = times[s];
> >  
> >  		times[s] = delta;
> > +		if (delta)
> > +			change_mask |= (1 << s);
> >  	}
> > +
> > +	return change_mask;
> >  }
> >  
> >  static void calc_avgs(unsigned long avg[3], int missed_periods,
> > @@ -268,17 +295,14 @@ static void calc_avgs(unsigned long avg[3], int missed_periods,
> >  	avg[2] = calc_load(avg[2], EXP_300s, pct);
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

I disagree on this one. collect_percpu_times() isn't too detailed of a
name, but it does reflect the complexity/cost of the function and the
structure that is being aggregated, which is a good thing.

But the return-by-parameter is a good idea.

> >  	u64 deltas[NR_PSI_STATES - 1] = { 0, };
> > -	unsigned long missed_periods = 0;
> >  	unsigned long nonidle_total = 0;
> > -	u64 now, expires, period;
> > +	u32 change_mask = 0;
> >  	int cpu;
> >  	int s;
> >  
> > -	mutex_lock(&group->update_lock);
> > -
> >  	/*
> >  	 * Collect the per-cpu time buckets and average them into a
> >  	 * single time sample that is normalized to wallclock time.
> > @@ -291,7 +315,7 @@ static bool update_stats(struct psi_group *group)
> >  		u32 times[NR_PSI_STATES];
> >  		u32 nonidle;
> >  
> > -		get_recent_times(group, cpu, times);
> > +		change_mask |= get_recent_times(group, cpu, times);
> >  
> >  		nonidle = nsecs_to_jiffies(times[PSI_NONIDLE]);
> >  		nonidle_total += nonidle;
> > @@ -316,11 +340,18 @@ static bool update_stats(struct psi_group *group)
> >  	for (s = 0; s < NR_PSI_STATES - 1; s++)
> >  		group->total[s] += div_u64(deltas[s], max(nonidle_total, 1UL));
> >  
> > +	return change_mask;
> > +}
> > +
> > +static u64 calculate_averages(struct psi_group *group, u64 now)
> 
>                                                               time?
> 
> The function name is still awkward to me.
> If someone see this function, he will expect return value as "average", not next_update.
> If we want to have next_update as return value, it would better to rename *update_avgs*.

update_averages() would be nice, agreed.

But I disagree on the now -> time. time is really vague - could be a
random timestamp or a period. We use "now" everywhere in this code to
mean the current time (cpu clock in cpu-local paths, sched clock for
global stuff), so let's keep it here as well.

> > +{
> > +	unsigned long missed_periods = 0;
> > +	u64 expires, period;
> > +	u64 avg_next_update;
> > +	int s;
> > +
> >  	/* avgX= */
> > -	now = sched_clock();
> >  	expires = group->avg_next_update;
> > -	if (now < expires)
> > -		goto out;
> >  	if (now - expires > psi_period)
> >  		missed_periods = div_u64(now - expires, psi_period);
> >  
> > @@ -331,7 +362,7 @@ static bool update_stats(struct psi_group *group)
> >  	 * But the deltas we sample out of the per-cpu buckets above
> >  	 * are based on the actual time elapsing between clock ticks.
> >  	 */
> > -	group->avg_next_update = expires + ((1 + missed_periods) * psi_period);
> > +	avg_next_update = expires + ((1 + missed_periods) * psi_period);
> >  	period = now - (group->avg_last_update + (missed_periods * psi_period));
> >  	group->avg_last_update = now;
> >  
> > @@ -361,20 +392,237 @@ static bool update_stats(struct psi_group *group)
> >  		group->avg_total[s] += sample;
> >  		calc_avgs(group->avg[s], missed_periods, sample, period);
> >  	}
> > -out:
> > -	mutex_unlock(&group->update_lock);
> > -	return nonidle_total;
> > +
> > +	return avg_next_update;
> > +}
> > +
> > +/* Trigger tracking window manupulations */
> > +static void window_init(struct psi_window *win, u64 now, u64 value)
> > +{
> > +	win->start_value = value;
> > +	win->start_time = now;
> > +	win->per_win_growth = 0;
> > +}
> > +
> > +/*
> > + * PSI growth tracking window update and growth calculation routine.
> 
> Let's add empty line here.

Agreed.

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

Disagreed on both :)

> > +{
> > +	u64 interval;
> 
> elapsed?

Hm, elapsed is a bit better, but how about period? We use that in the
averages code for the same functionality.

> > +	u64 growth;
> > +
> > +	interval = now - win->start_time;
> > +	growth = value - win->start_value;
> > +	/*
> > +	 * After each tracking window passes win->start_value and
> > +	 * win->start_time get reset and win->per_win_growth stores
> > +	 * the average per-window growth of the previous window.
> > +	 * win->per_win_growth is then used to interpolate additional
> > +	 * growth from the previous window assuming it was linear.
> > +	 */
> > +	if (interval > win->size) {
> > +		win->per_win_growth = growth;
> > +		win->start_value = value;
> > +		win->start_time = now;
> 
> We can use window_init via adding per_win_growth in the function
> parameter. Maybe, window_reset would be better function name.
> 
> > +	} else {
> > +		u32 unelapsed;
> 
> remaining? remained?

Yup, much better.

> > +
> > +		unelapsed = win->size - interval;
> > +		growth += div_u64(win->per_win_growth * unelapsed, win->size);
> > +	}
> > +
> > +	return growth;
> > +}
> > +
> > +static void init_triggers(struct psi_group *group, u64 now)
> > +{
> > +	struct psi_trigger *t;
> > +
> > +	list_for_each_entry(t, &group->triggers, node)
> > +		window_init(&t->win, now, group->total[t->state]);
> > +	memcpy(group->polling_total, group->total,
> > +		   sizeof(group->polling_total));
> > +	group->polling_next_update = now + group->trigger_min_period;
> > +}
> > +
> > +static u64 poll_triggers(struct psi_group *group, u64 now)
> 
> How about update_[poll|trigger]_stat?

update_triggers()? The signature already matches the update_averages()
one, so we might as well do the same thing there I guess.

> > +{
> > +	struct psi_trigger *t;
> > +	bool new_stall = false;
> > +
> > +	/*
> > +	 * On subsequent updates, calculate growth deltas and let
> > +	 * watchers know when their specified thresholds are exceeded.
> > +	 */
> > +	list_for_each_entry(t, &group->triggers, node) {
> > +		u64 growth;
> > +
> > +		/* Check for stall activity */
> > +		if (group->polling_total[t->state] == group->total[t->state])
> > +			continue;
> > +
> > +		/*
> > +		 * Multiple triggers might be looking at the same state,
> > +		 * remember to update group->polling_total[] once we've
> > +		 * been through all of them. Also remember to extend the
> > +		 * polling time if we see new stall activity.
> > +		 */
> > +		new_stall = true;
> > +
> > +		/* Calculate growth since last update */
> > +		growth = window_update(&t->win, now, group->total[t->state]);
> > +		if (growth < t->threshold)
> > +			continue;
> > +
> > +		/* Limit event signaling to once per window */
> > +		if (now < t->last_event_time + t->win.size)
> > +			continue;
> > +
> > +		/* Generate an event */
> > +		if (cmpxchg(&t->event, 0, 1) == 0)
> > +			wake_up_interruptible(&t->event_wait);
> > +		t->last_event_time = now;
> > +	}
> > +
> > +	if (new_stall) {
> > +		memcpy(group->polling_total, group->total,
> > +			   sizeof(group->polling_total));
> > +	}
> > +
> > +	return now + group->trigger_min_period;
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
> >  	struct delayed_work *dwork;
> >  	struct psi_group *group;
> > +	bool first_pass = true;
> > +	u64 next_update;
> > +	u32 change_mask;
> 
> How about [changed|updated]_states?

changed_states sounds good to me.

