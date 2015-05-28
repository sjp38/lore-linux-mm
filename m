Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 19EED6B0038
	for <linux-mm@kvack.org>; Thu, 28 May 2015 07:53:05 -0400 (EDT)
Received: by wizo1 with SMTP id o1so58804940wiz.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 04:53:04 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id fm3si4268223wib.17.2015.05.28.04.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 28 May 2015 04:52:55 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Thu, 28 May 2015 12:52:54 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id AE82317D8066
	for <linux-mm@kvack.org>; Thu, 28 May 2015 12:53:48 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4SBqrMJ22216942
	for <linux-mm@kvack.org>; Thu, 28 May 2015 11:52:53 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4SBqlpp002643
	for <linux-mm@kvack.org>; Thu, 28 May 2015 05:52:52 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 5/5] s390/mm: forward check for huge pmds to pmd_large()
Date: Thu, 28 May 2015 13:52:37 +0200
Message-Id: <1432813957-46874-6-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nathan Lynch <nathan_lynch@mentor.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andy Lutomirski <luto@amacapital.net>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

We already do the check in pmd_large, so we can just forward the call.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/mm/hugetlbpage.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 999616b..a4b2f5e 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -135,10 +135,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 
 int pmd_huge(pmd_t pmd)
 {
-	if (!MACHINE_HAS_HPAGE)
-		return 0;
-
-	return !!(pmd_val(pmd) & _SEGMENT_ENTRY_LARGE);
+	return pmd_large(pmd);
 }
 
 int pud_huge(pud_t pud)
-- 
2.3.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
