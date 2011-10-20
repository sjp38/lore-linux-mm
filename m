Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 35E4D6B002F
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 05:01:57 -0400 (EDT)
From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/6] mm: add a "struct page_frag" type containing a page, offset and length
Date: Thu, 20 Oct 2011 10:01:44 +0100
Message-ID: <1319101309-28431-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
References: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Cc: Ian Campbell <ian.campbell@citrix.com>, Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A few network drivers currently use skb_frag_struct for this purpose but I have
patches which add additional fields and semantics there which these other uses
do not want.

A structure for reference sub-page regions seems like a generally useful thing
so do so instead of adding a network subsystem specific structure.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Jens Axboe <jaxboe@fusionio.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
[since v1: s/struct subpage/struct page_frag/ on advice from Christoph]
[since v2: s/page_offset/offset/ on advice from Andrew]
---
 include/linux/mm_types.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 774b895..29971a5 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -135,6 +135,17 @@ struct page {
 #endif
 ;
 
+struct page_frag {
+	struct page *page;
+#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
+	__u32 offset;
+	__u32 size;
+#else
+	__u16 offset;
+	__u16 size;
+#endif
+};
+
 typedef unsigned long __nocast vm_flags_t;
 
 /*
-- 
1.7.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
