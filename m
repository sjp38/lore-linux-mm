Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 42B246B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 10:14:38 -0500 (EST)
Received: by vcbfl11 with SMTP id fl11so3571629vcb.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 07:14:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120130145900.GR25268@csn.ul.ie>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327572121-13673-8-git-send-email-gilad@benyossef.com>
	<20120130145900.GR25268@csn.ul.ie>
Date: Mon, 30 Jan 2012 17:14:37 +0200
Message-ID: <CAOtvUMcshnvQs4q4ySbtySWv_qHeEnHiD4USBSiOLGFNHSwzUw@mail.gmail.com>
Subject: Re: [v7 7/8] mm: only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Milton Miller <miltonm@bga.com>

On Mon, Jan 30, 2012 at 4:59 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Thu, Jan 26, 2012 at 12:02:00PM +0200, Gilad Ben-Yossef wrote:
>> Calculate a cpumask of CPUs with per-cpu pages in any zone
>> and only send an IPI requesting CPUs to drain these pages
>> to the buddy allocator if they actually have pages when
>> asked to flush.
>>
...
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d2186ec..4135983 100644
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
>
> Lets take two CPUs running this code at the same time. CPU 1 has per-cpu
> pages in all zones. CPU 2 has no per-cpu pages in any zone. If both run
> at the same time, CPU 2 can be clearing the mask for CPU 1 before it has
> had a chance to send the IPI. This means we'll miss sending IPIs to CPUs
> that we intended to.

I'm confused. You seem to be assuming that each CPU is looking at its own p=
cps
only (per zone). Assuming no change in the state of the pcps when both CPUs
run this code at the same time, both of them should mark the bit for
their respective
CPUs the same, unless one of them raced and managed to send the IPI to clea=
r
pcps from the other, at which point you might see one of them send a
spurious IPI
to drains pcps that have been drained - but that isn't bad.

At least, that is what I meant the code to do and what I believe it
does. What have I
missed?

> As I was willing to send no IPI at all;
>
> Acked-by: Mel Gorman <mel@csn.ul.ie>

Thank you for the review and the ACK :-)
>
> But if this gets another revision, add a comment saying that two CPUs
> can interfere with each other running at the same time but we don't
> care.
>
>> + =A0 =A0 on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
>> =A0}
>>

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
