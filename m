Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFED6B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:13:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 1so94301097pgz.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:13:07 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0066.outbound.protection.outlook.com. [104.47.34.66])
        by mx.google.com with ESMTPS id u10si7690973plu.58.2017.03.02.07.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:13:06 -0800 (PST)
Subject: [RFC PATCH v2 05/32] x86: Use encrypted access of BOOT related data
 with SEV
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:12:59 -0500
Message-ID: <148846757895.2349.561582698953591240.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

When Secure Encrypted Virtualization (SEV) is active, BOOT data (such as
EFI related data, setup data) is encrypted and needs to be accessed as
such when mapped. Update the architecture override in early_memremap to
keep the encryption attribute when mapping this data.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/ioremap.c |   36 +++++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index c6cb921..c400ab5 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -462,12 +462,31 @@ static bool memremap_is_setup_data(resource_size_t phys_addr,
 }
 
 /*
- * This function determines if an address should be mapped encrypted.
- * Boot setup data, EFI data and E820 areas are checked in making this
- * determination.
+ * This function determines if an address should be mapped encrypted when
+ * SEV is active.  E820 areas are checked in making this determination.
  */
-static bool memremap_should_map_encrypted(resource_size_t phys_addr,
-					  unsigned long size)
+static bool memremap_sev_should_map_encrypted(resource_size_t phys_addr,
+					      unsigned long size)
+{
+	/* Check if the address is in persistent memory */
+	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
+	case E820_TYPE_PMEM:
+	case E820_TYPE_PRAM:
+		return false;
+	default:
+		break;
+	}
+
+	return true;
+}
+
+/*
+ * This function determines if an address should be mapped encrypted when
+ * SME is active.  Boot setup data, EFI data and E820 areas are checked in
+ * making this determination.
+ */
+static bool memremap_sme_should_map_encrypted(resource_size_t phys_addr,
+					      unsigned long size)
 {
 	/*
 	 * SME is not active, return true:
@@ -508,6 +527,13 @@ static bool memremap_should_map_encrypted(resource_size_t phys_addr,
 	return true;
 }
 
+static bool memremap_should_map_encrypted(resource_size_t phys_addr,
+					  unsigned long size)
+{
+	return sev_active() ? memremap_sev_should_map_encrypted(phys_addr, size)
+			    : memremap_sme_should_map_encrypted(phys_addr, size);
+}
+
 /*
  * Architecure function to determine if RAM remap is allowed.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
