Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 1DAA26B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 14:56:42 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id v1so3441260lbd.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 11:56:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001405e70a92f-3b2a0b89-f807-45d7-af70-9e7292156dd4-000000@email.amazonses.com>
References: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
	<1371672168-9869-1-git-send-email-gilad@benyossef.com>
	<0000013f61e7609b-a8d1907b-8169-4f77-ab83-a624a8d0ab4a-000000@email.amazonses.com>
	<CAOtvUMe=QQni4Ouu=P_vh8QSb4ZdnaX_fW1twn3QFcOjYgJBGA@mail.gmail.com>
	<000001405e70a92f-3b2a0b89-f807-45d7-af70-9e7292156dd4-000000@email.amazonses.com>
Date: Fri, 9 Aug 2013 21:56:39 +0300
Message-ID: <CAOtvUMdPswm3pHesXAzLYA4c7yzsXKoRoOt2T3LWBCjZ86ybpg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: make vmstat_update periodic run conditional
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frederic Weisbecker <fweisbec@gmail.com>

On Thu, Aug 8, 2013 at 5:59 PM, Christoph Lameter <cl@gentwo.org> wrote:
> On Thu, 8 Aug 2013, Gilad Ben-Yossef wrote:
>
>> vmstat_update runs from the vmstat work queue item by the workqueue
>> kernel thread.
>>
>> If this code is running, it means there are at least two schedulable tasks:
>> 1. The workqueue kernel thread, because it is running.
>> 2. At least one more task, otherwise were were in idle and the
>> workqueue kernel thread
>> would not execute this work item.
>>
>> Unfortunately, having two schedulable tasks means we're not running
>> tickless, so the check
>> will never trigger - or have I've missed something obvious?
>
> The vmstat update is deferrable work. As such it is not required to run
> and can be pushed off. It will not be considered for the calculation of
> the next timer interupt. See __next_timer_interrupt().

Yes, I understand that. I was trying to say something else:

If the code does not consider setting the vmstat_cpus bit in the mask
unless we are running
on a CPU in tickless state, than we will (almost) never set
vmstat_cpus since we will (almost)
never be tickless in a deferrable work -

If there is no other task, we will be in idle and the deferreable work
will not be scheduled since the timer will not fire.

If there is one task originally, the work queue gets executed in the
work queue kernel thread, so we have two tasks so tickless will
disengae.

If there is more than one task tickless is not engage.

Bottom line - we will be in active tickless mode when running a
deferreable work item only if we happen to have fire the timer
that scheduled the work and the previously running task happened to
block. This is rare enough that in practice we will almost
never be in active tickless mode when running the vmstat_update function.

I hope I manage to explain myself better this time.

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
