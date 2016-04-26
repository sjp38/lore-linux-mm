Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A85416B0260
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:56:13 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id vv3so42139119pab.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:56:13 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0088.outbound.protection.outlook.com. [157.56.110.88])
        by mx.google.com with ESMTPS id ah8si1287327pad.148.2016.04.26.15.56.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:56:12 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 01/18] x86: Set the write-protect cache mode for AMD
 processors
Date: Tue, 26 Apr 2016 17:56:04 -0500
Message-ID: <20160426225604.13567.55443.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

For AMD processors that support PAT, set the write-protect cache mode
(_PAGE_CACHE_MODE_WP) entry to the actual write-protect value (x05).

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/pat.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index fb0604f..dda78ed 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -345,6 +345,8 @@ void pat_init(void)
 		 * we lose performance without causing a correctness issue.
 		 * Pentium 4 erratum N46 is an example for such an erratum,
 		 * although we try not to use PAT at all on affected CPUs.
+		 * AMD processors support write-protect so initialize the
+		 * PAT slot 5 appropriately.
 		 *
 		 *  PTE encoding:
 		 *      PAT
@@ -356,7 +358,7 @@ void pat_init(void)
 		 *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
 		 *      011    3    UC : _PAGE_CACHE_MODE_UC
 		 *      100    4    WB : Reserved
-		 *      101    5    WC : Reserved
+		 *      101    5    WC : Reserved (AMD: _PAGE_CACHE_MODE_WP)
 		 *      110    6    UC-: Reserved
 		 *      111    7    WT : _PAGE_CACHE_MODE_WT
 		 *
@@ -364,7 +366,12 @@ void pat_init(void)
 		 * corresponding types in the presence of PAT errata.
 		 */
 		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
-		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
+		      PAT(4, WB) | PAT(6, UC_MINUS) | PAT(7, WT);
+
+		if (c->x86_vendor == X86_VENDOR_AMD)
+			pat |= PAT(5, WP);
+		else
+			pat |= PAT(5, WC);
 	}
 
 	if (!boot_cpu_done) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
