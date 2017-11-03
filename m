Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 019526B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 03:54:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 191so2496072pgd.0
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 00:53:59 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o28si5310423pgc.521.2017.11.03.00.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 00:53:58 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP migration
Date: Fri,  3 Nov 2017 15:52:31 +0800
Message-Id: <20171103075231.25416-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.UK>

From: Huang Ying <ying.huang@intel.com>

If THP migration is enabled, the following situation is possible,

- A THP is mapped at source address
- Migration is started to move the THP to another node
- Page fault occurs
- The PMD (migration entry) is copied to the destination address in mremap

That is, it is possible for handle_userfault() encounter a PMD entry
which has been handled but !pmd_present().  In the current
implementation, we will wait for such PMD entries, which may cause
unnecessary waiting, and potential soft lockup.

This is fixed via avoiding to wait when !pmd_present(), only wait when
pmd_none().

Question:

I found userfaultfd_must_wait() is always called when PMD or PTE is
none, and with mm->mmap_sem read-lock held.  mremap() will write-lock
mm->mmap_sem.  And UFFDIO_COPY don't support to copy THP mapping.  So
the situation described above couldn't happen in practice?

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.UK>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/userfaultfd.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b5a0193e1960..0fcf66c3e439 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -294,10 +294,13 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	 * pmd_trans_unstable) of the pmd.
 	 */
 	_pmd = READ_ONCE(*pmd);
-	if (!pmd_present(_pmd))
+	if (pmd_none(_pmd))
 		goto out;
 
 	ret = false;
+	if (!pmd_present(_pmd))
+		goto out;
+
 	if (pmd_trans_huge(_pmd))
 		goto out;
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
