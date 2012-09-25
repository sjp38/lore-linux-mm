Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3EDD36B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 19:21:39 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <daef3c9f-c51b-4668-81c7-a21927db5bac@default>
Date: Tue, 25 Sep 2012 16:21:09 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH] zsmalloc added back to zcache2 (Was: [RFC] mm: add
 support for zsmalloc and zcache)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

Attached patch applies to staging-next and adds zsmalloc
support, optionally at compile-time and run-time, back into
zcache (aka zcache2).  It is only lightly tested and does
not provide some of the debug info from old zcache (aka zcache1)
because it needs to be converted from sysfs to debugfs.
I'll leave that as an exercise for someone else as I'm
not sure if any of those debug fields are critical to
anyone's needs and some of the datatypes are not supported
by debugfs.

Apologies if there are line breaks... I can't send this from
a linux mailer right now.  If it is broken, let me know,
and I will re-post tomorrow.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

diff --git a/drivers/staging/ramster/Kconfig b/drivers/staging/ramster/Kcon=
fig
index 843c541..28403cc 100644
--- a/drivers/staging/ramster/Kconfig
+++ b/drivers/staging/ramster/Kconfig
@@ -15,6 +15,17 @@ config ZCACHE2
 =09  again in the future.  Until then, zcache2 is a single-node
 =09  version of ramster.
=20
+config ZCACHE_ZSMALLOC
+=09bool "Allow use of zsmalloc allocator for compression of swap pages"
+=09depends on ZSMALLOC=3Dy
+=09default n
+=09help
+=09  Zsmalloc is a much more efficient allocator for compresssed
+=09  pages but currently has some design deficiencies in that it
+=09  does not support reclaim nor compaction.  Select this if
+=09  you are certain your workload will fit or has mostly short
+=09  running processes.
+
 config RAMSTER
 =09bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
 =09depends on CONFIGFS_FS=3Dy && SYSFS=3Dy && !HIGHMEM && ZCACHE2=3Dy
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramste=
r/zcache-main.c
index a09dd5c..9a4d780 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -26,6 +26,12 @@
 #include <linux/cleancache.h>
 #include <linux/frontswap.h>
 #include "tmem.h"
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+#include "../zsmalloc/zsmalloc.h"
+static int zsmalloc_enabled;
+#else
+#define zsmalloc_enabled 0
+#endif
 #include "zcache.h"
 #include "zbud.h"
 #include "ramster.h"
@@ -182,6 +188,35 @@ static unsigned long zcache_last_inactive_anon_pagefra=
mes;
 static unsigned long zcache_eph_nonactive_puts_ignored;
 static unsigned long zcache_pers_nonactive_puts_ignored;
=20
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+#define ZS_CHUNK_SHIFT=096
+#define ZS_CHUNK_SIZE=09(1 << ZS_CHUNK_SHIFT)
+#define ZS_CHUNK_MASK=09(~(ZS_CHUNK_SIZE-1))
+#define ZS_NCHUNKS=09(((PAGE_SIZE - sizeof(struct tmem_handle)) & \
+=09=09=09=09ZS_CHUNK_MASK) >> ZS_CHUNK_SHIFT)
+#define ZS_MAX_CHUNK=09(ZS_NCHUNKS-1)
+
+/* total number of persistent pages may not exceed this percentage */
+static unsigned int zv_page_count_policy_percent =3D 75;
+/*
+ * byte count defining poor compression; pages with greater zsize will be
+ * rejected
+ */
+static unsigned int zv_max_zsize =3D (PAGE_SIZE / 8) * 7;
+/*
+ * byte count defining poor *mean* compression; pages with greater zsize
+ * will be rejected until sufficient better-compressed pages are accepted
+ * driving the mean below this threshold
+ */
+static unsigned int zv_max_mean_zsize =3D (PAGE_SIZE / 8) * 5;
+
+static atomic_t zv_curr_dist_counts[ZS_NCHUNKS];
+static atomic_t zv_cumul_dist_counts[ZS_NCHUNKS];
+static atomic_t zcache_curr_pers_pampd_count =3D ATOMIC_INIT(0);
+static unsigned long zcache_curr_pers_pampd_count_max;
+
+#endif
+
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
 #define=09zdfs=09debugfs_create_size_t
@@ -370,6 +405,13 @@ int zcache_new_client(uint16_t cli_id)
 =09if (cli->allocated)
 =09=09goto out;
 =09cli->allocated =3D 1;
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+=09if (zsmalloc_enabled) {
+=09=09cli->zspool =3D zs_create_pool("zcache", ZCACHE_GFP_MASK);
+=09=09if (cli->zspool =3D=3D NULL)
+=09=09=09goto out;
+=09}
+#endif
 =09ret =3D 0;
 out:
 =09return ret;
