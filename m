Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id D1F7D6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 17:54:46 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rl12so7523006iec.10
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 14:54:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x5si19908258igw.15.2014.07.28.14.54.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 14:54:45 -0700 (PDT)
Date: Mon, 28 Jul 2014 14:54:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vmstat: On demand vmstat workers V8
Message-Id: <20140728145443.dce6fe72aed1bbdcf95b21f6@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1407281353450.15405@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
	<53D31101.8000107@oracle.com>
	<alpine.DEB.2.11.1407281353450.15405@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Mon, 28 Jul 2014 13:55:17 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:

> On Fri, 25 Jul 2014, Sasha Levin wrote:
> 
> > This patch doesn't interact well with my fuzzing setup. I'm seeing
> > the following:
> >
> > [  490.446927] BUG: using __this_cpu_read() in preemptible [00000000] code: kworker/16:1/7368
> > [  490.447909] caller is __this_cpu_preempt_check+0x13/0x20
> 
> __this_cpu_read() from vmstat_update is only called from a kworker that
> is bound to a single cpu. A false positive?

schedule_delayed_work() uses system_wq.  The comment in workqueue.h says

 * system_wq is the one used by schedule[_delayed]_work[_on]().
 * Multi-CPU multi-threaded.  There are users which expect relatively
 * short queue flush time.  Don't queue works which can run for too
 * long.

but the code itself does

	system_wq = alloc_workqueue("events", 0, 0);

ie: it didn't pass WQ_UNBOUND in the flags.


Tejun, wazzup?



Also, Sasha's report showed this:

[  490.464613] kernel BUG at mm/vmstat.c:1278!

That's your VM_BUG_ON() in vmstat_update().  That ain't no false
positive!



Is this code expecting that schedule_delayed_work() will schedule the
work on the current CPU?  I don't think it will do that.  Maybe you
should be looking at schedule_delayed_work_on().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
