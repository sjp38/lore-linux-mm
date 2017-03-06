Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68E6A6B0393
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 17:18:22 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e129so38620536pfh.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 14:18:22 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y76si20278033pfi.244.2017.03.06.14.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 14:18:21 -0800 (PST)
Subject: [PATCH] x86,
 mm: fix NOHIGHMEM && X86_PAE build config for native_pud_clear()
From: Dave Jiang <dave.jiang@intel.com>
Date: Mon, 06 Mar 2017 15:18:18 -0700
Message-ID: <148883869853.70777.12180810304957921737.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, jack@suse.com, dan.j.williams@intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

Looks like a 32bit x86 build failure case where X86_PAE and NOHIMEM
are on. This was reported by kbuild test bot.

   In file included from include/linux/mm.h:68:0,
                    from include/linux/highmem.h:7,
                    from include/linux/bio.h:21,
                    from include/linux/writeback.h:205,
                    from include/linux/memcontrol.h:30,
                    from include/linux/swap.h:8,
                    from include/linux/suspend.h:4,
                    from arch/x86/kernel/asm-offsets.c:12:
   arch/x86/include/asm/pgtable.h: In function 'native_local_pudp_get_and_clear':
>> arch/x86/include/asm/pgtable.h:888:2: error: implicit declaration of function 'native_pud_clear' [-Werror=implicit-function-declaration]
     native_pud_clear(pudp);
     ^~~~~~~~~~~~~~~~

Fixes: a00cc7d9dd93d ("mm, x86: add support for PUD-sized transparent
hugepages")

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 arch/x86/include/asm/pgtable-3level.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 72277b1..d337738 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -121,8 +121,9 @@ static inline void native_pmd_clear(pmd_t *pmd)
 	*(tmp + 1) = 0;
 }
 
-#if !defined(CONFIG_SMP) || (defined(CONFIG_HIGHMEM64G) && \
-		defined(CONFIG_PARAVIRT))
+#if !defined(CONFIG_SMP) || \
+	(defined(CONFIG_HIGHMEM64G) && defined(CONFIG_PARAVIRT)) || \
+	(defined(CONFIG_NOHIGHMEM) && defined(CONFIG_X86_PAE))
 static inline void native_pud_clear(pud_t *pudp)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
