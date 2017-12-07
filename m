Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 001CF6B0261
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 20:18:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z1so4112661pfl.9
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 17:18:19 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q17si2791524pgc.303.2017.12.06.17.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 17:18:18 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2] mm, userfaultfd, THP: Avoid waiting when PMD under THP migration
Date: Thu,  7 Dec 2017 09:17:52 +0800
Message-Id: <20171207011752.3292-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.UK>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>

From: Huang Ying <ying.huang@intel.com>

If THP migration is enabled, for a VMA handled by userfaultfd,
consider the following situation,

do_page_fault()
  __do_huge_pmd_anonymous_page()
   handle_userfault()
     userfault_msg()
       /* a huge page is allocated and mapped at fault address */
       /* the huge page is under migration, leaves migration entry
          in page table */
     userfaultfd_must_wait()
       /* return true because !pmd_present() */
     /* may wait in loop until fatal signal */

That is, it may be possible for userfaultfd_must_wait() encounters a
PMD entry which is !pmd_none() && !pmd_present().  In the current
implementation, we will wait for such PMD entries, which may cause
unnecessary waiting, and potential soft lockup.

This is fixed via avoiding to wait when !pmd_none() && !pmd_present(),
only wait when pmd_none().

This may be not a problem in practice, because userfaultfd_must_wait()
is always called with mm->mmap_sem read-locked.  mremap() will
write-lock mm->mmap_sem.  And UFFDIO_COPY doesn't support to copy THP
mapping.  But the change introduced still makes the code more correct,
and makes the PMD and PTE code more consistent.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
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
index ac9a4e65ca49..cbc715fc82e1 100644
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
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
