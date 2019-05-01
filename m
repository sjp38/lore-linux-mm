Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 319D8C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 20:24:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E06ED20866
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 20:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="p1KwXVza"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E06ED20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DBBA6B0005; Wed,  1 May 2019 16:24:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78A946B0006; Wed,  1 May 2019 16:24:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6791D6B0007; Wed,  1 May 2019 16:24:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D78B6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 16:24:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z7so81671pgc.1
        for <linux-mm@kvack.org>; Wed, 01 May 2019 13:24:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=/F6+zG6ES9qLhEiog6ySDXGDMtFDsKKrg+VMkkXC554=;
        b=k7A2eMVHR+Npz6PWgPTjQ14DhJ8aFOlVHioN5G1PWhYHZpduLN1Iqht7VrxiVFNB/Q
         3f3FoXJAuCT7rxzyopFeQzq8A3V8tpl+TudWIDcjLXk3T/Ld/P1ixKkz7UMQIFXPXClR
         NutbYPZLy0B3t+4bmgU/kE4d1AWz+BntBeL/R24pjK1iyJhhvyJ/61YoTAKo0m0nQ0zR
         KFtJdyXyUoSRXkuwwgRq1QdkXRAt1IWgcmRu4PwMcjobidKPaPH8v/KGO8OP344yyEFs
         Lza3beg5ACOwcAie3yXt3srm+8E00a07B4u08vv51zLvJI64MEZm/bHwHkD4Zm1dDIjq
         KS9g==
X-Gm-Message-State: APjAAAXzWUs6MNksMRBq12DtuaL1GObUFafQweG2BLvI9qAQLiP26DXD
	g87cfV0nLhOcyDZ8la2g34Vz+y3e/5wJFsfREzqpkl3qGOwPkT82A0TnWKeLYSvSoWGVUhkAZO3
	82z72ncrigVL8iGqKZuizyVuBInQhEg4Nv9NNMoIXhaFSQbD5cCf1/lWWNZhERMqgTw==
X-Received: by 2002:a63:f115:: with SMTP id f21mr74950023pgi.65.1556742275649;
        Wed, 01 May 2019 13:24:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl/h5u3Z8RbVRPMq8rLVjpuUAhhCNIRXM7VH1c8jJ7QqnwoO5INVOcRhQT5A6O6wAEqSzi
