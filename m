Subject: [1/6] generify early_pfn_to_nid
Message-Id: <E1DTQNY-0002Ug-Qt@pinky.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 04 May 2005 21:21:56 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org, haveblue@us.ibm.com, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

Provide a default implementation for early_pfn_to_nid returning
node 0.  Allow architectures to override this with their own
implementation out of asm/mmzone.h.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Martin Bligh <mbligh@aracnet.com>
---
 arch/i386/Kconfig         |    4 ++++
 include/asm-i386/mmzone.h |    3 +++
 include/linux/mmzone.h    |    4 ++++
 3 files changed, 11 insertions(+)

diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/Kconfig current/arch/i386/Kconfig
--- reference/arch/i386/Kconfig	2005-05-04 20:54:20.000000000 +0100
+++ current/arch/i386/Kconfig	2005-05-04 20:54:24.000000000 +0100
@@ -794,6 +794,10 @@ config HAVE_ARCH_ALLOC_REMAP
 
 source "mm/Kconfig"
 
+config HAVE_ARCH_EARLY_PFN_TO_NID
+	bool
+	default y
+
 config HIGHPTE
 	bool "Allocate 3rd-level pagetables from highmem"
 	depends on HIGHMEM4G || HIGHMEM64G
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/include/asm-i386/mmzone.h current/include/asm-i386/mmzone.h
--- reference/include/asm-i386/mmzone.h	2005-05-04 20:54:20.000000000 +0100
+++ current/include/asm-i386/mmzone.h	2005-05-04 20:54:24.000000000 +0100
@@ -143,4 +143,7 @@ static inline void get_memcfg_numa(void)
 }
 
 #endif /* CONFIG_DISCONTIGMEM */
+
+extern int early_pfn_to_nid(unsigned long pfn);
+
 #endif /* _ASM_MMZONE_H_ */
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h	2005-05-04 20:54:21.000000000 +0100
+++ current/include/linux/mmzone.h	2005-05-04 20:54:24.000000000 +0100
@@ -418,6 +418,10 @@ extern struct pglist_data contig_page_da
 
 #endif
 
+#ifndef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
+#define early_pfn_to_nid(nid)  (0UL)
+#endif
+
 #endif /* !__ASSEMBLY__ */
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MMZONE_H */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
