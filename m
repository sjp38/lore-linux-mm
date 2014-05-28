Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id AE28E6B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 12:19:55 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id hy4so12390583vcb.25
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:19:55 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id aq3si10898958vdc.7.2014.05.28.09.19.54
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 09:19:54 -0700 (PDT)
Date: Wed, 28 May 2014 11:19:49 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V5
In-Reply-To: <20140528152107.GB6507@localhost.localdomain>
Message-ID: <alpine.DEB.2.10.1405281110210.22514@gentwo.org>
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org> <20140528152107.GB6507@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Wed, 28 May 2014, Frederic Weisbecker wrote:

> On Mon, May 12, 2014 at 01:18:10PM -0500, Christoph Lameter wrote:
> >  #ifdef CONFIG_SMP
> >  static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
> >  int sysctl_stat_interval __read_mostly = HZ;
> > +static DECLARE_BITMAP(cpu_stat_off_bits, CONFIG_NR_CPUS) __read_mostly;
> > +const struct cpumask *const cpu_stat_off = to_cpumask(cpu_stat_off_bits);
> > +EXPORT_SYMBOL(cpu_stat_off);
>
> Is there no way to make it a cpumask_var_t, and allocate it from
> start_shepherd_timer()?
>
> This should really take less space overall.

This was taken from the way things work with the other cpumasks in
linux/kernel/cpu.c. Its compatible with the way done there and allows
also the write protection of the cpumask outside of vmstat.c

> > +	schedule_delayed_work(this_cpu_ptr(&vmstat_work),
> > +		__round_jiffies_relative(sysctl_stat_interval,
> > +		HOUSEKEEPING_CPU));
>
> Maybe you can just make the shepherd work unbound and let bind it from userspace
> once we have the workqueue user affinity patchset in.

Yes that is what V5 should have done. Looks like the final version was not
posted. Sigh. The correct patch follows this message and it no longer uses
HOUSEKEEPING_CPU.


> OTOH, it means you need to have a vmstat_update work on the housekeeping CPU as well.

Well the vnstat_udpate may not be needed on the processor where the
shepherd runs so it may save something.
