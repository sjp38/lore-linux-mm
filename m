Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0EB36B049C
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:11:49 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 123so1865126pgj.4
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:11:49 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0089.outbound.protection.outlook.com. [104.47.33.89])
        by mx.google.com with ESMTPS id r5si185357pli.208.2017.07.17.14.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:11:48 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 15/38] x86/boot/e820: Add support to determine the E820 type of an address
Date: Mon, 17 Jul 2017 16:10:12 -0500
Message-Id: <b797aaa588803bf33263d5dd8c32377668fa931a.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

Add a function that will return the E820 type associated with an address
range.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/e820/api.h |  2 ++
 arch/x86/kernel/e820.c          | 26 +++++++++++++++++++++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/e820/api.h b/arch/x86/include/asm/e820/api.h
index a504adc..cd266d8 100644
--- a/arch/x86/include/asm/e820/api.h
+++ b/arch/x86/include/asm/e820/api.h
@@ -39,6 +39,8 @@
 extern void e820__reallocate_tables(void);
 extern void e820__register_nosave_regions(unsigned long limit_pfn);
 
+extern int  e820__get_entry_type(u64 start, u64 end);
+
 /*
  * Returns true iff the specified range [start,end) is completely contained inside
  * the ISA region.
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 532da61..71c11ad 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -96,7 +96,8 @@ bool e820__mapped_any(u64 start, u64 end, enum e820_type type)
  * Note: this function only works correctly once the E820 table is sorted and
  * not-overlapping (at least for the range specified), which is the case normally.
  */
-bool __init e820__mapped_all(u64 start, u64 end, enum e820_type type)
+static struct e820_entry *__e820__mapped_all(u64 start, u64 end,
+					     enum e820_type type)
 {
 	int i;
 
@@ -122,9 +123,28 @@ bool __init e820__mapped_all(u64 start, u64 end, enum e820_type type)
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
+	return __e820__mapped_all(start, end, type);
+}
+
+/*
+ * This function returns the type associated with the range <start,end>.
+ */
+int e820__get_entry_type(u64 start, u64 end)
+{
+	struct e820_entry *entry = __e820__mapped_all(start, end, 0);
+
+	return entry ? entry->type : -EINVAL;
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
