Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E99CE680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:44:38 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h10so43799411ith.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:44:38 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0055.outbound.protection.outlook.com. [104.47.33.55])
        by mx.google.com with ESMTPS id 143si7531157ioe.128.2017.02.16.07.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:44:38 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 11/28] x86: Add support to determine the E820 type of
 an address
Date: Thu, 16 Feb 2017 09:44:30 -0600
Message-ID: <20170216154430.19244.95519.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

This patch adds support to return the E820 type associated with an address
range.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/e820/api.h   |    2 ++
 arch/x86/include/asm/e820/types.h |    2 ++
 arch/x86/kernel/e820.c            |   26 +++++++++++++++++++++++---
 3 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/e820/api.h b/arch/x86/include/asm/e820/api.h
index 8e0f8b8..7c1bdc9 100644
--- a/arch/x86/include/asm/e820/api.h
+++ b/arch/x86/include/asm/e820/api.h
@@ -38,6 +38,8 @@
 extern void e820__reallocate_tables(void);
 extern void e820__register_nosave_regions(unsigned long limit_pfn);
 
+extern enum e820_type e820__get_entry_type(u64 start, u64 end);
+
 /*
  * Returns true iff the specified range [start,end) is completely contained inside
  * the ISA region.
diff --git a/arch/x86/include/asm/e820/types.h b/arch/x86/include/asm/e820/types.h
index 4adeed0..bf49591 100644
--- a/arch/x86/include/asm/e820/types.h
+++ b/arch/x86/include/asm/e820/types.h
@@ -7,6 +7,8 @@
  * These are the E820 types known to the kernel:
  */
 enum e820_type {
+	E820_TYPE_INVALID	= 0,
+
 	E820_TYPE_RAM		= 1,
 	E820_TYPE_RESERVED	= 2,
 	E820_TYPE_ACPI		= 3,
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 6e9b26f..2ee7ee2 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -84,7 +84,8 @@ bool e820__mapped_any(u64 start, u64 end, enum e820_type type)
  * Note: this function only works correctly once the E820 table is sorted and
  * not-overlapping (at least for the range specified), which is the case normally.
  */
-bool __init e820__mapped_all(u64 start, u64 end, enum e820_type type)
+static struct e820_entry *__e820__mapped_all(u64 start, u64 end,
+					     enum e820_type type)
 {
 	int i;
 
@@ -110,9 +111,28 @@ bool __init e820__mapped_all(u64 start, u64 end, enum e820_type type)
 		 * coverage of the desired range exists:
 		 */
 		if (start >= end)
-			return 1;
+			return entry;
 	}
-	return 0;
+
+	return NULL;
+}
+
+/*
+ * This function checks if the entire range <start,end> is mapped with type.
+ */
+bool __init e820__mapped_all(u64 start, u64 end, enum e820_type type)
+{
+	return __e820__mapped_all(start, end, type) ? 1 : 0;
+}
+
+/*
+ * This function returns the type associated with the range <start,end>.
+ */
+enum e820_type e820__get_entry_type(u64 start, u64 end)
+{
+	struct e820_entry *entry = __e820__mapped_all(start, end, 0);
+
+	return entry ? entry->type : E820_TYPE_INVALID;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
