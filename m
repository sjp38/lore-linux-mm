Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 350F6C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 19:56:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC3802177E
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 19:56:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sjWzpAf+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC3802177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 243256B0003; Thu,  9 May 2019 15:56:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F3CC6B0006; Thu,  9 May 2019 15:56:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E3146B0007; Thu,  9 May 2019 15:56:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C80556B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 15:56:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d5so1599013pga.3
        for <linux-mm@kvack.org>; Thu, 09 May 2019 12:56:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ot8IQXIdycRfbnAGWMYEHNduuMkLuyWPm0ppqN5UQU8=;
        b=NfgUmddDP2fdTKEuauuRwQizxu1cx8QO5QU5tXOY02yWxtWqZdQw8G8LMHIwvUCAGF
         ShBfxQjd9HpHA8xTTmd9zwroYYwZwSg6kO5hSnVlyQc1QUh1cmL6RgbjHlzCcpx2pBeE
         uANoVQl0NPDN2Muj491lvKKpNfRTQyWfngE5A1oKBL3E8V3PZc2HvOXAYcAg+XXRAX3W
         tRbtgdherAzZtR+mPoJI7bqNQcS2MjO1Ucb6IN0Ka4r5KmMK/fObr1MSvx3oq1kh95iF
         r/rduxDnwnrrghs2VzjUec5HzZHy0UM+LqRTu7Ws1TZerHXEfhSNqU0JK8LEwQ2actwT
         xogw==
X-Gm-Message-State: APjAAAXE90exCJ/EKAKjvchwiVyx4IxCqByJEcPDsRJlU5LThZc5wOVg
	AfqumPSvnaBt3Iji69vsRdLmdG45vf6xHMpwe+Bt5kt7lpdzPsBRT0qU67uLpDfUqVAFSYQQ61J
	XzWCtPZeKtym3LerjmrPcv/kZaGUoX+IYfDiW+sSWNQHAGcBsDFs/K8ayHxBO1fnH5A==
X-Received: by 2002:a17:902:9a83:: with SMTP id w3mr7761102plp.241.1557431788203;
        Thu, 09 May 2019 12:56:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfJIKZqvlSuefaEXYQkSb8ayljq3+REe09vUrN8utkbfCro/LFfnLq+GGLc3wL1kdFOsUc
X-Received: by 2002:a17:902:9a83:: with SMTP id w3mr7761017plp.241.1557431787204;
        Thu, 09 May 2019 12:56:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557431787; cv=none;
        d=google.com; s=arc-20160816;
        b=I/rLUMUray5UmcHibDnLUuEwvadDygf75pI3TIkxHirDyh5pMUOxA5Rk5O+9YOG9Og
         eK5oXhOnxQR1V9k7zmKbPs0keAR1kzgBYCpDpuSlnkAW0PX6kJtRGgIAydYM7s/y7KTm
         ZhbQJL5GLdQly/5pgtZNXqFeePl95ci9Yj6IN3hVFsvZQjtgy8JvPKBvwg6biWzsjyDu
         7dj+RYV3up6JM+nereM1bJAsAsRKdcZvcrBEtXUV3zmpxFMjvdN1GWfYBoWFy9Z/qcLI
         6aLK3WJe1jO2uI7nrFwspzuVvA7KzhRF6aoeCwE0cg3qayJ/h3iCFdJY6brpcdeXQkqk
         MBiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ot8IQXIdycRfbnAGWMYEHNduuMkLuyWPm0ppqN5UQU8=;
        b=DZ1OjsicP331lZZT03/kGT4yK84XtMyxrvLtOm70zbuiWS9YL/i9pr7bauCgMbCDCj
         4FD5AMHG2UpMMpZrc353um6RmhqvI8lFlIsM4bi3OVHNV1pQyLvAqYuzlGS90XJwrY8o
         4HSdIR7BiNsMAk0qANPMcqqGXmTsvwT4L0KnP57Kiur8hbiephQeR0AnNYViXh/nRzW5
         Z0jcTLULdU5ry7XOdimEgU2CnOXWzEj4FLBpewxrDGYwLx0xFGhfw+MfUoT/H1W8QLRG
         gDkgIGKJ+hJtYgOeQoZqORwcVnitsMUgZ7lGnEOg0hcE0tUhPrRmPQfjIJ/A0AbNhN2k
         b0Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sjWzpAf+;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v1si4278609plo.191.2019.05.09.12.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 12:56:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sjWzpAf+;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ot8IQXIdycRfbnAGWMYEHNduuMkLuyWPm0ppqN5UQU8=; b=sjWzpAf+RG2sk7Xun0Y3JguxV
	Clw1VlgAF/0VHkox15p7PkRgGlnwoIoavF+resBPd0UAGNn4gi97iGsnxZirGpFCSa6ap5WOqu0XI
	4JQ+eSoyPMii+x8peXrFm/WTEcesMShFMutGTh4ovK/0s7M+xAiz5DLPpslbg6CuvDwEGl4th5As8
	+leYhoatWAVVGYkU4jZkU+mLA/BrV9kLnkCKewWS/Xkrxw6sp81AOu3UUPhSV6CLlwmEsuGcmR/3U
	9LDMxX6avTpVNSNJkBEsIXjtiaaqgiGrqCaoTO6DA3FHyal3Wgqo28gxNRm9WTA1u4U/D3QzaRrrD
	w+Xph81gQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOp9T-00066y-M8; Thu, 09 May 2019 19:56:23 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 3640623E95D36; Thu,  9 May 2019 21:56:21 +0200 (CEST)
