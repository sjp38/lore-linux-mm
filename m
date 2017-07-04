Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 035D36B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 03:58:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so38600312wry.4
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 00:58:10 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 64si13601824wra.123.2017.07.04.00.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jul 2017 00:58:09 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id u23so24533732wma.2
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 00:58:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: disallow early_pfn_to_nid on configurations which do not implement it
Date: Tue,  4 Jul 2017 09:58:03 +0200
Message-Id: <20170704075803.15979-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

early_pfn_to_nid will return node 0 if both HAVE_ARCH_EARLY_PFN_TO_NID
and HAVE_MEMBLOCK_NODE_MAP are disabled. It seems we are safe now
because all architectures which support NUMA define one of them (with an
exception of alpha which however has CONFIG_NUMA marked as broken) so
this works as expected. It can get silently and subtly broken too
easily, though. Make sure we fail the compilation if NUMA is enabled and
there is no proper implementation for this function. If that ever
happens we know that either the specific configuration is invalid
and the fix should either disable NUMA or enable one of the above
configs.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I have brought this up earlier [1] because I thought the deferred
initialization might be broken but then found out that this is not the
case right now. This is an attempt to prevent any subtly broken users in
future.

[1] http://lkml.kernel.org/r/20170630141847.GN22917@dhcp22.suse.cz

 include/linux/mmzone.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 16532fa0bb64..fc14b8b3f6ce 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1055,6 +1055,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
 static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 {
+	BUILD_BUG_ON(IS_ENABLED(CONFIG_NUMA));
 	return 0;
 }
 #endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
