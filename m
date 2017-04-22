Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0002803C1
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 23:47:57 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f23so18933336qkh.21
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 20:47:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p35si11598642qta.186.2017.04.21.20.47.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 20:47:56 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 01/15] mm, memory_hotplug: introduce add_pages
Date: Fri, 21 Apr 2017 23:30:23 -0400
Message-Id: <20170422033037.3028-2-jglisse@redhat.com>
In-Reply-To: <20170422033037.3028-1-jglisse@redhat.com>
References: <20170422033037.3028-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Michal Hocko <mhocko@suse.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

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
index c43f476..e515dc2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2263,6 +2263,10 @@ source "kernel/livepatch/Kconfig"
 
 endmenu
 
+config ARCH_HAS_ADD_PAGES
+	def_bool y
+	depends on X86_64 && ARCH_ENABLE_MEMORY_HOTPLUG
+
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 	depends on X86_64 || (X86_32 && HIGHMEM)
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index ffeba90..a573ebc 100644
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
index aec8865..5ec6d64 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -126,6 +126,17 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
