Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0533E2806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:22:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r129so2953239pgr.18
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:22:20 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0040.outbound.protection.outlook.com. [104.47.33.40])
        by mx.google.com with ESMTPS id d20si298228plj.104.2017.04.18.14.22.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:22:20 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 31/32] x86: Add sysfs support for Secure Memory Encryption
Date: Tue, 18 Apr 2017 16:22:12 -0500
Message-ID: <20170418212212.10190.73484.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add sysfs support for SME so that user-space utilities (kdump, etc.) can
determine if SME is active.

A new directory will be created:
  /sys/kernel/mm/sme/

And two entries within the new directory:
  /sys/kernel/mm/sme/active
  /sys/kernel/mm/sme/encryption_mask

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/mem_encrypt.c |   49 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 0ff41a4..7dc4e98 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -18,6 +18,8 @@
 #include <linux/mm.h>
 #include <linux/dma-mapping.h>
 #include <linux/swiotlb.h>
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
 
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
@@ -25,6 +27,7 @@
 #include <asm/bootparam.h>
 #include <asm/cacheflush.h>
 #include <asm/sections.h>
+#include <asm/mem_encrypt.h>
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -38,6 +41,52 @@
 static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
 
 /*
+ * Sysfs support for SME.
+ *   Create an sme directory under /sys/kernel/mm
+ *   Create two sme entries under /sys/kernel/mm/sme:
+ *     active - returns 0 if not active, 1 if active
+ *     encryption_mask - returns the encryption mask in use
+ */
+static ssize_t active_show(struct kobject *kobj, struct kobj_attribute *attr,
+			   char *buf)
+{
+	return sprintf(buf, "%u\n", sme_active());
+}
+static struct kobj_attribute active_attr = __ATTR_RO(active);
+
+static ssize_t encryption_mask_show(struct kobject *kobj,
+				    struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "0x%016lx\n", sme_me_mask);
+}
+static struct kobj_attribute encryption_mask_attr = __ATTR_RO(encryption_mask);
+
+static struct attribute *sme_attrs[] = {
+	&active_attr.attr,
+	&encryption_mask_attr.attr,
+	NULL
+};
+
+static struct attribute_group sme_attr_group = {
+	.attrs = sme_attrs,
+	.name = "sme",
+};
+
+static int __init sme_sysfs_init(void)
+{
+	int ret;
+
+	ret = sysfs_create_group(mm_kobj, &sme_attr_group);
+	if (ret) {
+		pr_err("SME sysfs initialization failed\n");
+		return ret;
+	}
+
+	return 0;
+}
+subsys_initcall(sme_sysfs_init);
+
+/*
  * This routine does not change the underlying encryption setting of the
  * page(s) that map this memory. It assumes that eventually the memory is
  * meant to be accessed as either encrypted or decrypted but the contents

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