@@ -632,6 +674,105 @@ out:
 =09return pampd;
 }
=20
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+struct zv_hdr {
+=09uint32_t pool_id;
+=09struct tmem_oid oid;
+=09uint32_t index;
+=09size_t size;
+};
+
+static unsigned long zv_create(struct zcache_client *cli, uint32_t pool_id=
,
+=09=09=09=09struct tmem_oid *oid, uint32_t index,
+=09=09=09=09struct page *page)
+{
+=09struct zv_hdr *zv;
+=09int chunks;
+=09unsigned long curr_pers_pampd_count, total_zsize, zv_mean_zsize;
+=09unsigned long handle =3D 0;
+=09void *cdata;
+=09unsigned clen;
+
+=09curr_pers_pampd_count =3D atomic_read(&zcache_curr_pers_pampd_count);
+=09if (curr_pers_pampd_count >
+=09    (zv_page_count_policy_percent * totalram_pages) / 100)
+=09=09goto out;
+=09zcache_compress(page, &cdata, &clen);
+=09/* reject if compression is too poor */
+=09if (clen > zv_max_zsize) {
+=09=09zcache_compress_poor++;
+=09=09goto out;
+=09}
+=09/* reject if mean compression is too poor */
+=09if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
+=09=09total_zsize =3D zs_get_total_size_bytes(cli->zspool);
+=09=09zv_mean_zsize =3D div_u64(total_zsize, curr_pers_pampd_count);
+=09=09if (zv_mean_zsize > zv_max_mean_zsize) {
+=09=09=09zcache_mean_compress_poor++;
+=09=09=09goto out;
+=09=09}
+=09}
+=09handle =3D zs_malloc(cli->zspool, clen + sizeof(struct zv_hdr));
+=09if (!handle)
+=09=09goto out;
+=09zv =3D zs_map_object(cli->zspool, handle, ZS_MM_WO);
+=09zv->index =3D index;
+=09zv->oid =3D *oid;
+=09zv->pool_id =3D pool_id;
+=09zv->size =3D clen;
+=09memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
+=09zs_unmap_object(cli->zspool, handle);
+=09chunks =3D (clen + (ZS_CHUNK_SIZE - 1)) >> ZS_CHUNK_SHIFT;
+=09atomic_inc(&zv_curr_dist_counts[chunks]);
+=09atomic_inc(&zv_cumul_dist_counts[chunks]);
+=09curr_pers_pampd_count =3D
+=09=09atomic_inc_return(&zcache_curr_pers_pampd_count);
+=09if (curr_pers_pampd_count > zcache_curr_pers_pampd_count_max)
+=09=09zcache_curr_pers_pampd_count_max =3D curr_pers_pampd_count;
+out:
+=09return handle;
+}
+
+static void zv_free(struct zs_pool *pool, unsigned long handle)
+{
+=09unsigned long flags;
+=09struct zv_hdr *zv;
+=09uint16_t size;
+=09int chunks;
+
+=09zv =3D zs_map_object(pool, handle, ZS_MM_RW);
+=09size =3D zv->size + sizeof(struct zv_hdr);
+=09zs_unmap_object(pool, handle);
+
+=09chunks =3D (size + (ZS_CHUNK_SIZE - 1)) >> ZS_CHUNK_SHIFT;
+=09BUG_ON(chunks >=3D ZS_NCHUNKS);
+=09atomic_dec(&zv_curr_dist_counts[chunks]);
+
+=09local_irq_save(flags);
+=09zs_free(pool, handle);
+=09local_irq_restore(flags);
+}
+
+static void zv_decompress(struct page *page, unsigned long handle)
+{
+=09unsigned int clen =3D PAGE_SIZE;
+=09char *to_va;
+=09int ret;
+=09struct zv_hdr *zv;
+
+=09zv =3D zs_map_object(zcache_host.zspool, handle, ZS_MM_RO);
+=09BUG_ON(zv->size =3D=3D 0);
+=09to_va =3D kmap_atomic(page);
+=09ret =3D zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, (char *)zv + sizeof(*z=
v),
+=09=09=09=09zv->size, to_va, &clen);
+=09kunmap_atomic(to_va);
+=09zs_unmap_object(zcache_host.zspool, handle);
+=09BUG_ON(ret);
+=09BUG_ON(clen !=3D PAGE_SIZE);
+}
+#endif
+
+
 /*
  * This is called directly from zcache_put_page to pre-allocate space
  * to store a zpage.
@@ -677,6 +818,16 @@ void *zcache_pampd_create(char *data, unsigned int siz=
e, bool raw,
 =09 */
 =09if (eph)
 =09=09pampd =3D zcache_pampd_eph_create(data, size, raw, th);
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+=09else if (zsmalloc_enabled) {
+=09=09struct zcache_client *cli =3D
+=09=09=09=09zcache_get_client_by_id(th->client_id);
+=09=09struct page *page =3D (struct page *)(data);
+=09=09BUG_ON(size !=3D PAGE_SIZE);
+=09=09pampd =3D (void *)zv_create(cli, th->pool_id, &th->oid,
+=09=09=09=09=09=09th->index, page);
+=09}
+#endif
 =09else
 =09=09pampd =3D zcache_pampd_pers_create(data, size, raw, th);
 out:
