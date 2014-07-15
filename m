Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CD7706B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 07:58:36 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so6977371pde.40
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 04:58:36 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id si5si11620851pab.41.2014.07.15.04.58.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 15 Jul 2014 04:58:35 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8R00L0C59KL920@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Jul 2014 12:58:33 +0100 (BST)
Subject: [PATCH] mm: do not call do_fault_around for non-linear fault
From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date: Tue, 15 Jul 2014 15:58:32 +0400
Message-id: <20140715115832.18997.90349.stgit@buzz>
In-reply-to: 
 <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
References: <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
Cc: Ingo Korb <ingo.korb@tu-dortmund.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ning Qu <quning@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>

From: Konstantin Khlebnikov <koct9i@gmail.com>

Faulting around non-linear page-fault has no sense and
breaks logic in do_fault_around because pgoff is shifted.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Reported-by: "Ingo Korb" <ingo.korb@tu-dortmund.de>
---
 mm/memory.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index d67fd9f..7e8d820 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2882,7 +2882,8 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * if page by the offset is not ready to be mapped (cold cache or
 	 * something).
 	 */
-	if (vma->vm_ops->map_pages && fault_around_pages() > 1) {
+	if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
+	    fault_around_pages() > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 		do_fault_around(vma, address, pte, pgoff, flags);
 		if (!pte_same(*pte, orig_pte))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
