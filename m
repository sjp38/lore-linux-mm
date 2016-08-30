Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E98EA82F64
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:00:26 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so32140674pad.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:26 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id p11si44647088par.193.2016.08.30.04.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:00:26 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hh10so962359pac.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:25 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 1/4] mm: mlock: check against vma for actual mlock() size
Date: Tue, 30 Aug 2016 18:59:38 +0800
Message-Id: <1472554781-9835-2-git-send-email-wei.guo.simon@gmail.com>
In-Reply-To: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
References: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Simon Guo <wei.guo.simon@gmail.com>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

From: Simon Guo <wei.guo.simon@gmail.com>

In do_mlock(), the check against locked memory limitation
has a hole which will fail following cases at step 3):
1) User has a memory chunk from addressA with 50k, and user
mem lock rlimit is 64k.
2) mlock(addressA, 30k)
3) mlock(addressA, 40k)

The 3rd step should have been allowed since the 40k request
is intersected with the previous 30k at step 2), and the
3rd step is actually for mlock on the extra 10k memory.

This patch checks vma to caculate the actual "new" mlock
size, if necessary, and ajust the logic to fix this issue.

Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>
---
 mm/mlock.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index 14645be..9283187 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -617,6 +617,43 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
 	return error;
 }
 
+/*
+ * Go through vma areas and sum size of mlocked
+ * vma pages, as return value.
+ * Note deferred memory locking case(mlock2(,,MLOCK_ONFAULT)
+ * is also counted.
+ * Return value: previously mlocked page counts
+ */
+static int count_mm_mlocked_page_nr(struct mm_struct *mm,
+		unsigned long start, size_t len)
+{
+	struct vm_area_struct *vma;
+	int count = 0;
+
+	if (mm == NULL)
+		mm = current->mm;
+
+	vma = find_vma(mm, start);
+	if (vma == NULL)
+		vma = mm->mmap;
+
+	for (; vma ; vma = vma->vm_next) {
+		if (start + len <=  vma->vm_start)
+			break;
+		if (vma->vm_flags && VM_LOCKED) {
+			if (start > vma->vm_start)
+				count -= (start - vma->vm_start);
+			if (start + len < vma->vm_end) {
+				count += start + len - vma->vm_start;
+				break;
+			}
+			count += vma->vm_end - vma->vm_start;
+		}
+	}
+
+	return (PAGE_ALIGN(count) >> PAGE_SHIFT);
+}
+
 static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 {
 	unsigned long locked;
@@ -639,6 +676,18 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 		return -EINTR;
 
 	locked += current->mm->locked_vm;
+	if ((locked > lock_limit) && (!capable(CAP_IPC_LOCK))) {
+		/*
+		 * It is possible that the regions requested
+		 * intersect with previously mlocked areas,
+		 * that part area in "mm->locked_vm" should
+		 * not be counted to new mlock increment
+		 * count. So check and adjust locked count
+		 * if necessary.
+		 */
+		locked -= count_mm_mlocked_page_nr(current->mm,
+				start, len);
+	}
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
