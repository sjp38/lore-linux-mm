Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19B2A6B46DE
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:36:13 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so10496014edd.2
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 00:36:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f18si1465137edq.256.2018.11.27.00.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 00:36:11 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAR8YSCJ107317
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:36:09 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p117r3tfk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:36:09 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 27 Nov 2018 08:36:07 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] mm: warn only once if page table misaccounting is detected
Date: Tue, 27 Nov 2018 09:36:03 +0100
Message-Id: <20181127083603.39041-1-heiko.carstens@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, Heiko Carstens <heiko.carstens@de.ibm.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Use pr_alert_once() instead of pr_alert() if page table misaccounting
has been detected.

If this happens once it is very likely that there will be numerous
other occurrence as well, which would flood dmesg and the console with
hardly any added information. Therefore print the warning only once.

Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 kernel/fork.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 07cddff89c7b..c887e9eba89f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -647,8 +647,8 @@ static void check_mm(struct mm_struct *mm)
 	}
 
 	if (mm_pgtables_bytes(mm))
-		pr_alert("BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
-				mm_pgtables_bytes(mm));
+		pr_alert_once("BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
+			      mm_pgtables_bytes(mm));
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
-- 
2.16.4
