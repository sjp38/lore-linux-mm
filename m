Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id C739A6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 05:47:02 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 21 Aug 2012 15:16:56 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7L9krUC29950072
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 15:16:54 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7L9krnj005942
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 19:46:53 +1000
Message-ID: <503358FF.3030009@linux.vnet.ibm.com>
Date: Tue, 21 Aug 2012 17:46:39 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] mm: mmu_notifier: fix inconsistent memory between secondary
 MMU and host
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

There has a bug in set_pte_at_notify which always set the pte to the
new page before release the old page in secondary MMU, at this time,
the process will access on the new page, but the secondary MMU still
access on the old page, the memory is inconsistent between them

Below scenario shows the bug more clearly:

at the beginning: *p = 0, and p is write-protected by KSM or shared with
parent process

CPU 0                                       CPU 1
write 1 to p to trigger COW,
set_pte_at_notify will be called:
  *pte = new_page + W; /* The W bit of pte is set */

                                     *p = 1; /* pte is valid, so no #PF */

                                     return back to secondary MMU, then
                                     the secondary MMU read p, but get:
                                     *p == 0;

                         /*
                          * !!!!!!
                          * the host has already set p to 1, but the secondary
                          * MMU still get the old value 0
                          */

  call mmu_notifier_change_pte to release
  old page in secondary MMU

We can fix it by release old page first, then set the pte to the new
page.

Note, the new page will be firstly used in secondary MMU before it is
mapped into the page table of the process, but this is safe because it
is protected by the page table lock, there is no race to change the pte

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 include/linux/mmu_notifier.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 1d1b1e1..8c7435a 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -317,8 +317,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	unsigned long ___address = __address;				\
 	pte_t ___pte = __pte;						\
 									\
-	set_pte_at(___mm, ___address, __ptep, ___pte);			\
 	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
+	set_pte_at(___mm, ___address, __ptep, ___pte);			\
 })

 #else /* CONFIG_MMU_NOTIFIER */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
