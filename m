Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31719C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE6DF213F2
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Gh3t9gEM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE6DF213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B88D58E0010; Tue, 25 Jun 2019 10:38:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA0168E000B; Tue, 25 Jun 2019 10:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C8638E000F; Tue, 25 Jun 2019 10:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0458E000B
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j7so11996839pfn.10
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=a9NQkpmukXy1lWC/LI5ypTEQqGqYwv/FPxR2noqbWvI=;
        b=Mis8LAr4TEDpkhPQ1SVtQeiLMx05/xAxVZrBvtXeNhsRkyrJKrcKA4N99zWQZ0P782
         hjA2C3HJ/pHaXGgMxH/8BD57pXvN2thQ4O1eqvU/Z8fGIix+AUuPBvqzuQo42nzRktYm
         7MqCbZoJGpT+f1tYrrDHgvmAjFCtjLvkSkDURW9mejJ8fFgyHJQ+qC+VRq0K1fpEHs+v
         AQSZsXJNUsQ4meZFlJGfp9u1z7UfWVVOWoqjbeaeRS/XY44BbE4aWYFRh7oisOTsvdLd
         X66MHI/4JIy/Kg4sUejp2mYdgeowLQbbq0sho6wusmFnXzj4fwPnCD3NXcNbUDqyEMim
         LhjA==
X-Gm-Message-State: APjAAAX2EOwnNCx0ys4GSe8IfS5Js8ijl54dpMyPbUvspI+VCDGTrn7w
	nb/jyWqomn5O6LV7yFsd9n8fIZ+AsMBpRXIgJ4nZ6lESvSI66D2x9VcDuCrCb88tjCFgQIWm29o
	HgiGXyDrhgJ6iG7W72Q41RrOG7sPskbwCAR5BZ7gLUkDI9cdreYfMPpjjxM7sBjM=
X-Received: by 2002:a17:90a:bc0c:: with SMTP id w12mr693963pjr.111.1561473494869;
        Tue, 25 Jun 2019 07:38:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxa7mvJVP/W/n8rKrdm90mo8zmhv7K+mA5i6blruWmyh+kyjFCqwWHWjs1BsyL0nCOc8+zD
X-Received: by 2002:a17:90a:bc0c:: with SMTP id w12mr693849pjr.111.1561473493586;
        Tue, 25 Jun 2019 07:38:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473493; cv=none;
        d=google.com; s=arc-20160816;
        b=WbOFkHNNkZialoP0qkuIosVi0lTkF3pXuCUCTpHpWNUHU5F4WU8KzqZvWe6XdAcK3a
         Mr6/I73FdUlKpQtKCLsKj+G2KjgqrOK+CQRbY+F5UuV27E0xjw4v9v3To13OREeSosyA
         Pn82V39q3lWOUN/pM37OmgNIcJpTvGAP3uW/zKxY/VU1qhJNNM6SNR+bqXJB5BPBsWkr
         gjODwWjMlXjmwE47qXl7XZVBsO2kZZ61T1E81IhskceP5dFaPj5TAO7ExAN1QtOInrj/
         sZZ04BqjrBMHGcgnLuGMzzNjmRj48R/hLeqUfKtgpqS3nsrXWK+z7ZzUOQFjbzsmFLHS
         x1wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=a9NQkpmukXy1lWC/LI5ypTEQqGqYwv/FPxR2noqbWvI=;
        b=cOt/q49f05GTBulkaEZ6FriRbKfcfAIe7PJVJeTJ7rU21TSK5CsfHbnX2KI8R0qz1/
         BgMj7L5C1Hco0hz06qVrhKahgku+e9HWoRRudNf4byJXkFQkedSVMRjDKjQNzi0lspoj
         rHjlkH0RW3djz6XAQt1txoactFb6TpTprKFOqkouEbl+i46f8azteydB8HHixdmjLh8B
         zad/C7LWz9jW6LrMICNJkUn5FuU/NEuxSNz6wq5OH8I5zG4AnimsPgBKLP6JbthCSsXe
         H30GAVssEsvlKRbQTQMpEEbnPI0HHAmy6s0bMhyxvVpyca6b84+3kt1aT4vxosnQKjBP
         5USA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Gh3t9gEM;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m22si13344881pgk.361.2019.06.25.07.38.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Gh3t9gEM;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=a9NQkpmukXy1lWC/LI5ypTEQqGqYwv/FPxR2noqbWvI=; b=Gh3t9gEMOW6SDRUUvXiEP7+/4L
	PLWxDogq/bQJmJEZDQIER0y9ehwsl5Otedae1zKqu84nl8L/27DqZhrM1xp+bQMcpQduYYZsYEJL4
	hce1U06se+qhkRCmEo+Te29xinOTrMS4zfk7Sb3cvAi7Kop9gqzUijqVQP6dxi/ol8dKsa3wANDt9
	AtLJmnFZGuiGC9A1UDO5h+0MDj+xYIpiqPP44h+vCRXpmJ+cQV0J9BgIAMqyn2JlN9IJ8HrBFTgu3
	QmYu3C8I7KE2jOHIkrQanNqZNfwJyyCsGkyXqqgTzVVB4rCKH9aQKAUNoeEM8q7GM84whzOkUANgG
	W2E9f2ng==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfma4-00083b-Sr; Tue, 25 Jun 2019 14:37:57 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 12/16] mm: consolidate the get_user_pages* implementations
