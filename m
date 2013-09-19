Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E74F36B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 12:55:02 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so9870539pad.37
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 09:55:02 -0700 (PDT)
Received: by mail-lb0-f172.google.com with SMTP id x18so8141773lbi.31
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 09:54:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com>
	<CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com>
	<0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
	<20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org>
Date: Thu, 19 Sep 2013 11:54:58 -0500
Message-ID: <CAOtvUMf6=Znpnn4JJmXzdHaZ1TpCAXUc6SGUX5ZM20J174qn0Q@mail.gmail.com>
Subject: Re: RFC vmstat: On demand vmstat threads
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Wed, Sep 18, 2013 at 5:06 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 10 Sep 2013 21:13:34 +0000 Christoph Lameter <cl@linux.com> wrote:
>

>> With this patch it is possible then to have periods longer than
>> 2 seconds without any OS event on a "cpu" (hardware thread).
>
> It would be useful (actually essential) to have a description of why
> anyone cares about this.  A good and detailed description, please.


Let me have a stab at this:

The existing vmstat_update mechanism depends on a deferrable timer
firing every second
by default which registers a work queue item that runs on the local
CPU, with the result
that we have 1 interrupt and one additional schedulable task on each
CPU aprox. every second.

If your workload indeed causes VM activity or you are running multiple
tasks per CPU, you probably
have bigger issues to deal with.

However, many existing workloads dedicate a CPU for a single  CPU bound task.
This is done by high performance computing folks, by high frequency
financial applications  folks,
by networking folks  (Intel DPDK, EZchip NPS) and with the advent of
systems with more and more
CPUs over time, this  will(?) become more and more common to do since
when you have enough CPUs
you care less about efficiently sharing your CPU with other tasks and
more about
efficiently monopolizing a CPU per task.

The difference of having this timer firing and workqueue kernel thread
scheduled per second can be enormous.
An artificial test I made measuring the worst case time to do a simple
"i++" in an endless loop on a bare metal
system and under Linux on an isolated CPU (cpusets or isolcpus - take
your pick) with dynticks and with and
without this patch, have Linux match the bare metal performance (~700
cycles) with this patch and loose by
couple of orders of magnitude (~200k cycles) without it[*]  - and all
this for something that just calculates statistics.
For  networking applications, for example, this is the difference
between dropping packets or sustaining line rate.

Statistics are important and useful, but if there is a way to not
cause statistics gathering produce
such a huge performance difference would be great. This is what we are
trying to do here.

Does it makes sense?

[*] To be honest it required one more patch, but this one or something
like is needed to get that one working, so...

Thanks,
Gilad





-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
