Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1166B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 07:51:46 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y15so5012548wrc.6
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 04:51:45 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id d8si4689815wmi.225.2017.12.15.04.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 04:51:44 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: thp: avoid uninitialized variable use
Date: Fri, 15 Dec 2017 13:51:04 +0100
Message-Id: <20171215125129.2948634-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When the down_read_trylock() fails, 'vma' has not been initialized
yet, which gcc now warns about:

mm/khugepaged.c: In function 'khugepaged':
mm/khugepaged.c:1659:25: error: 'vma' may be used uninitialized in this function [-Werror=maybe-uninitialized]

Presumable we are not supposed to call find_vma() without the mmap_sem
either, so setting it to NULL for this case seems appropriate.

Fixes: 0951b59acf3a ("mm: thp: use down_read_trylock() in khugepaged to avoid long block")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I'm not completely sure this patch is sufficient, it gets rid of
the warning, but it would be good to have the code reviewed better
to see if other problems remain that result from down_read_trylock()
patch.
---
 mm/khugepaged.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 521b908f9600..b7e2268dfc9a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1677,11 +1677,10 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	 * Don't wait for semaphore (to avoid long wait times).  Just move to
 	 * the next mm on the list.
 	 */
+	vma = NULL;
 	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
 		goto breakouterloop_mmap_sem;
-	if (unlikely(khugepaged_test_exit(mm)))
-		vma = NULL;
-	else
+	if (likely(!khugepaged_test_exit(mm)))
 		vma = find_vma(mm, khugepaged_scan.address);
 
 	progress++;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
