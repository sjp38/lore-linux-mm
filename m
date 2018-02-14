Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E97B56B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:17:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m65so5394847pfm.14
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:17:14 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p5si640820pgn.197.2018.02.14.03.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 03:17:13 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/9] x86/mm/64: Make __PHYSICAL_MASK_SHIFT always 52
Date: Wed, 14 Feb 2018 14:16:48 +0300
Message-Id: <20180214111656.88514-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

__PHYSICAL_MASK_SHIFT is used to define the mask that helps to extract
physical address from a page table entry.

Although, real physical address space available may differ between
machines, it's safe to use 52 as __PHYSICAL_MASK_SHIFT. Unused bits
above log2(MAXPHYADDR) up to bit 51 are reserved and must be 0.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/page_64_types.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index e1407312c412..f68e6526891d 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -52,11 +52,12 @@
 #define __START_KERNEL_map	_AC(0xffffffff80000000, UL)
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
-#ifdef CONFIG_X86_5LEVEL
+
 #define __PHYSICAL_MASK_SHIFT	52
+
+#ifdef CONFIG_X86_5LEVEL
 #define __VIRTUAL_MASK_SHIFT	56
 #else
-#define __PHYSICAL_MASK_SHIFT	46
 #define __VIRTUAL_MASK_SHIFT	47
 #endif
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
