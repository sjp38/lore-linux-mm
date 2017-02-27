Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7976B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 16:44:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 1so196840897pgz.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:44:43 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f35si16219404plh.40.2017.02.27.13.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 13:44:42 -0800 (PST)
Subject: [PATCH] mm,
 x86: fix HIGHMEM64 && PARAVIRT build config for native_pud_clear()
From: Dave Jiang <dave.jiang@intel.com>
Date: Mon, 27 Feb 2017 14:44:40 -0700
Message-ID: <148823188084.56076.17451228917824355200.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, alexander.kapshuk@gmail.com, mawilcox@microsoft.com, boris.ostrovsky@oracle.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, labbott@redhat.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

Looks like I also missed the build config that includes
CONFIG_HIGHMEM64G && CONFIG_PARAVIRT to export the native_pud_clear()
dummy function.

Fix: commit e5d56efc ("mm,x86: fix SMP x86 32bit build for native_pud_clear()")

Reported-by: Laura Abbott <labbott@redhat.com>
Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 arch/x86/include/asm/pgtable-3level.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 8f50fb3..72277b1 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -121,7 +121,8 @@ static inline void native_pmd_clear(pmd_t *pmd)
 	*(tmp + 1) = 0;
 }
 
-#ifndef CONFIG_SMP
+#if !defined(CONFIG_SMP) || (defined(CONFIG_HIGHMEM64G) && \
+		defined(CONFIG_PARAVIRT))
 static inline void native_pud_clear(pud_t *pudp)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
