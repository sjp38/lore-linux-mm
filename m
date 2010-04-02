Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 58BA46B01FD
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 05:13:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o329D5Nw010259
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 2 Apr 2010 18:13:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC6E145DE58
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:13:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F84145DE53
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:13:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5831D1DB8038
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:13:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1612E38001
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:13:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100401151639.a030fb10.akpm@linux-foundation.org>
References: <20100331145602.03A7.A69D9226@jp.fujitsu.com> <20100401151639.a030fb10.akpm@linux-foundation.org>
Message-Id: <20100402180812.646D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  2 Apr 2010 18:13:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > Yeah, I don't want ignore .33-stable too. if I can't find the root caus=
e
> > in 2-3 days, I'll revert guilty patch anyway.
> >=20
>=20
> It's a good idea to avoid fixing a bug one-way-in-stable,
> other-way-in-mainline.  Because then we have new code in both trees
> which is different.  And the -stable guys sensibly like to see code get
> a bit of a shakedown in mainline before backporting it.
>=20
> So it would be better to merge the "simple" patch into mainline, tagged
> for -stable backporting.  Then we can later implement the larger fix in
> mainline, perhaps starting by reverting the "simple" fix.

=2E....ok. I don't have to prevent your code maintainship. although I still=
=20
think we need to fix the issue completely.


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 52358cbccdfe94e0381974cd6e937bcc6b1c608b Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 2 Apr 2010 17:13:48 +0900
Subject: [PATCH] Revert "vmscan: get_scan_ratio() cleanup"

Shaohua Li reported his tmpfs streaming I/O test can lead to make oom.
The test uses a 6G tmpfs in a system with 3G memory. In the tmpfs,
there are 6 copies of kernel source and the test does kbuild for each
copy. His investigation shows the test has a lot of rotated anon
pages and quite few file pages, so get_scan_ratio calculates percent[0]
(i.e. scanning percent for anon)  to be zero. Actually the percent[0]
shoule be a big value, but our calculation round it to zero.

Although before commit 84b18490, we have the same sick too. but the old
logic can rescue percent[0]=3D=3D0 case only when priority=3D=3D0. It had h=
ided
the real issue. I didn't think merely streaming io can makes percent[0]=3D=
=3D0
&& priority=3D=3D0 situation. but I was wrong.

So, definitely we have to fix such tmpfs streaming io issue. but anyway
I revert the regression commit at first.

This reverts commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26.

Reported-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79c8098..cb3947e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1535,13 +1535,6 @@ static void get_scan_ratio(struct zone *zone, struct=
 scan_control *sc,
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat =3D get_reclaim_stat(zone, sc);
=20
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <=3D 0)) {
-		percent[0] =3D 0;
-		percent[1] =3D 100;
-		return;
-	}
-
 	anon  =3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
 		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
 	file  =3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
@@ -1639,20 +1632,22 @@ static void shrink_zone(int priority, struct zone *=
zone,
 	unsigned long nr_reclaimed =3D sc->nr_reclaimed;
 	unsigned long nr_to_reclaim =3D sc->nr_to_reclaim;
 	struct zone_reclaim_stat *reclaim_stat =3D get_reclaim_stat(zone, sc);
+	int noswap =3D 0;
=20
-	get_scan_ratio(zone, sc, percent);
+	/* If we have no swap space, do not bother scanning anon pages. */
+	if (!sc->may_swap || (nr_swap_pages <=3D 0)) {
+		noswap =3D 1;
+		percent[0] =3D 0;
+		percent[1] =3D 100;
+	} else
+		get_scan_ratio(zone, sc, percent);
=20
 	for_each_evictable_lru(l) {
 		int file =3D is_file_lru(l);
 		unsigned long scan;
=20
-		if (percent[file] =3D=3D 0) {
-			nr[l] =3D 0;
-			continue;
-		}
-
 		scan =3D zone_nr_lru_pages(zone, sc, l);
-		if (priority) {
+		if (priority || noswap) {
 			scan >>=3D priority;
 			scan =3D (scan * percent[file]) / 100;
 		}
--=20
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
