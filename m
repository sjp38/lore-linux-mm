Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A97E36B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:56:40 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id b204so19832826ioe.11
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:56:40 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0060.outbound.protection.outlook.com. [104.47.34.60])
        by mx.google.com with ESMTPS id j36si3088550iod.138.2017.06.27.07.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 07:56:39 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 02/38] x86/mm/pat: Set write-protect cache mode for full
 PAT support
Date: Tue, 27 Jun 2017 09:56:31 -0500
Message-ID: <20170627145631.15908.28761.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
References: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

For processors that support PAT, set the write-protect cache mode
(_PAGE_CACHE_MODE_WP) entry to the actual write-protect value (x05).

Acked-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/pat.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 9b78685..6753d9c 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -295,7 +295,7 @@ static void init_cache_modes(void)
  * pat_init - Initialize PAT MSR and PAT table
  *
  * This function initializes PAT MSR and PAT table with an OS-defined value
- * to enable additional cache attributes, WC and WT.
+ * to enable additional cache attributes, WC, WT and WP.
  *
  * This function must be called on all CPUs using the specific sequence of
  * operations defined in Intel SDM. mtrr_rendezvous_handler() provides this
@@ -356,7 +356,7 @@ void pat_init(void)
 		 *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
 		 *      011    3    UC : _PAGE_CACHE_MODE_UC
 		 *      100    4    WB : Reserved
-		 *      101    5    WC : Reserved
+		 *      101    5    WP : _PAGE_CACHE_MODE_WP
 		 *      110    6    UC-: Reserved
 		 *      111    7    WT : _PAGE_CACHE_MODE_WT
 		 *
@@ -364,7 +364,7 @@ void pat_init(void)
 		 * corresponding types in the presence of PAT errata.
 		 */
 		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
-		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
+		      PAT(4, WB) | PAT(5, WP) | PAT(6, UC_MINUS) | PAT(7, WT);
 	}
 
 	if (!boot_cpu_done) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
