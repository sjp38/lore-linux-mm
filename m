Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB1546B0397
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c198so29182644pfc.19
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d7si196985pfa.409.2017.04.27.08.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:32 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFmtxa075677
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:32 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a3jbcvbn9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:31 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:29 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 17/17] mm/spf: protect mremap() against speculative pf
Date: Thu, 27 Apr 2017 17:52:56 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-18-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

mremap() is modifying the VMA layout and thus must be protected against
the speculative page fault handler.

XXX: Is the change to vma->vm_flags to set VM_ACCOUNT require the
protection ?

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/mremap.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/mremap.c b/mm/mremap.c
index 30d7d2482eea..40c3c869dffc 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -288,6 +288,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (!new_vma)
 		return -ENOMEM;
 
+	write_seqcount_begin(&vma->vm_sequence);
+	write_seqcount_begin_nested(&new_vma->vm_sequence,
+				    SINGLE_DEPTH_NESTING);
+
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
 				     need_rmap_locks);
 	if (moved_len < old_len) {
@@ -304,6 +308,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		 */
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
 				 true);
+		write_seqcount_end(&vma->vm_sequence);
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
@@ -311,7 +316,9 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	} else {
 		arch_remap(mm, old_addr, old_addr + old_len,
 			   new_addr, new_addr + new_len);
+		write_seqcount_end(&vma->vm_sequence);
 	}
+	write_seqcount_end(&new_vma->vm_sequence);
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
 	if (vm_flags & VM_ACCOUNT) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
