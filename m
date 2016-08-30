Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B03583096
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:00:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so37648407pfg.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:31 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id 84si44736110pfk.97.2016.08.30.04.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:00:30 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id cf3so965731pad.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:30 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 2/4] mm: mlock: avoid increase mm->locked_vm on mlock() when already mlock2(,MLOCK_ONFAULT)
Date: Tue, 30 Aug 2016 18:59:39 +0800
Message-Id: <1472554781-9835-3-git-send-email-wei.guo.simon@gmail.com>
In-Reply-To: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
References: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Simon Guo <wei.guo.simon@gmail.com>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

From: Simon Guo <wei.guo.simon@gmail.com>

When one vma was with flag VM_LOCKED|VM_LOCKONFAULT (by invoking
mlock2(,MLOCK_ONFAULT)), it can again be populated with mlock() with
VM_LOCKED flag only.

There is a hole in mlock_fixup() which increase mm->locked_vm twice even
the two operations are on the same vma and both with VM_LOCKED flags.

The issue can be reproduced by following code:
mlock2(p, 1024 * 64, MLOCK_ONFAULT); //VM_LOCKED|VM_LOCKONFAULT
mlock(p, 1024 * 64);  //VM_LOCKED
Then check the increase VmLck field in /proc/pid/status(to 128k).

When vma is set with different vm_flags, and the new vm_flags is with
VM_LOCKED, it is not necessarily be a "new locked" vma.  This patch
corrects this bug by prevent mm->locked_vm from increment when old
vm_flags is already VM_LOCKED.

Signed-off-by: Simon Guo <wei.guo.simon@gmail.com>
---
 mm/mlock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index 9283187..df29aad 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -516,6 +516,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	int nr_pages;
 	int ret = 0;
 	int lock = !!(newflags & VM_LOCKED);
+	vm_flags_t old_flags = vma->vm_flags;
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
@@ -550,6 +551,8 @@ success:
 	nr_pages = (end - start) >> PAGE_SHIFT;
 	if (!lock)
 		nr_pages = -nr_pages;
+	else if (old_flags & VM_LOCKED)
+		nr_pages = 0;
 	mm->locked_vm += nr_pages;
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
