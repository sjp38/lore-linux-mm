Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id CD75E6B006E
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 06:27:36 -0400 (EDT)
Received: by wghl2 with SMTP id l2so30083254wgh.8
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 03:27:35 -0700 (PDT)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id ba2si35994832wib.73.2015.03.09.03.27.31
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 03:27:31 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 1/6] mm: move memtest under /mm
Date: Mon,  9 Mar 2015 10:27:05 +0000
Message-Id: <1425896830-19705-2-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
References: <1425896830-19705-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, lauraa@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com, linux@arm.linux.org.uk, arnd@arndb.de, mark.rutland@arm.com, ard.biesheuvel@linaro.org, baruch@tkos.co.il, rdunlap@infradead.org

There is nothing platform dependent in the core memtest code, so other plat=
form
might benefit of this feature too.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
---
 arch/x86/Kconfig            |   11 ----
 arch/x86/include/asm/e820.h |    8 ---
 arch/x86/mm/Makefile        |    2 -
 arch/x86/mm/memtest.c       |  118 ---------------------------------------=
----
 include/linux/memblock.h    |    8 +++
 lib/Kconfig.debug           |   11 ++++
 mm/Makefile                 |    1 +
 mm/memtest.c                |  118 +++++++++++++++++++++++++++++++++++++++=
++++
 8 files changed, 138 insertions(+), 139 deletions(-)
 delete mode 100644 arch/x86/mm/memtest.c
 create mode 100644 mm/memtest.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b7d31ca..d16e510 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -716,17 +716,6 @@ endif #HYPERVISOR_GUEST
 config NO_BOOTMEM
 =09def_bool y
=20
-config MEMTEST
-=09bool "Memtest"
-=09---help---
-=09  This option adds a kernel parameter 'memtest', which allows memtest
-=09  to be set.
-=09        memtest=3D0, mean disabled; -- default
-=09        memtest=3D1, mean do 1 test pattern;
-=09        ...
-=09        memtest=3D4, mean do 4 test patterns.
-=09  If you are unsure how to answer this question, answer N.
-
 source "arch/x86/Kconfig.cpu"
=20
 config HPET_TIMER
diff --git a/arch/x86/include/asm/e820.h b/arch/x86/include/asm/e820.h
index 779c2ef..3ab0537 100644
--- a/arch/x86/include/asm/e820.h
+++ b/arch/x86/include/asm/e820.h
@@ -40,14 +40,6 @@ static inline void e820_mark_nosave_regions(unsigned lon=
g limit_pfn)
 }
 #endif
=20
-#ifdef CONFIG_MEMTEST
-extern void early_memtest(unsigned long start, unsigned long end);
-#else
-static inline void early_memtest(unsigned long start, unsigned long end)
-{
-}
-#endif
-
 extern unsigned long e820_end_of_ram_pfn(void);
 extern unsigned long e820_end_of_low_ram_pfn(void);
 extern u64 early_reserve_e820(u64 sizet, u64 align);
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index c4cc740..a482d10 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -32,6 +32,4 @@ obj-$(CONFIG_AMD_NUMA)=09=09+=3D amdtopology.o
 obj-$(CONFIG_ACPI_NUMA)=09=09+=3D srat.o
 obj-$(CONFIG_NUMA_EMU)=09=09+=3D numa_emulation.o
=20
-obj-$(CONFIG_MEMTEST)=09=09+=3D memtest.o
-
 obj-$(CONFIG_X86_INTEL_MPX)=09+=3D mpx.o
