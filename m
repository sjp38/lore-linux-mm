Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA48E6B0424
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:22:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q126so283316968pga.0
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:22:29 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p19si10399611pgj.415.2017.03.12.22.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:22:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, gup: fix typo in gup_p4d_range()
Date: Mon, 13 Mar 2017 08:22:13 +0300
Message-Id: <20170313052213.11411-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

gup_p4d_range() should call gup_pud_range(), not itself.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
Fixes: c2febafc6773 ("mm: convert generic code to 5-level paging")
---
 mm/gup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index c74bad1bf6e8..04aa405350dc 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1455,7 +1455,7 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 			if (!gup_huge_pd(__hugepd(p4d_val(p4d)), addr,
 					 P4D_SHIFT, next, write, pages, nr))
 				return 0;
-		} else if (!gup_p4d_range(p4d, addr, next, write, pages, nr))
+		} else if (!gup_pud_range(p4d, addr, next, write, pages, nr))
 			return 0;
 	} while (p4dp++, addr = next, addr != end);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
