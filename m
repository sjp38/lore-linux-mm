Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0CA6B0282
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:29:32 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id k19so4582903ita.8
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:29:32 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z22si2362173ioi.297.2018.01.16.11.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:29:31 -0800 (PST)
From: Henry Willard <henry.willard@oracle.com>
Subject: [PATCH] mm: numa: Do not trap faults on shared data section pages.
Date: Tue, 16 Jan 2018 11:28:44 -0800
Message-Id: <1516130924-3545-2-git-send-email-henry.willard@oracle.com>
In-Reply-To: <1516130924-3545-1-git-send-email-henry.willard@oracle.com>
References: <1516130924-3545-1-git-send-email-henry.willard@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Workloads consisting of a large number processes running the same program
with a large shared data section may suffer from excessive numa balancing
page migration of the pages in the shared data section. This shows up as
high I/O wait time and degraded performance on machines with higher socket
or node counts.

This patch skips shared copy-on-write pages in change_pte_range() for the
numa balancing case.

Signed-off-by: Henry Willard <henry.willard@oracle.com>
Reviewed-by: HAJPYkon Bugge <haakon.bugge@oracle.com>
Reviewed-by: Steve Sistare steven.sistare@oracle.com
---
 mm/mprotect.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index ec39f730a0bf..fbbb3ab70818 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -84,6 +84,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				if (!page || PageKsm(page))
 					continue;
 
+				/* Also skip shared copy-on-write pages */
+				if (is_cow_mapping(vma->vm_flags) &&
+				    page_mapcount(page) != 1)
+					continue;
+
 				/* Avoid TLB flush if possible */
 				if (pte_protnone(oldpte))
 					continue;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
