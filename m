Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 060FF6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 18:15:51 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id js8so1420045lbc.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:15:50 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id n205si6635656wmf.93.2016.06.14.15.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 15:15:49 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id n184so1666396wmn.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:15:49 -0700 (PDT)
Date: Wed, 15 Jun 2016 00:22:37 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v3 4/4] Add the extra_latent_entropy kernel parameter
Message-Id: <20160615002237.87ab511f3ed4420923476c02@gmail.com>
In-Reply-To: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

When extra_latent_entropy is passed on the kernel command line,
entropy will be extracted from up to the first 4GB of RAM while the
runtime memory allocator is being initialized.

Based on work created by the PaX Team.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 Documentation/kernel-parameters.txt |  5 +++++
 arch/Kconfig                        |  5 +++++
 mm/page_alloc.c                     | 25 +++++++++++++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 5349363..6c2496e 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2862,6 +2862,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			the specified number of seconds.  This is to be used if
 			your oopses keep scrolling off the screen.
 
+	extra_latent_entropy
+			Enable a very simple form of latent entropy extraction
+			from the first 4GB of memory as the bootmem allocator
+			passes the memory pages to the buddy allocator.
+
 	pcbit=		[HW,ISDN]
 
 	pcd.		[PARIDE]
diff --git a/arch/Kconfig b/arch/Kconfig
index c099ebd..8bf832e 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -405,6 +405,11 @@ config GCC_PLUGIN_LATENT_ENTROPY
 	  is some slowdown of the boot process (about 0.5%) and fork and
 	  irq processing.
 
+	  When extra_latent_entropy is passed on the kernel command line,
+	  entropy will be extracted from up to the first 4GB of RAM while the
+	  runtime memory allocator is being initialized.  This costs even more
+	  slowdown of the boot process.
+
 	  Note that entropy extracted this way is not known to be cryptographically
 	  secure!
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ffc4f4a..72c61bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -63,6 +63,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/random.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -1234,6 +1235,15 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
+bool __meminitdata extra_latent_entropy;
+
+static int __init setup_extra_latent_entropy(char *str)
+{
+	extra_latent_entropy = true;
+	return 0;
+}
+early_param("extra_latent_entropy", setup_extra_latent_entropy);
+
 #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
 volatile u64 latent_entropy __latent_entropy;
 EXPORT_SYMBOL(latent_entropy);
@@ -1254,6 +1264,21 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 	__ClearPageReserved(p);
 	set_page_count(p, 0);
 
+	if (extra_latent_entropy && !PageHighMem(page) && page_to_pfn(page) < 0x100000) {
+		u64 hash = 0;
+		size_t index, end = PAGE_SIZE * nr_pages / sizeof hash;
+		const u64 *data = lowmem_page_address(page);
+
+		for (index = 0; index < end; index++)
+			hash ^= hash + data[index];
+#ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
+		latent_entropy ^= hash;
+		add_device_randomness((const void *)&latent_entropy, sizeof(latent_entropy));
+#else
+		add_device_randomness((const void *)&hash, sizeof(hash));
+#endif
+	}
+
 	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
 	__free_pages(page, order);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
