Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F259800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 05:55:36 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id q64so15502lfb.3
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 02:55:36 -0800 (PST)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id x129si20732lff.184.2018.01.23.02.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 02:55:35 -0800 (PST)
Subject: [PATCH 4/4] kernel/fork: add option to use virtually mapped stacks
 as fallback
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 23 Jan 2018 13:55:32 +0300
Message-ID: <151670493255.658225.2881484505285363395.stgit@buzz>
In-Reply-To: <151670492223.658225.4605377710524021456.stgit@buzz>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Virtually mapped stack have two bonuses: it eats order-0 pages and
adds guard page at the end. But it slightly slower if system have
plenty free high-order pages.

This patch adds option to use virtually bapped stack as fallback for
atomic allocation of traditional high-order page.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 arch/Kconfig  |   14 ++++++++++++++
 kernel/fork.c |   11 +++++++++++
 2 files changed, 25 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 400b9e1b2f27..c181ab263e7f 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -904,6 +904,20 @@ config VMAP_STACK
 	  the stack to map directly to the KASAN shadow map using a formula
 	  that is incorrect if the stack is in vmalloc space.
 
+config VMAP_STACK_AS_FALLBACK
+	default n
+	bool "Use a virtually-mapped stack as fallback for directly-mapped"
+	depends on VMAP_STACK
+	help
+	  With this option kernel first tries to allocate directly-mapped stack
+	  without calling direct memory reclaim and fallback to vmap stack.
+
+	  Allocation of directly mapped stack faster than vmap if system a lot
+	  of free memory and much slower if all memory is used or fragmented.
+
+	  This option neutralize stack overflow protection but allows to
+	  achieve best performance for syscalls fork() and clone().
+
 config ARCH_OPTIONAL_KERNEL_RWX
 	def_bool n
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 457c9151f3c8..cc61a083954d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -207,6 +207,17 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 	struct vm_struct *stack;
 	int i;
 
+#ifdef CONFIG_VMAP_STACK_AS_FALLBACK
+	struct page *page;
+
+	page = alloc_pages_node(node, THREADINFO_GFP & ~__GFP_DIRECT_RECLAIM,
+				THREAD_SIZE_ORDER);
+	if (page) {
+		tsk->stack_vm_area = NULL;
+		return page_address(page);
+	}
+#endif
+
 	for (i = 0; i < NR_CACHED_STACKS; i++) {
 		stack = this_cpu_xchg(cached_stacks[i], NULL);
 		if (!stack)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