@@ -689,7 +840,8 @@ out:
  */
 void zcache_pampd_create_finish(void *pampd, bool eph)
 {
-=09zbud_create_finish((struct zbudref *)pampd, eph);
+=09if (eph || !zsmalloc_enabled)
+=09=09zbud_create_finish((struct zbudref *)pampd, eph);
 }
=20
 /*
@@ -738,7 +890,13 @@ static int zcache_pampd_get_data(char *data, size_t *s=
izep, bool raw,
 =09=09ret =3D zbud_copy_from_zbud(data, (struct zbudref *)pampd,
 =09=09=09=09=09=09sizep, eph);
 =09else {
-=09=09ret =3D zbud_decompress((struct page *)(data),
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+=09=09if (zsmalloc_enabled && is_persistent(pool))
+=09=09=09zv_decompress((struct page *)(data),
+=09=09=09=09=09(unsigned long)pampd);
+=09=09else
+#endif
+=09=09=09ret =3D zbud_decompress((struct page *)(data),
 =09=09=09=09=09(struct zbudref *)pampd, false,
 =09=09=09=09=09zcache_decompress);
 =09=09*sizep =3D PAGE_SIZE;
@@ -824,6 +982,13 @@ static void zcache_pampd_free(void *pampd, struct tmem=
_pool *pool,
 =09=09zcache_eph_zbytes =3D
 =09=09    atomic_long_sub_return(zsize, &zcache_eph_zbytes_atomic);
 =09=09/* FIXME CONFIG_RAMSTER... check acct parameter? */
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+=09} else if (zsmalloc_enabled) {
+=09=09struct zcache_client *cli =3D pool->client;
+=09=09zv_free(cli->zspool, (unsigned long)pampd);
+=09=09atomic_dec(&zcache_curr_pers_pampd_count);
+=09=09BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
+#endif
 =09} else {
 =09=09page =3D zbud_free_and_delist((struct zbudref *)pampd,
 =09=09=09=09=09=09false, &zsize, &zpages);
@@ -837,7 +1002,7 @@ static void zcache_pampd_free(void *pampd, struct tmem=
_pool *pool,
 =09}
 =09if (!is_local_client(pool->client))
 =09=09ramster_count_foreign_pages(is_ephemeral(pool), -1);
-=09if (page)
+=09if (page && !zsmalloc_enabled)
 =09=09zcache_free_page(page);
 }
=20
@@ -1657,6 +1822,17 @@ static int __init enable_ramster(char *s)
 }
 __setup("ramster", enable_ramster);
=20
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+static int __init enable_zsmalloc(char *s)
+{
+=09zcache_enabled =3D 1;
+=09zsmalloc_enabled =3D 1;
+=09return 1;
+}
+__setup("zcache-zsmalloc", enable_zsmalloc);
+
+#endif
+
 /* allow independent dynamic disabling of cleancache and frontswap */
=20
 static int __init no_cleancache(char *s)
@@ -1800,6 +1976,12 @@ static int __init zcache_init(void)
 =09=09old_ops =3D zcache_frontswap_register_ops();
 =09=09if (frontswap_has_exclusive_gets)
 =09=09=09frontswap_tmem_exclusive_gets(true);
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+=09=09if (zsmalloc_enabled)
+=09=09=09pr_info("%s: frontswap enabled using kernel"
+=09=09=09=09"transcendent memory and zsmalloc\n", namestr);
+=09=09else
+#endif
 =09=09pr_info("%s: frontswap enabled using kernel transcendent "
 =09=09=09"memory and compression buddies\n", namestr);
 #ifdef ZCACHE_DEBUG
diff --git a/drivers/staging/ramster/zcache.h b/drivers/staging/ramster/zca=
che.h
index 81722b3..34d63b1 100644
--- a/drivers/staging/ramster/zcache.h
+++ b/drivers/staging/ramster/zcache.h
@@ -22,6 +22,9 @@ struct tmem_pool;
=20
 struct zcache_client {
 =09struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+=09struct zs_pool *zspool;
+#endif
 =09bool allocated;
 =09atomic_t refcount;
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
