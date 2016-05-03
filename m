Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD6A96B0264
	for <linux-mm@kvack.org>; Mon,  2 May 2016 20:26:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 77so8829607pfz.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 17:26:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 124si935727pff.27.2016.05.02.17.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 17:26:53 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 137/163] x86/mm/kmmio: Fix mmiotrace for hugepages
Date: Mon,  2 May 2016 17:12:45 -0700
Message-Id: <20160503000512.991090971@linuxfoundation.org>
In-Reply-To: <20160503000508.556845508@linuxfoundation.org>
References: <20160503000508.556845508@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Pierre Moreau <pierre.morrow@free.fr>, Karol Herbst <nouveau@karolherbst.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, linux-x86_64@vger.kernel.org, nouveau@lists.freedesktop.org, pq@iki.fi, rostedt@goodmis.org, Ingo Molnar <mingo@kernel.org>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Karol Herbst <nouveau@karolherbst.de>

commit cfa52c0cfa4d727aa3e457bf29aeff296c528a08 upstream.

Because Linux might use bigger pages than the 4K pages to handle those mmio
ioremaps, the kmmio code shouldn't rely on the pade id as it currently does.

Using the memory address instead of the page id lets us look up how big the
page is and what its base address is, so that we won't get a page fault
within the same page twice anymore.

Tested-by: Pierre Moreau <pierre.morrow@free.fr>
Signed-off-by: Karol Herbst <nouveau@karolherbst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org
Cc: linux-x86_64@vger.kernel.org
Cc: nouveau@lists.freedesktop.org
Cc: pq@iki.fi
Cc: rostedt@goodmis.org
Link: http://lkml.kernel.org/r/1456966991-6861-1-git-send-email-nouveau@karolherbst.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/mm/kmmio.c |   88 ++++++++++++++++++++++++++++++++++------------------
 1 file changed, 59 insertions(+), 29 deletions(-)

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
@@ -98,15 +105,19 @@ static struct kmmio_probe *get_kmmio_pro
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
@@ -137,10 +148,10 @@ static void clear_pte_presence(pte_t *pt
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
 
@@ -156,7 +167,7 @@ static int clear_page_presence(struct km
 		return -1;
 	}
 
-	__flush_tlb_one(f->page);
+	__flush_tlb_one(f->addr);
 	return 0;
 }
 
@@ -176,12 +187,12 @@ static int arm_kmmio_fault_page(struct k
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
@@ -191,7 +202,7 @@ static void disarm_kmmio_fault_page(stru
 {
 	int ret = clear_page_presence(f, false);
 	WARN_ONCE(ret < 0,
-			KERN_ERR "kmmio disarming 0x%08lx failed.\n", f->page);
+			KERN_ERR "kmmio disarming at 0x%08lx failed.\n", f->addr);
 	f->armed = false;
 }
 
@@ -215,6 +226,12 @@ int kmmio_handler(struct pt_regs *regs,
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
@@ -227,7 +244,7 @@ int kmmio_handler(struct pt_regs *regs,
 	preempt_disable();
 	rcu_read_lock();
 
-	faultpage = get_kmmio_fault_page(addr);
+	faultpage = get_kmmio_fault_page(page_base);
 	if (!faultpage) {
 		/*
 		 * Either this page fault is not caused by kmmio, or
@@ -239,7 +256,7 @@ int kmmio_handler(struct pt_regs *regs,
 
 	ctx = &get_cpu_var(kmmio_ctx);
 	if (ctx->active) {
-		if (addr == ctx->addr) {
+		if (page_base == ctx->addr) {
 			/*
 			 * A second fault on the same page means some other
 			 * condition needs handling by do_page_fault(), the
@@ -267,9 +284,9 @@ int kmmio_handler(struct pt_regs *regs,
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
@@ -372,26 +388,25 @@ static int add_kmmio_fault_page(unsigned
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
 
@@ -420,18 +435,27 @@ int register_kmmio_probe(struct kmmio_pr
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
@@ -506,11 +530,17 @@ void unregister_kmmio_probe(struct kmmio
 	const unsigned long size_lim = p->len + (p->addr & ~PAGE_MASK);
 	struct kmmio_fault_page *release_list = NULL;
 	struct kmmio_delayed_release *drelease;
+	unsigned int l;
+	pte_t *pte;
+
+	pte = lookup_address(p->addr, &l);
+	if (!pte)
+		return;
 
 	spin_lock_irqsave(&kmmio_lock, flags);
 	while (size < size_lim) {
 		release_kmmio_fault_page(p->addr + size, &release_list);
-		size += PAGE_SIZE;
+		size += page_level_size(l);
 	}
 	list_del_rcu(&p->list);
 	kmmio_count--;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
