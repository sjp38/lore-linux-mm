Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 505AF6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 17:02:47 -0500 (EST)
Received: by qcvx3 with SMTP id x3so46156822qcv.5
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 14:02:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n5si7151489qaz.109.2015.03.05.14.02.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 14:02:46 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/21] userfaultfd: prevent khugepaged to merge if userfaultfd is armed
Date: Thu,  5 Mar 2015 18:17:52 +0100
Message-Id: <1425575884-2574-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

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
index 5374132..8f1b6a5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2145,7 +2145,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
-			if (++none_or_zero <= khugepaged_max_ptes_none)
+			if (!userfaultfd_armed(vma) &&
+			    ++none_or_zero <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out;
@@ -2593,7 +2594,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
