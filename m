Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id C8E846B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 11:10:26 -0500 (EST)
Received: by vcge1 with SMTP id e1so784018vcg.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 08:10:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326265454_1664@mail4.comsite.net>
References: <alpine.DEB.2.00.1201091034390.31395@router.home>
	<1326040026-7285-8-git-send-email-gilad@benyossef.com>
	<op.v7vcjum63l0zgt@mpn-glaptop>
	<1326265454_1664@mail4.comsite.net>
Date: Wed, 11 Jan 2012 18:10:25 +0200
Message-ID: <CAOtvUMdXUjr8ZN+Mv8XuAmMtf0jZ-_r2f_1XJxhpwmJC6orSGw@mail.gmail.com>
Subject: Re: [PATCH v6 7/8] mm: only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milton Miller <miltonm@bga.com>
Cc: Christoph Lameter <cl@linux.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Wed, Jan 11, 2012 at 9:04 AM, Milton Miller <miltonm@bga.com> wrote:

>> > > @@ -1097,7 +1105,19 @@ void drain_local_pages(void *arg)
>> > > =A0 */
>> > > =A0void drain_all_pages(void)
>> > > =A0{
>> > > - on_each_cpu(drain_local_pages, NULL, 1);
>> > > + int cpu;
>> > > + struct per_cpu_pageset *pcp;
>> > > + struct zone *zone;
>> > > +
>> > > + for_each_online_cpu(cpu)
>> > > + =A0 =A0 =A0 =A0 for_each_populated_zone(zone) {
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcp =3D per_cpu_ptr(zone->pageset,=
 cpu);
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pcp->pcp.count)
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cpu(cp=
u, cpus_with_pcps);
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_clear_cpu(=
cpu, cpus_with_pcps);
>> > > + =A0 =A0 =A0 =A0 }
>> > > + on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
>> >
>
> This will only select cpus that have pcp pages in the last zone,
> not pages in any populated zone.

Oy! you are very right.

>
> Call cpu_mask_clear before the for_each_online_cpu loop, and only
> set cpus in the loop.
>
> Hmm, that means we actually need a lock for using the static mask.

We don't have to clear before the loop or lock. We can do something like th=
is:

        int cpu;
        struct per_cpu_pageset *pcp;
        struct zone *zone;

        for_each_online_cpu(cpu) {
                bool has_pcps =3D false;
                for_each_populated_zone(zone) {
                        pcp =3D per_cpu_ptr(zone->pageset, cpu);
                        if (pcp->pcp.count) {
                                has_pcps =3D true;
                                break;
                        }
                }
                if (has_pcps)
                        cpumask_set_cpu(cpu, cpus_with_pcps);
                else
                        cpumask_clear_cpu(cpu, cpus_with_pcps);
        }
        on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);


>
> -- what would happen without any lock?
> [The last to store would likely see all the cpus and send them IPIs
> but the earlier, racing callers would miss some cpus (It will test
> our smp_call_function_many locking!), and would retry before all the
> pages were drained from pcp pools]. =A0The locking should be better
> than racing -- one cpu will peek and pull all per-cpu data to itself,
> then copy the mask to its smp_call_function_many element, then wait
> for all the cpus it found cpus to process their list pulling their
> pcp data back to the owners. =A0 Not much sense in the racing cpus
> figighting to bring the per-cpu data to themselves to write to the
> now contended static mask while pulling the zone pcp data from the
> owning cpus that are trying to push to the buddy lists.
>

That is a very good point and I guess you are right that the locking
saves cache bounces and probably also some IPIs.

I am not 100% it is a win though. The lockless approach is simpler,
has zero risk of dead locks. I also fear that any non interruptable lock
(be it spinlock or  interruptable lock non mutex) might delay an OOM
in progress.

Having the lock there is not a correctness issue - it is a performance
enhancement. Because this is not a fast path, i would go for simple
and less risk and not have the lock there at all.

> The benefit numbers in the changelog need to be measured again
> after this correction.
>

Yes, of course. Preliminary numbers with the lockless version above
still looks good.

I am guessing though that Mel's patch will make all this moot anyway
since if we're not doing a drain_all in the direct reclaim we're left with
very rare code paths (memory error and memory migration) that call
the drain_all and they wont tend to do that concurrently like the direct
reclaim.

>
>
> Disabling preemption around online loop and the call will prevent
> races with cpus going offline, but we do not that we care as the
> offline notification will cause the notified cpu to drain that pool.
> on_each_cpu_mask disables preemption as part of its processing.
>
> If we document the o-e-c-m behaviour then we should consider putting a
> comment here, or at least put the previous paragraph in the change log.

I noticed that Mel's patch already added get_online_cpus() in drain_all.


>
>> > > =A0}
>> > >
>> > > =A0#ifdef CONFIG_HIBERNATION
>> > > @@ -3601,6 +3621,10 @@ static void setup_zone_pageset(struct zone *z=
one)
>> > > =A0void __init setup_per_cpu_pageset(void)
>> > > =A0{
>> > > =A0 struct zone *zone;
>> > > + int ret;
>> > > +
>> > > + ret =3D zalloc_cpumask_var(&cpus_with_pcps, GFP_KERNEL);
>> > > + BUG_ON(!ret);
>> > >
>
> Switching to cpumask_t will eliminate this hunk. =A0 Even if we decide
> to keep it a cpumask_var_t we don't need to pre-zero it as we set
> the entire mask so alloc_cpumask_var would be sufficient.
>

hmm... then we can make it a static local variable and it doesn't even
make the kernel image really bigger since it's in the BSS. Cool.

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
