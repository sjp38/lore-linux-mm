Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 613906B03F7
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:35 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l55so615414qtl.7
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:35 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id o3si118622qtc.72.2017.07.05.14.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:34 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id v31so187224qtb.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:34 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 27/38] powerpc: Macro the mask used for checking DSI exception
Date: Wed,  5 Jul 2017 14:22:04 -0700
Message-Id: <1499289735-14220-28-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Replace the magic number used to check for DSI exception
with a meaningful value.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/reg.h       |    7 ++++++-
 arch/powerpc/kernel/exceptions-64s.S |    2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/reg.h b/arch/powerpc/include/asm/reg.h
index 7e50e47..ba110dd 100644
--- a/arch/powerpc/include/asm/reg.h
+++ b/arch/powerpc/include/asm/reg.h
@@ -272,16 +272,21 @@
 #define SPRN_DAR	0x013	/* Data Address Register */
 #define SPRN_DBCR	0x136	/* e300 Data Breakpoint Control Reg */
 #define SPRN_DSISR	0x012	/* Data Storage Interrupt Status Register */
+#define   DSISR_BIT32		0x80000000	/* not defined */
 #define   DSISR_NOHPTE		0x40000000	/* no translation found */
+#define   DSISR_PAGEATTR_CONFLT	0x20000000	/* page attribute conflict */
+#define   DSISR_BIT35		0x10000000	/* not defined */
 #define   DSISR_PROTFAULT	0x08000000	/* protection fault */
 #define   DSISR_BADACCESS	0x04000000	/* bad access to CI or G */
 #define   DSISR_ISSTORE		0x02000000	/* access was a store */
 #define   DSISR_DABRMATCH	0x00400000	/* hit data breakpoint */
-#define   DSISR_NOSEGMENT	0x00200000	/* SLB miss */
 #define   DSISR_KEYFAULT	0x00200000	/* Key fault */
+#define   DSISR_BIT43		0x00100000	/* not defined */
 #define   DSISR_UNSUPP_MMU	0x00080000	/* Unsupported MMU config */
 #define   DSISR_SET_RC		0x00040000	/* Failed setting of R/C bits */
 #define   DSISR_PGDIRFAULT      0x00020000      /* Fault on page directory */
+#define   DSISR_PAGE_FAULT_MASK (DSISR_BIT32 | DSISR_PAGEATTR_CONFLT | \
+				DSISR_BADACCESS | DSISR_BIT43)
 #define SPRN_TBRL	0x10C	/* Time Base Read Lower Register (user, R/O) */
 #define SPRN_TBRU	0x10D	/* Time Base Read Upper Register (user, R/O) */
 #define SPRN_CIR	0x11B	/* Chip Information Register (hyper, R/0) */
diff --git a/arch/powerpc/kernel/exceptions-64s.S b/arch/powerpc/kernel/exceptions-64s.S
index ae418b8..3fd0528 100644
--- a/arch/powerpc/kernel/exceptions-64s.S
+++ b/arch/powerpc/kernel/exceptions-64s.S
@@ -1411,7 +1411,7 @@ USE_TEXT_SECTION()
 	.balign	IFETCH_ALIGN_BYTES
 do_hash_page:
 #ifdef CONFIG_PPC_STD_MMU_64
-	andis.	r0,r4,0xa410		/* weird error? */
+	andis.	r0,r4,DSISR_PAGE_FAULT_MASK@h
 	bne-	handle_page_fault	/* if not, try to insert a HPTE */
 	andis.  r0,r4,DSISR_DABRMATCH@h
 	bne-    handle_dabr_fault
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