X-Received: by 2002:a63:f115:: with SMTP id f21mr74949978pgi.65.1556742274849;
        Wed, 01 May 2019 13:24:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556742274; cv=none;
        d=google.com; s=arc-20160816;
        b=AWXGKlrMZyZ/8r9mXw0zu81XSCIrbr5KFQBkoBtFLOydW5is5DP7i3wiEPyQgj7Kkg
         NLHGbBkeT5YTDnbDOE/ONYOv/OmvdizRfhvK1rSGCo79GFonYXeQDSJdBFNQkhsuzHKM
         ehtCheh5u3tx8PT0ByBO/AJQjb8KZcbQ75MEcC+9oygB7a+7fIAlc/IysfavsSMDrhhX
         78a4wTceYAuifCd+6LaXd2F7yK2FyqmNF/lolXyeR5D/2XeI7mgGQ11P/wkDjk4HVNo5
         HKeuOoNNYGh2rQHX77F8g60JN2BPeTuSvV6Jfi2ye9AgABU8turwrL/lxRflMWUqnQ6e
         saYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=/F6+zG6ES9qLhEiog6ySDXGDMtFDsKKrg+VMkkXC554=;
        b=Myp6nB5MvaL+lZx9Ts+woKliZ2l0rJBiOorNVnz/Bq6U57/CB8K2LI7+jb+CkQSdsg
         GA1nARUNHYIJojNjoXFY4SLUzCgui6DimhblXaM2gsxyw8dRKJxADuj6RTV3/2s1vtqw
         aoOIG8a2rBs5Yr9tqp2ynZdd3DTVUCh1Rq+xDQP/I5ddSipG6QVASu3WdzO5FUuq6+9p
         PKSA3NKgVAqPt9APqcILaMi0Qe/HNlH3yrztIPRXvrkled7A7FVRFVkK3X9Gm3gjzGL7
         aNNTIlnJkRzdbukYoQJngerZiVChSLhweg5d2IdFgWNRPyzji6cLDrFL59kv0NZhVi7J
         7r3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=p1KwXVza;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 128si39117224pgc.469.2019.05.01.13.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 13:24:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=p1KwXVza;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:Message-ID:
	Subject:Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=/F6+zG6ES9qLhEiog6ySDXGDMtFDsKKrg+VMkkXC554=; b=p1KwXVzaVZ6h6ngQAa66qbkkop
	Tku0Hb0zx+xGN8O7OWYikToWXwEhahk/obn2aTr9d97E27c54J1lEpeWtIg63RizqSz3lEv8eB3/7
	SVX0GPQWmBEPQjHdJsY/D2a/L1ynMKt6CCxEhp895PA14aekKfcUxoTRgRSrFZ3PQUxh/BCwwmx5n
	bJglcREg5WA9I7v9j/x4OTAc/IYS5e8JrKL5C2TO+FJg29YkZ3hAcagfaUM1emEGEHKZxFWEELJMF
	MIO5Y88pIneGc8/72/NXxkT+K13Zsd5zFIvl9mTWNY7fecxQrxYCpyd4g3LkgDg7w5w17LsnX8/Zs
	qTN1ajHg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLvmL-0001vj-Vc; Wed, 01 May 2019 20:24:33 +0000
Date: Wed, 1 May 2019 13:24:33 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: linux-mm@kvack.org
Subject: compound_head() vs uninitialized struct page poisoning
Message-ID: <20190501202433.GC28500@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Pavel,

This strikes me as wrong:

#define PF_HEAD(page, enforce)  PF_POISONED_CHECK(compound_head(page))

If we hit a page which is poisoned, PAGE_POISON_PATTERN is ~0, so PageTail
is set, and compound_head will return() 0xfff..ffe.  PagePoisoned()
will then try to derefence that pointer and we'll get an oops that isn't
obviously PagePoisoned.

I think this should have been:

#define PF_HEAD(page, enforce)  compound_head(PF_POISONED_CHECK(page))

One could make the argument for double-checking:

#define PF_HEAD(page, enforce)  PF_POISONED_CHECK(compound_head(PF_POISONED_CHECK(page)))

but I think this is overkill; if a tail page is initialised, then there's
no way that its head page should have been uninitialised.

Would a patch something along these lines make sense?  Compile-tested only.

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a4b1a5..1d25d0899854 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -227,16 +227,18 @@ static inline void page_init_poison(struct page *page, size_t size)
 		VM_BUG_ON_PGFLAGS(PagePoisoned(page), page);		\
 		page; })
 #define PF_ANY(page, enforce)	PF_POISONED_CHECK(page)
-#define PF_HEAD(page, enforce)	PF_POISONED_CHECK(compound_head(page))
+#define PF_HEAD(page, enforce)	compound_head(PF_POISONED_CHECK(page))
 #define PF_ONLY_HEAD(page, enforce) ({					\
+		PF_POISONED_CHECK(page);				\
 		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
-		PF_POISONED_CHECK(page); })
+		page; })
 #define PF_NO_TAIL(page, enforce) ({					\
 		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
-		PF_POISONED_CHECK(compound_head(page)); })
+		compound_head(PF_POISONED_CHECK(page)); })
 #define PF_NO_COMPOUND(page, enforce) ({				\
+		PF_POISONED_CHECK(page); 				\
 		VM_BUG_ON_PGFLAGS(enforce && PageCompound(page), page);	\
-		PF_POISONED_CHECK(page); })
+		page; })
 
 /*
  * Macros to create function definitions for page flags

