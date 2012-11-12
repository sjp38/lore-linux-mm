Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 02F616B005A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 12:19:59 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so788451pbc.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 09:19:58 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] x86/tlb: correct vmflag test for checking VM_HUGETLB
Date: Tue, 13 Nov 2012 02:17:36 +0900
Message-Id: <1352740656-19417-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

commit 611ae8e3f5204f7480b3b405993b3352cfa16662('enable tlb flush range
support for x86') change flush_tlb_mm_range() considerably. After this,
we test whether vmflag equal to VM_HUGETLB and it may be always failed,
because vmflag usually has other flags simultaneously.
Our intention is to check whether this vma is for hughtlb, so correct it
according to this purpose.

Cc: Alex Shi <alex.shi@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 0777f04..60f926c 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -197,7 +197,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	}
 
 	if (end == TLB_FLUSH_ALL || tlb_flushall_shift == -1
-					|| vmflag == VM_HUGETLB) {
+					|| vmflag & VM_HUGETLB) {
 		local_flush_tlb();
 		goto flush_all;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
