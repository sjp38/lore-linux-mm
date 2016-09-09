Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16FE86B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 06:48:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g141so11300891wmd.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 03:48:11 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id r130si2399742wmf.44.2016.09.09.03.48.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 03:48:10 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm: mlock: check if vma is locked using & instead of && operator
Date: Fri,  9 Sep 2016 11:46:37 +0100
Message-Id: <20160909104637.2580-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Simon Guo <wei.guo.simon@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Alexey Klimov <klimov.linux@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The check to see if a vma is locked is using the operator && and
should be using the bitwise operator & to see if the VM_LOCKED bit
is set. Fix this to use & instead.

Fixes: ae38c3be005ee ("mm: mlock: check against vma for actual mlock() size")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/mlock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index fafbb78..f5b1d07 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -643,7 +643,7 @@ static int count_mm_mlocked_page_nr(struct mm_struct *mm,
 	for (; vma ; vma = vma->vm_next) {
 		if (start + len <=  vma->vm_start)
 			break;
-		if (vma->vm_flags && VM_LOCKED) {
+		if (vma->vm_flags & VM_LOCKED) {
 			if (start > vma->vm_start)
 				count -= (start - vma->vm_start);
 			if (start + len < vma->vm_end) {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
