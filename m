Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C73A36B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 12:47:14 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so64914920pab.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 09:47:14 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id po7si4305179pbc.6.2015.04.30.09.47.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 09:47:13 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 30 Apr 2015 22:17:09 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2083F125805B
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 22:19:09 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3UGl5cT46596158
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 22:17:05 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3UGl5Sj005558
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 22:17:05 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/3] mm/thp: Use pmdp_splitting_flush_notify to clear pmd on splitting
In-Reply-To: <87iocd38uj.fsf@linux.vnet.ibm.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1430382341-8316-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150430133035.GF15874@node.dhcp.inet.fi> <87iocd38uj.fsf@linux.vnet.ibm.com>
Date: Thu, 30 Apr 2015 22:17:04 +0530
Message-ID: <87fv7h36nr.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
>
>>> @@ -184,3 +185,13 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>>>  }
>>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>>  #endif
>>> +
>>> +#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
>>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>> +void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
>>> +				 unsigned long address, pmd_t *pmdp)
>>> +{
>>> +	pmdp_clear_flush_notify(vma, address, pmdp);
>>> +}
>>> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>> +#endif
>>
>> I think it worth inlining. Let's put it to <asm-generic/pgtable.h>
>>
>> It probably worth combining with collapse counterpart in the same patch.
>>
>
> I tried that first, But that pulls in mmu_notifier.h and huge_mm.h
> headers and other build failures
>

Putting them in TRANSPATENT_HUGEPAGE helped.

commit 9c60ab5d1d684db2ba454ee1c7f3e9a6bf57f026
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Wed Apr 29 14:57:30 2015 +0530

    mm/thp: Use pmdp_splitting_flush_notify to clear pmd on splitting
    
    Some arch may require an explicit IPI before a THP PMD split. This
    ensures that a local_irq_disable can prevent a parallel THP PMD split.
    So use new function which arch can override
    
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index fe617b7e4be6..6a0b2ab899d1 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -184,6 +184,24 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+					       unsigned long address,
+					       pmd_t *pmdp)
+{
+	pmdp_clear_flush_notify(vma, address, pmdp);
+}
+#else
+static inline void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+					       unsigned long address,
+					       pmd_t *pmdp)
+{
+	BUG();
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cce4604c192f..81e9578bf43a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2606,9 +2606,10 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
-
-	/* leave pmd empty until pte is filled */
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	/*
+	 * leave pmd empty until pte is filled.
+	 */
+	pmdp_splitting_flush_notify(vma, haddr, pmd);
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
