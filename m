Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E900A6B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 14:37:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so32759588wme.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:37:02 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id n7si5381517wjy.210.2016.06.20.11.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 11:36:56 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id a66so11014678wme.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:36:56 -0700 (PDT)
Date: Mon, 20 Jun 2016 20:43:36 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v4 4/4] Add the extra_latent_entropy kernel parameter
Message-Id: <20160620204336.9f5ca671b32acf298ab4bc17@gmail.com>
In-Reply-To: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
References: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
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
 mm/page_alloc.c                     | 26 ++++++++++++++++++++++++++
 3 files changed, 36 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 82b42c9..d870702 100644
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
index 4b7cc2f..3374d50 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -404,6 +404,11 @@ config GCC_PLUGIN_LATENT_ENTROPY
 	  is some slowdown of the boot process (about 0.5%) and fork and
 	  irq processing.
 
+	  When extra_latent_entropy is passed on the kernel command line,
+	  entropy will be extracted from up to the first 4GB of RAM while the
+	  runtime memory allocator is being initialized. This costs even more
+	  slowdown of the boot process.
+
 	  Note that entropy extracted this way is not cryptographically
 	  secure!
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ffc4f4a..0a40c12 100644
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
@@ -1254,6 +1264,22 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 	__ClearPageReserved(p);
 	set_page_count(p, 0);
 
+	if (extra_latent_entropy && !PageHighMem(page) &&
+		page_to_pfn(page) < 0x100000) {
+		u64 hash = 0;
+		size_t index, end = PAGE_SIZE * nr_pages / sizeof(hash);
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
