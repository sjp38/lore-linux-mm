Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF3C6B0254
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 04:59:41 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so108168005wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 01:59:41 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id e11si2703052wjs.28.2015.09.17.01.59.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Sep 2015 01:59:40 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 17 Sep 2015 09:59:38 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3A3E41B08070
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 10:00:44 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8H8x2UE29622466
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:59:02 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8H8x2Xa027298
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:59:02 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Date: Thu, 17 Sep 2015 10:58:59 +0200
Message-Id: <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

Fixes a regression introduced with commit 179ef71cbc085252
"mm: save soft-dirty bits on swapped pages"

The maybe_same_pte() function is used to match a swap pte independent
of the swap software dirty bit set with pte_swp_mksoft_dirty().

For CONFIG_HAVE_ARCH_SOFT_DIRTY=y but CONFIG_MEM_SOFT_DIRTY=n the
software dirty bit may be set but maybe_same_pte() will not recognize
a software dirty swap pte. Due to this a 'swapoff -a' will hang.

The straightforward solution is to replace CONFIG_MEM_SOFT_DIRTY
with HAVE_ARCH_SOFT_DIRTY in maybe_same_pte().

Cc: linux-mm@kvack.org
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5887731..bf7da58 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1113,7 +1113,7 @@ unsigned int count_swap_pages(int type, int free)
 
 static inline int maybe_same_pte(pte_t pte, pte_t swp_pte)
 {
-#ifdef CONFIG_MEM_SOFT_DIRTY
+#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 	/*
 	 * When pte keeps soft dirty bit the pte generated
 	 * from swap entry does not has it, still it's same
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
