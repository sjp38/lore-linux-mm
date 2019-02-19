Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76A96C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:34:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27A2320818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:34:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aCYhZeoV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27A2320818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61CC08E000F; Tue, 19 Feb 2019 05:33:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35BBD8E0015; Tue, 19 Feb 2019 05:33:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D6838E000F; Tue, 19 Feb 2019 05:33:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3EBE8E0014
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:10 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id r136so3617113ith.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=HSnqaAxiObsayZ4+EIHUMu5Su7NmTQDCZqQQgYiGzgI=;
        b=MotpxFN8HHmIZYDdjsFnPDLMMVgqdAzWfvoKT36+fvnABfmFvFuF9P8SNRvnZ3ChSd
         PYRdP0wHlvy85CmJTHdCvlV8SrtFhlshuxOhNIpO/ETfkaa7iyKn4+rwfnUmrI9p0qgw
         l+2IhbrMo21/nfgX1JK4gs3WFBEExLmVdR1Kcy6EDCWdlpLxKnFheiD3PAEEuA63gRq4
         ftG1HgcDdcqmMrIdf0G43O/EneuTTUGdTjGKyhEow2JnUHRa5G7pJuIbt3d466nWqvbA
         duZYN2190P8a/IuoVqTK0Su8hAxvaClwC8WJ5QJVbVDbKhTcEEJUJTkYZif4+Ep8eK92
         o39Q==
X-Gm-Message-State: AHQUAuZi3YkjwZQuGIzrQ8gq3sBLjXftw3PAJrib40CpoAHcylOVi3xn
	cNwkyc+ch0Ar+4wPQuZHbDJfwAcqQc5V+rkv2Owh39SGdHTgTH3kBWktZUCm1R4zd3GDszztHvM
	gkGEojPaRfQyaZJV4HhfuXJXLRqrADJq8dwBeDtdox2b5sL0sK6qAFAGY727FHs0cSA==
X-Received: by 2002:a24:9a84:: with SMTP id l126mr2140823ite.77.1550572390605;
        Tue, 19 Feb 2019 02:33:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbNFmVDCzvkVAtNNscp1jPgXOvSEg702iUZYY/4WoTHlN4fVN0gZxagDnIS3n86JvAS/atj
