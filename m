Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD8746B0028
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 13:29:47 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s23-v6so6036616plr.15
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 10:29:47 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id a61-v6si740752pla.400.2018.04.02.10.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 10:29:46 -0700 (PDT)
Subject: [PATCH 04/11] x86/espfix: document use of _PAGE_GLOBAL
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 02 Apr 2018 10:27:06 -0700
References: <20180402172700.65CAE838@viggo.jf.intel.com>
In-Reply-To: <20180402172700.65CAE838@viggo.jf.intel.com>
Message-Id: <20180402172706.561662DD@viggo.jf.intel.com>
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
--- a/arch/x86/kernel/espfix_64.c~espfix-use-kern-defaults-not-supported	2018-04-02 10:26:44.300661214 -0700
+++ b/arch/x86/kernel/espfix_64.c	2018-04-02 10:26:44.303661214 -0700
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