Date: Tue, 25 Jun 2019 16:37:11 +0200
Message-Id: <20190625143715.1689-13-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190625143715.1689-1-hch@lst.de>
References: <20190625143715.1689-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Always build mm/gup.c so that we don't have to provide separate nommu
stubs.  Also merge the get_user_pages_fast and __get_user_pages_fast
stubs when HAVE_FAST_GUP into the main implementations, which will
never call the fast path if HAVE_FAST_GUP is not set.

This also ensures the new put_user_pages* helpers are available for
nommu, as those are currently missing, which would create a problem as
soon as we actually grew users for it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/Kconfig  |  1 +
 mm/Makefile |  4 +--
 mm/gup.c    | 67 +++++++++++++++++++++++++++++++++++++---
 mm/nommu.c  | 88 -----------------------------------------------------
 mm/util.c   | 47 ----------------------------
 5 files changed, 65 insertions(+), 142 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 98dffb0f2447..5c41409557da 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -133,6 +133,7 @@ config HAVE_MEMBLOCK_PHYS_MAP
 	bool
 
 config HAVE_FAST_GUP
+	depends on MMU
 	bool
 
 config ARCH_KEEP_MEMBLOCK
diff --git a/mm/Makefile b/mm/Makefile
index ac5e5ba78874..dc0746ca1109 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -22,7 +22,7 @@ KCOV_INSTRUMENT_mmzone.o := n
 KCOV_INSTRUMENT_vmstat.o := n
 
 mmu-y			:= nommu.o
-mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
+mmu-$(CONFIG_MMU)	:= highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mmu_gather.o mprotect.o mremap.o \
 			   msync.o page_vma_mapped.o pagewalk.o \
 			   pgtable-generic.o rmap.o vmalloc.o
@@ -39,7 +39,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   debug.o $(mmu-y)
+			   debug.o gup.o $(mmu-y)
 
 # Give 'page_alloc' its own module-parameter namespace
 page-alloc-y := page_alloc.o
diff --git a/mm/gup.c b/mm/gup.c
index b29249581672..0e83dba98dfd 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -134,6 +134,7 @@ void put_user_pages(struct page **pages, unsigned long npages)
 }
 EXPORT_SYMBOL(put_user_pages);
 
+#ifdef CONFIG_MMU
 static struct page *no_page_table(struct vm_area_struct *vma,
 		unsigned int flags)
 {
@@ -1322,6 +1323,51 @@ struct page *get_dump_page(unsigned long addr)
 	return page;
 }
 #endif /* CONFIG_ELF_CORE */
