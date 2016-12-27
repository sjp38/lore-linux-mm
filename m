Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 774566B0266
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so269117472pgj.6
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:44 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e1si44820309pfb.241.2016.12.26.17.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 11/29] x86/ident_map: add 5-level paging support
Date: Tue, 27 Dec 2016 04:53:55 +0300
Message-Id: <20161227015413.187403-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nothing special: just handle one more level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/ident_map.c | 42 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
index 4473cb4f8b90..f1a620b9f2ef 100644
--- a/arch/x86/mm/ident_map.c
+++ b/arch/x86/mm/ident_map.c
@@ -45,6 +45,34 @@ static int ident_pud_init(struct x86_mapping_info *info, pud_t *pud_page,
 	return 0;
 }
 
+static int ident_p4d_init(struct x86_mapping_info *info, p4d_t *p4d_page,
+			  unsigned long addr, unsigned long end)
+{
+	unsigned long next;
+
+	for (; addr < end; addr = next) {
+		p4d_t *p4d = p4d_page + p4d_index(addr);
+		pud_t *pud;
+
+		next = (addr & P4D_MASK) + P4D_SIZE;
+		if (next > end)
+			next = end;
+
+		if (p4d_present(*p4d)) {
+			pud = pud_offset(p4d, 0);
+			ident_pud_init(info, pud, addr, next);
+			continue;
+		}
+		pud = (pud_t *)info->alloc_pgt_page(info->context);
+		if (!pud)
+			return -ENOMEM;
+		ident_pud_init(info, pud, addr, next);
+		set_p4d(p4d, __p4d(__pa(pud) | _KERNPG_TABLE));
+	}
+
+	return 0;
+}
+
 int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 			      unsigned long pstart, unsigned long pend)
 {
@@ -55,27 +83,27 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 
 	for (; addr < end; addr = next) {
 		pgd_t *pgd = pgd_page + pgd_index(addr);
-		pud_t *pud;
+		p4d_t *p4d;
 
 		next = (addr & PGDIR_MASK) + PGDIR_SIZE;
 		if (next > end)
 			next = end;
 
 		if (pgd_present(*pgd)) {
-			pud = pud_offset(pgd, 0);
-			result = ident_pud_init(info, pud, addr, next);
+			p4d = p4d_offset(pgd, 0);
+			result = ident_p4d_init(info, p4d, addr, next);
 			if (result)
 				return result;
 			continue;
 		}
 
-		pud = (pud_t *)info->alloc_pgt_page(info->context);
-		if (!pud)
+		p4d = (p4d_t *)info->alloc_pgt_page(info->context);
+		if (!p4d)
 			return -ENOMEM;
-		result = ident_pud_init(info, pud, addr, next);
+		result = ident_p4d_init(info, p4d, addr, next);
 		if (result)
 			return result;
-		set_pgd(pgd, __pgd(__pa(pud) | _KERNPG_TABLE));
+		set_pgd(pgd, __pgd(__pa(p4d) | _KERNPG_TABLE));
 	}
 
 	return 0;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
