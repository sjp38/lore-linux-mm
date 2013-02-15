Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id DC9AE6B0031
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 15:20:50 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 03/11] frontswap: Remove the check for frontswap_enabled.
Date: Fri, 15 Feb 2013 15:20:27 -0500
Message-Id: <1360959635-18922-4-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
References: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, minchan@kernel.org
Cc: ric.masonn@gmail.com, lliubbo@gmail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

With the support for loading of backends as modules (see for example:
"staging: zcache: enable zcache to be built/loaded as a module"), the
frontswap_enabled is always set to true ("mm: frontswap: lazy
initialization to allow tmem backends to build/run as modules").

The next patch "frontswap: Use static_key instead of frontswap_enabled and
frontswap_ops" is are going to convert the frontswap_enabled to be a bit more
selective and be on/off depending on whether the backend has registered - and
not whether the frontswap API is enabled.

The two functions: frontswap_init and frontswap_invalidate_area
can be called anytime - they queue up which of the swap devices are
active and can use the frontswap API - once the backend is loaded.

As such there is no need to check for 'frontswap_enabled' at all.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/frontswap.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index d4f2987..140323b 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -116,14 +116,12 @@ static inline void frontswap_invalidate_page(unsigned type, pgoff_t offset)
 
 static inline void frontswap_invalidate_area(unsigned type)
 {
-	if (frontswap_enabled)
-		__frontswap_invalidate_area(type);
+	__frontswap_invalidate_area(type);
 }
 
 static inline void frontswap_init(unsigned type)
 {
-	if (frontswap_enabled)
-		__frontswap_init(type);
+	__frontswap_init(type);
 }
 
 #endif /* _LINUX_FRONTSWAP_H */
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
