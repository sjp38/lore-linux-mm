Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E10276B002F
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 13:29:55 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f19-v6so5988630plr.23
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 10:29:55 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m125si524506pgm.163.2018.04.02.10.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 10:29:54 -0700 (PDT)
Subject: [PATCH 07/11] x86/mm: comment _PAGE_GLOBAL mystery
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 02 Apr 2018 10:27:10 -0700
References: <20180402172700.65CAE838@viggo.jf.intel.com>
In-Reply-To: <20180402172700.65CAE838@viggo.jf.intel.com>
Message-Id: <20180402172710.9AEB9D53@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

I was mystified as to where the _PAGE_GLOBAL in the kernel page tables
for kernel text came from.  I audited all the places I could find, but
I missed one: head_64.S.

The page tables that we create in here live for a long time, and they
also have _PAGE_GLOBAL set, despite whether the processor supports it
or not.  It's harmless, and we got *lucky* that the pageattr code
accidentally clears it when we wipe it out of __supported_pte_mask and
then later try to mark kernel text read-only.

Comment some of these properties to make it easier to find and
understand in the future.

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

 b/arch/x86/kernel/head_64.S |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff -puN arch/x86/kernel/head_64.S~comment-global-page arch/x86/kernel/head_64.S
--- a/arch/x86/kernel/head_64.S~comment-global-page	2018-04-02 10:26:46.113661210 -0700
+++ b/arch/x86/kernel/head_64.S	2018-04-02 10:26:46.116661210 -0700
@@ -399,8 +399,13 @@ NEXT_PAGE(level3_ident_pgt)
 	.quad	level2_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
 	.fill	511, 8, 0
 NEXT_PAGE(level2_ident_pgt)
-	/* Since I easily can, map the first 1G.
+	/*
+	 * Since I easily can, map the first 1G.
 	 * Don't set NX because code runs from these pages.
+	 *
+	 * Note: This sets _PAGE_GLOBAL despite whether
+	 * the CPU supports it or it is enabled.  But,
+	 * the CPU should ignore the bit.
 	 */
 	PMDS(0, __PAGE_KERNEL_IDENT_LARGE_EXEC, PTRS_PER_PMD)
 #else
@@ -431,6 +436,10 @@ NEXT_PAGE(level2_kernel_pgt)
 	 * (NOTE: at +512MB starts the module area, see MODULES_VADDR.
 	 *  If you want to increase this then increase MODULES_VADDR
 	 *  too.)
+	 *
+	 *  This table is eventually used by the kernel during normal
+	 *  runtime.  Care must be taken to clear out undesired bits
+	 *  later, like _PAGE_RW or _PAGE_GLOBAL in some cases.
 	 */
 	PMDS(0, __PAGE_KERNEL_LARGE_EXEC,
 		KERNEL_IMAGE_SIZE/PMD_SIZE)
_
