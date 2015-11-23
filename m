Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 683766B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 07:23:36 -0500 (EST)
Received: by qgcc31 with SMTP id c31so68982258qgc.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:23:36 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id p63si10965867qkl.45.2015.11.23.04.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 04:23:35 -0800 (PST)
Received: by qgec40 with SMTP id c40so111899755qge.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:23:35 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v2] mm: fix up sparse warning in gfpflags_allow_blocking
Date: Mon, 23 Nov 2015 07:23:29 -0500
Message-Id: <1448281409-13132-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

sparse says:

    include/linux/gfp.h:274:26: warning: incorrect type in return expression (different base types)
    include/linux/gfp.h:274:26:    expected bool
    include/linux/gfp.h:274:26:    got restricted gfp_t

Add a comparison to zero to have it return bool.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/gfp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

[v2: use a compare instead of forced cast, as suggested by Michal]

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6523109e136d..b76c92073b1b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -271,7 +271,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 
 static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 {
-	return gfp_flags & __GFP_DIRECT_RECLAIM;
+	return (gfp_flags & __GFP_DIRECT_RECLAIM) != 0;
 }
 
 #ifdef CONFIG_HIGHMEM
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
