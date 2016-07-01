Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2556B0262
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:12:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so203853593pfa.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 17:12:38 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pt9si922369pab.278.2016.06.30.17.12.34
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 17:12:34 -0700 (PDT)
Subject: [PATCH 2/6] mm, tlb: add mmu_gather->saw_unset_a_or_d
From: Dave Hansen <dave@sr71.net>
Date: Thu, 30 Jun 2016 17:12:12 -0700
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
In-Reply-To: <20160701001209.7DA24D1C@viggo.jf.intel.com>
Message-Id: <20160701001212.3001F812@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Add a field (->saw_unset_a_or_d) to the asm-generic version of
mmu_gather.  We will use this on x86 to indicate when a PTE got
cleared that might potentially have a stray Accessed or Dirty bit
set.

Note that since ->saw_unset_a_or_d shares space in a bitfield
with ->fullmm and ->need_flush_all, there's no incremental
storage cost.  In addition, since it is initialized to 0 like
->need_flush_all, they can likely be initialized together,
leading to no real cost for having ->saw_unset_a_or_d around.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/include/asm-generic/tlb.h |    7 ++++++-
 b/mm/memory.c               |    6 ++++--
 2 files changed, 10 insertions(+), 3 deletions(-)

diff -puN include/asm-generic/tlb.h~knl-leak-20-saw_unset_a_or_d include/asm-generic/tlb.h
--- a/include/asm-generic/tlb.h~knl-leak-20-saw_unset_a_or_d	2016-06-30 17:10:41.606203608 -0700
+++ b/include/asm-generic/tlb.h	2016-06-30 17:10:41.611203835 -0700
@@ -101,7 +101,12 @@ struct mmu_gather {
 	unsigned int		fullmm : 1,
 	/* we have performed an operation which
 	 * requires a complete flush of the tlb */
-				need_flush_all : 1;
+				need_flush_all : 1,
+	/* we cleared a PTE bit which may potentially
+	 * get set by hardware */
+				saw_unset_a_or_d: 1;
+
+
 
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
diff -puN mm/memory.c~knl-leak-20-saw_unset_a_or_d mm/memory.c
--- a/mm/memory.c~knl-leak-20-saw_unset_a_or_d	2016-06-30 17:10:41.607203654 -0700
+++ b/mm/memory.c	2016-06-30 17:10:41.614203971 -0700
@@ -222,8 +222,10 @@ void tlb_gather_mmu(struct mmu_gather *t
 	tlb->mm = mm;
 
 	/* Is it from 0 to ~0? */
-	tlb->fullmm     = !(start | (end+1));
-	tlb->need_flush_all = 0;
+	tlb->fullmm		= !(start | (end+1));
+	tlb->need_flush_all	= 0;
+	tlb->saw_unset_a_or_d	= 0;
+
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
