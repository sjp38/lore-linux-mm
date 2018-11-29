Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA6B36B5179
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 02:53:34 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so875557pfi.21
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 23:53:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c191si1428121pfg.72.2018.11.28.23.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 23:53:33 -0800 (PST)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH 1/2] mm: Move lru_to_page to mm.h
Date: Thu, 29 Nov 2018 09:52:56 +0200
Message-Id: <20181129075301.29087-1-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Nikolay Borisov <nborisov@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Souptick Joarder <jrdr.linux@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Keith Busch <keith.busch@intel.com>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org

There are multiple places in the kernel which opencode this helper,
this patch moves it to the more generic mm.h header in preparation for
using it. No functional changes.

Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---
 include/linux/mm.h        | 2 ++
 include/linux/mm_inline.h | 3 ---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..47b4aa5bba93 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -146,6 +146,8 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 /* test whether an address (unsigned long or pointer) is aligned to PAGE_SIZE */
 #define PAGE_ALIGNED(addr)	IS_ALIGNED((unsigned long)(addr), PAGE_SIZE)
 
+#define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
+
 /*
  * Linux kernel virtual memory manager primitives.
  * The idea being to have a "virtual" mm in the same way
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 10191c28fc04..04ec454d44ce 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -124,7 +124,4 @@ static __always_inline enum lru_list page_lru(struct page *page)
 	}
 	return lru;
 }
-
-#define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
-
 #endif
-- 
2.17.1
