Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id A935182FD8
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 00:12:52 -0500 (EST)
Received: by mail-yk0-f181.google.com with SMTP id k129so58317543yke.0
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 21:12:52 -0800 (PST)
Received: from mail-yk0-x244.google.com (mail-yk0-x244.google.com. [2607:f8b0:4002:c07::244])
        by mx.google.com with ESMTPS id y68si38401967ywf.124.2015.12.26.21.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 21:12:51 -0800 (PST)
Received: by mail-yk0-x244.google.com with SMTP id x184so24417610yka.0
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 21:12:51 -0800 (PST)
From: Joshua Clayton <stillcompiling@gmail.com>
Subject: [PATCH] mm: fix noisy sparse warning in LIBCFS_ALLOC_PRE()
Date: Sat, 26 Dec 2015 21:12:42 -0800
Message-Id: <1451193162-20057-1-git-send-email-stillcompiling@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, Joshua Clayton <stillcompiling@gmail.com>

running sparse on drivers/staging/lustre results in dozens of warnings:
include/linux/gfp.h:281:41: warning:
odd constant _Bool cast (400000 becomes 1)

Use "!!" to explicitly convert the result to bool range.
---
 include/linux/gfp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 91f74e7..6e58a8f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -278,7 +278,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 
 static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 {
-	return (bool __force)(gfp_flags & __GFP_DIRECT_RECLAIM);
+	return (bool __force)!!(gfp_flags & __GFP_DIRECT_RECLAIM);
 }
 
 #ifdef CONFIG_HIGHMEM
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
