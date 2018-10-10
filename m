Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E235B6B026F
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:27:48 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id p125-v6so6301964itg.1
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:27:48 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c203-v6sor12081564itb.30.2018.10.10.08.27.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 08:27:47 -0700 (PDT)
Date: Wed, 10 Oct 2018 17:27:36 +0200
Message-Id: <20181010152736.99475-1-jannh@google.com>
Mime-Version: 1.0
Subject: [PATCH] mm: don't clobber partially overlapping VMA with MAP_FIXED_NOREPLACE
From: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, jannh@google.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Michal Hocko <mhocko@suse.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>, Jason Evans <jasone@google.com>, David Goldblatt <davidtgoldblatt@gmail.com>, =?UTF-8?q?Edward=20Tomasz=20Napiera=C5=82a?= <trasz@FreeBSD.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>

Daniel Micay reports that attempting to use MAP_FIXED_NOREPLACE in an
application causes that application to randomly crash. The existing check
for handling MAP_FIXED_NOREPLACE looks up the first VMA that either
overlaps or follows the requested region, and then bails out if that VMA
overlaps *the start* of the requested region. It does not bail out if the
VMA only overlaps another part of the requested region.

Fix it by checking that the found VMA only starts at or after the end of
the requested region, in which case there is no overlap.

Reported-by: Daniel Micay <danielmicay@gmail.com>
Fixes: a4ff8e8620d3 ("mm: introduce MAP_FIXED_NOREPLACE")
Cc: stable@vger.kernel.org
Signed-off-by: Jann Horn <jannh@google.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b184c60..f7cd9cb966c0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1410,7 +1410,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	if (flags & MAP_FIXED_NOREPLACE) {
 		struct vm_area_struct *vma = find_vma(mm, addr);
 
-		if (vma && vma->vm_start <= addr)
+		if (vma && vma->vm_start < addr + len)
 			return -EEXIST;
 	}
 
-- 
2.19.0.605.g01d371f741-goog
