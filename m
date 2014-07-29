Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E114D6B003A
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 08:23:32 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so8692837wgh.8
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 05:23:30 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id bh9si39960308wjb.104.2014.07.29.05.23.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jul 2014 05:23:19 -0700 (PDT)
Date: Tue, 29 Jul 2014 14:23:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: vmstat: On demand vmstat workers V8
Message-ID: <20140729122303.GA3935@laptop>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
 <53D31101.8000107@oracle.com>
 <alpine.DEB.2.11.1407281353450.15405@gentwo.org>
 <20140729075637.GA19379@twins.programming.kicks-ass.net>
 <20140729120525.GA28366@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140729120525.GA28366@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org

On Tue, Jul 29, 2014 at 08:05:25AM -0400, Tejun Heo wrote:
> On Tue, Jul 29, 2014 at 09:56:37AM +0200, Peter Zijlstra wrote:
> > On Mon, Jul 28, 2014 at 01:55:17PM -0500, Christoph Lameter wrote:
> > > On Fri, 25 Jul 2014, Sasha Levin wrote:
> > > 
> > > > This patch doesn't interact well with my fuzzing setup. I'm seeing
> > > > the following:
> > > >
> > > > [  490.446927] BUG: using __this_cpu_read() in preemptible [00000000] code: kworker/16:1/7368
> > > > [  490.447909] caller is __this_cpu_preempt_check+0x13/0x20
> > > 
> > > __this_cpu_read() from vmstat_update is only called from a kworker that
> > > is bound to a single cpu. A false positive?
> > 
> > kworkers are never guaranteed to be so, its a 'feature' :/
> 
> It's because we don't distinguish work items which are per-cpu for
> optimization and per-cpu for correctness and can't automatically flush
> / cancel / block per-cpu work items when a cpu goes down.  I like the
> idea of distingushing them but it's gonna take a lot of auditing.

Just force flush on unplug and fix those that complain. No auditing
needed for that.

> Any work item usage which requires per-cpu for correctness should
> implement cpu down hook to flush in-flight work items and block
> further issuance.  This hasn't changed from the beginning and was
> necessary even before cmwq.

I think before cmwq we'd run into the broken affinity warning in the
scheduler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
