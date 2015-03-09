Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 56A546B006C
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 06:27:34 -0400 (EDT)
Received: by wivr20 with SMTP id r20so18811515wiv.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 03:27:32 -0700 (PDT)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id hx8si30049371wjb.100.2015.03.09.03.27.31
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 03:27:31 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 2/6] memtest: use phys_addr_t for physical addresses
Date: Mon,  9 Mar 2015 10:27:06 +0000
Message-Id: <1425896830-19705-3-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
References: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, lauraa@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com, linux@arm.linux.org.uk, arnd@arndb.de, mark.rutland@arm.com, ard.biesheuvel@linaro.org, baruch@tkos.co.il, rdunlap@infradead.org

Since memtest might be used by other architectures pass input parameters
as phys_addr_t instead of long to prevent overflow.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
---
 include/linux/memblock.h |    4 ++--
 mm/memtest.c             |   16 ++++++++--------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 6724cb0..9497ec7 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -366,9 +366,9 @@ static inline unsigned long memblock_region_reserved_en=
d_pfn(const struct memblo
 #endif
=20
 #ifdef CONFIG_MEMTEST
-extern void early_memtest(unsigned long start, unsigned long end);
+extern void early_memtest(phys_addr_t start, phys_addr_t end);
 #else
-static inline void early_memtest(unsigned long start, unsigned long end)
+static inline void early_memtest(phys_addr_t start, phys_addr_t end)
 {
 }
 #endif
diff --git a/mm/memtest.c b/mm/memtest.c
index 1e9da79..1997d93 100644
--- a/mm/memtest.c
+++ b/mm/memtest.c
@@ -29,7 +29,7 @@ static u64 patterns[] __initdata =3D {
 =090x7a6c7258554e494cULL, /* yeah ;-) */
 };
=20
-static void __init reserve_bad_mem(u64 pattern, u64 start_bad, u64 end_bad=
)
+static void __init reserve_bad_mem(u64 pattern, phys_addr_t start_bad, phy=
s_addr_t end_bad)
 {
 =09printk(KERN_INFO "  %016llx bad mem addr %010llx - %010llx reserved\n",
 =09       (unsigned long long) pattern,
@@ -38,11 +38,11 @@ static void __init reserve_bad_mem(u64 pattern, u64 sta=
rt_bad, u64 end_bad)
 =09memblock_reserve(start_bad, end_bad - start_bad);
 }
=20
-static void __init memtest(u64 pattern, u64 start_phys, u64 size)
+static void __init memtest(u64 pattern, phys_addr_t start_phys, phys_addr_=
t size)
 {
 =09u64 *p, *start, *end;
-=09u64 start_bad, last_bad;
-=09u64 start_phys_aligned;
+=09phys_addr_t start_bad, last_bad;
+=09phys_addr_t start_phys_aligned;
 =09const size_t incr =3D sizeof(pattern);
=20
 =09start_phys_aligned =3D ALIGN(start_phys, incr);
@@ -69,14 +69,14 @@ static void __init memtest(u64 pattern, u64 start_phys,=
 u64 size)
 =09=09reserve_bad_mem(pattern, start_bad, last_bad + incr);
 }
=20
-static void __init do_one_pass(u64 pattern, u64 start, u64 end)
+static void __init do_one_pass(u64 pattern, phys_addr_t start, phys_addr_t=
 end)
 {
 =09u64 i;
 =09phys_addr_t this_start, this_end;
=20
 =09for_each_free_mem_range(i, NUMA_NO_NODE, &this_start, &this_end, NULL) =
{
-=09=09this_start =3D clamp_t(phys_addr_t, this_start, start, end);
-=09=09this_end =3D clamp_t(phys_addr_t, this_end, start, end);
+=09=09this_start =3D clamp(this_start, start, end);
+=09=09this_end =3D clamp(this_end, start, end);
 =09=09if (this_start < this_end) {
 =09=09=09printk(KERN_INFO "  %010llx - %010llx pattern %016llx\n",
 =09=09=09       (unsigned long long)this_start,
@@ -102,7 +102,7 @@ static int __init parse_memtest(char *arg)
=20
 early_param("memtest", parse_memtest);
=20
-void __init early_memtest(unsigned long start, unsigned long end)
+void __init early_memtest(phys_addr_t start, phys_addr_t end)
 {
 =09unsigned int i;
 =09unsigned int idx =3D 0;
--=20
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
