Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC360C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:34:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66BBB2146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:34:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dFYG6VAK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66BBB2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 360328E0016; Tue, 19 Feb 2019 05:33:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24A068E0014; Tue, 19 Feb 2019 05:33:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C7598E0015; Tue, 19 Feb 2019 05:33:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB0AD8E000F
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:10 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id r136so3617111ith.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=1m499lCoWZDawBwduH5mia3SdJ+bH6wWKMriVQsCXbM=;
        b=r9bdsjddWNi8uFJYe+VD6ZwE0oy4Ct02+0kHrRh1hR2JmXOU7HbphzzEZvPeag15lD
         IWdrauKsd0EDAC1QtccaQs4OjZQKUbgnupgwsdneRTJE5uXASWojtN1eKgfWaQUQJDvf
         /rJbIz8tshnx+KRNPPZ6lQ5CJMhBZct3pyAPvn5d0u5ASMt8Oiq3mlkWYBU2cSn5gExP
         95zfiAe+fKr7RCnvq0mKafb/iayo3mNrMqu+NwoP4mhs3gxSHkuI2HC5k+uwP0GbJQMr
         NygTt2ijycJY29EaB/ZEj31Uwq0yOrv2NfljRoaiUqGcCwmPqa6LhEsQbiOOPHU8nNme
         X9+Q==
X-Gm-Message-State: AHQUAuaJH6/V7uocT6EmDqhMyit88HuNJ2s1N9e681zIcYQjmUmN617A
	ABijOrHQ2N/wXkJGLnlHei+9Jsly9Ns+c2VImaWM0GRN00B4DaGdXsROiX3EJY145+ZwBj3dAei
	Z2FiU39Bzbp334loVdJFZZ1DJIcl1tJuGJI8xJqy1IStcPngNB2lVKpRjDc65L+JqIQ==
X-Received: by 2002:a5d:9859:: with SMTP id p25mr17205174ios.64.1550572390625;
        Tue, 19 Feb 2019 02:33:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafoTH0tLlWd4OgtYCNJfm/nUJ3Pe67ChS1fsPucXmhpgeJpuJR8gIVfKBfmzTcySZa7OhN
X-Received: by 2002:a5d:9859:: with SMTP id p25mr17204977ios.64.1550572385480;
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572385; cv=none;
        d=google.com; s=arc-20160816;
        b=ddYpFCDnBqHUyN9l/O/BzNt8c7scApofzRtnoVcjVIw9cH1BbBdBtkE4DI4qGhSZjh
         fBwNfWZfUmB4K30SvMF0NTMjJOtyCoquHKu/fKl5iriwXE0MDL2uLZA4IF6kKmW+xS9/
         ao6gEK1CZSHO7Ut9cTecsm1kNd+N6msE6sgPkH53kHltcjgC9N8cyKlW2k55UdJ4wnIp
         YLYGjiFZs6gPnKyRYuv/OrmlKJZKxVSC3OSm33L0tVwZCKYmca9FogxsrkedC2wa+rkV
         JEuAgWKONG7z2KDjCA+Naiyr6iPLKsUBTo5TDJijIrD4MW3we+4L9o35KluyirslS5/e
         HPtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=1m499lCoWZDawBwduH5mia3SdJ+bH6wWKMriVQsCXbM=;
        b=dAt5vnqankL+ccJ3LHPovde8J6afamVjdlPGJYBvhuuKfM8KaZP3b+9TYMtn1HAwts
         7pecgs5cquHIqCW7JGKFHSTwbtMRN2T2n+S5HF5f2+Lfk2m/izMDgUJcgmp5F2+aOTbx
         lAVidvxtwho/cxh/Dkb3NYYRkUk+/zm9JDnCgL8hte+PymLxJ1DGfLgmDOvIH5lzflRs
         0xc7eS11y/SxThT1lIzoo2/LSK4icTZ339f/KvfU2y0n7UbQD4Wq9nkpB3hm5ev+hy83
         KpBu1kokwlhEqWhBHky4omfVJhQFABJSQ4NPjrqgfO7YtPeUlmV6npo2vV/CDykNtk1M
         xXyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dFYG6VAK;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i12si1038753itb.82.2019.02.19.02.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dFYG6VAK;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=1m499lCoWZDawBwduH5mia3SdJ+bH6wWKMriVQsCXbM=; b=dFYG6VAK1LK+4vkgXN0vUIsqq6
	5fk4Ykx9noitYB0eJyqW1qO8Q7PGgAjnssomkzP9XeppAeiW2TEx0TrfM5DUMHDs1xdWzFGndumss
	PniHG02dFakkjoWJu6EbacmsGYQzXCHGEB6c4TTk33Da1gvaTUvQAIq2l+MiB2Z69fS6ceTTT8jDN
	1AaBvXf0V+ZrjSUR7QrGlwOPBXx0t6bzYA+uUhrNnu0mTnDu3bNz9MWr643UYdj1T4Ux+2RqnDlJ9
	goOlZiJE9FufW0cR0uBywsIk1rJhozVPoroSLqKLnkhutKAr4Nt7bBCTZ8rOqR/Q3yTc+OjFKP27U
	4gfRfKdQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hn-0000di-I4; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 550AC285202C6; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.148854086@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:53 +0100
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
Subject: [PATCH v6 05/18] asm-generic/tlb: Provide generic tlb_flush() based on flush_tlb_mm()
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When an architecture does not have (an efficient) flush_tlb_range(),
but instead always uses full TLB invalidates, the current generic
tlb_flush() is sub-optimal, for it will generate extra flushes in
order to keep the range small.

