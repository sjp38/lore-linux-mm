Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E852A6B0062
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 09:50:30 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 06/11] zcache: Fix compile warnings due to usage of debugfs_create_size_t
Date: Mon,  5 Nov 2012 09:37:29 -0500
Message-Id: <1352126254-28933-7-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
References: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, ngupta@vflare.org, minchan@kernel.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
Cc: akpm@linux-foundation.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

When we compile we get tons of:
include/linux/debugfs.h:80:16: note: expected =E2=80=98size_t *=E2=80=99 =
but argument is
of type =E2=80=98long int *=E2=80=99
drivers/staging/ramster/zcache-main.c:279:2: warning: passing argument 4
of =E2=80=98debugfs_create_size_t=E2=80=99 from incompatible pointer type=
 [enabled by d
efault]

which is b/c we end up using 'unsigned' or 'unsigned long' instead
of 'ssize_t'. So lets fix this up and use the proper type.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |  135 +++++++++++++++++----------=
------
 1 files changed, 68 insertions(+), 67 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/rams=
ter/zcache-main.c
index 3402acc..1f354f2 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -132,23 +132,23 @@ static struct kmem_cache *zcache_obj_cache;
 static DEFINE_PER_CPU(struct zcache_preload, zcache_preloads) =3D { 0, }=
;
=20
 /* we try to keep these statistics SMP-consistent */
-static long zcache_obj_count;
+static ssize_t zcache_obj_count;
 static atomic_t zcache_obj_atomic =3D ATOMIC_INIT(0);
-static long zcache_obj_count_max;
+static ssize_t zcache_obj_count_max;
 static inline void inc_zcache_obj_count(void)
 {
 	zcache_obj_count =3D atomic_inc_return(&zcache_obj_atomic);
 	if (zcache_obj_count > zcache_obj_count_max)
 		zcache_obj_count_max =3D zcache_obj_count;
 }
-static long zcache_objnode_count;
+static ssize_t zcache_objnode_count;
 static inline void dec_zcache_obj_count(void)
 {
 	zcache_obj_count =3D atomic_dec_return(&zcache_obj_atomic);
 	BUG_ON(zcache_obj_count < 0);
 };
 static atomic_t zcache_objnode_atomic =3D ATOMIC_INIT(0);
-static long zcache_objnode_count_max;
+static ssize_t zcache_objnode_count_max;
 static inline void inc_zcache_objnode_count(void)
 {
 	zcache_objnode_count =3D atomic_inc_return(&zcache_objnode_atomic);
@@ -182,64 +182,65 @@ static inline void inc_zcache_pers_zbytes(unsigned =
clen)
 	if (zcache_pers_zbytes > zcache_pers_zbytes_max)
 		zcache_pers_zbytes_max =3D zcache_pers_zbytes;
 }
-static long zcache_eph_pageframes;
+static ssize_t zcache_eph_pageframes;
 static inline void dec_zcache_pers_zbytes(unsigned zsize)
 {
 	zcache_pers_zbytes =3D atomic_long_sub_return(zsize, &zcache_pers_zbyte=
s_atomic);
 }
 static atomic_t zcache_eph_pageframes_atomic =3D ATOMIC_INIT(0);
-static long zcache_eph_pageframes_max;
+static ssize_t zcache_eph_pageframes_max;
 static inline void inc_zcache_eph_pageframes(void)
 {
 	zcache_eph_pageframes =3D atomic_inc_return(&zcache_eph_pageframes_atom=
ic);
 	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
 		zcache_eph_pageframes_max =3D zcache_eph_pageframes;
 };
-static long zcache_pers_pageframes;
+static ssize_t zcache_pers_pageframes;
 static inline void dec_zcache_eph_pageframes(void)
 {
 	zcache_eph_pageframes =3D atomic_dec_return(&zcache_eph_pageframes_atom=
ic);
 };
 static atomic_t zcache_pers_pageframes_atomic =3D ATOMIC_INIT(0);
