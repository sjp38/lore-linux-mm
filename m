Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E0D856B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 07:18:33 -0500 (EST)
Received: by vcbfl11 with SMTP id fl11so2779204vcb.14
        for <linux-mm@kvack.org>; Sun, 29 Jan 2012 04:18:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120127161236.ff1e7e7e.akpm@linux-foundation.org>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327572121-13673-8-git-send-email-gilad@benyossef.com>
	<20120127161236.ff1e7e7e.akpm@linux-foundation.org>
Date: Sun, 29 Jan 2012 14:18:32 +0200
Message-ID: <CAOtvUMfAd_f=248PTEW6=fqkBxtEB6oahsiqdUC_i2yjfN9m8w@mail.gmail.com>
Subject: Re: [v7 7/8] mm: only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Milton Miller <miltonm@bga.com>

On Sat, Jan 28, 2012 at 2:12 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 26 Jan 2012 12:02:00 +0200
> Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>
>> Calculate a cpumask of CPUs with per-cpu pages in any zone
>> and only send an IPI requesting CPUs to drain these pages
>> to the buddy allocator if they actually have pages when
>> asked to flush.
>>
...
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1165,7 +1165,36 @@ void drain_local_pages(void *arg)
>> =A0 */
>> =A0void drain_all_pages(void)
>> =A0{
>> - =A0 =A0 on_each_cpu(drain_local_pages, NULL, 1);
>> + =A0 =A0 int cpu;
>> + =A0 =A0 struct per_cpu_pageset *pcp;
>> + =A0 =A0 struct zone *zone;
>> +
>> + =A0 =A0 /* Allocate in the BSS so we wont require allocation in
>> + =A0 =A0 =A0* direct reclaim path for CONFIG_CPUMASK_OFFSTACK=3Dy
>> + =A0 =A0 =A0*/
>> + =A0 =A0 static cpumask_t cpus_with_pcps;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* We don't care about racing with CPU hotplug event
>> + =A0 =A0 =A0* as offline notification will cause the notified
>> + =A0 =A0 =A0* cpu to drain that CPU pcps and on_each_cpu_mask
>> + =A0 =A0 =A0* disables preemption as part of its processing
>> + =A0 =A0 =A0*/
>
> hmmm.
>
>> + =A0 =A0 for_each_online_cpu(cpu) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 bool has_pcps =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_populated_zone(zone) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcp =3D per_cpu_ptr(zone->page=
set, cpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pcp->pcp.count) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 has_pcps =3D t=
rue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (has_pcps)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cpu(cpu, &cpus_wit=
h_pcps);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_clear_cpu(cpu, &cpus_w=
ith_pcps);
>> + =A0 =A0 }
>> + =A0 =A0 on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
>> =A0}
>
> Can we end up sending an IPI to a now-unplugged CPU? =A0That won't work
> very well if that CPU is now sitting on its sysadmin's desk.

Nope. on_each_cpu_mask() disables preemption and calls smp_call_function_ma=
ny()
which then checks the mask against the cpu_online_mask

> There's also the case of CPU online. =A0We could end up failing to IPI a
> CPU which now has some percpu pages. =A0That's not at all serious - 90%
> is good enough in page reclaim. =A0But this thinking merits a mention in
> the comment. =A0Or we simply make this code hotplug-safe.

hmm.. I'm probably daft but I don't see how to make the code hotplug safe f=
or
CPU online case. I mean, let's say we disable preemption throughout the
entire ordeal and then the CPU goes online and gets itself some percpu page=
s
*after* we've calculated the masks, sent the IPIs and waiting for the
whole thing
to finish but before we've returned...

I might be missing something here, but I think that unless you have some ot=
her
means to stop newly hotplugged CPUs to grab per cpus pages there is nothing
you can do in this code to stop it. Maybe make the race window
shorter, that's all.

Would adding a comment such as the following OK?

"This code is protected against sending  an IPI to an offline CPU but does =
not
guarantee sending an IPI to newly hotplugged CPUs"


Thanks,
Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
