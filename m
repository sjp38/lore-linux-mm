Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 77F156B00C1
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 02:45:12 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so1302531vbb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 23:45:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1321960128-15191-6-git-send-email-gilad@benyossef.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<1321960128-15191-6-git-send-email-gilad@benyossef.com>
Date: Wed, 23 Nov 2011 09:45:10 +0200
Message-ID: <CAOJsxLG1dCkUb=_08Sry+p8X6LzjFjA8wgoFmHL=xexJfQTUxg@mail.gmail.com>
Subject: Re: [PATCH v4 5/5] mm: Only IPI CPUs to drain local pages if they exist
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Nov 22, 2011 at 1:08 PM, Gilad Ben-Yossef <gilad@benyossef.com> wro=
te:
> Calculate a cpumask of CPUs with per-cpu pages in any zone and only send =
an IPI requesting CPUs to drain these pages to the buddy allocator if they =
actually have pages when asked to flush.
>
> The code path of memory allocation failure for CPUMASK_OFFSTACK=3Dy confi=
g was tested using fault injection framework.
>
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> CC: Russell King <linux@arm.linux.org.uk>
> CC: linux-mm@kvack.org
> CC: Pekka Enberg <penberg@kernel.org>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Sasha Levin <levinsasha928@gmail.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Andi Kleen <andi@firstfloor.org>

I'm adding Mel and Andrew to CC.

> ---
> =A0mm/page_alloc.c | =A0 18 +++++++++++++++++-
> =A01 files changed, 17 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..a3efdf1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1119,7 +1119,23 @@ void drain_local_pages(void *arg)
> =A0*/
> =A0void drain_all_pages(void)
> =A0{
> - =A0 =A0 =A0 on_each_cpu(drain_local_pages, NULL, 1);
> + =A0 =A0 =A0 int cpu;
> + =A0 =A0 =A0 struct zone *zone;
> + =A0 =A0 =A0 cpumask_var_t cpus;
> + =A0 =A0 =A0 struct per_cpu_pageset *pcp;
> +
> + =A0 =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {

__GFP_NOWARN

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_populated_zone(zon=
e) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcp =3D per=
_cpu_ptr(zone->pageset, cpu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pcp->pc=
p.count)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 cpumask_set_cpu(cpu, cpus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu_mask(cpus, drain_local_pages, N=
ULL, 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(cpus);
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu(drain_local_pages, NULL, 1);
> =A0}
>
> =A0#ifdef CONFIG_HIBERNATION

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
