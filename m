Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 792B78E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 17:40:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so18866586pfj.4
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 14:40:27 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s13si17407523pgc.509.2018.12.26.14.40.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 14:40:26 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.14 19/59] x86/dump_pagetables: Fix LDT remap address marker
Date: Wed, 26 Dec 2018 17:37:59 -0500
Message-Id: <20181226223839.150262-19-sashal@kernel.org>
In-Reply-To: <20181226223839.150262-1-sashal@kernel.org>
References: <20181226223839.150262-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, hans.van.kranenburg@mendix.com, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Sasha Levin <sashal@kernel.org>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[ Upstream commit 254eb5505ca0ca749d3a491fc6668b6c16647a99 ]

The LDT remap placement has been changed. It's now placed before the direct
mapping in the kernel virtual address space for both paging modes.

Change address markers order accordingly.

Fixes: d52888aa2753 ("x86/mm: Move LDT remap out of KASLR region on 5-level paging")
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: bp@alien8.de
Cc: hpa@zytor.com
Cc: dave.hansen@linux.intel.com
Cc: luto@kernel.org
Cc: peterz@infradead.org
Cc: boris.ostrovsky@oracle.com
Cc: jgross@suse.com
Cc: bhe@redhat.com
Cc: hans.van.kranenburg@mendix.com
Cc: linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org
Link: https://lkml.kernel.org/r/20181130202328.65359-3-kirill.shutemov@linux.intel.com
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/x86/mm/dump_pagetables.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index cf403e057f3f..6bca45d06676 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -51,10 +51,10 @@ struct addr_marker {
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
@@ -62,9 +62,6 @@ enum address_markers_idx {
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
2.19.1
