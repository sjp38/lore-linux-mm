Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 801F46B007E
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 20:03:23 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p65so13004544wmp.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 17:03:23 -0800 (PST)
Received: from smtp01.udag.de (smtp01.udag.de. [62.146.106.17])
        by mx.google.com with ESMTPS id h62si7662535wme.86.2016.03.02.17.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 17:03:22 -0800 (PST)
From: Karol Herbst <nouveau@karolherbst.de>
Subject: RFC: [PATCH] x86/kmmio: fix mmiotrace for hugepages
Date: Thu,  3 Mar 2016 02:03:11 +0100
Message-Id: <1456966991-6861-1-git-send-email-nouveau@karolherbst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-x86_64@vger.kernel.org, rostedt@goodmis.org, pq@iki.fi, mingo@redhat.com, nouveau@lists.freedesktop.org

Because Linux might use bigger pages than the 4K pages to handle those mmio
ioremaps, the kmmio code shouldn't rely on the pade id as it currently does.

Using the memory address instead of the page id let's us lookup how big the
page is and what it's base address is, so that we won't get a page fault
within the same page twice anymore.

I don't know if I got this right though, so please read this change with
great care

v2: use page_level macros

Signed-off-by: Karol Herbst <nouveau@karolherbst.de>
---
 arch/x86/mm/kmmio.c | 89 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 60 insertions(+), 29 deletions(-)

diff --git a/arch/x86/mm/kmmio.c b/arch/x86/mm/kmmio.c
index 637ab34..d203beb 100644
--- a/arch/x86/mm/kmmio.c
+++ b/arch/x86/mm/kmmio.c
@@ -33,7 +33,7 @@
 struct kmmio_fault_page {
 	struct list_head list;
 	struct kmmio_fault_page *release_next;
-	unsigned long page; /* location of the fault page */
+	unsigned long addr; /* the requested address */
 	pteval_t old_presence; /* page presence prior to arming */
 	bool armed;
 
@@ -70,9 +70,16 @@ unsigned int kmmio_count;
 static struct list_head kmmio_page_table[KMMIO_PAGE_TABLE_SIZE];
 static LIST_HEAD(kmmio_probes);
 
-static struct list_head *kmmio_page_list(unsigned long page)
+static struct list_head *kmmio_page_list(unsigned long addr)
 {
-	return &kmmio_page_table[hash_long(page, KMMIO_PAGE_HASH_BITS)];
+	unsigned int l;
+	pte_t *pte = lookup_address(addr, &l);
+
+	if (!pte)
+		return NULL;
+	addr &= page_level_mask(l);
+
+	return &kmmio_page_table[hash_long(addr, KMMIO_PAGE_HASH_BITS)];
 }
 
 /* Accessed per-cpu */
@@ -98,15 +105,19 @@ static struct kmmio_probe *get_kmmio_probe(unsigned long addr)
 }
 
 /* You must be holding RCU read lock. */
-static struct kmmio_fault_page *get_kmmio_fault_page(unsigned long page)
+static struct kmmio_fault_page *get_kmmio_fault_page(unsigned long addr)
 {
 	struct list_head *head;
 	struct kmmio_fault_page *f;
+	unsigned int l;
+	pte_t *pte = lookup_address(addr, &l);
 
-	page &= PAGE_MASK;
-	head = kmmio_page_list(page);
+	if (!pte)
+		return NULL;
+	addr &= page_level_mask(l);
+	head = kmmio_page_list(addr);
 	list_for_each_entry_rcu(f, head, list) {
-		if (f->page == page)
+		if (f->addr == addr)
 			return f;
 	}
 	return NULL;
@@ -137,10 +148,10 @@ static void clear_pte_presence(pte_t *pte, bool clear, pteval_t *old)
 static int clear_page_presence(struct kmmio_fault_page *f, bool clear)
 {
 	unsigned int level;
-	pte_t *pte = lookup_address(f->page, &level);
+	pte_t *pte = lookup_address(f->addr, &level);
 
 	if (!pte) {
-		pr_err("no pte for page 0x%08lx\n", f->page);
+		pr_err("no pte for addr 0x%08lx\n", f->addr);
 		return -1;
 	}
 
@@ -156,7 +167,7 @@ static int clear_page_presence(struct kmmio_fault_page *f, bool clear)
 		return -1;
 	}
 
-	__flush_tlb_one(f->page);
+	__flush_tlb_one(f->addr);
 	return 0;
 }
 
@@ -176,12 +187,12 @@ static int arm_kmmio_fault_page(struct kmmio_fault_page *f)
 	int ret;
 	WARN_ONCE(f->armed, KERN_ERR pr_fmt("kmmio page already armed.\n"));
 	if (f->armed) {
-		pr_warning("double-arm: page 0x%08lx, ref %d, old %d\n",
-			   f->page, f->count, !!f->old_presence);
+		pr_warning("double-arm: addr 0x%08lx, ref %d, old %d\n",
+			   f->addr, f->count, !!f->old_presence);
 	}
 	ret = clear_page_presence(f, true);
-	WARN_ONCE(ret < 0, KERN_ERR pr_fmt("arming 0x%08lx failed.\n"),
-		  f->page);
+	WARN_ONCE(ret < 0, KERN_ERR pr_fmt("arming at 0x%08lx failed.\n"),
+		  f->addr);
 	f->armed = true;
 	return ret;
 }
