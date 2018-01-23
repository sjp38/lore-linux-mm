Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA29800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 05:55:33 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id j185so10551lfe.13
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 02:55:33 -0800 (PST)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id n17si3680138lja.481.2018.01.23.02.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 02:55:31 -0800 (PST)
Subject: [PATCH 3/4] kernel/fork: switch vmapped stack callation to
 __vmalloc_area()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 23 Jan 2018 13:55:29 +0300
Message-ID: <151670492913.658225.2758351129158778856.stgit@buzz>
In-Reply-To: <151670492223.658225.4605377710524021456.stgit@buzz>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

This gives as pointer vm_struct without calling find_vm_area().

And fix comment about that task holds cache of vm area: this cache used
for retrieving actual stack pages, freeing is done by vfree_deferred().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 kernel/fork.c |   37 +++++++++++++++----------------------
 1 file changed, 15 insertions(+), 22 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 2295fc69717f..457c9151f3c8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -204,39 +204,32 @@ static int free_vm_stack_cache(unsigned int cpu)
 static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 #ifdef CONFIG_VMAP_STACK
-	void *stack;
+	struct vm_struct *stack;
 	int i;
 
 	for (i = 0; i < NR_CACHED_STACKS; i++) {
-		struct vm_struct *s;
-
-		s = this_cpu_xchg(cached_stacks[i], NULL);
-
-		if (!s)
+		stack = this_cpu_xchg(cached_stacks[i], NULL);
+		if (!stack)
 			continue;
 
 #ifdef CONFIG_DEBUG_KMEMLEAK
 		/* Clear stale pointers from reused stack. */
-		memset(s->addr, 0, THREAD_SIZE);
+		memset(stack->addr, 0, THREAD_SIZE);
 #endif
-		tsk->stack_vm_area = s;
-		return s->addr;
+		tsk->stack_vm_area = stack;
+		return stack->addr;
 	}
 
-	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
-				     VMALLOC_START, VMALLOC_END,
-				     THREADINFO_GFP,
-				     PAGE_KERNEL,
-				     0, node, __builtin_return_address(0));
+	stack = __vmalloc_area(THREAD_SIZE, THREAD_ALIGN,
+			       VMALLOC_START, VMALLOC_END,
+			       THREADINFO_GFP, PAGE_KERNEL,
+			       0, node, __builtin_return_address(0));
+	if (unlikely(!stack))
+		return NULL;
 
-	/*
-	 * We can't call find_vm_area() in interrupt context, and
-	 * free_thread_stack() can be called in interrupt context,
-	 * so cache the vm_struct.
-	 */
-	if (stack)
-		tsk->stack_vm_area = find_vm_area(stack);
-	return stack;
+	/* Cache the vm_struct for stack to page conversions. */
+	tsk->stack_vm_area = stack;
+	return stack->addr;
 #else
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
 					     THREAD_SIZE_ORDER);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