diff --git a/arch/x86/mm/memtest.c b/arch/x86/mm/memtest.c
deleted file mode 100644
index 1e9da79..0000000
--- a/arch/x86/mm/memtest.c
+++ /dev/null
@@ -1,118 +0,0 @@
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/string.h>
-#include <linux/types.h>
-#include <linux/mm.h>
-#include <linux/smp.h>
-#include <linux/init.h>
-#include <linux/pfn.h>
-#include <linux/memblock.h>
-
-static u64 patterns[] __initdata =3D {
-=09/* The first entry has to be 0 to leave memtest with zeroed memory */
-=090,
-=090xffffffffffffffffULL,
-=090x5555555555555555ULL,
-=090xaaaaaaaaaaaaaaaaULL,
-=090x1111111111111111ULL,
-=090x2222222222222222ULL,
-=090x4444444444444444ULL,
-=090x8888888888888888ULL,
-=090x3333333333333333ULL,
-=090x6666666666666666ULL,
-=090x9999999999999999ULL,
-=090xccccccccccccccccULL,
-=090x7777777777777777ULL,
-=090xbbbbbbbbbbbbbbbbULL,
-=090xddddddddddddddddULL,
-=090xeeeeeeeeeeeeeeeeULL,
-=090x7a6c7258554e494cULL, /* yeah ;-) */
-};
-
-static void __init reserve_bad_mem(u64 pattern, u64 start_bad, u64 end_bad=
)
-{
-=09printk(KERN_INFO "  %016llx bad mem addr %010llx - %010llx reserved\n",
-=09       (unsigned long long) pattern,
-=09       (unsigned long long) start_bad,
-=09       (unsigned long long) end_bad);
-=09memblock_reserve(start_bad, end_bad - start_bad);
-}
-
-static void __init memtest(u64 pattern, u64 start_phys, u64 size)
-{
-=09u64 *p, *start, *end;
-=09u64 start_bad, last_bad;
-=09u64 start_phys_aligned;
-=09const size_t incr =3D sizeof(pattern);
-
-=09start_phys_aligned =3D ALIGN(start_phys, incr);
-=09start =3D __va(start_phys_aligned);
-=09end =3D start + (size - (start_phys_aligned - start_phys)) / incr;
-=09start_bad =3D 0;
-=09last_bad =3D 0;
-
-=09for (p =3D start; p < end; p++)
-=09=09*p =3D pattern;
-
-=09for (p =3D start; p < end; p++, start_phys_aligned +=3D incr) {
-=09=09if (*p =3D=3D pattern)
-=09=09=09continue;
-=09=09if (start_phys_aligned =3D=3D last_bad + incr) {
-=09=09=09last_bad +=3D incr;
-=09=09=09continue;
-=09=09}
-=09=09if (start_bad)
-=09=09=09reserve_bad_mem(pattern, start_bad, last_bad + incr);
-=09=09start_bad =3D last_bad =3D start_phys_aligned;
-=09}
-=09if (start_bad)
-=09=09reserve_bad_mem(pattern, start_bad, last_bad + incr);
-}
-
-static void __init do_one_pass(u64 pattern, u64 start, u64 end)
-{
-=09u64 i;
-=09phys_addr_t this_start, this_end;
-
-=09for_each_free_mem_range(i, NUMA_NO_NODE, &this_start, &this_end, NULL) =
{
-=09=09this_start =3D clamp_t(phys_addr_t, this_start, start, end);
-=09=09this_end =3D clamp_t(phys_addr_t, this_end, start, end);
-=09=09if (this_start < this_end) {
-=09=09=09printk(KERN_INFO "  %010llx - %010llx pattern %016llx\n",
-=09=09=09       (unsigned long long)this_start,
-=09=09=09       (unsigned long long)this_end,
-=09=09=09       (unsigned long long)cpu_to_be64(pattern));
-=09=09=09memtest(pattern, this_start, this_end - this_start);
-=09=09}
-=09}
-}
-
-/* default is disabled */
-static int memtest_pattern __initdata;
-
-static int __init parse_memtest(char *arg)
-{
-=09if (arg)
-=09=09memtest_pattern =3D simple_strtoul(arg, NULL, 0);
-=09else
-=09=09memtest_pattern =3D ARRAY_SIZE(patterns);
-
-=09return 0;
-}
-
-early_param("memtest", parse_memtest);
-
-void __init early_memtest(unsigned long start, unsigned long end)
-{
-=09unsigned int i;
-=09unsigned int idx =3D 0;
-
-=09if (!memtest_pattern)
-=09=09return;
-
-=09printk(KERN_INFO "early_memtest: # of tests: %d\n", memtest_pattern);
-=09for (i =3D memtest_pattern-1; i < UINT_MAX; --i) {
-=09=09idx =3D i % ARRAY_SIZE(patterns);
-=09=09do_one_pass(patterns[idx], start, end);
-=09}
-}
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index e8cc453..6724cb0 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -365,6 +365,14 @@ static inline unsigned long memblock_region_reserved_e=
nd_pfn(const struct memblo
 #define __initdata_memblock
 #endif
=20
+#ifdef CONFIG_MEMTEST
+extern void early_memtest(unsigned long start, unsigned long end);
+#else
+static inline void early_memtest(unsigned long start, unsigned long end)
+{
+}
+#endif
+
 #else
 static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t ali=
gn)
 {
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c5cefb3..8eb064fd 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1732,6 +1732,17 @@ config TEST_UDELAY
=20
 =09  If unsure, say N.
=20
+config MEMTEST
+=09bool "Memtest"
+=09---help---
+=09  This option adds a kernel parameter 'memtest', which allows memtest
+=09  to be set.
+=09        memtest=3D0, mean disabled; -- default
+=09        memtest=3D1, mean do 1 test pattern;
+=09        ...
+=09        memtest=3D4, mean do 4 test patterns.
+=09  If you are unsure how to answer this question, answer N.
+
 source "samples/Kconfig"
=20
 source "lib/Kconfig.kgdb"
diff --git a/mm/Makefile b/mm/Makefile
index 3c1caa2..e925708 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -76,3 +76,4 @@ obj-$(CONFIG_GENERIC_EARLY_IOREMAP) +=3D early_ioremap.o
 obj-$(CONFIG_CMA)=09+=3D cma.o
 obj-$(CONFIG_MEMORY_BALLOON) +=3D balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) +=3D page_ext.o
