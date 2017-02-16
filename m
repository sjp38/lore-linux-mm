Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 502CC680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:46:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r207so26500658pgr.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:46:44 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0081.outbound.protection.outlook.com. [104.47.41.81])
        by mx.google.com with ESMTPS id g27si7272944pgn.377.2017.02.16.07.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:46:43 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 20/28] iommu/amd: Disable AMD IOMMU if memory
 encryption is active
Date: Thu, 16 Feb 2017 09:46:32 -0600
Message-ID: <20170216154632.19244.26080.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

For now, disable the AMD IOMMU if memory encryption is active. A future
patch will re-enable the function with full memory encryption support.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/iommu/amd_iommu_init.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/iommu/amd_iommu_init.c b/drivers/iommu/amd_iommu_init.c
index 6799cf9..6df2dd5 100644
--- a/drivers/iommu/amd_iommu_init.c
+++ b/drivers/iommu/amd_iommu_init.c
@@ -29,6 +29,7 @@
 #include <linux/export.h>
 #include <linux/iommu.h>
 #include <linux/kmemleak.h>
+#include <linux/mem_encrypt.h>
 #include <asm/pci-direct.h>
 #include <asm/iommu.h>
 #include <asm/gart.h>
@@ -2544,6 +2545,12 @@ int __init amd_iommu_detect(void)
 	if (amd_iommu_disabled)
 		return -ENODEV;
 
+	/* For now, disable the IOMMU if SME is active */
+	if (sme_active()) {
+		pr_notice("AMD-Vi: SME is active, disabling the IOMMU\n");
+		return -ENODEV;
+	}
+
 	ret = iommu_go_to_state(IOMMU_IVRS_DETECTED);
 	if (ret)
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
