Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C76436B0093
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 07:56:49 -0500 (EST)
Received: by gxk12 with SMTP id 12so2424273gxk.14
        for <linux-mm@kvack.org>; Wed, 18 Feb 2009 04:56:48 -0800 (PST)
Date: Wed, 18 Feb 2009 20:56:49 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] mm: fix null pointer dereference in vm_normal_page()
Message-ID: <20090218125649.GU7272@hack.private>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>


One usage of vm_normal_page() is:

    struct page *page = vm_normal_page(gate_vma, start, *pte);

where gate_vma is returned by get_gate_vma() which can be NULL.
So let vm_normal_page return NULL when vma is NULL.

Signed-off-by: WANG Cong <wangcong@zeuux.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>

---
diff --git a/mm/memory.c b/mm/memory.c
index baa999e..e428aa6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -493,6 +493,9 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 {
 	unsigned long pfn = pte_pfn(pte);
 
+	if (!vma)
+		return NULL;
+
 	if (HAVE_PTE_SPECIAL) {
 		if (likely(!pte_special(pte)))
 			goto check_pfn;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
