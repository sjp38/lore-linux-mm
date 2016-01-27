Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 675C86B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:40:44 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id n5so44529908wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:40:44 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bv6si10367690wjc.97.2016.01.27.11.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 11:40:43 -0800 (PST)
Date: Wed, 27 Jan 2016 14:39:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: do not let vdso pages into LRU rotation
Message-ID: <20160127193958.GA31407@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

I noticed that vdso pages are faulted and unmapped as if they were
regular file pages. And I'm guessing this is so that the vdso mappings
are able to use the generic COW code in memory.c.

However, it's a little unsettling that zap_pte_range() makes decisions
based on PageAnon() and the page even reaches mark_page_accessed(), as
that function makes several assumptions about the page being a regular
LRU user page. It seems this isn't crashing today by sheer luck, but I
am working on code that does when page_is_file_cache() returns garbage.

I'm using this hack to work around it:

diff --git a/mm/memory.c b/mm/memory.c
index c387430f06c3..f0537c500150 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1121,7 +1121,8 @@ again:
 					set_page_dirty(page);
 				}
 				if (pte_young(ptent) &&
-				    likely(!(vma->vm_flags & VM_SEQ_READ)))
+				    likely(!(vma->vm_flags & VM_SEQ_READ)) &&
+				    !PageReserved(page))
 					mark_page_accessed(page);
 				rss[MM_FILEPAGES]--;
 			}

but I think we need a cleaner (and more robust) solution there to make
it clearer that these pages are not regularly managed pages.

Could the VDSO be a VM_MIXEDMAP to keep the initial unmanaged pages
out of the VM while allowing COW into regular anonymous pages?

Are there other requirements of the VDSO that I might be missing?

Any feedback would be greatly appreciated.

Thanks!
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
