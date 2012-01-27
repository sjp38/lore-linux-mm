Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 2DD4E6B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 04:13:27 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so1273344wgb.26
        for <linux-mm@kvack.org>; Fri, 27 Jan 2012 01:13:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120126145914.58619765@cuia.bos.redhat.com>
References: <20120126145450.2d3d2f4c@cuia.bos.redhat.com>
	<20120126145914.58619765@cuia.bos.redhat.com>
Date: Fri, 27 Jan 2012 17:13:25 +0800
Message-ID: <CAJd=RBB=MDiYLVSYJj8d8NfBZp+OU0Lf3-W5+xZUqj0J1JA4cQ@mail.gmail.com>
Subject: Re: [PATCH v3 -mm 1/3] mm: reclaim at order 0 when compaction is enabled
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hillf Danton <dhillf@gmail.com>

Hi Rik

On Fri, Jan 27, 2012 at 3:59 AM, Rik van Riel <riel@redhat.com> wrote:
> When built with CONFIG_COMPACTION, kswapd should not try to free
> contiguous pages, because it is not trying hard enough to have
> a real chance at being successful, but still disrupts the LRU
> enough to break other things.
>
> Do not do higher order page isolation unless we really are in
> lumpy reclaim mode.
>
> Stop reclaiming pages once we have enough free pages that
> compaction can deal with things, and we hit the normal order 0
> watermarks used by kswapd.
>
> Also remove a line of code that increments balanced right before
> exiting the function.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> -v4: further cleanups suggested by Mel Gorman
> =C2=A0mm/vmscan.c | =C2=A0 43 +++++++++++++++++++++++++++++--------------
> =C2=A01 files changed, 29 insertions(+), 14 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2880396..2e2e43d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1139,7 +1139,7 @@ int __isolate_lru_page(struct page *page, isolate_m=
ode_t mode, int file)
> =C2=A0* @mz: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0The m=
em_cgroup_zone to pull pages from.
> =C2=A0* @dst: =C2=A0 =C2=A0 =C2=A0 The temp list to put pages on to.
> =C2=A0* @nr_scanned: =C2=A0 =C2=A0 =C2=A0 =C2=A0The number of pages that =
were scanned.
> - * @order: =C2=A0 =C2=A0 The caller's attempted allocation order
> + * @sc: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0The scan_=
control struct for this reclaim session
> =C2=A0* @mode: =C2=A0 =C2=A0 =C2=A0One of the LRU isolation modes
> =C2=A0* @active: =C2=A0 =C2=A0True [1] if isolating active pages
> =C2=A0* @file: =C2=A0 =C2=A0 =C2=A0True [1] if isolating file [!anon] pag=
es
> @@ -1148,8 +1148,8 @@ int __isolate_lru_page(struct page *page, isolate_m=
ode_t mode, int file)
> =C2=A0*/
> =C2=A0static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_=
zone *mz, struct list_head *dst,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *nr_scan=
ned, int order, isolate_mode_t mode,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int active, int file)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *nr_scan=
ned, struct scan_control *sc,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolate_mode_t mode, i=
nt active, int file)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct lruvec *lruvec;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head *src;
> @@ -1195,7 +1195,7 @@ static unsigned long isolate_lru_pages(unsigned lon=
g nr_to_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0BUG();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!order)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!sc->order || !(sc=
->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
Just a tiny advice 8-)

mind to move checking lumpy reclaim out of the loop,
something like

	unsigned long nr_lumpy_failed =3D 0;
	unsigned long scan;
	int lru =3D LRU_BASE;
+	int order =3D sc->order;
+
+	if (!(sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM))
+		order =3D 0;

	lruvec =3D mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
	if (active)
		lru +=3D LRU_ACTIVE;

with a line of comment?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
