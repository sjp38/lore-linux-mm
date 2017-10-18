Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24E606B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:32:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j14so2111405wre.4
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 01:32:36 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id b5si9047004wrf.514.2017.10.18.01.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 01:32:35 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: mark mm_pgtables_bytes() argument as const
Date: Wed, 18 Oct 2017 10:31:17 +0200
Message-Id: <20171018083226.3124972-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The newly introduced mm_pgtables_bytes() function has two
definitions with slightly different prototypes. The one
used for CONFIG_MMU=n causes a compile-time warning:

In file included from include/linux/kernel.h:13:0,
                 from mm/debug.c:8:
mm/debug.c: In function 'dump_mm':
mm/debug.c:137:21: error: passing argument 1 of 'mm_pgtables_bytes' discards 'const' qualifier from pointer target type [-Werror=discarded-qualifiers]

This changes it to be the same as the other one and avoid the
warning.

Fixes: 7444e6ee9cce ("mm: consolidate page table accounting")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f7db128d2c59..2067dc7d03e7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1677,7 +1677,7 @@ static inline void mm_dec_nr_ptes(struct mm_struct *mm)
 #else
 
 static inline void mm_pgtables_bytes_init(struct mm_struct *mm) {}
-static inline unsigned long mm_pgtables_bytes(struct mm_struct *mm)
+static inline unsigned long mm_pgtables_bytes(const struct mm_struct *mm)
 {
 	return 0;
 }
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