-static long zcache_pers_pageframes_max;
+static ssize_t zcache_pers_pageframes_max;
 static inline void inc_zcache_pers_pageframes(void)
 {
 	zcache_pers_pageframes =3D atomic_inc_return(&zcache_pers_pageframes_at=
omic);
 	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
 		zcache_pers_pageframes_max =3D zcache_pers_pageframes;
 }
-static long zcache_pageframes_alloced;
+static ssize_t zcache_pageframes_alloced;
 static inline void dec_zcache_pers_pageframes(void)
 {
 	zcache_pers_pageframes =3D atomic_dec_return(&zcache_pers_pageframes_at=
omic);
 }
 static atomic_t zcache_pageframes_alloced_atomic =3D ATOMIC_INIT(0);
+static ssize_t zcache_pageframes_freed;
+static atomic_t zcache_pageframes_freed_atomic =3D ATOMIC_INIT(0);
+static ssize_t zcache_eph_zpages;
 static inline void inc_zcache_pageframes_alloced(void)
 {
 	zcache_pageframes_alloced =3D atomic_inc_return(&zcache_pageframes_allo=
ced_atomic);
 };
-static long zcache_pageframes_freed;
-static atomic_t zcache_pageframes_freed_atomic =3D ATOMIC_INIT(0);
 static inline void inc_zcache_pageframes_freed(void)
 {
 	zcache_pageframes_freed =3D atomic_inc_return(&zcache_pageframes_freed_=
atomic);
 }
-static long zcache_eph_zpages;
+static ssize_t zcache_eph_zpages;
 static atomic_t zcache_eph_zpages_atomic =3D ATOMIC_INIT(0);
-static long zcache_eph_zpages_max;
+static ssize_t zcache_eph_zpages_max;
 static inline void inc_zcache_eph_zpages(void)
 {
 	zcache_eph_zpages =3D atomic_inc_return(&zcache_eph_zpages_atomic);
 	if (zcache_eph_zpages > zcache_eph_zpages_max)
 		zcache_eph_zpages_max =3D zcache_eph_zpages;
 }
-static long zcache_pers_zpages;
+static ssize_t zcache_pers_zpages;
 static inline void dec_zcache_eph_zpages(unsigned zpages)
 {
 	zcache_eph_zpages =3D atomic_sub_return(zpages, &zcache_eph_zpages_atom=
ic);
 }
 static atomic_t zcache_pers_zpages_atomic =3D ATOMIC_INIT(0);
-static long zcache_pers_zpages_max;
+static ssize_t zcache_pers_zpages_max;
 static inline void inc_zcache_pers_zpages(void)
 {
 	zcache_pers_zpages =3D atomic_inc_return(&zcache_pers_zpages_atomic);
@@ -259,29 +260,29 @@ static inline unsigned long curr_pageframes_count(v=
oid)
 		atomic_read(&zcache_pers_pageframes_atomic);
 };
 /* but for the rest of these, counting races are ok */
