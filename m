Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7805F6B026D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:11:38 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gt1so2730296wjc.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:11:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u73si433223wrc.271.2017.01.18.06.11.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 06:11:37 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm/mempolicy.c: do not put mempolicy before using its nodemask
Date: Wed, 18 Jan 2017 15:11:24 +0100
Message-Id: <20170118141124.8345-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>

Since commit be97a41b291e ("mm/mempolicy.c: merge alloc_hugepage_vma to
alloc_pages_vma") alloc_pages_vma() can potentially free a mempolicy by
mpol_cond_put() before accessing the embedded nodemask by
__alloc_pages_nodemask(). The commit log says it's so "we can use a single
exit path within the function" but that's clearly wrong. We can still do that
when doing mpol_cond_put() after the allocation attempt.

Make sure the mempolicy is not freed prematurely, otherwise
__alloc_pages_nodemask() can end up using a bogus nodemask, which could lead
e.g. to premature OOM.

Fixes: be97a41b291e ("mm/mempolicy.c: merge alloc_hugepage_vma to alloc_pages_vma")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: stable@vger.kernel.org
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2e346645eb80..1e7873e40c9a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2017,8 +2017,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 
 	nmask = policy_nodemask(gfp, pol);
 	zl = policy_zonelist(gfp, pol, node);
-	mpol_cond_put(pol);
 	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
+	mpol_cond_put(pol);
 out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
