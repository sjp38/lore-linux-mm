Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89F236B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 18:20:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r68so16900825wmr.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 15:20:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c25si2592357ede.207.2017.10.09.15.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 15:20:26 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v11 1/9] x86/mm: setting fields in deferred pages
Date: Mon,  9 Oct 2017 18:19:23 -0400
Message-Id: <20171009221931.1481-2-pasha.tatashin@oracle.com>
In-Reply-To: <20171009221931.1481-1-pasha.tatashin@oracle.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Without deferred struct page feature (CONFIG_DEFERRED_STRUCT_PAGE_INIT),
flags and other fields in "struct page"es are never changed prior to first
initializing struct pages by going through __init_single_page().

With deferred struct page feature enabled, however, we set fields in
register_page_bootmem_info that are subsequently clobbered right after in
free_all_bootmem:

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

We end-up with issue where, currently we do not observe problem as memory
is explicitly zeroed. But, if flag asserts are changed we can start hitting
issues.

Also, because in this patch series we will stop zeroing struct page memory
during allocation, we must make sure that struct pages are properly
initialized prior to using them.

The deferred-reserved pages are initialized in free_all_bootmem().
Therefore, the fix is to switch the above calls.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/mm/init_64.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5ea1c3c2636e..8822523fdcd7 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1182,12 +1182,18 @@ void __init mem_init(void)
 
 	/* clear_bss() already clear the empty_zero_page */
 
-	register_page_bootmem_info();
-
 	/* this will put all memory onto the freelists */
 	free_all_bootmem();
 	after_bootmem = 1;
 
+	/*
+	 * Must be done after boot memory is put on freelist, because here we
+	 * might set fields in deferred struct pages that have not yet been
+	 * initialized, and free_all_bootmem() initializes all the reserved
+	 * deferred pages for us.
+	 */
+	register_page_bootmem_info();
+
 	/* Register memory areas for /proc/kcore */
 	kclist_add(&kcore_vsyscall, (void *)VSYSCALL_ADDR,
 			 PAGE_SIZE, KCORE_OTHER);
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
