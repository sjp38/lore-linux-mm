Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id F00696B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 09:12:31 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id j7so9258644qaq.0
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 06:12:31 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id b30si37668173qgf.107.2014.07.29.06.12.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 06:12:30 -0700 (PDT)
Received: by mail-qg0-f44.google.com with SMTP id e89so10332504qgf.17
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 06:12:30 -0700 (PDT)
Date: Tue, 29 Jul 2014 09:12:26 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: vmstat: On demand vmstat workers V8
Message-ID: <20140729131226.GS7462@htj.dyndns.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
 <53D31101.8000107@oracle.com>
 <alpine.DEB.2.11.1407281353450.15405@gentwo.org>
 <20140729075637.GA19379@twins.programming.kicks-ass.net>
 <20140729120525.GA28366@mtj.dyndns.org>
 <20140729122303.GA3935@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140729122303.GA3935@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

(cc'ing Lai)

Hello,

On Tue, Jul 29, 2014 at 02:23:03PM +0200, Peter Zijlstra wrote:
> > It's because we don't distinguish work items which are per-cpu for
> > optimization and per-cpu for correctness and can't automatically flush
> > / cancel / block per-cpu work items when a cpu goes down.  I like the
> > idea of distingushing them but it's gonna take a lot of auditing.
> 
> Just force flush on unplug and fix those that complain. No auditing
> needed for that.

I'm not sure that's a viable way forward.  It's not like we can
readily trigger the problematic cases which can lead to long pauses
during cpu down.  Besides, we need the distinction at the API level,
which is the whole point of this.  The best way probably is converting
all the correctness ones (these are the minorities) over to
queue_work_on() so that the per-cpu requirement is explicit.

> > Any work item usage which requires per-cpu for correctness should
> > implement cpu down hook to flush in-flight work items and block
> > further issuance.  This hasn't changed from the beginning and was
> > necessary even before cmwq.
> 
> I think before cmwq we'd run into the broken affinity warning in the
> scheduler.

That and work items silently not executed if queued on a downed cpu.
IIRC, we also had quite a few broken ones which were per-cpu but w/o
cpu down handling which just happened to work most of the time because
queueing itself was per-cpu in most cases and we didn't do cpu
on/offlining as often back then.  During cmwq conversion, I just
allowed them as I didn't want to add cpu down hooks for all of the
many per-cpu workqueue usages.  The lack of the distinction between
the two sets has always been there.

I agree this can be improved, but at least for now, please add cpu
down hooks.  We need them right now and they'll be helpful when later
separating out the correctness ones.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
