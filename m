Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C84456B0255
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:30:08 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id uo6so55365962pac.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:30:08 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id sq8si8243730pab.10.2016.01.30.01.30.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:30:08 -0800 (PST)
Date: Sat, 30 Jan 2016 01:29:07 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-f33b14a4b96b185634848046f54fb0d5028566a9@git.kernel.org>
Reply-To: luto@amacapital.net, hpa@zytor.com, bhe@redhat.com,
        brgerst@gmail.com, dan.j.williams@intel.com,
        torvalds@linux-foundation.org, msalter@redhat.com, bp@alien8.de,
        jkosina@suse.cz, mcgrof@suse.com, pbonzini@redhat.com,
        mingo@kernel.org, peterz@infradead.org, tony.luck@intel.com,
        toshi.kani@hpe.com, jgross@suse.com, tglx@linutronix.de,
        toshi.kani@hp.com, linux-kernel@vger.kernel.org, dvlasenk@redhat.com,
        akpm@linux-foundation.org, dyoung@redhat.com, bp@suse.de,
        chaowang@redhat.com, linux-mm@kvack.org, jroedel@suse.de
In-Reply-To: <1453841853-11383-5-git-send-email-bp@alien8.de>
References: <1453841853-11383-5-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] x86/e820: Set System RAM type and descriptor
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: bp@alien8.de, jkosina@suse.cz, mcgrof@suse.com, pbonzini@redhat.com, bhe@redhat.com, brgerst@gmail.com, hpa@zytor.com, luto@amacapital.net, torvalds@linux-foundation.org, msalter@redhat.com, dan.j.williams@intel.com, chaowang@redhat.com, akpm@linux-foundation.org, bp@suse.de, dyoung@redhat.com, jroedel@suse.de, linux-mm@kvack.org, toshi.kani@hpe.com, jgross@suse.com, tglx@linutronix.de, mingo@kernel.org, peterz@infradead.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, dvlasenk@redhat.com, toshi.kani@hp.com

Commit-ID:  f33b14a4b96b185634848046f54fb0d5028566a9
Gitweb:     http://git.kernel.org/tip/f33b14a4b96b185634848046f54fb0d5028566a9
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:20 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:57 +0100

x86/e820: Set System RAM type and descriptor

Change e820_reserve_resources() to set 'flags' and 'desc' from
e820 types.

Set E820_RESERVED_KERN and E820_RAM's (System RAM) io resource
type to IORESOURCE_SYSTEM_RAM.

Do the same for "Kernel data", "Kernel code", and "Kernel bss",
which are child nodes of System RAM.

I/O resource descriptor is set to 'desc' for entries that are
(and will be) target ranges of walk_iomem_res() and
region_intersects().

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Baoquan He <bhe@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Mark Salter <msalter@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: WANG Chao <chaowang@redhat.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-5-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/e820.c  | 38 +++++++++++++++++++++++++++++++++++++-
 arch/x86/kernel/setup.c |  6 +++---
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 569c1e4..837365f 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -925,6 +925,41 @@ static const char *e820_type_to_string(int e820_type)
 	}
 }
 
+static unsigned long e820_type_to_iomem_type(int e820_type)
+{
+	switch (e820_type) {
+	case E820_RESERVED_KERN:
+	case E820_RAM:
+		return IORESOURCE_SYSTEM_RAM;
+	case E820_ACPI:
+	case E820_NVS:
+	case E820_UNUSABLE:
+	case E820_PRAM:
+	case E820_PMEM:
+	default:
+		return IORESOURCE_MEM;
+	}
+}
+
+static unsigned long e820_type_to_iores_desc(int e820_type)
+{
+	switch (e820_type) {
+	case E820_ACPI:
+		return IORES_DESC_ACPI_TABLES;
+	case E820_NVS:
+		return IORES_DESC_ACPI_NV_STORAGE;
+	case E820_PMEM:
+		return IORES_DESC_PERSISTENT_MEMORY;
+	case E820_PRAM:
+		return IORES_DESC_PERSISTENT_MEMORY_LEGACY;
+	case E820_RESERVED_KERN:
+	case E820_RAM:
+	case E820_UNUSABLE:
+	default:
+		return IORES_DESC_NONE;
+	}
+}
+
 static bool do_mark_busy(u32 type, struct resource *res)
 {
 	/* this is the legacy bios/dos rom-shadow + mmio region */
@@ -967,7 +1002,8 @@ void __init e820_reserve_resources(void)
 		res->start = e820.map[i].addr;
 		res->end = end;
 
-		res->flags = IORESOURCE_MEM;
+		res->flags = e820_type_to_iomem_type(e820.map[i].type);
+		res->desc = e820_type_to_iores_desc(e820.map[i].type);
 
 		/*
 		 * don't register the region that could be conflicted with
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d3d80e6..aa52c10 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -152,21 +152,21 @@ static struct resource data_resource = {
 	.name	= "Kernel data",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource code_resource = {
 	.name	= "Kernel code",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource bss_resource = {
 	.name	= "Kernel bss",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
