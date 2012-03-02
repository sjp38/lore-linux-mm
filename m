Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B02196B007E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 12:36:51 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 2 Mar 2012 12:36:40 -0500
Subject: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

Sometimes we'd like to avoid swapping out anonymous memory
in particular, avoid swapping out pages of important process or
process groups while there is a reasonable amount of pagecache
on RAM so that we can satisfy our customers' requirements.

OTOH, we can control how aggressive the kernel will swap memory pages
with /proc/sys/vm/swappiness for global and
/sys/fs/cgroup/memory/memory.swappiness for each memcg.

But with current reclaim implementation, the kernel may swap out
even if we set swappiness=3D=3D0 and there is pagecache on RAM.

This patch changes the behavior with swappiness=3D=3D0. If we set
swappiness=3D=3D0, the kernel does not swap out completely
(for global reclaim until the amount of free pages and filebacked
pages in a zone has been reduced to something very very small
(nr_free + nr_filebacked < high watermark)).

Any comments are welcome.

Regards,
Satoru Moriya

Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
---
 mm/vmscan.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..27dc3e8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1983,10 +1983,10 @@ static void get_scan_count(struct mem_cgroup_zone *=
mz, struct scan_control *sc,
 	 * proportional to the fraction of recently scanned pages on
 	 * each list that were recently referenced and in active use.
 	 */
-	ap =3D (anon_prio + 1) * (reclaim_stat->recent_scanned[0] + 1);
+	ap =3D anon_prio * (reclaim_stat->recent_scanned[0] + 1);
 	ap /=3D reclaim_stat->recent_rotated[0] + 1;
=20
-	fp =3D (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
+	fp =3D file_prio * (reclaim_stat->recent_scanned[1] + 1);
 	fp /=3D reclaim_stat->recent_rotated[1] + 1;
 	spin_unlock_irq(&mz->zone->lru_lock);
=20
@@ -1999,7 +1999,7 @@ out:
 		unsigned long scan;
=20
 		scan =3D zone_nr_lru_pages(mz, lru);
-		if (priority || noswap) {
+		if (priority || noswap || !vmscan_swappiness(mz, sc)) {
 			scan >>=3D priority;
 			if (!scan && force_scan)
 				scan =3D SWAP_CLUSTER_MAX;
--=20
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
