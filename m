Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id C66906B0037
	for <linux-mm@kvack.org>; Sat, 10 May 2014 08:31:23 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so3336082eei.19
        for <linux-mm@kvack.org>; Sat, 10 May 2014 05:31:23 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id p43si2212965eem.3.2014.05.10.05.31.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 10 May 2014 05:31:22 -0700 (PDT)
Date: Sat, 10 May 2014 14:31:28 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: vmstat: On demand vmstat workers V4
In-Reply-To: <20140510004843.GB32393@localhost.localdomain>
Message-ID: <alpine.DEB.2.02.1405101423360.6261@ionos.tec.linutronix.de>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org> <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org> <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de> <alpine.DEB.2.10.1405091027040.11318@gentwo.org> <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de> <20140509234745.GB8754@linux.vnet.ibm.com>
 <20140510004843.GB32393@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, John Stultz <john.stultz@linaro.org>

On Sat, 10 May 2014, Frederic Weisbecker wrote:
> But I still have the plan to make the timekeeper use the full sysidle
> facility in order to adaptively get to dynticks idle.
> 
> Reminder for others: in NO_HZ_FULL, the timekeeper (always CPU 0) stays
> completely periodic. It can't enter in dynticks idle mode because it
> must maintain timekeeping on behalf of full dynticks CPUs. So that's
> a power issue.
> 
> But Paul has a feature in RCU that lets us know when all CPUs are idle
> and the timekeeper can finally sleep. Then when a full nohz CPU wakes
> up from idle, it sends an IPI to the timekeeper if needed so the latter
> restarts timekeeping maintainance.
>
> It's not complicated to add to the timer code.
> Most of the code is already there, in RCU, for a while already.
> 
> Are we keeping that direction? 

So the idea is that the timekeeper stays on cpu0, but if everything is
idle it is allowed to take a long nap as well. So if some other cpu
wakes up it updates timekeeping without taking over the time keeper
duty and if it has work to do, it kicks cpu0 into gear. If it just
goes back to sleep, then nothing to do.

No objections from my side.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
