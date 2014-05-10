Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4B16B0037
	for <linux-mm@kvack.org>; Sat, 10 May 2014 09:14:30 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so5090761wgg.12
        for <linux-mm@kvack.org>; Sat, 10 May 2014 06:14:29 -0700 (PDT)
Received: from mail-we0-x231.google.com (mail-we0-x231.google.com [2a00:1450:400c:c03::231])
        by mx.google.com with ESMTPS id fu6si839646wib.18.2014.05.10.06.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 May 2014 06:14:28 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id x48so4889730wes.8
        for <linux-mm@kvack.org>; Sat, 10 May 2014 06:14:28 -0700 (PDT)
Date: Sat, 10 May 2014 15:14:25 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: vmstat: On demand vmstat workers V4
Message-ID: <20140510131422.GA13660@localhost.localdomain>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org>
 <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org>
 <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405091027040.11318@gentwo.org>
 <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de>
 <20140509234745.GB8754@linux.vnet.ibm.com>
 <20140510004843.GB32393@localhost.localdomain>
 <alpine.DEB.2.02.1405101423360.6261@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405101423360.6261@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, John Stultz <john.stultz@linaro.org>

On Sat, May 10, 2014 at 02:31:28PM +0200, Thomas Gleixner wrote:
> On Sat, 10 May 2014, Frederic Weisbecker wrote:
> > But I still have the plan to make the timekeeper use the full sysidle
> > facility in order to adaptively get to dynticks idle.
> > 
> > Reminder for others: in NO_HZ_FULL, the timekeeper (always CPU 0) stays
> > completely periodic. It can't enter in dynticks idle mode because it
> > must maintain timekeeping on behalf of full dynticks CPUs. So that's
> > a power issue.
> > 
> > But Paul has a feature in RCU that lets us know when all CPUs are idle
> > and the timekeeper can finally sleep. Then when a full nohz CPU wakes
> > up from idle, it sends an IPI to the timekeeper if needed so the latter
> > restarts timekeeping maintainance.
> >
> > It's not complicated to add to the timer code.
> > Most of the code is already there, in RCU, for a while already.
> > 
> > Are we keeping that direction? 
> 
> So the idea is that the timekeeper stays on cpu0, but if everything is
> idle it is allowed to take a long nap as well. So if some other cpu
> wakes up it updates timekeeping without taking over the time keeper
> duty and if it has work to do, it kicks cpu0 into gear. If it just
> goes back to sleep, then nothing to do.

Exactly! Except perhaps the last sentence "If it just goes back to sleep,
then nothing to do.", I didn't think about that although this special case
is quite frequent indeed when an interrupt fires on idle but no task is woken up.

Maybe I should move the code that fires the IPI to cpu0, if it is sleeping,
on irq exit (the plan was to do it right away on irq enter) and fire it
only if need_resched().

> 
> No objections from my side.

Great! Thanks for checking that!

> 
> Thanks,
> 
> 	tglx
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
