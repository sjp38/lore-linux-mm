Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D38E6B0033
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 11:26:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so5414732pfh.7
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 08:26:30 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r7si15839020ple.403.2018.01.12.08.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 08:26:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] kdump: Write a correct address of mem_section into vmcoreinfo
Date: Fri, 12 Jan 2018 19:25:32 +0300
Message-Id: <20180112162532.35896-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

Depending on configuration mem_section can now be an array or a pointer
to an array allocated dynamically. In most cases, we can continue to refer
to it as 'mem_section' regardless of what it is.

But there's one exception: '&mem_section' means "address of the array" if
mem_section is an array, but if mem_section is a pointer, it would mean
"address of the pointer".

We've stepped onto this in kdump code. VMCOREINFO_SYMBOL(mem_section)
writes down address of pointer into vmcoreinfo, not array as we wanted.

Let's introduce VMCOREINFO_SYMBOL_ARRAY() that would handle the
situation correctly for both cases.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
Cc: stable@vger.kernel.org
Acked-by: Baoquan He <bhe@redhat.com>
Acked-by: Dave Young <dyoung@redhat.com>
---
 include/linux/crash_core.h | 2 ++
 kernel/crash_core.c        | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
index 06097ef30449..b511f6d24b42 100644
--- a/include/linux/crash_core.h
+++ b/include/linux/crash_core.h
@@ -42,6 +42,8 @@ phys_addr_t paddr_vmcoreinfo_note(void);
 	vmcoreinfo_append_str("PAGESIZE=%ld\n", value)
 #define VMCOREINFO_SYMBOL(name) \
 	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)&name)
+#define VMCOREINFO_SYMBOL_ARRAY(name) \
+	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)name)
 #define VMCOREINFO_SIZE(name) \
 	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
 			      (unsigned long)sizeof(name))
diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index b3663896278e..4f63597c824d 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -410,7 +410,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_SYMBOL(contig_page_data);
 #endif
 #ifdef CONFIG_SPARSEMEM
-	VMCOREINFO_SYMBOL(mem_section);
+	VMCOREINFO_SYMBOL_ARRAY(mem_section);
 	VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
 	VMCOREINFO_STRUCT_SIZE(mem_section);
 	VMCOREINFO_OFFSET(mem_section, section_mem_map);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
