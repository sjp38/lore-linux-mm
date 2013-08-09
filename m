Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id CC0E56B0033
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 17:35:17 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id t13so3536003lbd.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 14:35:15 -0700 (PDT)
MIME-Version: 1.0
From: Ning Qu <quning@google.com>
Date: Fri, 9 Aug 2013 14:34:35 -0700
Message-ID: <CACQD4-6_AmsDu6q_ChaiTCZNZ6zghJdWzZTmD1JQhLCkfMeeNA@mail.gmail.com>
Subject: [PATCH] thp: Fix deadlock situation in vma_adjust with huge page in
 page cache.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>

In vma_adjust, the current code grabs i_mmap_mutex before calling
vma_adjust_trans_huge. This used to be fine until huge page in page
cache comes in. The problem is the underlying function
split_file_huge_page will also grab the i_mmap_mutex before splitting
the huge page in page cache. Obviously this is causing deadlock
situation.

This fix is to move the vma_adjust_trans_huge before grab the lock for
file, the same as what the function is currently doing for anonymous
memory. Tested, everything works fine so far.

Signed-off-by: Ning Qu <quning@google.com>
---
 mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 519ce78..accf1b3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -750,6 +750,8 @@ again: remove_next = 1 + (end > next->vm_end);
  }
  }

+ vma_adjust_trans_huge(vma, start, end, adjust_next);
+
  if (file) {
  mapping = file->f_mapping;
  if (!(vma->vm_flags & VM_NONLINEAR)) {
@@ -773,8 +775,6 @@ again: remove_next = 1 + (end > next->vm_end);
  }
  }

- vma_adjust_trans_huge(vma, start, end, adjust_next);
-
  anon_vma = vma->anon_vma;
  if (!anon_vma && adjust_next)
  anon_vma = next->anon_vma;
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
