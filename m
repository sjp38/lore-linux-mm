Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 266E96B00A9
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:49:15 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so15616987vbb.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:49:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
	<1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
Date: Sun, 1 Jan 2012 09:49:13 +0200
Message-ID: <CAOtvUMeAVgDwRNsDTcG07ChYnAuNgNJjQ+sKALJ79=Ezikos-A@mail.gmail.com>
Subject: Re: [PATCH 01/11] mm: page_alloc: set_migratetype_isolate: drain PCP
 prior to isolating
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Dec 29, 2011 at 2:39 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
>
> When set_migratetype_isolate() sets pageblock's migrate type, it does
> not change each page_private data. =A0This makes sense, as the function
> has no way of knowing what kind of information page_private stores.
...
>
>
> A side effect is that instead of draining pages from all zones,
> set_migratetype_isolate() now drain only pages from zone pageblock it
> operates on is in.
>
...


>
> +/* Caller must hold zone->lock. */
> +static void __zone_drain_local_pages(void *arg)
> +{
> + =A0 =A0 =A0 struct per_cpu_pages *pcp;
> + =A0 =A0 =A0 struct zone *zone =3D arg;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 local_irq_save(flags);
> + =A0 =A0 =A0 pcp =3D &per_cpu_ptr(zone->pageset, smp_processor_id())->pc=
p;
> + =A0 =A0 =A0 if (pcp->count) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Caller holds zone->lock, no need to grab=
 it. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pcppages_bulk(zone, pcp->count, pcp)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcp->count =3D 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 local_irq_restore(flags);
> +}
> +
> +/*
> + * Like drain_all_pages() but operates on a single zone. =A0Caller must
> + * hold zone->lock.
> + */
> +static void __zone_drain_all_pages(struct zone *zone)
> +{
> + =A0 =A0 =A0 on_each_cpu(__zone_drain_local_pages, zone, 1);
> +}
> +

Please consider whether sending an IPI to all processors in the system
and interrupting them is appropriate here.

You seem to assume that it is probable that each CPU of the possibly
4,096 (MAXSMP on x86) has a per-cpu page
for the specified zone, otherwise you're just interrupting them out of
doing something useful, or save power idle
for nothing.

While that may or may not be a reasonable assumption for the general
drain_all_pages that drains pcps from
all zones, I feel it is less likely to be the right thing once you
limit the drain to a single zone.

Some background on my attempt to reduce "IPI noise" in the system in
this context is probably useful here as
well: https://lkml.org/lkml/2011/11/22/133

Thanks :-)
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
