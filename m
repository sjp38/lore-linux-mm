Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE7F06B0009
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 21:12:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 91-v6so11992981pla.18
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 18:12:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u91-v6si1860593plb.698.2018.04.03.18.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 18:12:42 -0700 (PDT)
Subject: [PATCH 04/11] x86/espfix: document use of _PAGE_GLOBAL
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 03 Apr 2018 18:09:56 -0700
References: <20180404010946.6186729B@viggo.jf.intel.com>
In-Reply-To: <20180404010946.6186729B@viggo.jf.intel.com>
Message-Id: <20180404010956.32C1983F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The "normal" kernel page table creation mechanisms using
PAGE_KERNEL_* page protections will never set _PAGE_GLOBAL with PTI.
The few places in the kernel that always want _PAGE_GLOBAL must
avoid using PAGE_KERNEL_*.

Document that we want it here and its use is not accidental.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
Cc: Nadav Amit <namit@vmware.com>
---

 b/arch/x86/kernel/espfix_64.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN arch/x86/kernel/espfix_64.c~espfix-use-kern-defaults-not-supported arch/x86/kernel/espfix_64.c
--- a/arch/x86/kernel/espfix_64.c~espfix-use-kern-defaults-not-supported	2018-04-02 16:41:14.274605175 -0700
+++ b/arch/x86/kernel/espfix_64.c	2018-04-02 16:41:14.278605175 -0700
@@ -195,6 +195,10 @@ void init_espfix_ap(int cpu)
 
 	pte_p = pte_offset_kernel(&pmd, addr);
 	stack_page = page_address(alloc_pages_node(node, GFP_KERNEL, 0));
+	/*
+	 * __PAGE_KERNEL_* includes _PAGE_GLOBAL, which we want since
+	 * this is mapped to userspace.
+	 */
 	pte = __pte(__pa(stack_page) | ((__PAGE_KERNEL_RO | _PAGE_ENC) & ptemask));
 	for (n = 0; n < ESPFIX_PTE_CLONES; n++)
 		set_pte(&pte_p[n*PTE_STRIDE], pte);
_
