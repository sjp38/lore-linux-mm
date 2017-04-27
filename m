Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31BB76B0343
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e16so29210885pfj.15
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si3031358pgi.120.2017.04.27.08.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:21 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFqHuV042451
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:20 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a3dhrk97q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:19 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:17 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 09/17] mm/spf: Fix fe.sequence init in __handle_mm_fault()
Date: Thu, 27 Apr 2017 17:52:48 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

__handle_mm_fault() calls handle_pte_fault which requires the sequence
field of the fault_env to be initialized.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index 458f579feb6f..f8afd52f0d34 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3694,6 +3694,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pmd = pmd_alloc(mm, pud, address);
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
+	vmf.sequence = raw_read_seqcount(&vma->vm_sequence);
 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
 		int ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
