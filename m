Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E04C46B0315
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:20:38 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j13so69839577qta.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:20:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b52si102250qta.156.2017.05.24.10.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:20:38 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 06/15] mm/memory_hotplug: introduce add_pages
Date: Wed, 24 May 2017 13:20:15 -0400
Message-Id: <20170524172024.30810-7-jglisse@redhat.com>
In-Reply-To: <20170524172024.30810-1-jglisse@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Michal Hocko <mhocko@suse.com>

There are new users of memory hotplug emerging. Some of them require
different subset of arch_add_memory. There are some which only require
allocation of struct pages without mapping those pages to the kernel
address space. We currently have __add_pages for that purpose. But this
is rather lowlevel and not very suitable for the code outside of the
memory hotplug. E.g. x86_64 wants to update max_pfn which should be
done by the caller. Introduce add_pages() which should care about those
details if they are needed. Each architecture should define its
implementation and select CONFIG_ARCH_HAS_ADD_PAGES. All others use
the currently existing __add_pages.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 arch/x86/Kconfig               |  4 ++++
 arch/x86/mm/init_64.c          | 22 +++++++++++++++-------
 include/linux/memory_hotplug.h | 11 +++++++++++
 3 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a42ac0f..1baa525 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2264,6 +2264,10 @@ source "kernel/livepatch/Kconfig"
 
 endmenu
 
+config ARCH_HAS_ADD_PAGES
+	def_bool y
+	depends on X86_64 && ARCH_ENABLE_MEMORY_HOTPLUG
+
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 	depends on X86_64 || (X86_32 && HIGHMEM)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7332930..a8a9972 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -671,7 +671,7 @@ void __init paging_init(void)
  * After memory hotplug the variables max_pfn, max_low_pfn and high_memory need
  * updating.
  */
-static void  update_end_of_memory_vars(u64 start, u64 size)
+static void update_end_of_memory_vars(u64 start, u64 size)
 {
 	unsigned long end_pfn = PFN_UP(start + size);
 
@@ -682,22 +682,30 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int add_pages(int nid, unsigned long start_pfn,
+	      unsigned long nr_pages, bool want_memblock)
 {
-	unsigned long start_pfn = start >> PAGE_SHIFT;
-	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	init_memory_mapping(start, start + size);
-
 	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
-	update_end_of_memory_vars(start, size);
+	update_end_of_memory_vars(start_pfn << PAGE_SHIFT,
+				  nr_pages << PAGE_SHIFT);
 
 	return ret;
 }
+
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	init_memory_mapping(start, start + size);
+
+	return add_pages(nid, start_pfn, nr_pages, want_memblock);
+}
 EXPORT_SYMBOL_GPL(arch_add_memory);
 
 #define PAGE_INUSE 0xFD
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 9e0249d..abb9395d 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -127,6 +127,17 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 extern int __add_pages(int nid, unsigned long start_pfn,
 	unsigned long nr_pages, bool want_memblock);
 
+#ifndef CONFIG_ARCH_HAS_ADD_PAGES
+static inline int add_pages(int nid, unsigned long start_pfn,
+			    unsigned long nr_pages, bool want_memblock)
+{
+	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
+}
+#else /* ARCH_HAS_ADD_PAGES */
+int add_pages(int nid, unsigned long start_pfn,
+	      unsigned long nr_pages, bool want_memblock);
+#endif /* ARCH_HAS_ADD_PAGES */
+
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
 #else
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
