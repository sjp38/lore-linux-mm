Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 187D16B0255
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 04:20:10 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so22011870wic.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 01:20:09 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id n7si9604057wjb.50.2015.09.18.01.20.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Sep 2015 01:20:08 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 18 Sep 2015 09:20:08 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id DE4821B0804B
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 09:21:47 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8I8K6Is29294814
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:20:06 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8I8K4ml024238
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 02:20:05 -0600
Date: Fri, 18 Sep 2015 10:20:01 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150918102001.0e0389c7@mschwide>
In-Reply-To: <20150918071549.GA2035@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
	<1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
	<20150917193152.GJ2000@uranus>
	<20150918085835.597fb036@mschwide>
	<20150918071549.GA2035@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, 18 Sep 2015 10:15:50 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Fri, Sep 18, 2015 at 08:58:35AM +0200, Martin Schwidefsky wrote:
> > > 
> > > Martin, could you please elaborate? Seems I'm missing
> > > something obvious.
> >  
> > It is me who missed something.. thanks for the explanation.
> 
> Sure thing! Ping me if any.
 
Ok, with the conditional define for the _PAGE_SOFT_DIRTY bit my
s390 code now works. But there is one common code patch that would
make sense, see below. If this is ok with you I can queue this via
the linux-s390 tree.

--
Subject: [PATCH] mm: add architecture primitives for software dirty bit
 clearing

There are primitives to create and query the software dirty bits
in a pte or pmd. The clearing of the software dirty bit is done
in common code with x86 specific page table functions.

Add the missing architecture primitives to clear the software dirty
bits to allow the feature to be used on non-x86 systems.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/x86/include/asm/pgtable.h | 10 ++++++++++
 fs/proc/task_mmu.c             |  4 ++--
 include/asm-generic/pgtable.h  | 10 ++++++++++
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 867da5b..0be49a2 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -318,6 +318,16 @@ static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_SOFT_DIRTY);
 }
 
+static inline pte_t pte_clear_soft_dirty(pte_t pte)
+{
+	return pte_clear_flags(pte, _PAGE_SOFT_DIRTY);
+}
+
+static inline pmd_t pmd_clear_soft_dirty(pmd_t pmd)
+{
+	return pmp_clear_flags(pmd, _PAGE_SOFT_DIRTY);
+}
+
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 /*
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e2d46ad..b029d42 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -754,7 +754,7 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 
 	if (pte_present(ptent)) {
 		ptent = pte_wrprotect(ptent);
-		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
+		ptent = pte_clear_soft_dirty(ptent);
 	} else if (is_swap_pte(ptent)) {
 		ptent = pte_swp_clear_soft_dirty(ptent);
 	}
@@ -768,7 +768,7 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 	pmd_t pmd = *pmdp;
 
 	pmd = pmd_wrprotect(pmd);
-	pmd = pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);
+	pmd = pmd_clear_soft_dirty(pmd);
 
 	if (vma->vm_flags & VM_SOFTDIRTY)
 		vma->vm_flags &= ~VM_SOFTDIRTY;
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 29c57b2..f167cdd 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -482,6 +482,16 @@ static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
 	return pmd;
 }
 
+static inline pte_t pte_clear_soft_dirty(pte_t pte)
+{
+	return pte;
+}
+
+static inline pmd_t pmd_clear_soft_dirty(pmd_t pmd)
+{
+	return pmd;
+}
+
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
 {
 	return pte;
-- 
2.3.8

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
