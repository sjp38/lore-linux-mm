Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F03E66B0005
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 00:06:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so192795156pfy.2
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 21:06:26 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id pz7si4251406pab.216.2016.04.23.21.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 23 Apr 2016 21:06:26 -0700 (PDT)
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xyjxie@linux.vnet.ibm.com>;
	Sun, 24 Apr 2016 14:06:22 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 365AC3578053
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 14:06:04 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3O45pAP66322506
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 14:06:04 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3O45R41016509
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 14:05:27 +1000
From: Yongji Xie <xyjxie@linux.vnet.ibm.com>
Subject: [PATCH v2] mm: fix incorrect pfn passed to untrack_pfn() in remap_pfn_range()
Date: Sun, 24 Apr 2016 12:01:41 +0800
Message-Id: <1461470501-5044-1-git-send-email-xyjxie@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jmarchan@redhat.com, mingo@kernel.org, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, matthew.r.wilcox@intel.com, aarcange@redhat.com, mhocko@suse.com, luto@kernel.org, dahi@linux.vnet.ibm.com, Yongji Xie <xyjxie@linux.vnet.ibm.com>

We use generic hooks in remap_pfn_range() to help archs to
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
 mm/memory.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 098f00d..eee75ed 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1711,6 +1711,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	unsigned long next;
 	unsigned long end = addr + PAGE_ALIGN(size);
 	struct mm_struct *mm = vma->vm_mm;
+	unsigned long remap_pfn = pfn;
 	int err;
 
 	/*
@@ -1737,7 +1738,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 		vma->vm_pgoff = pfn;
 	}
 
-	err = track_pfn_remap(vma, &prot, pfn, addr, PAGE_ALIGN(size));
+	err = track_pfn_remap(vma, &prot, remap_pfn, addr, PAGE_ALIGN(size));
 	if (err)
 		return -EINVAL;
 
@@ -1756,7 +1757,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	} while (pgd++, addr = next, addr != end);
 
 	if (err)
-		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
+		untrack_pfn(vma, remap_pfn, PAGE_ALIGN(size));
 
 	return err;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
