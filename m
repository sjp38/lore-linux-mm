Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54C8A6B0262
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:15:26 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id c79so84609193ybf.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:15:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n62si15155478ywf.291.2016.09.21.14.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 14:15:25 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/4] mm: vma_merge/vma_adjust minor updates against -mm
Date: Wed, 21 Sep 2016 23:15:18 +0200
Message-Id: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>

Hello,

Here 4 more minor patches that are incremental against -mm.

In short:

1/4) updates vm_page_prot atomically as it's updated outside the
     rmap_locks. It's always better to use READ_ONCE/WRITE_ONCE if the
     access is concurrent from multiple CPUs, even if there wouldn't
     be risk of reading intermediate values... like in this case there
     is too.

     Not critical, theoretical issue only so far, it might be possible
     that gcc emits right asm code already, but this is safer and
     forces gcc to emit the right asm code.

2/4) comment correction

     Not critical, noop change.

3/4) adapts CONFIG_DEBUG_VM_RB=y to cope with the case of
     next->vm_start reduced. Earlier that could never happen and
     vma->vm_end was always increased instead. validate_mm() is always
     called before returning from vma_adjust() and the argumented
     rbtree is always consistent while exercising a flood of case8.

     Not critical if CONFIG_DEBUG_VM_RB=n as there's no functional
     change in such case. Critical if you set CONFIG_DEBUG_VM_RB=y, in
     which case without the patch false positives are emitted.

4/4) cleanup a line that is superfluous and in turns it can confuse
     the reader if the reader assumes it's not superfluous.

     Not critical, noop change.

Andrea Arcangeli (4):
  mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
  mm: vma_adjust: minor comment correction
  mm: vma_merge: correct false positive from
    __vma_unlink->validate_mm_rb
  mm: vma_adjust: remove superfluous confusing update in remove_next ==
    1 case

 mm/huge_memory.c |  2 +-
 mm/migrate.c     |  2 +-
 mm/mmap.c        | 94 +++++++++++++++++++++++++++++++++++++++++---------------
 3 files changed, 72 insertions(+), 26 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
