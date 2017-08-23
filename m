Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAAB6B04DC
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:04:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l87so1569858pfj.14
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:04:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 90si1021427plf.944.2017.08.23.05.04.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 05:04:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 02/19] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Date: Wed, 23 Aug 2017 15:03:15 +0300
Message-Id: <20170823120332.2288-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
References: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

With boot-time switching between paging mode we will have variable
MAX_PHYSMEM_BITS.

Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
configuration to define zsmalloc data structures.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
---
 mm/zsmalloc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 308acb9d814b..d44129613768 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -93,7 +93,13 @@
 #define MAX_PHYSMEM_BITS BITS_PER_LONG
 #endif
 #endif
+
+#ifdef CONFIG_X86_5LEVEL
+/* MAX_PHYSMEM_BITS is variable, use maximum value here */
+#define _PFN_BITS		(52 - PAGE_SHIFT)
+#else
 #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
+#endif
 
 /*
  * Memory for allocating for handle keeps object position by
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
