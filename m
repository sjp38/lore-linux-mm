Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C9FEC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D36002146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="xMiQs30T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D36002146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 976E18E0011; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92AEF8E000F; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 708CC8E0011; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1428E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p21so3583227itb.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=IUo7iBIklHrRHP8ftZwwZUgsCS7kaKlA6dnR39QGIyc=;
        b=ZTCpMNRjlrxCDkelsrLvfs0kJEI74ZgjO+bgrg31kclLb1GHUGj8aiCFI//vE+FSuY
         B3n1cn5at4eml7mRTRSBUzI7na5sJE4jIbUo2BqAbi7VBifA9+5CyBjvxnxsIO6Qxd0e
         uoeS/Y2Kd/zNbApQodIl3Gum8iAL4LWVEhUBh+vNkcpiY/LOVmQUD68hT9LHi/Sk+EOs
         I1pbPNd9kNHQbsjgE4OupI7ebUcUimz56Wvwi3k19HtNCCij2TeEFjetLfJEDxz+wDzZ
         lNhR/D5OXCm0NktuYLieqXJt4r1jnfnQEs2Tpl7QljBsTr4huVC0NaDV71DMDCFXwzCk
         7EmA==
X-Gm-Message-State: AHQUAub1dtwdiQ43SD50KAoU/fMx7vO1LhCsic8TaSVbrrNwXtktePR2
	unHe7+Dwp022Mfq/UAe9xo179BRXDr/GorqBKmwp9Vzeu8G9P6yb/xfjloSfnBX5ybVZNKHl5jx
	Xvhvx+CazHWdraQaSg7t6chF+xDurUrHvd4GA5mI4PCwNVKclHQKBSgxmWYMfCxwjBQ==
X-Received: by 2002:a02:9b31:: with SMTP id o46mr14593575jak.93.1550572386031;
        Tue, 19 Feb 2019 02:33:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6LIf4Ze/VgyEVM8nl9pKgmZ594s/sgTS97Wu7iktUD5FWfLS4vDpvQu9NdTyaXAS7LKNH
X-Received: by 2002:a02:9b31:: with SMTP id o46mr14593558jak.93.1550572385473;
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572385; cv=none;
        d=google.com; s=arc-20160816;
        b=ZEC35XneI5AU8iQcxLPPghjTlP86o/EsOg0+L6pkDstHXkstHQBfH2srSwzwLPwN6D
         hsYbtgwG9FV9Wm4RBU6MhA/+YZjZH4ncCdacesniXiBCVTlU8RdV28o172y53K7S1fTX
         ZtwiL9/KCxTe0AEz6ZMZF0TTn0wdWl2yNhWLQWTgX3u0uH0AVQtuwRdqdkZcys5MNVJ7
         EGkV+xRUIlHiGdOefGIlgfJFG59Jret9GWXNx8k4EX9XISx5R6Rx9uvwD9XT0keCj5Rs
         c9qXaaFQ7cwLtxE6nZEpNfHXjRQx6SDBnLcJt3I1MKv4IZRmMs4FW8ww8dffsAoOZh+k
         6G3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=IUo7iBIklHrRHP8ftZwwZUgsCS7kaKlA6dnR39QGIyc=;
        b=fK/YaS4gbMv9Qv0aPcizfugYcCIgcqcUpqz/3ed6oJbo3zPbTuOxozeQN712d6/MUt
         ucicPc+w2b7Grz6MFqZkPv5dxTBxTe3l/W7JTT5vlHuyxpR4adGf8g89hDXPhwtff9cu
         Uv4H7Y122YTmXPwhfxuIRZY69AIY+ToK6lw0gaGAXDNr9RgncREcFFmTuzdgkqB/0RBC
         d/8RkcI5HWa0bq2ajQCY524zbBZYVUZDmfIHEJE7JMI3CVBJkr4tLRVy2GeeB/TGYzWX
         JrL02bpR6fwR7nTfQLTW9cv/VqGWGdZycTxkTZGMgWto0MobiXiGcx4NRRYIM1kgbwm4
         3omA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xMiQs30T;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c100si1069451itd.11.2019.02.19.02.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=xMiQs30T;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=IUo7iBIklHrRHP8ftZwwZUgsCS7kaKlA6dnR39QGIyc=; b=xMiQs30TXekYleqbvtIXDNUy7T
	6A7LAb2RgsJ17QxyScnexR01d39zsp9pTEIs4AbdQvkcTYIq8fjaaRFx/O7Jd77Ljz2ml11nuAUpX
	j8UfFPZrbOaAMpNsOp1qAP3bGXSTOhX9gfaS8kdtl4AEybZo01bo93kUAfggflrXVG44He/yu9/sM
	E0QaaPwN7gWHOOHUfxjkNlF6c+0j+ZKmFiV+909+ylcMTaUESjRX9+lrQKTNL+y1r0JaKnAa0Uxgp
	Nz2L25LAIeNF6yGwBufvGc76n5CPuyJoNUBe/+f/zDfxSEZucnoQWl4opbl8Y6xtgGeSahKXdUqq8
	JwnnNsqg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hp-0000dy-9K; Tue, 19 Feb 2019 10:32:53 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 7CE76285205A3; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.810881730@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:32:04 +0100
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
Subject: [PATCH v6 16/18] asm-generic/tlb: Remove HAVE_GENERIC_MMU_GATHER
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since all architectures are now using it, it is redundant.

Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |    1 -
 mm/mmu_gather.c           |    4 ----
 2 files changed, 5 deletions(-)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -142,7 +142,6 @@
  *
  *  Use this if your architecture lacks an efficient flush_tlb_range().
  */
-#define HAVE_GENERIC_MMU_GATHER
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 /*
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -11,8 +11,6 @@
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 
-#ifdef HAVE_GENERIC_MMU_GATHER
-
 #ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
 
 static bool tlb_next_batch(struct mmu_gather *tlb)
@@ -109,8 +107,6 @@ void tlb_flush_mmu(struct mmu_gather *tl
 	tlb_flush_mmu_free(tlb);
 }
 
-#endif /* HAVE_GENERIC_MMU_GATHER */
-
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 
 /*


