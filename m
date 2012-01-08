Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E236A6B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 11:01:55 -0500 (EST)
Received: by vcge1 with SMTP id e1so2661106vcg.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 08:01:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120105155445.GC27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
	<1325499859-2262-8-git-send-email-gilad@benyossef.com>
	<20120105155445.GC27881@csn.ul.ie>
Date: Sun, 8 Jan 2012 18:01:54 +0200
Message-ID: <CAOtvUMezyvi1icpxo6YC5apJU-LZ5ns-RSeaL1q3CYw34AULFQ@mail.gmail.com>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 5, 2012 at 5:54 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>
> On Mon, Jan 02, 2012 at 12:24:18PM +0200, Gilad Ben-Yossef wrote:


>
> > Tested by running "hackbench 400" on a 4 CPU x86 otherwise
> > idle VM and observing the difference between the number
> > of direct reclaim attempts that end up in drain_all_pages()
> > and those were more then 1/2 of the online CPU had any
> > per-cpu page in them, using the vmstat counters introduced
> > in the next patch in the series and using proc/interrupts.
> >
> > In the test sceanrio, this saved around 500 global IPIs.
> > After trigerring an OOM:
> >
> > $ cat /proc/vmstat
> > ...
> > pcp_global_drain 627
> > pcp_global_ipi_saved 578
> >
>
> This isn't 99% savings as you claim earlier but they are still great.
>

You are right of course, more like 92%. I did =A0see test runs where the %
was 99% (which is were the 99% number came from) .I never saw it drop
below 90% for the specified =A0test load.

I modified the description to read 90%+. I guess that is good enough.

> Thanks for doing the stats. Just to be clear, I didn't expect these
> stats to be merged, nor do I want them to. I wanted to be sure the patch
> was really behaving as advertised.
>
> Acked-by: Mel Gorman <mgorman@suse.de>
>
Of course, my pleasure and thanks for the review.
>
>
> > + =A0 =A0 for_each_online_cpu(cpu)
> > + =A0 =A0 =A0 =A0 =A0 =A0 for_each_populated_zone(zone) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcp =3D per_cpu_ptr(zone->pag=
eset, cpu);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pcp->pcp.count)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_c=
pu(cpu, cpus_with_pcps);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_clear=
_cpu(cpu, cpus_with_pcps);
> > + =A0 =A0 =A0 =A0 =A0 =A0 }
> > + =A0 =A0 on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
>
> As a heads-up, I'm looking at a candidate CPU hotplug patch that almost
> certainly will collide with this patch. If/when I get it fixed, I'll be
> sure to CC you so we can figure out what order the patches need to go
> in. Ordinarily it wouldn't matter but if this really is a CPU hotplug
> fix, it might also be a -stable candidate so it would need to go in
> before your patches.


No problem. I'm sending v6 right now because of unrelated changes Andrew M.
asked for. I'll be happy to re-base on top of CPU hotplug fixes later.

Thanks,
Gilad


--
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
