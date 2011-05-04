Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0016B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 21:33:51 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p441XlKH008315
	for <linux-mm@kvack.org>; Tue, 3 May 2011 18:33:47 -0700
Received: from yxi11 (yxi11.prod.google.com [10.190.3.11])
	by kpbe20.cbf.corp.google.com with ESMTP id p441XHI0000571
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 3 May 2011 18:33:45 -0700
Received: by yxi11 with SMTP id 11so337949yxi.15
        for <linux-mm@kvack.org>; Tue, 03 May 2011 18:33:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110502212427.42b5a90f@annuminas.surriel.com>
References: <20110502212427.42b5a90f@annuminas.surriel.com>
Date: Tue, 3 May 2011 18:33:42 -0700
Message-ID: <BANLkTi=X9WwsELPR1jS_2r=QvZafySfofw@mail.gmail.com>
Subject: Re: [RFC PATCH -mm] add extra free kbytes tunable
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, Mel Gorman <mel@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, May 2, 2011 at 6:24 PM, Rik van Riel <riel@redhat.com> wrote:
> Add a userspace visible knob to tell the VM to keep an extra amount
> of memory free, by increasing the gap between each zone's min and
> low watermarks.
>
> This can be used to make the VM free up memory, for when an extra
> workload is to be added to a system, or to temporarily reduce the
> memory use of a virtual machine. In this application, extra_free_kbytes
> would be raised temporarily and reduced again later. =A0The workload
> management system could also monitor the current workloads with
> reduced memory, to verify that there really is memory space for
> an additional workload, before starting it.
>
> It may also be useful for realtime applications that call system
> calls and have a bound on the number of allocations that happen
> in any short time period. =A0In this application, extra_free_kbytes
> would be left at an amount equal to or larger than than the
> maximum number of allocations that happen in any burst.
>
> I realize nobody really likes this solution to their particular
> issue, but it is hard to deny the simplicity - especially
> considering that this one knob could solve three different issues
> and is fairly simple to understand.

Hi Rik:

In general, i would wonder what's the specific use case requiring the
extra tunable in the kernel. I think I can see the point you are
making,  but it would be hard for admin to adjust the per-zone
extra_free_bytes based on the workload.

In memcg case, we are proposing to add the "high_wmark_distance"
per-memcg, which allows us to tune the high/low_wmark per-memcg
background reclaim. One of the usecase shares w/ your comment which we
want to proactively reclaim memory for launching new jobs. More on
that, this tunable gives us more targeting reclaim. While looking at
this patch, some motivation are common but not the same. At least in
memcg, it might be hard to use per-zone extra_free_bytes to serve the
same purpose because the tunable is for every zone of the system. So
we might start soft_limit reclaim on all the memcgs on all the zones.
Which sounds overkill if we can pick few memcgs to reclaim from.

In non-memcg case, we can imagine lifting the low_wmark might
introduce more background reclaim, which in turn less direct reclaim.
But tuning the knob would be tricky and we need data to support that.

Thanks

--Ying

>
> Signed-off-by: Rik van Riel<riel@redhat.com>
>
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index c0bb324..feecc1a 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -95,6 +95,7 @@ extern char core_pattern[];
> =A0extern unsigned int core_pipe_limit;
> =A0extern int pid_max;
> =A0extern int min_free_kbytes;
> +extern int extra_free_kbytes;
> =A0extern int pid_max_min, pid_max_max;
> =A0extern int sysctl_drop_caches;
> =A0extern int percpu_pagelist_fraction;
> @@ -1173,6 +1174,14 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra1 =A0 =A0 =A0 =A0 =3D &zero,
> =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "extra_free_kbyte=
s",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &extra_free_k=
bytes,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(extra_fr=
ee_kbytes),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D min_free_kbytes_sysct=
l_handler,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .extra1 =A0 =A0 =A0 =A0 =3D &zero,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "percpu_pagelist=
_fraction",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =A0 =A0 =3D &percpu_page=
list_fraction,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.maxlen =A0 =A0 =A0 =A0 =3D sizeof(percpu_=
pagelist_fraction),
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9f8a97b..b85dcb1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -172,8 +172,20 @@ static char * const zone_names[MAX_NR_ZONES] =3D {
> =A0 =A0 =A0 =A0 "Movable",
> =A0};
>
> +/*
> + * Try to keep at least this much lowmem free. =A0Do not allow normal
> + * allocations below this point, only high priority ones. Automatically
> + * tuned according to the amount of memory in the system.
> + */
> =A0int min_free_kbytes =3D 1024;
>
> +/*
> + * Extra memory for the system to try freeing. Used to temporarily
> + * free memory, to make space for new workloads. Anyone can allocate
> + * down to the min watermarks controlled by min_free_kbytes above.
> + */
> +int extra_free_kbytes =3D 0;
> +
> =A0static unsigned long __meminitdata nr_kernel_pages;
> =A0static unsigned long __meminitdata nr_all_pages;
> =A0static unsigned long __meminitdata dma_reserve;
> @@ -4999,6 +5011,7 @@ static void setup_per_zone_lowmem_reserve(void)
> =A0void setup_per_zone_wmarks(void)
> =A0{
> =A0 =A0 =A0 =A0unsigned long pages_min =3D min_free_kbytes >> (PAGE_SHIFT=
 - 10);
> + =A0 =A0 =A0 unsigned long pages_low =3D extra_free_kbytes >> (PAGE_SHIF=
T - 10);
> =A0 =A0 =A0 =A0unsigned long lowmem_pages =3D 0;
> =A0 =A0 =A0 =A0struct zone *zone;
> =A0 =A0 =A0 =A0unsigned long flags;
> @@ -5010,11 +5023,14 @@ void setup_per_zone_wmarks(void)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0for_each_zone(zone) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 tmp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 min, low;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_irqsave(&zone->lock, flags);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D (u64)pages_min * zone->present_page=
s;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_div(tmp, lowmem_pages);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 min =3D (u64)pages_min * zone->present_page=
s;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_div(min, lowmem_pages);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 low =3D (u64)pages_low * zone->present_page=
s;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_div(low, vm_total_pages);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (is_highmem(zone)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * __GFP_HIGH and PF_MEMAL=
LOC allocations usually don't
> @@ -5038,11 +5054,13 @@ void setup_per_zone_wmarks(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * If it's a lowmem zone, =
reserve a number of pages
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * proportionate to the zo=
ne's size.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_MIN] =
=3D tmp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_MIN] =
=3D min;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_LOW] =A0=3D min_wmark=
_pages(zone) + (tmp >> 2);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_HIGH] =3D min_wmark_p=
ages(zone) + (tmp >> 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_LOW] =A0=3D min_wmark=
_pages(zone) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 low + (min >> 2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->watermark[WMARK_HIGH] =3D min_wmark_p=
ages(zone) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 low + (min >> 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0setup_zone_migrate_reserve(zone);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lock, flags)=
;
> =A0 =A0 =A0 =A0}
> @@ -5139,7 +5157,7 @@ module_init(init_per_zone_wmark_min)
> =A0/*
> =A0* min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec=
() so
> =A0* =A0 =A0 that we can call two helper functions whenever min_free_kbyt=
es
> - * =A0 =A0 changes.
> + * =A0 =A0 or extra_free_kbytes changes.
> =A0*/
> =A0int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
> =A0 =A0 =A0 =A0void __user *buffer, size_t *length, loff_t *ppos)
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