+obj-$(CONFIG_MEMTEST)=09=09+=3D memtest.o
diff --git a/mm/memtest.c b/mm/memtest.c
new file mode 100644
index 0000000..1e9da79
--- /dev/null
+++ b/mm/memtest.c
@@ -0,0 +1,118 @@
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/smp.h>
+#include <linux/init.h>
+#include <linux/pfn.h>
+#include <linux/memblock.h>
+
+static u64 patterns[] __initdata =3D {
+=09/* The first entry has to be 0 to leave memtest with zeroed memory */
+=090,
+=090xffffffffffffffffULL,
+=090x5555555555555555ULL,
+=090xaaaaaaaaaaaaaaaaULL,
+=090x1111111111111111ULL,
+=090x2222222222222222ULL,
+=090x4444444444444444ULL,
+=090x8888888888888888ULL,
+=090x3333333333333333ULL,
+=090x6666666666666666ULL,
+=090x9999999999999999ULL,
+=090xccccccccccccccccULL,
+=090x7777777777777777ULL,
+=090xbbbbbbbbbbbbbbbbULL,
+=090xddddddddddddddddULL,
+=090xeeeeeeeeeeeeeeeeULL,
+=090x7a6c7258554e494cULL, /* yeah ;-) */
+};
+
+static void __init reserve_bad_mem(u64 pattern, u64 start_bad, u64 end_bad=
)
+{
+=09printk(KERN_INFO "  %016llx bad mem addr %010llx - %010llx reserved\n",
+=09       (unsigned long long) pattern,
+=09       (unsigned long long) start_bad,
+=09       (unsigned long long) end_bad);
+=09memblock_reserve(start_bad, end_bad - start_bad);
+}
+
+static void __init memtest(u64 pattern, u64 start_phys, u64 size)
+{
+=09u64 *p, *start, *end;
+=09u64 start_bad, last_bad;
+=09u64 start_phys_aligned;
+=09const size_t incr =3D sizeof(pattern);
+
+=09start_phys_aligned =3D ALIGN(start_phys, incr);
+=09start =3D __va(start_phys_aligned);
+=09end =3D start + (size - (start_phys_aligned - start_phys)) / incr;
+=09start_bad =3D 0;
+=09last_bad =3D 0;
+
+=09for (p =3D start; p < end; p++)
+=09=09*p =3D pattern;
+
+=09for (p =3D start; p < end; p++, start_phys_aligned +=3D incr) {
+=09=09if (*p =3D=3D pattern)
+=09=09=09continue;
+=09=09if (start_phys_aligned =3D=3D last_bad + incr) {
+=09=09=09last_bad +=3D incr;
+=09=09=09continue;
+=09=09}
+=09=09if (start_bad)
+=09=09=09reserve_bad_mem(pattern, start_bad, last_bad + incr);
+=09=09start_bad =3D last_bad =3D start_phys_aligned;
+=09}
+=09if (start_bad)
+=09=09reserve_bad_mem(pattern, start_bad, last_bad + incr);
+}
+
+static void __init do_one_pass(u64 pattern, u64 start, u64 end)
+{
+=09u64 i;
+=09phys_addr_t this_start, this_end;
+
+=09for_each_free_mem_range(i, NUMA_NO_NODE, &this_start, &this_end, NULL) =
{
+=09=09this_start =3D clamp_t(phys_addr_t, this_start, start, end);
+=09=09this_end =3D clamp_t(phys_addr_t, this_end, start, end);
+=09=09if (this_start < this_end) {
+=09=09=09printk(KERN_INFO "  %010llx - %010llx pattern %016llx\n",
+=09=09=09       (unsigned long long)this_start,
+=09=09=09       (unsigned long long)this_end,
+=09=09=09       (unsigned long long)cpu_to_be64(pattern));
+=09=09=09memtest(pattern, this_start, this_end - this_start);
+=09=09}
+=09}
+}
+
+/* default is disabled */
+static int memtest_pattern __initdata;
+
+static int __init parse_memtest(char *arg)
+{
+=09if (arg)
+=09=09memtest_pattern =3D simple_strtoul(arg, NULL, 0);
+=09else
+=09=09memtest_pattern =3D ARRAY_SIZE(patterns);
+
+=09return 0;
+}
+
+early_param("memtest", parse_memtest);
+
+void __init early_memtest(unsigned long start, unsigned long end)
+{
+=09unsigned int i;
+=09unsigned int idx =3D 0;
+
+=09if (!memtest_pattern)
+=09=09return;
+
+=09printk(KERN_INFO "early_memtest: # of tests: %d\n", memtest_pattern);
+=09for (i =3D memtest_pattern-1; i < UINT_MAX; --i) {
+=09=09idx =3D i % ARRAY_SIZE(patterns);
+=09=09do_one_pass(patterns[idx], start, end);
+=09}
+}
--=20
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
