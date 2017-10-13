Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4943B6B0038
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:33:02 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id c76so2736563vkd.0
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 10:33:02 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y35si375837uay.17.2017.10.13.10.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 10:33:00 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v12 03/11] sparc64/mm: setting fields in deferred pages
Date: Fri, 13 Oct 2017 13:32:06 -0400
Message-Id: <20171013173214.27300-4-pasha.tatashin@oracle.com>
In-Reply-To: <20171013173214.27300-1-pasha.tatashin@oracle.com>
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Without deferred struct page feature (CONFIG_DEFERRED_STRUCT_PAGE_INIT),
flags and other fields in "struct page"es are never changed prior to first
initializing struct pages by going through __init_single_page().

With deferred struct page feature enabled there is a case where we set some
fields prior to initializing:

mem_init() {
     register_page_bootmem_info();
     free_all_bootmem();
     ...
}

When register_page_bootmem_info() is called only non-deferred struct pages
are initialized. But, this function goes through some reserved pages which
might be part of the deferred, and thus are not yet initialized.

mem_init
register_page_bootmem_info
register_page_bootmem_info_node
 get_page_bootmem
  .. setting fields here ..
  such as: page->freelist = (void *)type;

free_all_bootmem()
free_low_memory_core_early()
 for_each_reserved_mem_region()
  reserve_bootmem_region()
   init_reserved_page() <- Only if this is deferred reserved page
    __init_single_pfn()
     __init_single_page()
      memset(0) <-- Loose the set fields here

We end-up with similar issue as in the previous patch, where currently we
do not observe problem as memory is zeroed. But, if flag asserts are
changed we can start hitting issues.

Also, because in this patch series we will stop zeroing struct page memory
during allocation, we must make sure that struct pages are properly
initialized prior to using them.

The deferred-reserved pages are initialized in free_all_bootmem().
Therefore, the fix is to switch the above calls.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/sparc/mm/init_64.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 6034569e2c0d..caed495544e9 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2548,9 +2548,16 @@ void __init mem_init(void)
 {
 	high_memory = __va(last_valid_pfn << PAGE_SHIFT);
 
-	register_page_bootmem_info();
 	free_all_bootmem();
 
+	/*
+	 * Must be done after boot memory is put on freelist, because here we
+	 * might set fields in deferred struct pages that have not yet been
+	 * initialized, and free_all_bootmem() initializes all the reserved
+	 * deferred pages for us.
+	 */
+	register_page_bootmem_info();
+
 	/*
 	 * Set up the zero page, mark it reserved, so that page count
 	 * is not manipulated when freeing the page from user ptes.
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
