Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id E04EE6B0044
	for <linux-mm@kvack.org>; Sun,  6 May 2012 09:15:31 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so4024082vbb.14
        for <linux-mm@kvack.org>; Sun, 06 May 2012 06:15:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120503153941.GA5528@google.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
	<1336056962-10465-4-git-send-email-gilad@benyossef.com>
	<20120503153941.GA5528@google.com>
Date: Sun, 6 May 2012 16:15:30 +0300
Message-ID: <CAOtvUMcJurhAKB5pbq91WCsSM7cELNOdUbANzx4gF0Cf8x4cTg@mail.gmail.com>
Subject: Re: [PATCH v1 3/6] workqueue: introduce schedule_on_each_cpu_cond
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Thu, May 3, 2012 at 6:39 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Thu, May 03, 2012 at 05:55:59PM +0300, Gilad Ben-Yossef wrote:
>> Introduce the schedule_on_each_cpu_cond() function that schedules
>> a work item on each online CPU for which the supplied condition
>> function returns true.
>>
>> This function should be used instead of schedule_on_each_cpu()
>> when only some of the CPUs have actual work to do and a predicate
>> function can tell if a certain CPU does or does not have work to do,
>> thus saving unneeded wakeups and schedules.
>>
>> =A0/**
>> + * schedule_on_each_cpu_cond - execute a function synchronously on each
>> + * online CPU for which the supplied condition function returns true
>> + * @func: the function to run on the selected CPUs
>> + * @cond_func: the function to call to select the CPUs
>> + *
>> + * schedule_on_each_cpu_cond() executes @func on each online CPU for
>> + * @cond_func returns true using the system workqueue and blocks until
>> + * all CPUs have completed.
>> + * schedule_on_each_cpu_cond() is very slow.
>> + *
>> + * RETURNS:
>> + * 0 on success, -errno on failure.
>> + */
>> +int schedule_on_each_cpu_cond(work_func_t func, bool (*cond_func)(int c=
pu))
>> +{
>> + =A0 =A0 int cpu, ret;
>> + =A0 =A0 cpumask_var_t mask;
>> +
>> + =A0 =A0 if (unlikely(!zalloc_cpumask_var(&mask, GFP_KERNEL)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> +
>> + =A0 =A0 get_online_cpus();
>> +
>> + =A0 =A0 for_each_online_cpu(cpu)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (cond_func(cpu))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cpu(cpu, mask);
>> +
>> + =A0 =A0 ret =3D schedule_on_each_cpu_mask(func, mask);
>> +
>> + =A0 =A0 put_online_cpus();
>> +
>> + =A0 =A0 free_cpumask_var(mask);
>> +
>> + =A0 =A0 return ret;
>> +}
>
> I'm usually not a big fan of callback based interface. =A0They tend to
> be quite clunky to use.

My first academic computer science course used SICP as the text book.
I've managed to kick most of the bad habits I've gained in that course
over the years,
but two: a taste for higher order functions and a fetish for
parenthesis.I can't quite tell
which of the two is a bigger barrier to my re-integration with normal
society... ;-)

> =A0e.g. in this case, wouldn't it be better to
> have helper functions which allocate cpumask and disables cpu hotplug
> and undo that afterwards? =A0That is, if such convenience helpers are
> necessary at all.

If we'll always have only a single call sign you are certainly right.
My thought was
that I'm not only solving the specific problem here, but trying to
help the next person
doing something similar do the right thing.

A single helper function called schedule_on_each_cpu_cond() is very
obvious to find
to someone reading the source or documentation. On the other hand
figuring out that
the helper functions that handle cpu hotplug and cpumask allocation
are there for that
purpose is a bit more involved.

That was my thinking at least.

> Also, callback which doesn't have a private data
> argument tends to be PITA.
>

You are 100% right. The callback should have a private data parameter.

The way i see it, I can either obliterate on_each_cpu_cond() and out its co=
de
in place in the LRU path, or fix the callback to get an extra private
data parameter -

It's your call - what would you have me do?

Thanks,
Gilad



> Thanks.
>
> --
> tejun



--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
