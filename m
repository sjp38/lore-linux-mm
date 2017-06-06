Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4A236B037E
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:32:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e131so159438033pfh.7
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:32:16 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s11si7526878pfe.164.2017.06.06.04.32.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 04:32:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 10/14] x86/mm: Add sync_global_pgds() for configuration with 5-level paging
Date: Tue,  6 Jun 2017 14:31:29 +0300
Message-Id: <20170606113133.22974-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This basically restores slightly modified version of original
sync_global_pgds() which we had before folded p4d was introduced.

The only modification is protection against 'addr' overflow.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/init_64.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 95651dc58e09..7a9497ac468d 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -92,6 +92,44 @@ __setup("noexec32=", nonx32_setup);
  * When memory was added make sure all the processes MM have
  * suitable PGD entries in the local PGD level page.
  */
+#ifdef CONFIG_X86_5LEVEL
+void sync_global_pgds(unsigned long start, unsigned long end)
+{
+	unsigned long addr;
+
+	for (addr = start; addr <= end; addr = ALIGN(addr + 1, PGDIR_SIZE)) {
+		const pgd_t *pgd_ref = pgd_offset_k(addr);
+		struct page *page;
+
+		/* Check for overflow */
+		if (addr < start)
+			break;
+
+		if (pgd_none(*pgd_ref))
+			continue;
+
+		spin_lock(&pgd_lock);
+		list_for_each_entry(page, &pgd_list, lru) {
+			pgd_t *pgd;
+			spinlock_t *pgt_lock;
+
+			pgd = (pgd_t *)page_address(page) + pgd_index(addr);
+			/* the pgt_lock only for Xen */
+			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
+			spin_lock(pgt_lock);
+
+			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
+				BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_ref));
+
+			if (pgd_none(*pgd))
+				set_pgd(pgd, *pgd_ref);
+
+			spin_unlock(pgt_lock);
+		}
+		spin_unlock(&pgd_lock);
+	}
+}
+#else
 void sync_global_pgds(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
@@ -135,6 +173,7 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		spin_unlock(&pgd_lock);
 	}
 }
+#endif
 
 /*
  * NOTE: This function is marked __ref because it calls __init function
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
