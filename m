Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 544AD6B0036
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:49:25 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so1244943eek.11
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:49:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 49si5302581een.5.2014.04.23.15.49.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 15:49:23 -0700 (PDT)
Date: Thu, 24 Apr 2014 08:49:16 +1000
From: NeilBrown <neilb@suse.de>
Subject: [PATCH revised - was 1/5] MM: avoid throttling reclaim for
 loop-back nfsd threads.
Message-ID: <20140424084916.2f1da0c8@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZslvOujvpOu=TtTjOBITTty"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>

--Sig_/ZslvOujvpOu=TtTjOBITTty
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



When a loop-back NFS mount is active and the backing device for the
NFS mount becomes congested, that can impose throttling delays on the
nfsd threads.

These delays significantly reduce throughput and so the NFS mount
remains congested.

This results in a live lock and the reduced throughput persists.

This live lock has been found in testing with the 'wait_iff_congested'
call, and could possibly be caused by the 'congestion_wait' call.

This livelock is similar to the deadlock which justified the
introduction of PF_LESS_THROTTLE, and the same flag can be used to
remove this livelock.

To minimise the impact of the change, we still throttle nfsd when the
filesystem it is writing to is congested, but not when some separate
filesystem (e.g. the NFS filesystem) is congested.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b409681..ce0e4dfc6d67 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1425,6 +1425,19 @@ putback_inactive_pages(struct lruvec *lruvec, struct=
 list_head *page_list)
 }
=20
 /*
+ * If a kernel thread (such as nfsd for loop-back mounts) services
+ * a backing device by writing to the page cache it sets PF_LESS_THROTTLE.
+ * In that case we should only throttle if the backing device it is
+ * writing to is congested.  In other cases it is safe to throttle.
+ */
+static int current_may_throttle(void)
+{
+	return !(current->flags & PF_LESS_THROTTLE) ||
+		current->backing_dev_info =3D=3D NULL ||
+		bdi_write_congested(current->backing_dev_info);
+}
+
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the n=
umber
  * of reclaimed pages
  */
@@ -1552,7 +1565,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct=
 lruvec *lruvec,
 		 * implies that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (nr_unqueued_dirty =3D=3D nr_taken || nr_immediate)
+		if ((nr_unqueued_dirty =3D=3D nr_taken || nr_immediate) &&
+		    current_may_throttle())
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
=20
@@ -1561,7 +1575,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct=
 lruvec *lruvec,
 	 * is congested. Allow kswapd to continue until it starts encountering
 	 * unqueued dirty pages or cycling through the LRU too quickly.
 	 */
-	if (!sc->hibernation_mode && !current_is_kswapd())
+	if (!sc->hibernation_mode && !current_is_kswapd() &&
+	    current_may_throttle())
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
=20
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,

--Sig_/ZslvOujvpOu=TtTjOBITTty
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU1hDbDnsnt1WYoG5AQKczg//VjNRwC4g736Gt3Ec1HcynbycVjUzybHW
yrFn67CeL0HK/J5bQX5Jw4Lvuws0EeRrfRyOnFScw5kIIfFiU6qSOtQEj09BVD58
ZUFN4PdaMqd2YjLf/hzfJcw198kSm75CvYo8ZlsgSot0eDQmdCkaLsfPY4DJO2zP
160qvrfMcSihq/e8V/pmmMkF+VfsiMhNx7+bNwjH9JinSl1UjWTt0j86paENuIIQ
ubS/Xik2r8+MvK5LDQnSWYMhis+hiDPceELoykuTasOOxifdXw1SvRvp25N284xM
q9sYP8XHVB4swQzEuQVxw8l4Htm9Yl3TOYw6yUWNDoSvNX/eTelcP78nB8UaBxZy
ffBB/8snO7kelT1qGEmTWZva/jPCNWjeNYJrRjLBzPd9DVgl/zqZNKkpl/n/1yNX
KeHXX2GBxh12B1uYAcvUT/7sGk954uHGIX9lK+DWhXWEwUTCAqMxpfKBNVrM5eWG
PI/to5cWBN82V28tLVf3YzxlKlsJ8rDEyiNnOyR8xpKXRmF8a6Ol6zSTwIi/fRTm
Xv/I3awk9PCGaezyv/cmbGkFbE3/BGxE7HTC4C4CEf0LJ7IxZFJs0drxu++3YNkT
DoPWivg2YBB8XxFm7U1usGWHnmqF48oWj4yUn6rkuA1/ob/398kc1L2GPUXeE0gW
2uerYmLgsPY=
=Fo/n
-----END PGP SIGNATURE-----

--Sig_/ZslvOujvpOu=TtTjOBITTty--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