X-Received: by 2002:a24:9a84:: with SMTP id l126mr2140623ite.77.1550572385433;
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572385; cv=none;
        d=google.com; s=arc-20160816;
        b=S8uZlJ5ffHKfPdRcf81L/qJ2JsI43UVzdPsvbJxIYLCxSzWbS6UqEiSwBe7A0/Q6Ev
         NtSsAGHYBNMAZAAylGUr8uFrWZ5QUc08qKpZWP7/tBrDllaIH0Yl86/IsFcw3iu8T3ck
         US0Ge551kkzbkaIiMAzSiiB9sOCTDcCPgupueM+WoiZzZhYCJMox0aEsTWhV1qdlNUdo
         NHnXe2SmSHVszfxVfn7AKkJNn+jk6Dqt+1eC+5NuhD1Yea9jF1eBqRKB7yLxVV1+N5Wb
         WmwHsNkoFEJ8u6IkGS+Z+bqBvrBFBNaJKx4+1EfiZrqsy9sqtJoNnjRRiKNkGCCpvOjv
         WGJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=HSnqaAxiObsayZ4+EIHUMu5Su7NmTQDCZqQQgYiGzgI=;
        b=xjTa6PwA811IPe4Odc2/LWlIrTCv/iaaK0I5OhqPJaUdQVTXZ8VXTiVgc39UF6w01S
         0MJMoFFVHU5drNvw9axKCxt8bBlAgBsqe9xX72ZwyQnEpGfv2g+FSWglwRgYgBYk2LtY
         U2pI9vO5AYYGCu6gqVzw2ngl06Eeu+PsMRsxW4jF5WiK/SXYLSPtdUVqueAHgxTOU1JU
         +k0pH2sEZZLOOyQ4ox2LxQyYiB63exPTwG8+gZZAxy4mOGWBryy5XDHrxkILhgtSyCoa
         TchrM9mFjn7RqRe0YOQfC8lRyFP9lqv7E+RefHo8NpZ0KhqwGjgX4/9C7RG9JoorExcg
         cNPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=aCYhZeoV;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m1si3385621iol.45.2019.02.19.02.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=aCYhZeoV;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=HSnqaAxiObsayZ4+EIHUMu5Su7NmTQDCZqQQgYiGzgI=; b=aCYhZeoVURRtBIdPipMvux7sXW
	gVhr0Ovtnm18dasYNLzI8HAMEG++W76a0Ivj72FuyNR5Lo63KtxQFy34ba0q041yuOqtDZSwnzONp
	X0i0+b3fFvsdpgh2sGoqC48i6/f+sBdj508q79pbSxbLYQ/dNzqR4QjdIYtyNVXizs6LvB5rixh6A
	NexhvRk+nyniGMRDD7MkCe5dcoRgO4Vy+5wIAhbLUSaYkCyOIpjVt8ib+mqpBnRmWS2B7E+7aVxbV
	HcHLmf3HrcWQu0ji6gbLFl6pNMefd4pBGVtfxrd16o3Cu2rsKQ2HtemosuSJgibQl3CsDwi4xeViy
	d1gOnspQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hm-0000dV-0G; Tue, 19 Feb 2019 10:32:50 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 481DD285202C1; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103232.912967090@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: will.deacon@arm.com,
 aneesh.kumar@linux.vnet.ibm.com,
 akpm@linux-foundation.org,
 npiggin@gmail.com
Cc: linux-arch@vger.kernel.org,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 peterz@infradead.org,
 linux@armlinux.org.uk,
 heiko.carstens@de.ibm.com,
 riel@surriel.com
Subject: [PATCH v6 01/18] asm-generic/tlb: Provide a comment
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Write a comment explaining some of this..

Cc: Nick Piggin <npiggin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |  119 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 116 insertions(+), 3 deletions(-)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -22,6 +22,118 @@
 
 #ifdef CONFIG_MMU
 
