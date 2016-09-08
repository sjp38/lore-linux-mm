Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1796B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 05:13:29 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so90468281pad.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:29 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id f76si11009932pfa.105.2016.09.08.02.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 02:13:28 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id g202so2240222pfb.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:28 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 1/3] mm: mlock: correct a typo in count_mm_mlocked_page_nr() for caculate VMLOCKED pages
Date: Thu,  8 Sep 2016 17:12:48 +0800
Message-Id: <1473325970-11393-2-git-send-email-wei.guo.simon@gmail.com>
In-Reply-To: <1473325970-11393-1-git-send-email-wei.guo.simon@gmail.com>
References: <1473325970-11393-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Simon Guo <wei.guo.simon@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Thierry Reding <treding@nvidia.com>, Mike Kravetz <mike.kravetz@oracle.com>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org

From: Simon Guo <wei.guo.simon@gmail.com>

There is a typo/bug in count_mm_mlocked_page_nr() for "&" which is
mistakenly used with "&&".

Also add more checks and some minor change based on Kirill's previous
comment.

Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>
---
 mm/mlock.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index fafbb78..145a425 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -641,9 +641,11 @@ static int count_mm_mlocked_page_nr(struct mm_struct *mm,
 		vma = mm->mmap;
 
 	for (; vma ; vma = vma->vm_next) {
+		if (start >= vma->vm_end)
+			continue;
 		if (start + len <=  vma->vm_start)
 			break;
-		if (vma->vm_flags && VM_LOCKED) {
+		if (vma->vm_flags & VM_LOCKED) {
 			if (start > vma->vm_start)
 				count -= (start - vma->vm_start);
 			if (start + len < vma->vm_end) {
@@ -654,7 +656,7 @@ static int count_mm_mlocked_page_nr(struct mm_struct *mm,
 		}
 	}
 
-	return (PAGE_ALIGN(count) >> PAGE_SHIFT);
+	return count >> PAGE_SHIFT;
 }
 
 static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
