Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 699256B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:32:38 -0400 (EDT)
Received: by payr10 with SMTP id r10so28485260pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:38 -0700 (PDT)
Received: from mail-pd0-x241.google.com (mail-pd0-x241.google.com. [2607:f8b0:400e:c02::241])
        by mx.google.com with ESMTPS id og9si12303078pbc.66.2015.06.09.23.32.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:32:37 -0700 (PDT)
Received: by pdbht2 with SMTP id ht2so7453873pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:37 -0700 (PDT)
From: Wenwei Tao <wenweitaowenwei@gmail.com>
Subject: [RFC PATCH 3/6] perf: change the condition of identifying hugetlb vm
Date: Wed, 10 Jun 2015 14:27:16 +0800
Message-Id: <1433917639-31699-4-git-send-email-wenweitaowenwei@gmail.com>
In-Reply-To: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, hughd@google.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, wenweitaowenwei@gmail.com

Hugetlb VMAs are not mergeable, that means a VMA couldn't have VM_HUGETLB and
VM_MERGEABLE been set in the same time. So we use VM_HUGETLB to indicate new
mergeable VMAs. Because of that a VMA which has VM_HUGETLB been set is a hugetlb
VMA only if it doesn't have VM_MERGEABLE been set in the same time.

Signed-off-by: Wenwei Tao <wenweitaowenwei@gmail.com>
---
 kernel/events/core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index f04daab..6313bdd 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5624,7 +5624,7 @@ static void perf_event_mmap_event(struct perf_mmap_event *mmap_event)
 			flags |= MAP_EXECUTABLE;
 		if (vma->vm_flags & VM_LOCKED)
 			flags |= MAP_LOCKED;
-		if (vma->vm_flags & VM_HUGETLB)
+		if ((vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB)
 			flags |= MAP_HUGETLB;
 
 		goto got_name;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
