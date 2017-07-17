Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2196B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:18:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e3so157557593pfc.4
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 23:18:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u6si1620775plm.229.2017.07.16.23.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 23:18:30 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6H6HXCG140789
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:18:29 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2brqmn8jaw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:18:29 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 17 Jul 2017 07:18:27 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: non-cooperative: notify about unmap of destination during mremap
Date: Mon, 17 Jul 2017 09:18:13 +0300
Message-Id: <1500272293-17174-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, stable@vger.kernel.org

When mremap is called with MREMAP_FIXED it unmaps memory at the destination
address without notifying userfaultfd monitor. If the destination were
registered with userfaultfd, the monitor has no way to distinguish between
the old and new ranges and to properly relate the page faults that would
occur in the destination region.

Cc: stable@vger.kernel.org
Fixes: 897ab3e0c49e ("userfaultfd: non-cooperative: add event for memory
unmaps")

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/mremap.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b199ef9..eb36ef9410e4 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -446,9 +446,14 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (addr + old_len > new_addr && new_addr + new_len > addr)
 		goto out;
 
-	ret = do_munmap(mm, new_addr, new_len, NULL);
+	/*
+	 * We presume the uf_unmap list is empty by this point and it
+	 * will be cleared again in userfaultfd_unmap_complete.
+	 */
+	ret = do_munmap(mm, new_addr, new_len, uf_unmap);
 	if (ret)
 		goto out;
+	userfaultfd_unmap_complete(mm, uf_unmap);
 
 	if (old_len >= new_len) {
 		ret = do_munmap(mm, addr+new_len, old_len - new_len, uf_unmap);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