+/*
+ * Generic MMU-gather implementation.
+ *
+ * The mmu_gather data structure is used by the mm code to implement the
+ * correct and efficient ordering of freeing pages and TLB invalidations.
+ *
+ * This correct ordering is:
+ *
+ *  1) unhook page
+ *  2) TLB invalidate page
+ *  3) free page
+ *
+ * That is, we must never free a page before we have ensured there are no live
+ * translations left to it. Otherwise it might be possible to observe (or
+ * worse, change) the page content after it has been reused.
+ *
+ * The mmu_gather API consists of:
+ *
+ *  - tlb_gather_mmu() / tlb_finish_mmu(); start and finish a mmu_gather
+ *
+ *    Finish in particular will issue a (final) TLB invalidate and free
+ *    all (remaining) queued pages.
+ *
+ *  - tlb_start_vma() / tlb_end_vma(); marks the start / end of a VMA
+ *
+ *    Defaults to flushing at tlb_end_vma() to reset the range; helps when
+ *    there's large holes between the VMAs.
+ *
+ *  - tlb_remove_page() / __tlb_remove_page()
+ *  - tlb_remove_page_size() / __tlb_remove_page_size()
+ *
+ *    __tlb_remove_page_size() is the basic primitive that queues a page for
+ *    freeing. __tlb_remove_page() assumes PAGE_SIZE. Both will return a
+ *    boolean indicating if the queue is (now) full and a call to
+ *    tlb_flush_mmu() is required.
+ *
+ *    tlb_remove_page() and tlb_remove_page_size() imply the call to
+ *    tlb_flush_mmu() when required and has no return value.
+ *
+ *  - tlb_remove_check_page_size_change()
+ *
+ *    call before __tlb_remove_page*() to set the current page-size; implies a
+ *    possible tlb_flush_mmu() call.
+ *
+ *  - tlb_flush_mmu() / tlb_flush_mmu_tlbonly() / tlb_flush_mmu_free()
+ *
+ *    tlb_flush_mmu_tlbonly() - does the TLB invalidate (and resets
+ *                              related state, like the range)
+ *
+ *    tlb_flush_mmu_free() - frees the queued pages; make absolutely
+ *			     sure no additional tlb_remove_page()
+ *			     calls happen between _tlbonly() and this.
+ *
+ *    tlb_flush_mmu() - the above two calls.
+ *
+ *  - mmu_gather::fullmm
+ *
+ *    A flag set by tlb_gather_mmu() to indicate we're going to free
+ *    the entire mm; this allows a number of optimizations.
+ *
+ *    - We can ignore tlb_{start,end}_vma(); because we don't
+ *      care about ranges. Everything will be shot down.
+ *
+ *    - (RISC) architectures that use ASIDs can cycle to a new ASID
+ *      and delay the invalidation until ASID space runs out.
+ *
+ *  - mmu_gather::need_flush_all
+ *
+ *    A flag that can be set by the arch code if it wants to force
+ *    flush the entire TLB irrespective of the range. For instance
+ *    x86-PAE needs this when changing top-level entries.
+ *
+ * And requires the architecture to provide and implement tlb_flush().
+ *
+ * tlb_flush() may, in addition to the above mentioned mmu_gather fields, make
+ * use of:
+ *
+ *  - mmu_gather::start / mmu_gather::end
+ *
+ *    which provides the range that needs to be flushed to cover the pages to
+ *    be freed.
+ *
+ *  - mmu_gather::freed_tables
+ *
+ *    set when we freed page table pages
+ *
+ *  - tlb_get_unmap_shift() / tlb_get_unmap_size()
+ *
+ *    returns the smallest TLB entry size unmapped in this range
+ *
+ * Additionally there are a few opt-in features:
+ *
+ *  HAVE_RCU_TABLE_FREE
+ *
+ *  This provides tlb_remove_table(), to be used instead of tlb_remove_page()
+ *  for page directores (__p*_free_tlb()). This provides separate freeing of
+ *  the page-table pages themselves in a semi-RCU fashion (see comment below).
+ *  Useful if your architecture doesn't use IPIs for remote TLB invalidates
+ *  and therefore doesn't naturally serialize with software page-table walkers.
+ *
+ *  When used, an architecture is expected to provide __tlb_remove_table()
+ *  which does the actual freeing of these pages.
+ *
+ *  HAVE_RCU_TABLE_INVALIDATE
+ *
+ *  This makes HAVE_RCU_TABLE_FREE call tlb_flush_mmu_tlbonly() before freeing
+ *  the page-table pages. Required if you use HAVE_RCU_TABLE_FREE and your
+ *  architecture uses the Linux page-tables natively.
+ *
+ */
+#define HAVE_GENERIC_MMU_GATHER
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 /*
  * Semi RCU freeing of the page directories.
@@ -89,14 +201,17 @@ struct mmu_gather_batch {
  */
 #define MAX_GATHER_BATCH_COUNT	(10000UL/MAX_GATHER_BATCH)
 
-/* struct mmu_gather is an opaque type used by the mm code for passing around
+/*
+ * struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
 	struct mm_struct	*mm;
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch	*batch;
 #endif
+
 	unsigned long		start;
 	unsigned long		end;
 	/*
@@ -131,8 +246,6 @@ struct mmu_gather {
 	int page_size;
 };
 
-#define HAVE_GENERIC_MMU_GATHER
-
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
 	struct mm_struct *mm, unsigned long start, unsigned long end);
 void tlb_flush_mmu(struct mmu_gather *tlb);


