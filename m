Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id E27F56B0257
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 15:08:20 -0500 (EST)
Received: by qkeg192 with SMTP id g192so11650997qke.1
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 12:08:20 -0800 (PST)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id 92si13801233qgh.25.2015.12.05.12.08.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 05 Dec 2015 12:08:20 -0800 (PST)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Sat, 5 Dec 2015 15:08:19 -0500
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id EEFF8C90042
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 14:56:26 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tB5K8HOm30277730
	for <linux-mm@kvack.org>; Sat, 5 Dec 2015 20:08:17 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tB5K8HG0015605
	for <linux-mm@kvack.org>; Sat, 5 Dec 2015 15:08:17 -0500
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] mm/swapfile: mm/swapfile: fix swapoff vs. software dirty bits
Date: Mon, 14 Sep 2015 11:24:47 +0200
Message-Id: <1442222687-9758-2-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1442222687-9758-1-git-send-email-schwidefsky@de.ibm.com>
References: <1442222687-9758-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>
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
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
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