+#else /* CONFIG_MMU */
+static long __get_user_pages_locked(struct task_struct *tsk,
+		struct mm_struct *mm, unsigned long start,
+		unsigned long nr_pages, struct page **pages,
+		struct vm_area_struct **vmas, int *locked,
+		unsigned int foll_flags)
+{
+	struct vm_area_struct *vma;
+	unsigned long vm_flags;
+	int i;
+
+	/* calculate required read or write permissions.
+	 * If FOLL_FORCE is set, we only require the "MAY" flags.
+	 */
+	vm_flags  = (foll_flags & FOLL_WRITE) ?
+			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
+	vm_flags &= (foll_flags & FOLL_FORCE) ?
+			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
+
+	for (i = 0; i < nr_pages; i++) {
+		vma = find_vma(mm, start);
+		if (!vma)
+			goto finish_or_fault;
+
+		/* protect what we can, including chardevs */
+		if ((vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
+		    !(vm_flags & vma->vm_flags))
+			goto finish_or_fault;
+
+		if (pages) {
+			pages[i] = virt_to_page(start);
+			if (pages[i])
+				get_page(pages[i]);
+		}
+		if (vmas)
+			vmas[i] = vma;
+		start = (start + PAGE_SIZE) & PAGE_MASK;
+	}
+
+	return i;
+
+finish_or_fault:
+	return i ? : -EFAULT;
+}
+#endif /* !CONFIG_MMU */
 
 #if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
 static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
@@ -1484,7 +1530,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 {
 	return nr_pages;
 }
-#endif
+#endif /* CONFIG_CMA */
 
 /*
  * __gup_longterm_locked() is a wrapper for __get_user_pages_locked which
@@ -2160,6 +2206,12 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
 			return;
 	} while (pgdp++, addr = next, addr != end);
 }
+#else
+static inline void gup_pgd_range(unsigned long addr, unsigned long end,
+		unsigned int flags, struct page **pages, int *nr)
+{
+}
+#endif /* CONFIG_HAVE_FAST_GUP */
 
 #ifndef gup_fast_permitted
 /*
@@ -2177,6 +2229,9 @@ static bool gup_fast_permitted(unsigned long start, unsigned long end)
  * the regular GUP.
  * Note a difference with get_user_pages_fast: this always returns the
  * number of pages pinned, 0 if no pages were pinned.
+ *
+ * If the architecture does not support this function, simply return with no
+ * pages pinned.
  */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
@@ -2206,7 +2261,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, end)) {
+	if (IS_ENABLED(CONFIG_HAVE_FAST_GUP) &&
+	    gup_fast_permitted(start, end)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_restore(flags);
@@ -2214,6 +2270,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	return nr;
 }
+EXPORT_SYMBOL_GPL(__get_user_pages_fast);
 
 static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
 				   unsigned int gup_flags, struct page **pages)
@@ -2270,7 +2327,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return -EFAULT;
 
-	if (gup_fast_permitted(start, end)) {
+	if (IS_ENABLED(CONFIG_HAVE_FAST_GUP) &&
+	    gup_fast_permitted(start, end)) {
 		local_irq_disable();
 		gup_pgd_range(addr, end, gup_flags, pages, &nr);
 		local_irq_enable();
@@ -2296,5 +2354,4 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 
 	return ret;
 }
-
-#endif /* CONFIG_HAVE_GENERIC_GUP */
+EXPORT_SYMBOL_GPL(get_user_pages_fast);
diff --git a/mm/nommu.c b/mm/nommu.c
index d8c02fbe03b5..07165ad2e548 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -111,94 +111,6 @@ unsigned int kobjsize(const void *objp)
 	return PAGE_SIZE << compound_order(page);
 }
 
