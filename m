Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EACB76B0071
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:32:53 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so30819729pdj.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:53 -0700 (PDT)
Received: from mail-pd0-x242.google.com (mail-pd0-x242.google.com. [2607:f8b0:400e:c02::242])
        by mx.google.com with ESMTPS id hn9si12325244pdb.133.2015.06.09.23.32.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:32:52 -0700 (PDT)
Received: by pdbht2 with SMTP id ht2so7464539pdb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:52 -0700 (PDT)
From: Wenwei Tao <wenweitaowenwei@gmail.com>
Subject: [RFC PATCH 5/6] x86/mm: change the condition of identifying hugetlb vm
Date: Wed, 10 Jun 2015 14:27:18 +0800
Message-Id: <1433917639-31699-6-git-send-email-wenweitaowenwei@gmail.com>
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
 arch/x86/mm/tlb.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 3250f23..0247916 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -195,7 +195,8 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		goto out;
 	}
 
-	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
+	if ((end != TLB_FLUSH_ALL) &&
+		!((vmflag & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB))
 		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
 
 	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
