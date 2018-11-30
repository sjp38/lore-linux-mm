Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2416B5810
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 06:58:06 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h86-v6so4301380pfd.2
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 03:58:06 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k11si5136491plt.68.2018.11.30.03.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 03:58:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] x86/dump_pagetables: Fix LDT remap address marker
Date: Fri, 30 Nov 2018 14:57:58 +0300
Message-Id: <20181130115758.4425-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181130115758.4425-1-kirill.shutemov@linux.intel.com>
References: <20181130115758.4425-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The LDT remap placement has been changed. It's now placed before direct
mapping in the kernel virtual address space for both paging modes.

Change address markers order accordingly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: d52888aa2753 ("x86/mm: Move LDT remap out of KASLR region on 5-level paging")
---
 arch/x86/mm/dump_pagetables.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index dad153e5a427..abcb8d00b014 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -55,10 +55,10 @@ struct addr_marker {
 enum address_markers_idx {
 	USER_SPACE_NR = 0,
 	KERNEL_SPACE_NR,
-	LOW_KERNEL_NR,
-#if defined(CONFIG_MODIFY_LDT_SYSCALL) && defined(CONFIG_X86_5LEVEL)
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
 	LDT_NR,
 #endif
+	LOW_KERNEL_NR,
 	VMALLOC_START_NR,
 	VMEMMAP_START_NR,
 #ifdef CONFIG_KASAN
@@ -66,9 +66,6 @@ enum address_markers_idx {
 	KASAN_SHADOW_END_NR,
 #endif
 	CPU_ENTRY_AREA_NR,
-#if defined(CONFIG_MODIFY_LDT_SYSCALL) && !defined(CONFIG_X86_5LEVEL)
-	LDT_NR,
-#endif
 #ifdef CONFIG_X86_ESPFIX64
 	ESPFIX_START_NR,
 #endif
-- 
2.19.2