Date: Thu, 9 May 2019 21:56:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, jstancek@redhat.com,
	akpm@linux-foundation.org, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com,
	namit@vmware.com, minchan@kernel.org, Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190509195621.GM2650@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509103813.GP2589@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 12:38:13PM +0200, Peter Zijlstra wrote:

> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index 99740e1dd273..fe768f8d612e 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>  		unsigned long start, unsigned long end)
>  {
>  	/*
> -	 * If there are parallel threads are doing PTE changes on same range
> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> -	 * flush by batching, a thread has stable TLB entry can fail to flush
> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> -	 * forcefully if we detect parallel PTE batching threads.
> +	 * Sensible comment goes here..
>  	 */
> -	if (mm_tlb_flush_nested(tlb->mm)) {
> -		__tlb_reset_range(tlb);
> -		__tlb_adjust_range(tlb, start, end - start);
> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
> +		/*
> +		 * Since we're can't tell what we actually should have
> +		 * flushed flush everything in the given range.
> +		 */
> +		tlb->start = start;
> +		tlb->end = end;
> +		tlb->freed_tables = 1;
> +		tlb->cleared_ptes = 1;
> +		tlb->cleared_pmds = 1;
> +		tlb->cleared_puds = 1;
> +		tlb->cleared_p4ds = 1;
>  	}
>  
>  	tlb_flush_mmu(tlb);

So PPC-radix has page-size dependent TLBI, but the above doesn't work
for them, because they use the tlb_change_page_size() interface and
don't look at tlb->cleared_p*().

Concequently, they have their own special magic :/

Nick, how about you use the tlb_change_page_size() interface to
find/flush on the page-size boundaries, but otherwise use the
tlb->cleared_p* flags to select which actual sizes to flush?

AFAICT that should work just fine for you guys. Maybe something like so?

(fwiw, there's an aweful lot of almost identical functions there)

---

diff --git a/arch/powerpc/mm/tlb-radix.c b/arch/powerpc/mm/tlb-radix.c
index 6a23b9ebd2a1..efc99ef78db6 100644
--- a/arch/powerpc/mm/tlb-radix.c
+++ b/arch/powerpc/mm/tlb-radix.c
@@ -692,7 +692,7 @@ static unsigned long tlb_local_single_page_flush_ceiling __read_mostly = POWER9_
 
 static inline void __radix__flush_tlb_range(struct mm_struct *mm,
 					unsigned long start, unsigned long end,
-					bool flush_all_sizes)
+					bool pflush, bool hflush, bool gflush)
 
 {
 	unsigned long pid;
@@ -734,14 +734,9 @@ static inline void __radix__flush_tlb_range(struct mm_struct *mm,
 				_tlbie_pid(pid, RIC_FLUSH_TLB);
 		}
 	} else {
-		bool hflush = flush_all_sizes;
-		bool gflush = flush_all_sizes;
 		unsigned long hstart, hend;
 		unsigned long gstart, gend;
 
-		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
-			hflush = true;
-
 		if (hflush) {
 			hstart = (start + PMD_SIZE - 1) & PMD_MASK;
 			hend = end & PMD_MASK;
@@ -758,7 +753,9 @@ static inline void __radix__flush_tlb_range(struct mm_struct *mm,
 
 		asm volatile("ptesync": : :"memory");
 		if (local) {
-			__tlbiel_va_range(start, end, pid, page_size, mmu_virtual_psize);
+			if (pflush)
+				__tlbiel_va_range(start, end, pid,
+						page_size, mmu_virtual_psize);
 			if (hflush)
 				__tlbiel_va_range(hstart, hend, pid,
 						PMD_SIZE, MMU_PAGE_2M);
@@ -767,7 +764,9 @@ static inline void __radix__flush_tlb_range(struct mm_struct *mm,
 						PUD_SIZE, MMU_PAGE_1G);
 			asm volatile("ptesync": : :"memory");
 		} else {
-			__tlbie_va_range(start, end, pid, page_size, mmu_virtual_psize);
+			if (pflush)
+				__tlbie_va_range(start, end, pid,
+						page_size, mmu_virtual_psize);
 			if (hflush)
 				__tlbie_va_range(hstart, hend, pid,
 						PMD_SIZE, MMU_PAGE_2M);
@@ -785,12 +784,17 @@ void radix__flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
 		     unsigned long end)
 
 {
+	bool hflush = false;
+
 #ifdef CONFIG_HUGETLB_PAGE
 	if (is_vm_hugetlb_page(vma))
 		return radix__flush_hugetlb_tlb_range(vma, start, end);
 #endif
 
-	__radix__flush_tlb_range(vma->vm_mm, start, end, false);
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		hflush = true;
+
+	__radix__flush_tlb_range(vma->vm_mm, start, end, true, hflush, false);
 }
 EXPORT_SYMBOL(radix__flush_tlb_range);
 
@@ -881,49 +885,14 @@ void radix__tlb_flush(struct mmu_gather *tlb)
 	 */
 	if (tlb->fullmm) {
 		__flush_all_mm(mm, true);
-#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLB_PAGE)
-	} else if (mm_tlb_flush_nested(mm)) {
-		/*
-		 * If there is a concurrent invalidation that is clearing ptes,
-		 * then it's possible this invalidation will miss one of those
-		 * cleared ptes and miss flushing the TLB. If this invalidate
-		 * returns before the other one flushes TLBs, that can result
-		 * in it returning while there are still valid TLBs inside the
-		 * range to be invalidated.
-		 *
-		 * See mm/memory.c:tlb_finish_mmu() for more details.
-		 *
-		 * The solution to this is ensure the entire range is always
-		 * flushed here. The problem for powerpc is that the flushes
-		 * are page size specific, so this "forced flush" would not
-		 * do the right thing if there are a mix of page sizes in
-		 * the range to be invalidated. So use __flush_tlb_range
-		 * which invalidates all possible page sizes in the range.
-		 *
-		 * PWC flush probably is not be required because the core code
-		 * shouldn't free page tables in this path, but accounting
-		 * for the possibility makes us a bit more robust.
-		 *
-		 * need_flush_all is an uncommon case because page table
-		 * teardown should be done with exclusive locks held (but
-		 * after locks are dropped another invalidate could come
-		 * in), it could be optimized further if necessary.
-		 */
-		if (!tlb->need_flush_all)
-			__radix__flush_tlb_range(mm, start, end, true);
-		else
-			radix__flush_all_mm(mm);
-#endif
-	} else if ( (psize = radix_get_mmu_psize(page_size)) == -1) {
-		if (!tlb->need_flush_all)
-			radix__flush_tlb_mm(mm);
-		else
-			radix__flush_all_mm(mm);
 	} else {
 		if (!tlb->need_flush_all)
-			radix__flush_tlb_range_psize(mm, start, end, psize);
+			__radix__flush_tlb_range(mm, start, end,
+					tlb->cleared_pte,
+				        tlb->cleared_pmd,
+					tlb->cleared_pud);
 		else
-			radix__flush_tlb_pwc_range_psize(mm, start, end, psize);
+			radix__flush_all_mm(mm);
 	}
 	tlb->need_flush_all = 0;
 }