But if we cannot do range flushes, that is a moot concern. Optionally
provide this simplified default.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |   41 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 40 insertions(+), 1 deletion(-)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -114,7 +114,8 @@
  *    returns the smallest TLB entry size unmapped in this range.
  *
  * If an architecture does not provide tlb_flush() a default implementation
- * based on flush_tlb_range() will be used.
+ * based on flush_tlb_range() will be used, unless MMU_GATHER_NO_RANGE is
+ * specified, in which case we'll default to flush_tlb_mm().
  *
  * Additionally there are a few opt-in features:
  *
@@ -140,6 +141,9 @@
  *  the page-table pages. Required if you use HAVE_RCU_TABLE_FREE and your
  *  architecture uses the Linux page-tables natively.
  *
+ *  MMU_GATHER_NO_RANGE
+ *
+ *  Use this if your architecture lacks an efficient flush_tlb_range().
  */
 #define HAVE_GENERIC_MMU_GATHER
 
@@ -302,12 +306,45 @@ static inline void __tlb_reset_range(str
 	 */
 }
 
+#ifdef CONFIG_MMU_GATHER_NO_RANGE
+
+#if defined(tlb_flush) || defined(tlb_start_vma) || defined(tlb_end_vma)
+#error MMU_GATHER_NO_RANGE relies on default tlb_flush(), tlb_start_vma() and tlb_end_vma()
+#endif
+
+/*
+ * When an architecture does not have efficient means of range flushing TLBs
+ * there is no point in doing intermediate flushes on tlb_end_vma() to keep the
+ * range small. We equally don't have to worry about page granularity or other
+ * things.
+ *
+ * All we need to do is issue a full flush for any !0 range.
+ */
+static inline void tlb_flush(struct mmu_gather *tlb)
+{
+	if (tlb->end)
+		flush_tlb_mm(tlb->mm);
+}
+
+static inline void
+tlb_update_vma_flags(struct mmu_gather *tlb, struct vm_area_struct *vma) { }
+
+#define tlb_end_vma tlb_end_vma
+static inline void tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma) { }
+
+#else /* CONFIG_MMU_GATHER_NO_RANGE */
+
 #ifndef tlb_flush
 
 #if defined(tlb_start_vma) || defined(tlb_end_vma)
 #error Default tlb_flush() relies on default tlb_start_vma() and tlb_end_vma()
 #endif
 
+/*
+ * When an architecture does not provide its own tlb_flush() implementation
+ * but does have a reasonably efficient flush_vma_range() implementation
+ * use that.
+ */
 static inline void tlb_flush(struct mmu_gather *tlb)
 {
 	if (tlb->fullmm || tlb->need_flush_all) {
@@ -348,6 +385,8 @@ tlb_update_vma_flags(struct mmu_gather *
 
 #endif
 
+#endif /* CONFIG_MMU_GATHER_NO_RANGE */
+
 static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	if (!tlb->end)


