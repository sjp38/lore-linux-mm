Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 577E56B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:54:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so34115311pgy.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:54:27 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w19si778931pgj.62.2017.08.08.05.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:54:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 02/14] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Date: Tue,  8 Aug 2017 15:54:03 +0300
Message-Id: <20170808125415.78842-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

With boot-time switching between paging mode we will have variable
MAX_PHYSMEM_BITS.

Let's use the maximum varible possible for CONFIG_X86_5LEVEL=y
configuration to define zsmalloc data structures.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
---
 mm/zsmalloc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 013eea76685e..468879915d3d 100644
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
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
