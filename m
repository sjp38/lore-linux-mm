From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: Do not use double negation for testing page flags
Date: Tue, 7 Mar 2017 15:36:37 +0900
Message-ID: <1488868597-32222-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Minchan Kim <minchan@kernel.org>, Vlastimil Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <gang.chen.5i5j@gmail.com>
List-Id: linux-mm.kvack.org

With the discussion[1], I found it seems there are every PageFlags
functions return bool at this moment so we don't need double
negation any more.
Although it's not a problem to keep it, it makes future users
confused to use dobule negation for them, too.

Remove such possibility.

[1] https://marc.info/?l=linux-kernel&m=148881578820434

Frankly sepaking, I like every PageFlags return bool instead of int.
It will make it clear. AFAIR, Chen Gang had tried it but don't know
why it was not merged at that time.

http://lkml.kernel.org/r/1469336184-1904-1-git-send-email-chengang@emindsoft.com.cn

Cc: Vlastimil Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chen Gang <gang.chen.5i5j@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/khugepaged.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 88e4b17..7cb9c88 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -548,7 +548,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 * The page must only be referenced by the scanned process
 		 * and page swap cache.
 		 */
-		if (page_count(page) != 1 + !!PageSwapCache(page)) {
+		if (page_count(page) != 1 + PageSwapCache(page)) {
 			unlock_page(page);
 			result = SCAN_PAGE_COUNT;
 			goto out;
@@ -1181,7 +1181,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		 * The page must only be referenced by the scanned process
 		 * and page swap cache.
 		 */
-		if (page_count(page) != 1 + !!PageSwapCache(page)) {
+		if (page_count(page) != 1 + PageSwapCache(page)) {
 			result = SCAN_PAGE_COUNT;
 			goto out_unmap;
 		}
-- 
2.7.4
