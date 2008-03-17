Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HK2uQf014380
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:02:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HK2ucu237618
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:02:56 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HK2tT9017437
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:02:55 -0400
Subject: [PATCH] hugetlb: vmstat events for huge page allocations v3
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-P56pVd2icS4eWwY9c6Rr"
Date: Mon, 17 Mar 2008 13:02:55 -0700
Message-Id: <1205784175.7122.2.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: aglitke@us.ibm.com
List-ID: <linux-mm.kvack.org>

--=-P56pVd2icS4eWwY9c6Rr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

From: Adam Litke <agl@us.ibm.com>

Following feedback here is v3

Allocating huge pages directly from the buddy allocator is not guaranteed
to succeed.  Success depends on several factors (such as the amount of
physical memory available and the level of fragmentation).  With the
addition of dynamic hugetlb pool resizing, allocations can occur much more
frequently.  For these reasons it is desirable to keep track of huge page
allocation successes and failures.

Add two new vmstat entries to track huge page allocations that succeed and
fail.  The presence of the two entries is contingent upon
CONFIG_HUGETLB_PAGE being enabled.

This patch was created against linux-2.6.25-rc5

Signed-off-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Eric Munson <ebmunson@us.ibm.com>

 include/linux/vmstat.h |    8 +++++++-
 mm/hugetlb.c           |    7 +++++++
 mm/vmstat.c            |    4 ++++
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 9f1b4b4..f68f538 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -25,6 +25,12 @@
 #define HIGHMEM_ZONE(xx)
 #endif
=20
+#ifdef CONFIG_HUGETLB_PAGE
+#define HTLB_STATS	HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
+#else
+#define HTLB_STATS
+#endif
+
 #define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_=
ZONE(xx) , xx##_MOVABLE
=20
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
@@ -36,7 +42,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
-		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		PAGEOUTRUN, ALLOCSTALL, PGROTATED, HTLB_STATS
 		NR_VM_EVENT_ITEMS
 };
=20
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 74c1b6b..dd20cb0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -239,6 +239,11 @@ static int alloc_fresh_huge_page(void)
 		hugetlb_next_nid =3D next_nid;
 	} while (!page && hugetlb_next_nid !=3D start_nid);
=20
+	if (ret)
+		count_vm_event(HTLB_BUDDY_PGALLOC);
+	else
+		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
+
 	return ret;
 }
=20
@@ -299,9 +304,11 @@ static struct page *alloc_buddy_huge_page(struct vm_ar=
ea_struct *vma,
 		 */
 		nr_huge_pages_node[nid]++;
 		surplus_huge_pages_node[nid]++;
+		__count_vm_event(HTLB_BUDDY_PGALLOC);
 	} else {
 		nr_huge_pages--;
 		surplus_huge_pages--;
+		__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
 	}
 	spin_unlock(&hugetlb_lock);
=20
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 422d960..bbe728d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -644,6 +644,10 @@ static const char * const vmstat_text[] =3D {
 	"allocstall",
=20
 	"pgrotated",
+#ifdef CONFIG_HUGETLB_PAGE
+	"htlb_alloc_success",
+	"htlb_alloc_fail",
+#endif
 #endif
 };
=20

--=-P56pVd2icS4eWwY9c6Rr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH3s5vsnv9E83jkzoRAkZGAKDSXiX208MzgIX4wljTDn8cF8L3FwCgt8sx
BaI9NyN1n7YD+2ASiAk7wZ8=
=YYPE
-----END PGP SIGNATURE-----

--=-P56pVd2icS4eWwY9c6Rr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
