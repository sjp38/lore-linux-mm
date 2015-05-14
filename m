Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D8EB06B0099
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:52 -0400 (EDT)
Received: by wgin8 with SMTP id n8so83042712wgi.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t5si5031379wjy.122.2015.05.14.10.31.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:44 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/23] userfaultfd: prevent khugepaged to merge if userfaultfd is armed
Date: Thu, 14 May 2015 19:31:06 +0200
Message-Id: <1431624680-20153-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

If userfaultfd is armed on a certain vma we can't "fill" the holes
with zeroes or we'll break the userland on demand paging. The holes if
the userfault is armed, are really missing information (not zeroes)
that the userland has to load from network or elsewhere.

The same issue happens for wrprotected ptes that we can't just convert
into a single writable pmd_trans_huge.

We could however in theory still merge across zeropages if only
VM_UFFD_MISSING is set (so if VM_UFFD_WP is not set)... that could be
slightly improved but it'd be much more complex code for a tiny corner
case.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c221be3..9671f51 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2198,7 +2198,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
-			if (++none_or_zero <= khugepaged_max_ptes_none)
+			if (!userfaultfd_armed(vma) &&
+			    ++none_or_zero <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out;
@@ -2651,7 +2652,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
-			if (++none_or_zero <= khugepaged_max_ptes_none)
+			if (!userfaultfd_armed(vma) &&
+			    ++none_or_zero <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out_unmap;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
