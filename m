Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04E078E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 20:57:40 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so23858768qte.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:57:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a12sor1914531qvd.0.2018.12.18.17.57.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 17:57:38 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] mm: skip checking poison pattern for page_to_nid()
Date: Tue, 18 Dec 2018 20:57:32 -0500
Message-Id: <20181219015732.26179-1-cai@lca.pw>
In-Reply-To: <1545172285.18411.26.camel@lca.pw>
References: <1545172285.18411.26.camel@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, mhocko@suse.com, hpa@zytor.com, mgorman@techsingularity.net, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

Kernel panic with page_owner=on

CONFIG_DEBUG_VM_PGFLAGS=y
PAGE_OWNER=y
NODE_NOT_IN_PAGE_FLAGS=n

This is due to f165b378bbd (mm: uninitialized struct page poisoning
sanity checking) shoots itself in the foot.

[   11.917212] page:ffffea0004200000 is uninitialized and poisoned
[   11.917220] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.921745] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.924523] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[   11.926498] page_owner info is not active (free page?)
[   12.329560] kernel BUG at include/linux/mm.h:990!
[   12.337632] RIP: 0010:init_page_owner+0x486/0x520

At first,

start_kernel
  setup_arch
    pagetable_init
      paging_init
        sparse_init
          sparse_init_nid
            sparse_buffer_init
              memblock_virt_alloc_try_nid_raw

It poisons all the allocated pages there.

memset(ptr, PAGE_POISON_PATTERN, size)

Later,

page_ext_init
  invoke_init_callbacks
    init_section_page_ext
      init_page_owner
        init_early_allocated_pages
          init_zones_in_node
            init_pages_in_zone
              lookup_page_ext
                page_to_nid
                  PF_POISONED_CHECK <--- panic here.

This because all allocated pages are not initialized until later.

init_pages_in_zone
  __set_page_owner_handle

Fixes: f165b378bbd (mm: uninitialized struct page poisoning
sanity checking)
Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/linux/mm.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..f083f366ea90 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -985,9 +985,7 @@ extern int page_to_nid(const struct page *page);
 #else
 static inline int page_to_nid(const struct page *page)
 {
-	struct page *p = (struct page *)page;
-
-	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
+	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
 }
 #endif
 
-- 
2.17.2 (Apple Git-113)
