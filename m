Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6D06B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 01:42:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t126so106120999pgc.9
        for <linux-mm@kvack.org>; Tue, 23 May 2017 22:42:54 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 70si21816948pga.321.2017.05.23.22.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 22:42:53 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id f27so31716109pfe.0
        for <linux-mm@kvack.org>; Tue, 23 May 2017 22:42:53 -0700 (PDT)
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: [PATCH] mm/zsmalloc: fix -Wunneeded-internal-declaration warning
Date: Tue, 23 May 2017 22:38:57 -0700
Message-Id: <20170524053859.29059-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: md@google.com, mka@chromium.org, Nick Desaulniers <nick.desaulniers@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

is_first_page() is only called from the macro VM_BUG_ON_PAGE() which is
only compiled in as a runtime check when CONFIG_DEBUG_VM is set,
otherwise is checked at compile time and not actually compiled in.

Fixes the following warning, found with Clang:

mm/zsmalloc.c:472:12: warning: function 'is_first_page' is not needed and
will not be emitted [-Wunneeded-internal-declaration]
static int is_first_page(struct page *page)
           ^

Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d41edd28298b..15959d35fc26 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -469,7 +469,7 @@ static bool is_zspage_isolated(struct zspage *zspage)
 	return zspage->isolated;
 }
 
-static int is_first_page(struct page *page)
+static __maybe_unused int is_first_page(struct page *page)
 {
 	return PagePrivate(page);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
