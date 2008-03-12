Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2CKilB3011359
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 16:44:47 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2CKikjR286710
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 16:44:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2CKiklc031421
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 16:44:46 -0400
Received: from [9.47.17.125] (grover.beaverton.ibm.com [9.47.17.125])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m2CKikrQ031393
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 16:44:46 -0400
Subject: [PATCH] hugetlb: vmstat events for huge page allocations v2
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Xj+8anspC2v5Z96E40wk"
Date: Wed, 12 Mar 2008 13:44:46 -0700
Message-Id: <1205354686.7191.9.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-Xj+8anspC2v5Z96E40wk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Changed from v1: fixed whitespace mangling.

From: Adam Litke <agl@us.ibm.com>

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

---

 include/linux/vmstat.h |    4 +++-
 mm/hugetlb.c           |    7 +++++++
 mm/vmstat.c            |    2 ++
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 9f1b4b4..70f6861 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -27,6 +27,8 @@

 #define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_=
ZONE(xx) , xx##_MOVABLE

+#define HTLB_STATS     HTLB_ALLOC_SUCCESS, HTLB_ALLOC_FAIL
+
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
		FOR_ALL_ZONES(PGALLOC),
		PGFREE, PGACTIVATE, PGDEACTIVATE,
@@ -36,7 +38,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
		FOR_ALL_ZONES(PGSCAN_KSWAPD),
		FOR_ALL_ZONES(PGSCAN_DIRECT),
		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
-		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		PAGEOUTRUN, ALLOCSTALL, PGROTATED, HTLB_STATS,
		NR_VM_EVENT_ITEMS
 };

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dcacc81..1507697 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -239,6 +239,11 @@ static int alloc_fresh_huge_page(void)
		hugetlb_next_nid =3D next_nid;
	} while (!page && hugetlb_next_nid !=3D start_nid);

+	if (ret)
+		count_vm_event(HTLB_ALLOC_SUCCESS);
+	else
+		count_vm_event(HTLB_ALLOC_FAIL);
+
	return ret;
 }

@@ -293,9 +298,11 @@ static struct page *alloc_buddy_huge_page(struct vm_ar=
ea_struct *vma,
		 */
		nr_huge_pages_node[nid]++;
		surplus_huge_pages_node[nid]++;
+		count_vm_event(HTLB_ALLOC_SUCCESS);
	} else {
		nr_huge_pages--;
		surplus_huge_pages--;
+		count_vm_event(HTLB_ALLOC_FAIL);
	}
	spin_unlock(&hugetlb_lock);

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 422d960..045a8d7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -644,6 +644,8 @@ static const char * const vmstat_text[] =3D {
	"allocstall",

	"pgrotated",
+	"htlb_alloc_success",
+	"htlb_alloc_fail",
 #endif
 };

--=20
Eric Munson
IBM LTC
ebmunson@us.ibm.com
503.578.3104

--=-Xj+8anspC2v5Z96E40wk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH2EC+snv9E83jkzoRAkjdAKC8QW1y9oDcUobU1D4JychKT0DX1QCg6gr0
+dePItK75NdZF6UHu0w1Me0=
=K2yq
-----END PGP SIGNATURE-----

--=-Xj+8anspC2v5Z96E40wk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
