Received: from toomuch.toronto.redhat.com (unknown [172.16.14.22])
	by touchme.toronto.redhat.com (Postfix) with ESMTP id E8EA2B8036
	for <linux-mm@kvack.org>; Thu, 23 May 2002 16:57:36 -0400 (EDT)
Received: (from bcrl@localhost)
	by toomuch.toronto.redhat.com (8.11.6/8.11.2) id g4NKvak29022
	for linux-mm@kvack.org; Thu, 23 May 2002 16:57:36 -0400
Date: Thu, 23 May 2002 16:57:36 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: [bcrl@redhat.com: [PATCH] 2.4.19-pre8 vm86 smp locking fix]
Message-ID: <20020523165736.B27881@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Forwarded message from Benjamin LaHaise <bcrl@redhat.com> -----

Subject: [PATCH] 2.4.19-pre8 vm86 smp locking fix
From: Benjamin LaHaise <bcrl@redhat.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@redhat.com
Date: Thu, 23 May 2002 16:51:05 -0400

arch/i386/kernel/vm86.c performs page table operations without obtaining 
any locks.  This patch obtains page_table_lock around the the table walk 
and modification.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."


diff -urN v2.4.19-pre8/arch/i386/kernel/vm86.c work/arch/i386/kernel/vm86.c
--- v2.4.19-pre8/arch/i386/kernel/vm86.c	Thu Mar  7 16:39:56 2002
+++ work/arch/i386/kernel/vm86.c	Thu May 23 16:21:38 2002
@@ -97,21 +97,22 @@
 	pte_t *pte;
 	int i;
 
+	spin_lock(&tsk->mm->page_table_lock);
 	pgd = pgd_offset(tsk->mm, 0xA0000);
 	if (pgd_none(*pgd))
-		return;
+		goto out;
 	if (pgd_bad(*pgd)) {
 		pgd_ERROR(*pgd);
 		pgd_clear(pgd);
-		return;
+		goto out;
 	}
 	pmd = pmd_offset(pgd, 0xA0000);
 	if (pmd_none(*pmd))
-		return;
+		goto out;
 	if (pmd_bad(*pmd)) {
 		pmd_ERROR(*pmd);
 		pmd_clear(pmd);
-		return;
+		goto out;
 	}
 	pte = pte_offset(pmd, 0xA0000);
 	for (i = 0; i < 32; i++) {
@@ -119,6 +120,8 @@
 			set_pte(pte, pte_wrprotect(*pte));
 		pte++;
 	}
+out:
+	spin_unlock(&tsk->mm->page_table_lock);
 	flush_tlb();
 }
 

----- End forwarded message -----

-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