@@ -191,7 +202,7 @@ static void disarm_kmmio_fault_page(struct kmmio_fault_page *f)
 {
 	int ret = clear_page_presence(f, false);
 	WARN_ONCE(ret < 0,
-			KERN_ERR "kmmio disarming 0x%08lx failed.\n", f->page);
+			KERN_ERR "kmmio disarming at 0x%08lx failed.\n", f->addr);
 	f->armed = false;
 }
 
@@ -215,6 +226,12 @@ int kmmio_handler(struct pt_regs *regs, unsigned long addr)
 	struct kmmio_context *ctx;
 	struct kmmio_fault_page *faultpage;
 	int ret = 0; /* default to fault not handled */
+	unsigned long page_base = addr;
+	unsigned int l;
+	pte_t *pte = lookup_address(addr, &l);
+	if (!pte)
+		return -EINVAL;
+	page_base &= page_level_mask(l);
 
 	/*
 	 * Preemption is now disabled to prevent process switch during
@@ -227,7 +244,7 @@ int kmmio_handler(struct pt_regs *regs, unsigned long addr)
 	preempt_disable();
 	rcu_read_lock();
 
-	faultpage = get_kmmio_fault_page(addr);
+	faultpage = get_kmmio_fault_page(page_base);
 	if (!faultpage) {
 		/*
 		 * Either this page fault is not caused by kmmio, or
@@ -239,7 +256,7 @@ int kmmio_handler(struct pt_regs *regs, unsigned long addr)
 
 	ctx = &get_cpu_var(kmmio_ctx);
 	if (ctx->active) {
-		if (addr == ctx->addr) {
+		if (page_base == ctx->addr) {
 			/*
 			 * A second fault on the same page means some other
 			 * condition needs handling by do_page_fault(), the
@@ -267,9 +284,9 @@ int kmmio_handler(struct pt_regs *regs, unsigned long addr)
 	ctx->active++;
 
 	ctx->fpage = faultpage;
-	ctx->probe = get_kmmio_probe(addr);
+	ctx->probe = get_kmmio_probe(page_base);
 	ctx->saved_flags = (regs->flags & (X86_EFLAGS_TF | X86_EFLAGS_IF));
-	ctx->addr = addr;
+	ctx->addr = page_base;
 
 	if (ctx->probe && ctx->probe->pre_handler)
 		ctx->probe->pre_handler(ctx->probe, regs, addr);
@@ -354,12 +371,11 @@ out:
 }
 
 /* You must be holding kmmio_lock. */
-static int add_kmmio_fault_page(unsigned long page)
+static int add_kmmio_fault_page(unsigned long addr)
 {
 	struct kmmio_fault_page *f;
 
-	page &= PAGE_MASK;
-	f = get_kmmio_fault_page(page);
+	f = get_kmmio_fault_page(addr);
 	if (f) {
 		if (!f->count)
 			arm_kmmio_fault_page(f);
@@ -372,26 +388,25 @@ static int add_kmmio_fault_page(unsigned long page)
 		return -1;
 
 	f->count = 1;
-	f->page = page;
+	f->addr = addr;
 
 	if (arm_kmmio_fault_page(f)) {
 		kfree(f);
 		return -1;
 	}
 
-	list_add_rcu(&f->list, kmmio_page_list(f->page));
+	list_add_rcu(&f->list, kmmio_page_list(f->addr));
 
 	return 0;
 }
 
 /* You must be holding kmmio_lock. */
-static void release_kmmio_fault_page(unsigned long page,
+static void release_kmmio_fault_page(unsigned long addr,
 				struct kmmio_fault_page **release_list)
 {
 	struct kmmio_fault_page *f;
 
-	page &= PAGE_MASK;
-	f = get_kmmio_fault_page(page);
+	f = get_kmmio_fault_page(addr);
 	if (!f)
 		return;
 
@@ -420,18 +435,27 @@ int register_kmmio_probe(struct kmmio_probe *p)
 	int ret = 0;
 	unsigned long size = 0;
 	const unsigned long size_lim = p->len + (p->addr & ~PAGE_MASK);
+	unsigned int l;
+	pte_t *pte;
 
 	spin_lock_irqsave(&kmmio_lock, flags);
 	if (get_kmmio_probe(p->addr)) {
 		ret = -EEXIST;
 		goto out;
 	}
+
+	pte = lookup_address(p->addr, &l);
+	if (!pte) {
+		ret = -EINVAL;
+		goto out;
+	}
+
 	kmmio_count++;
 	list_add_rcu(&p->list, &kmmio_probes);
 	while (size < size_lim) {
 		if (add_kmmio_fault_page(p->addr + size))
 			pr_err("Unable to set page fault.\n");
-		size += PAGE_SIZE;
+		size += page_level_size(l);
 	}
 out:
 	spin_unlock_irqrestore(&kmmio_lock, flags);
@@ -506,11 +530,18 @@ void unregister_kmmio_probe(struct kmmio_probe *p)
 	const unsigned long size_lim = p->len + (p->addr & ~PAGE_MASK);
 	struct kmmio_fault_page *release_list = NULL;
 	struct kmmio_delayed_release *drelease;
+	unsigned int l;
+	pte_t *pte;
+
+	pte = lookup_address(p->addr, &l);
+	if (!pte) {
+		return;
+	}
 
 	spin_lock_irqsave(&kmmio_lock, flags);
 	while (size < size_lim) {
 		release_kmmio_fault_page(p->addr + size, &release_list);
-		size += PAGE_SIZE;
+		size += page_level_size(l);
 	}
 	list_del_rcu(&p->list);
 	kmmio_count--;
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
