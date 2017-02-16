Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0812680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:47:51 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 203so42653152ith.3
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:47:51 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0055.outbound.protection.outlook.com. [104.47.33.55])
        by mx.google.com with ESMTPS id i75si7550670itf.96.2017.02.16.07.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:47:51 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 25/28] x86: Access the setup data through sysfs
 decrypted
Date: Thu, 16 Feb 2017 09:47:38 -0600
Message-ID: <20170216154738.19244.37908.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Use memremap() to map the setup data.  This will make the appropriate
decision as to whether a RAM remapping can be done or if a fallback to
ioremap_cache() is needed (similar to the setup data debugfs support).

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/ksysfs.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kernel/ksysfs.c b/arch/x86/kernel/ksysfs.c
index 4afc67f..d653b3e 100644
--- a/arch/x86/kernel/ksysfs.c
+++ b/arch/x86/kernel/ksysfs.c
@@ -16,6 +16,7 @@
 #include <linux/stat.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
+#include <linux/io.h>
 
 #include <asm/io.h>
 #include <asm/setup.h>
@@ -79,12 +80,12 @@ static int get_setup_data_paddr(int nr, u64 *paddr)
 			*paddr = pa_data;
 			return 0;
 		}
-		data = ioremap_cache(pa_data, sizeof(*data));
+		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
 		if (!data)
 			return -ENOMEM;
 
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 		i++;
 	}
 	return -EINVAL;
@@ -97,17 +98,17 @@ static int __init get_setup_data_size(int nr, size_t *size)
 	u64 pa_data = boot_params.hdr.setup_data;
 
 	while (pa_data) {
-		data = ioremap_cache(pa_data, sizeof(*data));
+		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
 		if (!data)
 			return -ENOMEM;
 		if (nr == i) {
 			*size = data->len;
-			iounmap(data);
+			memunmap(data);
 			return 0;
 		}
 
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 		i++;
 	}
 	return -EINVAL;
@@ -127,12 +128,12 @@ static ssize_t type_show(struct kobject *kobj,
 	ret = get_setup_data_paddr(nr, &paddr);
 	if (ret)
 		return ret;
-	data = ioremap_cache(paddr, sizeof(*data));
+	data = memremap(paddr, sizeof(*data), MEMREMAP_WB);
 	if (!data)
 		return -ENOMEM;
 
 	ret = sprintf(buf, "0x%x\n", data->type);
-	iounmap(data);
+	memunmap(data);
 	return ret;
 }
 
@@ -154,7 +155,7 @@ static ssize_t setup_data_data_read(struct file *fp,
 	ret = get_setup_data_paddr(nr, &paddr);
 	if (ret)
 		return ret;
-	data = ioremap_cache(paddr, sizeof(*data));
+	data = memremap(paddr, sizeof(*data), MEMREMAP_WB);
 	if (!data)
 		return -ENOMEM;
 
@@ -170,15 +171,15 @@ static ssize_t setup_data_data_read(struct file *fp,
 		goto out;
 
 	ret = count;
-	p = ioremap_cache(paddr + sizeof(*data), data->len);
+	p = memremap(paddr + sizeof(*data), data->len, MEMREMAP_WB);
 	if (!p) {
 		ret = -ENOMEM;
 		goto out;
 	}
 	memcpy(buf, p + off, count);
-	iounmap(p);
+	memunmap(p);
 out:
-	iounmap(data);
+	memunmap(data);
 	return ret;
 }
 
@@ -250,13 +251,13 @@ static int __init get_setup_data_total_num(u64 pa_data, int *nr)
 	*nr = 0;
 	while (pa_data) {
 		*nr += 1;
-		data = ioremap_cache(pa_data, sizeof(*data));
+		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
 		if (!data) {
 			ret = -ENOMEM;
 			goto out;
 		}
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 	}
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
