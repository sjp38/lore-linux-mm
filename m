Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id F3FA36B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 11:24:10 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so522890eek.18
        for <linux-mm@kvack.org>; Tue, 13 May 2014 08:24:10 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id h6si5652481eew.131.2014.05.13.08.24.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 13 May 2014 08:24:09 -0700 (PDT)
Date: Tue, 13 May 2014 17:24:10 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: vmstat: On demand vmstat workers V5
In-Reply-To: <alpine.DEB.2.10.1405121317270.29911@gentwo.org>
Message-ID: <alpine.DEB.2.02.1405131651120.6261@ionos.tec.linutronix.de>
References: <alpine.DEB.2.10.1405121317270.29911@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Mon, 12 May 2014, Christoph Lameter wrote:

> 
> V4->V5:
> - Shepherd thread on a specific cpu (HOUSEKEEPING_CPU).

That's going to fail for the NOHZ_IDLE case, e.g. for the little/big
cluster support on ARM. They need to be able to move it from the
housekeeper on the big to the housekeeper on the little cluster.

So as I said before: This wants to be on a dedicated housekeeper
workqueue. Where the thread is placed is decided by the core depending
on system configuration and state.

 	  nohz = off	    CPU0
	  nohz = idle	    core decision depending on state
	  nohz = full	    CPU0

Your solution solves only the off and full case and will fail when in
the idle case CPU0 should be sent into deep idle sleep until the user
decides to do some work which requires CPU0 to come back.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
