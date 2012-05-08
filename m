Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D61B56B0083
	for <linux-mm@kvack.org>; Tue,  8 May 2012 11:18:45 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so6602866vbb.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 08:18:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205071024550.1060@router.home>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
	<1336056962-10465-6-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1205071024550.1060@router.home>
Date: Tue, 8 May 2012 18:18:44 +0300
Message-ID: <CAOtvUMeF6Xi-sOYZkJuAF0=jzqUHBNEMZU4BD=K3-yqQbdQxUw@mail.gmail.com>
Subject: Re: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Mon, May 7, 2012 at 6:29 PM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 3 May 2012, Gilad Ben-Yossef wrote:
>
>> vmstat_update runs every second from the work queue to update statistics
>> and drain per cpu pages back into the global page allocator.
>
> Looks good.

Thanks :-)

>
> - vmstat_off_cpus is a bit strange. Could we have a cpumask that has a bi=
t
> set if vmstat is active? Rename to "vmstat_cpus"?

Sure.

> - Start out with vmstat_cpus cleared? Cpus only need vmstat if they do
> something and if a cpu is idle on boot then it will not need vmstat
> enabled until the cpu does something useful.

Ah cool. I haven't thought of that.

>
>> @@ -1204,8 +1265,14 @@ static int __init setup_vmstat(void)
>>
>> =A0 =A0 =A0 register_cpu_notifier(&vmstat_notifier);
>>
>> + =A0 =A0 INIT_DELAYED_WORK_DEFERRABLE(&vmstat_monitor_work,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vmstat_update_=
monitor);
>> + =A0 =A0 queue_delayed_work(system_unbound_wq,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &vmstat_monito=
r_work,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 round_jiffies_=
relative(HZ));
>> +
>> =A0 =A0 =A0 for_each_online_cpu(cpu)
>> - =A0 =A0 =A0 =A0 =A0 =A0 start_cpu_timer(cpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 setup_cpu_timer(cpu);
>> =A0#endif
>> =A0#ifdef CONFIG_PROC_FS
>> =A0 =A0 =A0 proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_=
operations);
>
> So the monitoring thread just bounces around the system? Hope that the
> scheduler does the right thing to keep it on processors that do some othe=
r
> work.

My line of thought was that if we explicitly choose a scapegoat cpu we
and the user
need to manage this - such as worry about what happens if the
scapegoats is offlines and
let the user explicitly  designate the scapegoat cpu thus creating
another knob, and worrying
about what happens if the user designate such a cpu but then it goes offlin=
es...

I figured the user needs to worry about other unbounded work items
anyway if he cares about
where such things are run in the general case, but using isolcpus for examp=
le.

The same should be doable with cpusets, except that right now we mark
unbounded workqueue
worker threads as pinned even though they aren't. If I understood the
discussion, the idea is
exactly to stop users from putting these threads in non root cpusets.
I am not 100% sure why..

Does that makes sense?

Thanks!
Gilad

Gilad


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
