Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0D86B0255
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:50:05 -0500 (EST)
Received: by wmdw130 with SMTP id w130so219680495wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:50:04 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id de6si7538207wjc.21.2015.11.18.15.50.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 15:50:03 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 18 Nov 2015 23:50:03 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 00EC01B08069
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 23:50:21 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAINo0B35243376
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 23:50:00 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAINnxYF006176
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:50:00 -0700
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/2] s390/mm: allow gmap code to retry on faulting in guest memory
Date: Thu, 19 Nov 2015 00:49:58 +0100
Message-Id: <1447890598-56860-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1447890598-56860-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1447890598-56860-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-s390@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

The userfaultfd does need FAULT_FLAG_ALLOW_RETRY to not return
VM_FAULT_SIGBUS.  So we improve the gmap code to handle one
VM_FAULT_RETRY.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/mm/pgtable.c | 28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 54ef3bc..8a0025d 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -577,15 +577,22 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
 	       unsigned int fault_flags)
 {
 	unsigned long vmaddr;
-	int rc;
+	int rc, fault;
 
+	fault_flags |= FAULT_FLAG_ALLOW_RETRY;
+retry:
 	down_read(&gmap->mm->mmap_sem);
 	vmaddr = __gmap_translate(gmap, gaddr);
 	if (IS_ERR_VALUE(vmaddr)) {
 		rc = vmaddr;
 		goto out_up;
 	}
-	if (fixup_user_fault(current, gmap->mm, vmaddr, fault_flags)) {
+	fault = fixup_user_fault(current, gmap->mm, vmaddr, fault_flags);
+	if (fault & VM_FAULT_RETRY) {
+		fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
+		fault_flags |= FAULT_FLAG_TRIED;
+		goto retry;
+	} else if (fault) {
 		rc = -EFAULT;
 		goto out_up;
 	}
@@ -717,10 +724,13 @@ int gmap_ipte_notify(struct gmap *gmap, unsigned long gaddr, unsigned long len)
 	spinlock_t *ptl;
 	pte_t *ptep, entry;
 	pgste_t pgste;
+	int fault, fault_flags;
 	int rc = 0;
 
+	fault_flags = FAULT_FLAG_WRITE | FAULT_FLAG_ALLOW_RETRY;
 	if ((gaddr & ~PAGE_MASK) || (len & ~PAGE_MASK))
 		return -EINVAL;
+retry:
 	down_read(&gmap->mm->mmap_sem);
 	while (len) {
 		/* Convert gmap address and connect the page tables */
@@ -730,7 +740,12 @@ int gmap_ipte_notify(struct gmap *gmap, unsigned long gaddr, unsigned long len)
 			break;
 		}
 		/* Get the page mapped */
-		if (fixup_user_fault(current, gmap->mm, addr, FAULT_FLAG_WRITE)) {
+		fault = fixup_user_fault(current, gmap->mm, addr, fault_flags);
+		if (fault & VM_FAULT_RETRY) {
+			fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			fault_flags |= FAULT_FLAG_TRIED;
+			goto retry;
+		} else if (fault) {
 			rc = -EFAULT;
 			break;
 		}
@@ -794,7 +809,9 @@ int set_guest_storage_key(struct mm_struct *mm, unsigned long addr,
 	spinlock_t *ptl;
 	pgste_t old, new;
 	pte_t *ptep;
+	int fault, fault_flags;
 
+	fault_flags = FAULT_FLAG_WRITE | FAULT_FLAG_ALLOW_RETRY;
 	down_read(&mm->mmap_sem);
 retry:
 	ptep = get_locked_pte(mm, addr, &ptl);
@@ -805,10 +822,13 @@ retry:
 	if (!(pte_val(*ptep) & _PAGE_INVALID) &&
 	     (pte_val(*ptep) & _PAGE_PROTECT)) {
 		pte_unmap_unlock(ptep, ptl);
-		if (fixup_user_fault(current, mm, addr, FAULT_FLAG_WRITE)) {
+		fault = fixup_user_fault(current, mm, addr, fault_flags);
+		if (fault && !(fault & VM_FAULT_RETRY)) {
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
 		}
+		fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
+		fault_flags |= FAULT_FLAG_TRIED;
 		goto retry;
 	}
 
-- 
2.3.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
