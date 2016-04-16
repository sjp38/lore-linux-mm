Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9F426B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:29:47 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so183754957pac.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:29:47 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id g4si9619628pax.154.2016.04.16.16.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 16:29:47 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id e128so68077810pfe.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:29:47 -0700 (PDT)
Date: Sat, 16 Apr 2016 16:29:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm 2/5] huge tmpfs: fix mlocked meminfo track huge unhuge
 mlocks fix
In-Reply-To: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604161627260.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kbuild test robot <fengguang.wu@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Please add this fix after
huge-tmpfs-fix-mlocked-meminfo-track-huge-unhuge-mlocks.patch
for later merging into it.  I expect this to fix a build problem found
by robot on an x86_64 randconfig.  I was not able to reproduce the error,
but I'm growing to realize that different optimizers behave differently.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/rmap.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1445,8 +1445,12 @@ static int try_to_unmap_one(struct page
 	 */
 	if (!(flags & TTU_IGNORE_MLOCK)) {
 		if (vma->vm_flags & VM_LOCKED) {
+			int nr_pages = 1;
+
+			if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && !pte)
+				nr_pages = HPAGE_PMD_NR;
 			/* Holding pte lock, we do *not* need mmap_sem here */
-			mlock_vma_pages(page, pte ? 1 : HPAGE_PMD_NR);
+			mlock_vma_pages(page, nr_pages);
 			ret = SWAP_MLOCK;
 			goto out_unmap;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
