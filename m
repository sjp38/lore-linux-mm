Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6295B6B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 09:41:06 -0500 (EST)
Received: by qgcc31 with SMTP id c31so30845377qgc.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 06:41:06 -0800 (PST)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id 189si11029143qhp.113.2015.11.20.06.41.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 06:41:05 -0800 (PST)
Received: by qgec40 with SMTP id c40so73604589qge.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 06:41:04 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH] mm: fix up sparse warning in gfpflags_allow_blocking
Date: Fri, 20 Nov 2015 09:40:59 -0500
Message-Id: <1448030459-20990-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

sparse says:

    include/linux/gfp.h:274:26: warning: incorrect type in return expression (different base types)
    include/linux/gfp.h:274:26:    expected bool
    include/linux/gfp.h:274:26:    got restricted gfp_t

...add a forced cast to silence the warning.

Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/gfp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6523109e136d..8942af0813e3 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -271,7 +271,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 
 static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 {
-	return gfp_flags & __GFP_DIRECT_RECLAIM;
+	return (bool __force)(gfp_flags & __GFP_DIRECT_RECLAIM);
 }
 
 #ifdef CONFIG_HIGHMEM
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
