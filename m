Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B684F6B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 06:20:34 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id f206so208377388wmf.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 03:20:34 -0800 (PST)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id lg10si144404595wjc.20.2016.01.04.03.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 03:20:33 -0800 (PST)
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Mon, 4 Jan 2016 11:20:32 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3AA001B0805F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 11:21:11 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u04BKUmM8520180
	for <linux-mm@kvack.org>; Mon, 4 Jan 2016 11:20:30 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u04BKTVB003546
	for <linux-mm@kvack.org>; Mon, 4 Jan 2016 04:20:30 -0700
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/2] s390/mm: enable fixup_user_fault retrying
Date: Mon,  4 Jan 2016 12:19:55 +0100
Message-Id: <1451906395-80878-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1451906395-80878-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1451906395-80878-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org

By passing a non-null flag we allow fixup_user_fault to retry, which
enables userfaultfd.  As during these retries we might drop the mmap_sem we
need to check if that happened and redo the complete chain of actions.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/mm/pgtable.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index b15759c..3c5456d 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -578,17 +578,29 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
 {
 	unsigned long vmaddr;
 	int rc;
+	bool unlocked;
 
 	down_read(&gmap->mm->mmap_sem);
+
+retry:
+	unlocked = false;
 	vmaddr = __gmap_translate(gmap, gaddr);
 	if (IS_ERR_VALUE(vmaddr)) {
 		rc = vmaddr;
 		goto out_up;
 	}
-	if (fixup_user_fault(current, gmap->mm, vmaddr, fault_flags, NULL)) {
+	if (fixup_user_fault(current, gmap->mm, vmaddr, fault_flags,
+			     &unlocked)) {
 		rc = -EFAULT;
 		goto out_up;
 	}
+	/*
+	 * In the case that fixup_user_fault unlocked the mmap_sem during
+	 * faultin redo __gmap_translate to not race with a map/unmap_segment.
+	 */
+	if (unlocked)
+		goto retry;
+
 	rc = __gmap_link(gmap, gaddr, vmaddr);
 out_up:
 	up_read(&gmap->mm->mmap_sem);
@@ -717,12 +729,14 @@ int gmap_ipte_notify(struct gmap *gmap, unsigned long gaddr, unsigned long len)
 	spinlock_t *ptl;
 	pte_t *ptep, entry;
 	pgste_t pgste;
+	bool unlocked;
 	int rc = 0;
 
 	if ((gaddr & ~PAGE_MASK) || (len & ~PAGE_MASK))
 		return -EINVAL;
 	down_read(&gmap->mm->mmap_sem);
 	while (len) {
+		unlocked = false;
 		/* Convert gmap address and connect the page tables */
 		addr = __gmap_translate(gmap, gaddr);
 		if (IS_ERR_VALUE(addr)) {
@@ -731,10 +745,13 @@ int gmap_ipte_notify(struct gmap *gmap, unsigned long gaddr, unsigned long len)
 		}
 		/* Get the page mapped */
 		if (fixup_user_fault(current, gmap->mm, addr, FAULT_FLAG_WRITE,
-				     NULL)) {
+				     &unlocked)) {
 			rc = -EFAULT;
 			break;
 		}
+		/* While trying to map mmap_sem got unlocked. Let us retry */
+		if (unlocked)
+			continue;
 		rc = __gmap_link(gmap, gaddr, addr);
 		if (rc)
 			break;
@@ -795,9 +812,11 @@ int set_guest_storage_key(struct mm_struct *mm, unsigned long addr,
 	spinlock_t *ptl;
 	pgste_t old, new;
 	pte_t *ptep;
+	bool unlocked;
 
 	down_read(&mm->mmap_sem);
 retry:
+	unlocked = false;
 	ptep = get_locked_pte(mm, addr, &ptl);
 	if (unlikely(!ptep)) {
 		up_read(&mm->mmap_sem);
@@ -806,8 +825,12 @@ retry:
 	if (!(pte_val(*ptep) & _PAGE_INVALID) &&
 	     (pte_val(*ptep) & _PAGE_PROTECT)) {
 		pte_unmap_unlock(ptep, ptl);
+		/*
+		 * We do not really care about unlocked. We will retry either
+		 * way. But this allows fixup_user_fault to enable userfaultfd.
+		 */
 		if (fixup_user_fault(current, mm, addr, FAULT_FLAG_WRITE,
-				     NULL)) {
+				     &unlocked)) {
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
 		}
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
