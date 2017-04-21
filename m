Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC7662806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:33:06 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g67so5007227wrd.0
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 09:33:06 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id o26si15190000wra.182.2017.04.21.09.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 09:33:05 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: gup: fix access_ok() argument type
Date: Fri, 21 Apr 2017 18:26:32 +0200
Message-Id: <20170421162659.3314521-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

MIPS just got changed to only accept a pointer argument for access_ok(),
causing one warning in drivers/scsi/pmcraid.c. I tried changing x86
the same way and found the same warning in __get_user_pages_fast()
and nowhere else in the kernel during randconfig testing:

mm/gup.c: In function '__get_user_pages_fast':
mm/gup.c:1578:6: error: passing argument 1 of '__chk_range_not_ok' makes pointer from integer without a cast [-Werror=int-conversion]

It would probably be a good idea to enforce type-safety in general,
so let's change this file to not cause a warning if we do that.

I don't know why the warning did not appear on MIPS.

Fixes: 2667f50e8b81 ("mm: introduce a general RCU get_user_pages_fast()")
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/gup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 2559a3987de7..7f5bc26d9229 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1575,7 +1575,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	end = start + len;
 
 	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
-					start, len)))
+					(void __user *)start, len)))
 		return 0;
 
 	/*
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
