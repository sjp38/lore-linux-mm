Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 1EC8A6B13FA
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 21:05:00 -0500 (EST)
Received: by bkty12 with SMTP id y12so62013bkt.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 18:04:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120203140428.GG5796@csn.ul.ie>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-12-git-send-email-m.szyprowski@samsung.com> <20120203140428.GG5796@csn.ul.ie>
From: sandeep patil <psandeep.s@gmail.com>
Date: Tue, 7 Feb 2012 18:04:18 -0800
Message-ID: <CA+K6fF49BQiNer=7Di+gCU_EX4E41q-teXJJUBjEd2xc12-j4w@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 11/15] mm: trigger page reclaim in
 alloc_contig_range() to stabilize watermarks
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Fri, Feb 3, 2012 at 6:04 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Feb 03, 2012 at 01:18:54PM +0100, Marek Szyprowski wrote:
>
> Nothing prevents two or more processes updating the wmarks at the same
> time which is racy and unpredictable. Today it is not much of a problem
> but CMA makes this path hotter than it was and you may see weirdness
> if two processes are updating zonelists at the same time. Swap-over-NFS
> actually starts with a patch that serialises setup_per_zone_wmarks()
>
> You also potentially have a BIG problem here if this happens
>
> min_free_kbytes =3D 32768
> Process a: min_free_kbytes =A0+=3D 65536
> Process a: start direct reclaim
> echo 16374 > /proc/sys/vm/min_free_kbytes
> Process a: exit direct_reclaim
> Process a: min_free_kbytes -=3D 65536
>
> min_free_kbytes now wraps negative and the machine hangs.
>

There's another problem I am facing with zone watermarks and CMA.

Test details:
Memory  : 480 MB of total memory, 128 MB CMA region
Test case : around 600 MB of file transfer over USB RNDIS onto target
System Load : ftpd with console running on target.
No one is doing CMA allocations except for the DMA allocations done by the
drivers.

Result : After about 300MB transfer, I start getting GFP_ATOMIC
allocation failures.
This only happens if CMA region is reserved.

Here's the free_list before I start the test

Free pages count per migrate type at order       0      1      2
3      4      5      6      7      8      9     10
Node    0, zone   Normal, type    Unmovable      2      9      6
7      3      3      3      4      2      1      0
Node    0, zone   Normal, type  Reclaimable     31      4      1
2      1      1      0      1      1      0      0
Node    0, zone   Normal, type      Movable     22     20     23
14      3      4      4      3      1      0     70
Node    0, zone   Normal, type      Reserve      0      0      0
0      0      0      0      0      0      0      1
Node    0, zone   Normal, type          CMA      2      0      0
2      1      1      1      1      1      1     34
Node    0, zone   Normal, type      Isolate      0      0      0
0      0      0      0      0      0      0      0

and here's what I get when I print the same when allocation fails.

Normal: Free pages count per migrate type at order       0      1
2      3      4      5      6      7      8      9     10
[  401.887634]                    zone   Normal, type    Unmovable
 0      0      0      0      0      0      0      0      0      0
0
[  401.901916]                    zone   Normal, type  Reclaimable
 0      0      0      0      0      0      0      0      0      0
0
[  401.916229]                    zone   Normal, type      Movable
 0      0      0      0      0      0      0      0      0      0
0
[  401.930541]                    zone   Normal, type      Reserve
 0      0      0      0      0      0      0      0      0      0
0
[  401.944824]                    zone   Normal, type          CMA
6582   6580   2380      0      0      0      0      0      0      0
  0
[  401.961486]                    zone   Normal, type      Isolate
 0      0      0      0      0      0      0      0      0      0
0

Total memory available is way above the zone watermarks. So, we ended
up starving
UNMOVABLE/RECLAIMABLE atomic allocations that cannot fallback on CMA region=
.

I know the CMA region is big, but I think reducing the region size
will only delay the problem.
it walso on't recover as long as most of the CMA region pages get
allocated and the zone
watermark is hit

To check my theory, I changed __zone_watermark_ok() to ignore free CMA page=
s
With this change, the transfer succeeds w/o any failures.

The patch does make things slow of course. Ideally, I would have liked
to do this only if
the watermark is being checked for non-Movable allocations, but I couldn't =
find
an easy way to do that.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 371a79f..b672d97 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1580,6 +1580,21 @@ static bool __zone_watermark_ok(struct zone *z,
int order, unsigned long mark,
 		if (free_pages <=3D min)
 			return false;
 	}
+
+#ifdef CONFIG_CMA
+	/* If cma is enabled, ignore free pages from MIGRATE_CMA list
+	 * for watermark checks
+	 */
+	for (o =3D order; o < MAX_ORDER; o++) {
+		struct list_head *curr;
+		list_for_each(curr, &z->free_area[o].free_list[MIGRATE_CMA]) {
+			free_pages -=3D (1 << o);
+			if (free_pages <=3D min)
+				return false;
+		}
+	}
+#endif
+
 	return true;
 }

Sandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
