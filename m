Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2C9FC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:20:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93F732075C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:20:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oUiR0kiD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93F732075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E3CA6B027D; Mon, 27 May 2019 08:20:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BA306B027E; Mon, 27 May 2019 08:20:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AB846B027F; Mon, 27 May 2019 08:20:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3D3D6B027D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 08:20:44 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id v15so4086945wmh.1
        for <linux-mm@kvack.org>; Mon, 27 May 2019 05:20:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tFuM1NJvdZZ5PGdDzchsgFWPXIYp9ioXN9wuNgNAYyg=;
        b=mPyEaf6cAO4qJt99LxGmn27ppACiJ5MD5oB2A+zxaOWBxLrfnxgNumeb/kws964QVo
         UsF0NA27xlsbn7JW5P/8ricT0s+wS/KoE6QEku+V2mE+ZLq8eR2rsmCqwN2PO06Aucjb
         HLe05Ta3aQF61EBb1aYNkzrA1DkXUOT/eGqlsiA0LJwwilrdrTc8naNtyVJKcgZWdwEy
         Nii1Ajflr/uf+pqHiRUOteC14Evc5f7F3axb5QxW2mat8fY8wGDH7SeT5jkUjkdh8hYh
         Nsx7/86LnmR44pZqhtLgVnrmUgjgLD3HoWKuCm7biLVCGMc5i9ccHXkmSiK8MrMWK5ep
         TYKw==
X-Gm-Message-State: APjAAAWuenMBiPAiw0FPj8gN77zt0NovlcI9VyiLJ91+Dh9BW+hb+7Im
	8Df2XZOC0whfrX8DKV6H3gNLay+jC3kVNS2uflPnE0qoIRHItc0KhAl4PR4Bwn7j5SlUP4vbzjd
	1ca8//qmnm4OaQqaYK6ip4Mg6/02PVIyCKOD1fHLyxSbHQsi7XVOXOdfBJhyXQ7ogcg==
X-Received: by 2002:adf:c709:: with SMTP id k9mr67428444wrg.144.1558959644292;
        Mon, 27 May 2019 05:20:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4edlhtgVgbwoY4sUr+pNrphezOmPyJ0HvhSbLNFzhtA3/ftWG8FU59YHGDZFGuxr2bi2o
X-Received: by 2002:adf:c709:: with SMTP id k9mr67428394wrg.144.1558959643363;
        Mon, 27 May 2019 05:20:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558959643; cv=none;
        d=google.com; s=arc-20160816;
        b=Pu/yJGoviHcCkuHukZFaJl2SW5+4YHj7+R0TBkxR5pvF/XB1lB3JY/l/jaN9H3qcuq
         Dj/lq74Y20dwmGJrZit6hMDKkQflRK/XpVMX1oCHrEyduzqH/RlZ5UDxEGCFaEdoSGEq
         PHHywgkKoKFETU85TYWrudzcAEq3xGDsj8feCZbH1b3hFF2gtNB/3Y5uWJRyebWVeAb+
         l7okS+2mmeJHEZcl9BUefuoso/AN2zxqhdGs3aRcKQtqO6LINNJQ1Uu+yGV97ELwBlln
         i35HkQHe9eUztadKKrpcPJWHFw+DdUaU6K1TpR6v6/2tyI+O0XL0fkp1HveV37eSXqE5
         wZJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tFuM1NJvdZZ5PGdDzchsgFWPXIYp9ioXN9wuNgNAYyg=;
        b=ORf4dkYuCD1ZXRFwtx2Nt9w3OUMPYUebEuYPnswJCl3a0KG3PcEQKg83nvIqGLmpxE
         BzPQijfL0MCsWrEUdCypjcFJEz6DaeTpuD7XPQs9FGYEUaAHfqu1swd2Ud6FpnFIYNAq
         eQ9jvsutUBnSqZ71O21P8r0i9ylPWXST6+dwYG4LpkzISp5VibcyaucMMX1ZjrKwOnAr
         Vft4AVR8XT/zIW7MYiZPkLoRMb4qYPKQ7II4VDAsNqEv0Q4gX64hsWXySnQxRHmNo2es
         EoOyojfJG5RxvOteGgM7GA3A3nZsxu/Tg80/HH+JQ30q4fIl39fzGlYxLNIgTd43a7B4
         yIYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=oUiR0kiD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t72si8386026wmt.107.2019.05.27.05.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 May 2019 05:20:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=oUiR0kiD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tFuM1NJvdZZ5PGdDzchsgFWPXIYp9ioXN9wuNgNAYyg=; b=oUiR0kiDf4WfWEHLhlG/gMa83
	Hs7r4JFq1+8G928+0OxQ4XKo/m1Gep4RZJuSZ4we14xgB/wGPOdOO3rSNQFZlE635gNPMwDnZ4wmz
	i20iXquy2HgUh9oalCmOAMudLPp0xnyJZ4dqGx1qZIIT4bFRlmTZoN/399UoMZ/GpEAB0dVe15Gto
	0dWszejN2xc3RHBA6SU2fQzJxGg0Hl8NjO6NEF7Ut34MvoJzO5zjfRCBkiCjH6dZViJ2c6b8RjkMq
	N++pTj9EiLSEozG7LGkWm04BhV/uOUGDAaf8K+uoVf1YKz5oIy6Rt0J9LjPLWuUEKqy0+IQBV9PPE
	W3sV/GUhQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hVEc4-00037W-U6; Mon, 27 May 2019 12:20:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 4909520254842; Mon, 27 May 2019 14:20:22 +0200 (CEST)
