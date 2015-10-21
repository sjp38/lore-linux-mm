Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id E12526B0257
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 17:57:01 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so2362047igb.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 14:57:01 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ru5si9023097igb.2.2015.10.21.14.56.58
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 14:56:58 -0700 (PDT)
Subject: [PATCH] mm, hugetlbfs: Fix new warning in fault-time huge page allocation
From: Dave Hansen <dave@sr71.net>
Date: Wed, 21 Oct 2015 14:56:58 -0700
Message-Id: <20151021215658.ABDE5545@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Kirill reported that he hit:
>> +	if (vma || addr) {
>> +		WARN_ON_ONCE(!addr || addr == -1);
>
> Trinity triggered the WARN for me:

This was just a dumb mistake. I put the WARN_ON() in and planned to
have addr=0 mean "use nid". But, I realized pretty quickly that addr=0
_is_ a valid place to fault. So I made it addr=-1 in
__alloc_buddy_huge_page_no_mpol(), but I did not fix up the WARN_ON().

So hitting the warning in this case was harmless.  But, fix up the
warning condition.

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

---

 b/mm/hugetlb.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff -puN mm/hugetlb.c~hugetlbfs-fix-warn mm/hugetlb.c
--- a/mm/hugetlb.c~hugetlbfs-fix-warn	2015-10-21 14:40:15.809961389 -0700
+++ b/mm/hugetlb.c	2015-10-21 14:40:15.814961616 -0700
@@ -1520,8 +1520,14 @@ static struct page *__alloc_buddy_huge_p
 	if (hstate_is_gigantic(h))
 		return NULL;
 
-	if (vma || addr) {
-		VM_WARN_ON_ONCE(!addr || addr == -1);
+	/*
+	 * Make sure that anyone specifying 'nid' is not also
+	 * specifying a VMA.  This makes sure the caller is
+	 * picking _one_ of the modes with which we can call this
+	 * function, not both.
+	 */
+	if (vma || (addr != -1)) {
+		VM_WARN_ON_ONCE(addr == -1);
 		VM_WARN_ON_ONCE(nid != NUMA_NO_NODE);
 	}
 	/*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
