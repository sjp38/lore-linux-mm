Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 894486B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 05:38:35 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so28137802lfh.2
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 02:38:35 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id qp6si12917554wjc.185.2016.06.10.02.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 02:38:34 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id D30911C248C
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 10:38:33 +0100 (IST)
Date: Fri, 10 Jun 2016 10:38:32 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, slaub: Add __GFP_ATOMIC to the GFP reclaim mask
Message-ID: <20160610093832.GK2527@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marcin Wojtas <mw@semihalf.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Commit d0164adc89f6 ("mm, page_alloc: distinguish between being unable to
sleep, unwilling to sleep and avoiding waking kswapd") modified __GFP_WAIT
to explicitly identify the difference between atomic callers and those that
were unwilling to sleep. Later the definition was removed entirely.

The GFP_RECLAIM_MASK is the set of flags that affect watermark checking
and reclaim behaviour but __GFP_ATOMIC was never added. Without it, atomic
users of the slab allocator strip the __GFP_ATOMIC flag and cannot access
the page allocator atomic reserves.  This patch addresses the problem.

The user-visible impact depends on the workload but potentially atomic
allocations unnecessarily fail without this path.

Cc: <stable@vger.kernel.org> # 4.4+
Reported-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/internal.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index a37e5b6f9d25..2524ec880e24 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -24,7 +24,8 @@
  */
 #define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
 			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
-			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
+			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
+			__GFP_ATOMIC)
 
 /* The GFP flags allowed during early boot */
 #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_RECLAIM|__GFP_IO|__GFP_FS))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