Date: Mon, 27 May 2019 14:20:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, luto@kernel.org,
	dave.hansen@intel.com, namit@vmware.com,
	Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>,
	Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH v4 1/2] vmalloc: Fix calculation of direct map addr range
Message-ID: <20190527122022.GP2606@hirez.programming.kicks-ass.net>
References: <20190521205137.22029-1-rick.p.edgecombe@intel.com>
 <20190521205137.22029-2-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521205137.22029-2-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:51:36PM -0700, Rick Edgecombe wrote:
> The calculation of the direct map address range to flush was wrong.
> This could cause problems on x86 if a RO direct map alias ever got loaded
> into the TLB. This shouldn't normally happen, but it could cause the
> permissions to remain RO on the direct map alias, and then the page
> would return from the page allocator to some other component as RO and
> cause a crash.
> 
> So fix fix the address range calculation so the flush will include the
> direct map range.
> 
> Fixes: 868b104d7379 ("mm/vmalloc: Add flag for freeing of special permsissions")
> Cc: Meelis Roos <mroos@linux.ee>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  mm/vmalloc.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index c42872ed82ac..836888ae01f6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2159,9 +2159,10 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
>  	 * the vm_unmap_aliases() flush includes the direct map.
>  	 */
>  	for (i = 0; i < area->nr_pages; i++) {
> -		if (page_address(area->pages[i])) {
> +		addr = (unsigned long)page_address(area->pages[i]);
> +		if (addr) {
>  			start = min(addr, start);
> -			end = max(addr, end);
> +			end = max(addr + PAGE_SIZE, end);
>  		}
>  	}
>  

Indeed; howevr I'm thinking this bug was caused to exist by the dual use
of @addr in this function, so should we not, perhaps, do something like
the below instead?

Also; having looked at this, it makes me question the use of
flush_tlb_kernel_range() in _vm_unmap_aliases() and
__purge_vmap_area_lazy(), it's potentially combining multiple ranges,
which never really works well.

Arguably, we should just do flush_tlb_all() here, but that's for another
patch I'm thinking.

---
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2123,7 +2123,6 @@ static inline void set_area_direct_map(c
 /* Handle removing and resetting vm mappings related to the vm_struct. */
 static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 {
-	unsigned long addr = (unsigned long)area->addr;
 	unsigned long start = ULONG_MAX, end = 0;
 	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
 	int i;
@@ -2135,8 +2134,8 @@ static void vm_remove_mappings(struct vm
 	 * execute permissions, without leaving a RW+X window.
 	 */
 	if (flush_reset && !IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP)) {
-		set_memory_nx(addr, area->nr_pages);
-		set_memory_rw(addr, area->nr_pages);
+		set_memory_nx((unsigned long)area->addr, area->nr_pages);
+		set_memory_rw((unsigned long)area->addr, area->nr_pages);
 	}
 
 	remove_vm_area(area->addr);
@@ -2160,9 +2159,10 @@ static void vm_remove_mappings(struct vm
 	 * the vm_unmap_aliases() flush includes the direct map.
 	 */
 	for (i = 0; i < area->nr_pages; i++) {
-		if (page_address(area->pages[i])) {
+		unsigned long addr = (unsigned long)page_address(area->pages[i]);
+		if (addr) {
 			start = min(addr, start);
-			end = max(addr, end);
+			end = max(addr + PAGE_SIZE, end);
 		}
 	}
 

