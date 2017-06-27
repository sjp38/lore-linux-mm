Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A59F6B03C7
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:10:15 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f127so29293139pgc.10
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:10:15 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0051.outbound.protection.outlook.com. [104.47.34.51])
        by mx.google.com with ESMTPS id g4si2137607pgf.136.2017.06.27.08.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:10:14 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 15/38] x86/boot/e820: Add support to determine the
 E820 type of an address
Date: Tue, 27 Jun 2017 10:09:59 -0500
Message-ID: <20170627150959.17428.15703.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add a function that will return the E820 type associated with an address
range.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/e820/api.h |    2 ++
 arch/x86/kernel/e820.c          |   26 +++++++++++++++++++++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/e820/api.h b/arch/x86/include/asm/e820/api.h
index 8e0f8b8..3641f5f 100644
--- a/arch/x86/include/asm/e820/api.h
+++ b/arch/x86/include/asm/e820/api.h
@@ -38,6 +38,8 @@
 extern void e820__reallocate_tables(void);
 extern void e820__register_nosave_regions(unsigned long limit_pfn);
 
+extern int  e820__get_entry_type(u64 start, u64 end);
+
 /*
  * Returns true iff the specified range [start,end) is completely contained inside
  * the ISA region.
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index d78a586..46c9b65 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
