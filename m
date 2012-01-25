Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 25E1C6B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 16:58:09 -0500 (EST)
MIME-Version: 1.0
Message-ID: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
Date: Wed, 25 Jan 2012 13:58:03 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH] mm: implement WasActive page flag (for improving cleancache)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>

(Feedback welcome if there is a different/better way to do this
without using a page flag!)

Since about 2.6.27, the page replacement algorithm maintains
an "active" bit to help decide which pages are most eligible
to reclaim, see http://linux-mm.org/PageReplacementDesign=20

This "active' information is also useful to cleancache but is lost
by the time that cleancache has the opportunity to preserve the
pageful of data.  This patch adds a new page flag "WasActive" to
retain the state.  The flag may possibly be useful elsewhere.

It is up to each cleancache backend to utilize the bit as
it desires.  The matching patch for zcache is included here
for clarification/discussion purposes, though it will need to
go through GregKH and the staging tree.

The patch resolves issues reported with cleancache which occur
especially during streaming workloads on older processors,
see https://lkml.org/lkml/2011/8/17/351=20

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e90a673..0f5e86a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -51,6 +51,9 @@
  * PG_hwpoison indicates that a page got corrupted in hardware and contain=
s
  * data with incorrect ECC bits that triggered a machine check. Accessing =
is
  * not safe since it may cause another machine check. Don't touch!
+ *
+ * PG_wasactive reflects that a page previously was promoted to active sta=
tus.
+ * Such pages should be considered higher priority for cleancache backends=
.
  */
=20
 /*
@@ -107,6 +110,9 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 =09PG_compound_lock,
 #endif
+#ifdef CONFIG_CLEANCACHE
+=09PG_was_active,
+#endif
 =09__NR_PAGEFLAGS,
=20
 =09/* Filesystems */
@@ -209,6 +215,10 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapB=
acked, swapbacked)
=20
 __PAGEFLAG(SlobFree, slob_free)
=20
+#ifdef CONFIG_CLEANCACHE
+PAGEFLAG(WasActive, was_active)
+#endif
+
 /*
  * Private page markings that may be used by the filesystem that owns the =
page
  * for its own purposes.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..fdd9e88 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -636,6 +636,8 @@ void putback_lru_page(struct page *page)
 =09int was_unevictable =3D PageUnevictable(page);
=20
 =09VM_BUG_ON(PageLRU(page));
+=09if (active)
+=09=09SetPageWasActive(page);
=20
 redo:
 =09ClearPageUnevictable(page);
@@ -1429,6 +1431,7 @@ update_isolated_counts(struct mem_cgroup_zone *mz,
 =09=09if (PageActive(page)) {
 =09=09=09lru +=3D LRU_ACTIVE;
 =09=09=09ClearPageActive(page);
+=09=09=09SetPageWasActive(page);
 =09=09=09nr_active +=3D numpages;
 =09=09}
 =09=09count[lru] +=3D numpages;
@@ -1755,6 +1758,7 @@ static void shrink_active_list(unsigned long nr_to_sc=
an,
 =09=09}
=20
 =09=09ClearPageActive(page);=09/* we are de-activating */
+=09=09SetPageWasActive(page);
 =09=09list_add(&page->lru, &l_inactive);
 =09}
=20
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/=
zcache-main.c
index 642840c..8c81ec2 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1696,6 +1696,8 @@ static void zcache_cleancache_put_page(int pool_id,
 =09u32 ind =3D (u32) index;
 =09struct tmem_oid oid =3D *(struct tmem_oid *)&key;
=20
+=09if (!PageWasActive(page))
+=09=09return;
 =09if (likely(ind =3D=3D index))
 =09=09(void)zcache_put_page(LOCAL_CLIENT, pool_id, &oid, index, page);
 }
@@ -1710,6 +1712,8 @@ static int zcache_cleancache_get_page(int pool_id,
=20
 =09if (likely(ind =3D=3D index))
 =09=09ret =3D zcache_get_page(LOCAL_CLIENT, pool_id, &oid, index, page);
+=09if (ret =3D=3D 0)
+=09=09SetPageWasActive(page);
 =09return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