-static unsigned long zcache_flush_total;
-static unsigned long zcache_flush_found;
-static unsigned long zcache_flobj_total;
-static unsigned long zcache_flobj_found;
-static unsigned long zcache_failed_eph_puts;
-static unsigned long zcache_failed_pers_puts;
-static unsigned long zcache_failed_getfreepages;
-static unsigned long zcache_failed_alloc;
-static unsigned long zcache_put_to_flush;
-static unsigned long zcache_compress_poor;
-static unsigned long zcache_mean_compress_poor;
-static unsigned long zcache_eph_ate_tail;
-static unsigned long zcache_eph_ate_tail_failed;
-static unsigned long zcache_pers_ate_eph;
-static unsigned long zcache_pers_ate_eph_failed;
-static unsigned long zcache_evicted_eph_zpages;
-static unsigned long zcache_evicted_eph_pageframes;
-static unsigned long zcache_last_active_file_pageframes;
-static unsigned long zcache_last_inactive_file_pageframes;
-static unsigned long zcache_last_active_anon_pageframes;
-static unsigned long zcache_last_inactive_anon_pageframes;
-static unsigned long zcache_eph_nonactive_puts_ignored;
-static unsigned long zcache_pers_nonactive_puts_ignored;
+static ssize_t zcache_flush_total;
+static ssize_t zcache_flush_found;
+static ssize_t zcache_flobj_total;
+static ssize_t zcache_flobj_found;
+static ssize_t zcache_failed_eph_puts;
+static ssize_t zcache_failed_pers_puts;
+static ssize_t zcache_failed_getfreepages;
+static ssize_t zcache_failed_alloc;
+static ssize_t zcache_put_to_flush;
+static ssize_t zcache_compress_poor;
+static ssize_t zcache_mean_compress_poor;
+static ssize_t zcache_eph_ate_tail;
+static ssize_t zcache_eph_ate_tail_failed;
+static ssize_t zcache_pers_ate_eph;
+static ssize_t zcache_pers_ate_eph_failed;
+static ssize_t zcache_evicted_eph_zpages;
+static ssize_t zcache_evicted_eph_pageframes;
+static ssize_t zcache_last_active_file_pageframes;
+static ssize_t zcache_last_inactive_file_pageframes;
+static ssize_t zcache_last_active_anon_pageframes;
+static ssize_t zcache_last_inactive_anon_pageframes;
+static ssize_t zcache_eph_nonactive_puts_ignored;
+static ssize_t zcache_pers_nonactive_puts_ignored;
=20
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
@@ -351,41 +352,41 @@ static int zcache_debugfs_init(void)
 /* developers can call this in case of ooms, e.g. to find memory leaks *=
/
 void zcache_dump(void)
 {
-	pr_info("zcache: obj_count=3D%lu\n", zcache_obj_count);
-	pr_info("zcache: obj_count_max=3D%lu\n", zcache_obj_count_max);
-	pr_info("zcache: objnode_count=3D%lu\n", zcache_objnode_count);
-	pr_info("zcache: objnode_count_max=3D%lu\n", zcache_objnode_count_max);
-	pr_info("zcache: flush_total=3D%lu\n", zcache_flush_total);
-	pr_info("zcache: flush_found=3D%lu\n", zcache_flush_found);
-	pr_info("zcache: flobj_total=3D%lu\n", zcache_flobj_total);
-	pr_info("zcache: flobj_found=3D%lu\n", zcache_flobj_found);
-	pr_info("zcache: failed_eph_puts=3D%lu\n", zcache_failed_eph_puts);
-	pr_info("zcache: failed_pers_puts=3D%lu\n", zcache_failed_pers_puts);
-	pr_info("zcache: failed_get_free_pages=3D%lu\n",
+	pr_info("zcache: obj_count=3D%u\n", zcache_obj_count);
+	pr_info("zcache: obj_count_max=3D%u\n", zcache_obj_count_max);
+	pr_info("zcache: objnode_count=3D%u\n", zcache_objnode_count);
+	pr_info("zcache: objnode_count_max=3D%u\n", zcache_objnode_count_max);
+	pr_info("zcache: flush_total=3D%u\n", zcache_flush_total);
+	pr_info("zcache: flush_found=3D%u\n", zcache_flush_found);
+	pr_info("zcache: flobj_total=3D%u\n", zcache_flobj_total);
+	pr_info("zcache: flobj_found=3D%u\n", zcache_flobj_found);
+	pr_info("zcache: failed_eph_puts=3D%u\n", zcache_failed_eph_puts);
+	pr_info("zcache: failed_pers_puts=3D%u\n", zcache_failed_pers_puts);
+	pr_info("zcache: failed_get_free_pages=3D%u\n",
 				zcache_failed_getfreepages);
-	pr_info("zcache: failed_alloc=3D%lu\n", zcache_failed_alloc);
-	pr_info("zcache: put_to_flush=3D%lu\n", zcache_put_to_flush);
-	pr_info("zcache: compress_poor=3D%lu\n", zcache_compress_poor);
-	pr_info("zcache: mean_compress_poor=3D%lu\n",
+	pr_info("zcache: failed_alloc=3D%u\n", zcache_failed_alloc);
+	pr_info("zcache: put_to_flush=3D%u\n", zcache_put_to_flush);
+	pr_info("zcache: compress_poor=3D%u\n", zcache_compress_poor);
+	pr_info("zcache: mean_compress_poor=3D%u\n",
 				zcache_mean_compress_poor);
-	pr_info("zcache: eph_ate_tail=3D%lu\n", zcache_eph_ate_tail);
-	pr_info("zcache: eph_ate_tail_failed=3D%lu\n",
+	pr_info("zcache: eph_ate_tail=3D%u\n", zcache_eph_ate_tail);
+	pr_info("zcache: eph_ate_tail_failed=3D%u\n",
 				zcache_eph_ate_tail_failed);
-	pr_info("zcache: pers_ate_eph=3D%lu\n", zcache_pers_ate_eph);
-	pr_info("zcache: pers_ate_eph_failed=3D%lu\n",
+	pr_info("zcache: pers_ate_eph=3D%u\n", zcache_pers_ate_eph);
+	pr_info("zcache: pers_ate_eph_failed=3D%u\n",
 				zcache_pers_ate_eph_failed);
-	pr_info("zcache: evicted_eph_zpages=3D%lu\n", zcache_evicted_eph_zpages=
);
-	pr_info("zcache: evicted_eph_pageframes=3D%lu\n",
+	pr_info("zcache: evicted_eph_zpages=3D%u\n", zcache_evicted_eph_zpages)=
;
+	pr_info("zcache: evicted_eph_pageframes=3D%u\n",
 				zcache_evicted_eph_pageframes);
-	pr_info("zcache: eph_pageframes=3D%lu\n", zcache_eph_pageframes);
-	pr_info("zcache: eph_pageframes_max=3D%lu\n", zcache_eph_pageframes_max=
);
-	pr_info("zcache: pers_pageframes=3D%lu\n", zcache_pers_pageframes);
-	pr_info("zcache: pers_pageframes_max=3D%lu\n",
+	pr_info("zcache: eph_pageframes=3D%u\n", zcache_eph_pageframes);
+	pr_info("zcache: eph_pageframes_max=3D%u\n", zcache_eph_pageframes_max)=
;
+	pr_info("zcache: pers_pageframes=3D%u\n", zcache_pers_pageframes);
+	pr_info("zcache: pers_pageframes_max=3D%u\n",
 				zcache_pers_pageframes_max);
-	pr_info("zcache: eph_zpages=3D%lu\n", zcache_eph_zpages);
-	pr_info("zcache: eph_zpages_max=3D%lu\n", zcache_eph_zpages_max);
-	pr_info("zcache: pers_zpages=3D%lu\n", zcache_pers_zpages);
-	pr_info("zcache: pers_zpages_max=3D%lu\n", zcache_pers_zpages_max);
+	pr_info("zcache: eph_zpages=3D%u\n", zcache_eph_zpages);
+	pr_info("zcache: eph_zpages_max=3D%u\n", zcache_eph_zpages_max);
+	pr_info("zcache: pers_zpages=3D%u\n", zcache_pers_zpages);
+	pr_info("zcache: pers_zpages_max=3D%u\n", zcache_pers_zpages_max);
 	pr_info("zcache: eph_zbytes=3D%llu\n",
 				(unsigned long long)zcache_eph_zbytes);
 	pr_info("zcache: eph_zbytes_max=3D%llu\n",
--=20
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
