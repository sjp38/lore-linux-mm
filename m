Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 960BA6B00E8
	for <linux-mm@kvack.org>; Tue,  8 May 2012 11:22:54 -0400 (EDT)
Received: by eekb47 with SMTP id b47so1898876eek.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 08:22:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA823A7.9000801@gmail.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
	<1336056962-10465-6-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1205071024550.1060@router.home>
	<4FA823A7.9000801@gmail.com>
Date: Tue, 8 May 2012 18:22:45 +0300
Message-ID: <CAOtvUMekh0PdVTsdgL=NuVwPW=Yrmum=WWecmfB6wbgwLQzVGw@mail.gmail.com>
Subject: Re: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Mon, May 7, 2012 at 10:33 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>>> @@ -1204,8 +1265,14 @@ static int __init setup_vmstat(void)
>>>
>>> =A0 =A0 =A0 =A0register_cpu_notifier(&vmstat_notifier);
>>>
>>> + =A0 =A0 =A0 INIT_DELAYED_WORK_DEFERRABLE(&vmstat_monitor_work,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vmstat_up=
date_monitor);
>>> + =A0 =A0 =A0 queue_delayed_work(system_unbound_wq,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &vmstat_m=
onitor_work,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 round_jif=
fies_relative(HZ));
>>> +
>>> =A0 =A0 =A0 =A0for_each_online_cpu(cpu)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_cpu_timer(cpu);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 setup_cpu_timer(cpu);
>>> =A0#endif
>>> =A0#ifdef CONFIG_PROC_FS
>>> =A0 =A0 =A0 =A0proc_create("buddyinfo", S_IRUGO,
>>> NULL,&fragmentation_file_operations);
>>
>>
>> So the monitoring thread just bounces around the system? Hope that the
>> scheduler does the right thing to keep it on processors that do some oth=
er
>> work.
>
>
> Good point. Usually, all cpus have update items and monitor worker only
> makes
> new noise. I think this feature is only useful some hpc case. =A0So I won=
der
> if
> this vmstat improvemnt can integrate Frederic's Nohz cpusets activity. I.=
e.
> vmstat-update integrate timer house keeping and automatically stop when
> stopping
> hz house keeping.

I wrote this and the previous IPI patch set explicitly to use with
Frederic's  Nohz stuff
for CPU isolation. It just seemed at the time to be wrong to tie them
together - I mean
people that do CPU isolation can enjoy this even if they don't want to
kill the tick (that
comes with its own overhead for doing system calls, for example).

Thanks!
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
