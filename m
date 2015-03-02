Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8F41D6B0071
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 09:55:59 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id x12so23084807qac.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 06:55:59 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id q76si11803166qgq.44.2015.03.02.06.55.56
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 06:55:57 -0800 (PST)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [RFC PATCH 2/4] memtest: use phys_addr_t for physical addresses
Date: Mon,  2 Mar 2015 14:55:43 +0000
Message-Id: <1425308145-20769-3-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, lauraa@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com, linux@arm.linux.org.uk, arnd@arndb.de, mark.rutland@arm.com, ard.biesheuvel@linaro.org

Since memtest might be used by other architectures pass input parameters
as phys_addr_t instead of long to prevent overflow.
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
