Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 875526B0394
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:13:18 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so94087026pgc.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:13:18 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0057.outbound.protection.outlook.com. [104.47.38.57])
        by mx.google.com with ESMTPS id b4si7682452plb.157.2017.03.02.07.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:13:17 -0800 (PST)
Subject: [RFC PATCH v2 06/32] x86/pci: Use memremap when walking setup data
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:13:10 -0500
Message-ID: <148846759008.2349.8274808454274279039.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

The use of ioremap will force the setup data to be mapped decrypted even
though setup data is encrypted.  Switch to using memremap which will be
able to perform the proper mapping.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/pci/common.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index a4fdfa7..0b06670 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -691,7 +691,7 @@ int pcibios_add_device(struct pci_dev *dev)
 
 	pa_data = boot_params.hdr.setup_data;
 	while (pa_data) {
-		data = ioremap(pa_data, sizeof(*rom));
+		data = memremap(pa_data, sizeof(*rom), MEMREMAP_WB);
 		if (!data)
 			return -ENOMEM;
 
@@ -710,7 +710,7 @@ int pcibios_add_device(struct pci_dev *dev)
 			}
 		}
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 	}
 	set_dma_domain_ops(dev);
 	set_dev_domain_options(dev);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
