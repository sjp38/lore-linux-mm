Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 64EA4280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:46:29 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so225976579wiw.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:46:29 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id vf7si14340046wjc.127.2015.07.03.05.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jul 2015 05:46:20 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 3 Jul 2015 13:46:19 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id DDEF92190056
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 13:45:54 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t63CkGfU30933202
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 12:46:16 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t63CkGIS004789
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 06:46:16 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 4/4] s390/hugetlb: add hugepages_supported define
Date: Fri,  3 Jul 2015 14:46:09 +0200
Message-Id: <1435927569-41132-5-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1435927569-41132-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1435927569-41132-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On s390 we only can enable hugepages if the underlying hardware/hypervisor
also does support this. Common code now would assume this to be signaled
by setting HPAGE_SHIFT to 0. But on s390, where we only support one
hugepage size, there is a link between HPAGE_SHIFT and pageblock_order.

So instead of setting HPAGE_SHIFT to 0, we will implement the check for the
hardware capability.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/hugetlb.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 0130d03..d9be7c0 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -14,6 +14,7 @@
 
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range			free_pgd_range
+#define hugepages_supported()			(MACHINE_HAS_HPAGE)
 
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
-- 
2.3.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
