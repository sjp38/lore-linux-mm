Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCEF6B0269
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 17:15:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v88-v6so7313251pfk.19
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 14:15:29 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id 20-v6si6146295pfk.287.2018.10.04.14.15.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 14:15:28 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 2/2 -mm] mm: mremap: fix unsigned compare against 0 issue
Date: Fri,  5 Oct 2018 05:14:32 +0800
Message-Id: <1538687672-17795-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1538687672-17795-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1538687672-17795-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, kirill.shutemov@linux.intel.com, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, colin.king@canonical.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Static analysis reported unsigned compare against 0 issue according to
Colin Ian King.

Defined an int temp variable to check the return value of __do_munmap().

Reported-by: Colin Ian King <colin.king@canonical.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
Andrew, this should be able to be folded into the original patch.

 mm/mremap.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 3524d16..f9d5d1f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -566,12 +566,14 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 	 * downgrade mmap_sem to read.
 	 */
 	if (old_len >= new_len) {
-		ret = __do_munmap(mm, addr+new_len, old_len - new_len,
+		int retval;
+		retval = __do_munmap(mm, addr+new_len, old_len - new_len,
 				  &uf_unmap, true);
-		if (ret < 0 && old_len != new_len)
+		if (retval < 0 && old_len != new_len) {
+			ret = retval;
 			goto out;
 		/* Returning 1 indicates mmap_sem is downgraded to read. */
-		else if (ret == 1)
+		} else if (retval == 1)
 			downgraded = true;
 		ret = addr;
 		goto out;
-- 
1.8.3.1