-static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		      unsigned long start, unsigned long nr_pages,
-		      unsigned int foll_flags, struct page **pages,
-		      struct vm_area_struct **vmas, int *nonblocking)
-{
-	struct vm_area_struct *vma;
-	unsigned long vm_flags;
-	int i;
-
-	/* calculate required read or write permissions.
-	 * If FOLL_FORCE is set, we only require the "MAY" flags.
-	 */
-	vm_flags  = (foll_flags & FOLL_WRITE) ?
-			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
-	vm_flags &= (foll_flags & FOLL_FORCE) ?
-			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
-
-	for (i = 0; i < nr_pages; i++) {
-		vma = find_vma(mm, start);
-		if (!vma)
-			goto finish_or_fault;
-
-		/* protect what we can, including chardevs */
-		if ((vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
-		    !(vm_flags & vma->vm_flags))
-			goto finish_or_fault;
-
-		if (pages) {
-			pages[i] = virt_to_page(start);
-			if (pages[i])
-				get_page(pages[i]);
-		}
-		if (vmas)
-			vmas[i] = vma;
-		start = (start + PAGE_SIZE) & PAGE_MASK;
-	}
-
-	return i;
-
-finish_or_fault:
-	return i ? : -EFAULT;
-}
-
-/*
- * get a list of pages in an address range belonging to the specified process
- * and indicate the VMA that covers each page
- * - this is potentially dodgy as we may end incrementing the page count of a
- *   slab page or a secondary page from a compound page
- * - don't permit access to VMAs that don't support it, such as I/O mappings
- */
-long get_user_pages(unsigned long start, unsigned long nr_pages,
-		    unsigned int gup_flags, struct page **pages,
-		    struct vm_area_struct **vmas)
-{
-	return __get_user_pages(current, current->mm, start, nr_pages,
-				gup_flags, pages, vmas, NULL);
-}
-EXPORT_SYMBOL(get_user_pages);
-
-long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-			    unsigned int gup_flags, struct page **pages,
-			    int *locked)
-{
-	return get_user_pages(start, nr_pages, gup_flags, pages, NULL);
-}
-EXPORT_SYMBOL(get_user_pages_locked);
-
-static long __get_user_pages_unlocked(struct task_struct *tsk,
-			struct mm_struct *mm, unsigned long start,
-			unsigned long nr_pages, struct page **pages,
-			unsigned int gup_flags)
-{
-	long ret;
-	down_read(&mm->mmap_sem);
-	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
-				NULL, NULL);
-	up_read(&mm->mmap_sem);
-	return ret;
-}
-
-long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
-			     struct page **pages, unsigned int gup_flags)
-{
-	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
-					 pages, gup_flags);
-}
-EXPORT_SYMBOL(get_user_pages_unlocked);
-
 /**
  * follow_pfn - look up PFN at a user virtual address
  * @vma: memory mapping
diff --git a/mm/util.c b/mm/util.c
index 9834c4ab7d8e..68575a315dc5 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -300,53 +300,6 @@ void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 }
 #endif
 
-/*
- * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
- * back to the regular GUP.
- * Note a difference with get_user_pages_fast: this always returns the
- * number of pages pinned, 0 if no pages were pinned.
- * If the architecture does not support this function, simply return with no
- * pages pinned.
- */
-int __weak __get_user_pages_fast(unsigned long start,
-				 int nr_pages, int write, struct page **pages)
-{
-	return 0;
-}
-EXPORT_SYMBOL_GPL(__get_user_pages_fast);
-
-/**
- * get_user_pages_fast() - pin user pages in memory
- * @start:	starting user address
- * @nr_pages:	number of pages from start to pin
- * @gup_flags:	flags modifying pin behaviour
- * @pages:	array that receives pointers to the pages pinned.
- *		Should be at least nr_pages long.
- *
- * get_user_pages_fast provides equivalent functionality to get_user_pages,
- * operating on current and current->mm, with force=0 and vma=NULL. However
- * unlike get_user_pages, it must be called without mmap_sem held.
- *
- * get_user_pages_fast may take mmap_sem and page table locks, so no
- * assumptions can be made about lack of locking. get_user_pages_fast is to be
- * implemented in a way that is advantageous (vs get_user_pages()) when the
- * user memory area is already faulted in and present in ptes. However if the
- * pages have to be faulted in, it may turn out to be slightly slower so
- * callers need to carefully consider what to use. On many architectures,
- * get_user_pages_fast simply falls back to get_user_pages.
- *
- * Return: number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno.
- */
-int __weak get_user_pages_fast(unsigned long start,
-				int nr_pages, unsigned int gup_flags,
-				struct page **pages)
-{
-	return get_user_pages_unlocked(start, nr_pages, pages, gup_flags);
-}
-EXPORT_SYMBOL_GPL(get_user_pages_fast);
-
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long pgoff)
-- 
2.20.1

