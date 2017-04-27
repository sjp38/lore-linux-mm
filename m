Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAA1D6B037E
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y43so3452201wrc.11
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m42si3078368wrm.44.2017.04.27.08.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:26 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFnDXE045398
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:25 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a34yd5fsc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:24 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:22 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 13/17] mm/spf Protect vm_policy's changes against speculative pf
Date: Thu, 27 Apr 2017 17:52:52 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-14-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

Mark the VMA touched when policy changes are applied to it so that
speculative page fault will be aborted.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1518b022927d..57ec8d0a9c95 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -444,8 +444,11 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		write_seqcount_begin(&vma->vm_sequence);
 		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
+		write_seqcount_end(&vma->vm_sequence);
+	}
 	up_write(&mm->mmap_sem);
 }
 
@@ -708,6 +711,7 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	write_seqcount_begin(&vma->vm_sequence);
 	if (vma->vm_ops && vma->vm_ops->set_policy) {
 		err = vma->vm_ops->set_policy(vma, new);
 		if (err)
@@ -716,10 +720,12 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 
 	old = vma->vm_policy;
 	vma->vm_policy = new; /* protected by mmap_sem */
+	write_seqcount_end(&vma->vm_sequence);
 	mpol_put(old);
 
 	return 0;
  err_out:
+	write_seqcount_end(&vma->vm_sequence);
 	mpol_put(new);
 	return err;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
