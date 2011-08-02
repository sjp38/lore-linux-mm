Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 50F226B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 04:06:52 -0400 (EDT)
Received: by vxg38 with SMTP id 38so6842656vxg.14
        for <linux-mm@kvack.org>; Tue, 02 Aug 2011 01:06:49 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 2 Aug 2011 13:36:49 +0530
Message-ID: <CAFPAmTQGkTstM1j0kJWng8rf9_wfBa427r69-5rQpFJCSQGZkw@mail.gmail.com>
Subject: =?UTF-8?B?W1BBVENIXSBBUk0gOiBzcGFyc2VtZW06IENyYXNoZXMgb24gQVJNIHBsYXRmb3JtIHdoZQ==?=
	=?UTF-8?B?biBzcGFyc2VtZW0gZW5hYmxlZCBpbiBsaW51eC0yLjYu4oCLMzUuMTMgZHVlIHRvIHBmbl92YWxpZCg=?=
	=?UTF-8?B?4oCLKSBhbmQgcGZuX3ZhbGlkX+KAi3dpdGhpbigpLg==?=
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@kernel.org
Cc: Mel Gorman <mgorman@suse.de>, "Russell King\"" <rmk@arm.linux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On my ARM machine, I have linux-2.6.35.13 installed and the total
kernel memory is not aligned to the section size SECTION_SIZE_BITS.

I observe kernel crashes in the following 3 scenarios:
i)    When we do a "cat /proc/pagetypeinfo": This happens because the
pfn_valid() macro is not able to detect invalid PFNs in the loop in
vmstat.c: pagetypeinfo_showblockcount_print().
ii)    When we do "echo xxxx > /proc/vm/sys/min_free_kbytes": This
happens because the pfn_valid() macro is not able to detect invalid
PFNs in page_alloc.c: setup_zone_migrate_reserve().
iii)   When I try to copy a really huge file: This happens because the
CONFIG_HOLES_IN_ZONE config option is not set.
       The code then crashes in the VM_BUG_ON in loop in
move_freepages() as pfn_valid_within() did not compile correctly to
pfn_valid().

This patch is a combination of :
a)  Back-ported changes of the patch from Will Deacon found at:
http://git.kernel.org/?p=linux/kernel/git/stable/linux-3.0.y.git;a=commit;h=7b7bf499f79de3f6c85a340c8453a78789523f85
b) Addition of the CONFIG_HOLES_IN_ZONE config option to
arch/arm/Kconfig in order to prevent crashes in move_freepages()
when/if the total kernel memory is not aligned to SECTION_SIZE_BITS.
This also leads to
proper compilation of the pfn_valid_within() macro which otherwise
will always return 1 to the caller.

Apologies for the last patch which I sent to these mailing lists in
improper format.

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 arch/arm/include/asm/page.h |    2 +-
 arch/arm/Kconfig            |    6 ++++++
 arch/arm/mm/init.c          |    4 +++-
 include/linux/mmzone.h      |    2 ++
 4 files changed, 12 insertions(+), 2 deletions(-)

diff -uprN a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
--- a/arch/arm/include/asm/page.h       2011-08-02 10:04:54.917207995 +0530
+++ b/arch/arm/include/asm/page.h       2011-08-02 10:14:45.464208248 +0530
@@ -195,7 +195,7 @@ typedef unsigned long pgprot_t;

 typedef struct page *pgtable_t;

-#ifndef CONFIG_SPARSEMEM
+#ifdef CONFIG_ARCH_PROVIDES_PFN_VALID
 extern int pfn_valid(unsigned long);
 #endif

diff -uprN a/arch/arm/Kconfig b/arch/arm/Kconfig
--- a/arch/arm/Kconfig  2011-08-02 10:04:55.607207996 +0530
+++ b/arch/arm/Kconfig  2011-08-02 10:13:56.461207994 +0530
@@ -1265,6 +1265,12 @@ config ARCH_SPARSEMEM_DEFAULT
 config ARCH_SELECT_MEMORY_MODEL
       def_bool ARCH_DISCONTIGMEM_ENABLE && ARCH_SPARSEMEM_ENABLE

+config ARCH_PROVIDES_PFN_VALID
+       def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
+
+config HOLES_IN_ZONE
+       def_bool ARCH_HAS_HOLES_MEMORYMODEL || SPARSEMEM
+
 config NODES_SHIFT
       int
       default "4" if ARCH_LH7A40X
diff -uprN a/arch/arm/mm/init.c b/arch/arm/mm/init.c
--- a/arch/arm/mm/init.c        2011-08-02 10:04:55.492207995 +0530
+++ b/arch/arm/mm/init.c        2011-08-02 10:29:47.408208131 +0530
@@ -325,7 +325,7 @@ static void __init bootmem_free_node(int
       free_area_init_node(node, zone_size, min, zhole_size);
 }

-#ifndef CONFIG_SPARSEMEM
+#ifdef CONFIG_ARCH_PROVIDES_PFN_VALID
 int pfn_valid(unsigned long pfn)
 {
       struct meminfo *mi = &meminfo;
@@ -345,7 +345,9 @@ int pfn_valid(unsigned long pfn)
       return 0;
 }
 EXPORT_SYMBOL(pfn_valid);
+#endif

+#ifndef CONFIG_SPARSEMEM
 static void arm_memory_present(struct meminfo *mi, int node)
 {
 }
diff -uprN a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h    2011-08-02 10:04:48.998207995 +0530
+++ b/include/linux/mmzone.h    2011-08-02 10:16:49.007207996 +0530
@@ -1058,12 +1058,14 @@ static inline struct mem_section *__pfn_
       return __nr_to_section(pfn_to_section_nr(pfn));
 }

+#ifndef CONFIG_ARCH_PROVIDES_PFN_VALID
 static inline int pfn_valid(unsigned long pfn)
 {
       if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
               return 0;
       return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
+#endif

 static inline int pfn_present(unsigned long pfn)
 {
--

Thanks,
Kautuk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
