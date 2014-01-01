Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7896B0031
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 19:29:44 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so13068757qeb.34
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 16:29:44 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id g1si21097725qcl.57.2013.12.31.16.29.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Dec 2013 16:29:43 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Tue, 31 Dec 2013 19:29:42 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id ADF636E803C
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 19:29:35 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s010TdOd57540848
	for <linux-mm@kvack.org>; Wed, 1 Jan 2014 00:29:39 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s010TcK5014456
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 19:29:38 -0500
Date: Wed, 1 Jan 2014 08:29:35 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140101002935.GA15683@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

min_free_kbytes may be updated during thp's initialization. Sometimes,
this will change the value being set by user. Showing message will
clarify this confusion.

Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>
---
 mm/huge_memory.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7de1bf8..46011c6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -130,8 +130,11 @@ static int set_recommended_min_free_kbytes(void)
 			      (unsigned long) nr_free_buffer_pages() / 20);
 	recommended_min <<= (PAGE_SHIFT-10);
 
-	if (recommended_min > min_free_kbytes)
+	if (recommended_min > min_free_kbytes) {
 		min_free_kbytes = recommended_min;
+		pr_info("min_free_kbytes is updated to %d by enabling transparent hugepage.\n",
+			min_free_kbytes);
+	}
 	setup_per_zone_wmarks();
 	return 0;
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
