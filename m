Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 850CF6B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 06:32:04 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id jl1so151913373obb.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 03:32:04 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [125.16.236.1])
        by mx.google.com with ESMTPS id mf5si3184677igb.24.2016.04.22.03.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 22 Apr 2016 03:32:03 -0700 (PDT)
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xyjxie@linux.vnet.ibm.com>;
	Fri, 22 Apr 2016 16:02:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3MAVtb237683382
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 16:01:55 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3MAVqtK011260
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 16:01:54 +0530
From: Yongji Xie <xyjxie@linux.vnet.ibm.com>
Subject: [PATCH] mm: Fix incorrect pfn passed to untrack_pfn in remap_pfn_range
Date: Fri, 22 Apr 2016 18:31:28 +0800
Message-Id: <1461321088-3247-1-git-send-email-xyjxie@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jmarchan@redhat.com, mingo@kernel.org, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, matthew.r.wilcox@intel.com, aarcange@redhat.com, mhocko@suse.com, luto@kernel.org, dahi@linux.vnet.ibm.com, Yongji Xie <xyjxie@linux.vnet.ibm.com>

We used generic hooks in remap_pfn_range to help archs to
track pfnmap regions. The code is something like:

int remap_pfn_range()
{
	...
	track_pfn_remap(vma, &prot, pfn, addr, PAGE_ALIGN(size));
	...
	pfn -= addr >> PAGE_SHIFT;
	...
	untrack_pfn(vma, pfn, PAGE_ALIGN(size));
	...
}

Here we can easily find the pfn is changed but not recovered
before untrack_pfn() is called. That's incorrect.

Signed-off-by: Yongji Xie <xyjxie@linux.vnet.ibm.com>
---
 mm/memory.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index 098f00d..cb9e0c4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1755,6 +1755,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 			break;
 	} while (pgd++, addr = next, addr != end);
 
+	pfn += (end - PAGE_ALIGN(size)) >> PAGE_SHIFT;
 	if (err)
 		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
