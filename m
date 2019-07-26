Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B79EC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:01:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F31FF229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:01:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MENHCNXh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F31FF229F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61A046B0003; Fri, 26 Jul 2019 17:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CB638E0003; Fri, 26 Jul 2019 17:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BA388E0002; Fri, 26 Jul 2019 17:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 159856B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 17:01:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so33739544pgc.19
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 14:01:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=6TrgjAhO6ZAK/fo21aoT5+j5KScnfYl+8cYDqaqsMh4=;
        b=iXUnw5zioewImVyykXDGCJxr2aWZKtZxwtP6QVQrFWk7mVeEeTBPQIxrkd0LPyAahf
         fqY4qNly4vK744oo/5BZGqKQ3O8O/BZva0m+mDL8jGG3vEH3Fft5nBy5e0jjU0P0AbPW
         Ix0KcB+NHcl4JeWK+qI69upeLpFfph/gNYF2h8tJ1lBpCV5fEnG14NiVboz22GFMYC1i
         +nWkOnqoMOaaOONZwbh3C3sbApx94M2sMesL8wEaJf1Z74pO9exPwREjmAp/HRFHQwpQ
         33++5HNEE+BKg01IlnShhBhdwHg+92kRUrfDDqrHtDJMLTuz0a42hWS9FJbWo/7uKydG
         hM4Q==
X-Gm-Message-State: APjAAAUQL0xgTVfmOG+LcOTAlsto/qX/0/1dUstCHLvI7ChlnUSAwj8x
	HfJi70x+2+4sw7yhSi51VOlj+NGL/2aSe16IS/yLYFRJ5Neom8AFLzu3u/u7HBzDi2fsJAZ8k8t
	DsdTpHisFWpZ5MVcyFZPY/KobxjknKl1oG2UkQWh2wTxfrXGvhKg8TNhiE5ZSRSFHBg==
X-Received: by 2002:a62:6344:: with SMTP id x65mr25318807pfb.111.1564174906746;
        Fri, 26 Jul 2019 14:01:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBLMnN9b70bxUMJNEt2BIdUjyPk4GorAhwxzBJCP5AotPVtxZoTkunUPMa0psUS1JgOVJf
X-Received: by 2002:a62:6344:: with SMTP id x65mr25318746pfb.111.1564174905939;
        Fri, 26 Jul 2019 14:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564174905; cv=none;
        d=google.com; s=arc-20160816;
        b=Ej85jY25N3RM1eIgGFNoFpHjXlFhQQ/wixNEEQVtRxiwQ7mxaB+S2brR0KptGIiTyy
         FfBIyq71b202vCTK3E+5+hTjqGUlYMWG/mVrnUrSAiGfXrE/4TJ3PONhXIMe4bKCoo7C
         uBOCmsbt2i/z4dEZ5L1IYbEChgVoogyWTvTUhkleewEADqTa2fhlzWD3z5vKP4A/wj8M
         DD7+evQt78Wx2OvzpMOCehGPUWFZwjI4po5Q4LKhPmEGwRh7NofioD5D0e4LUivZwA4o
         WNpnP20RcuYVO+A+4JobZEAs57+ePpyEASkf7LwmX0WoJE8dIRmSLQw1tbGUz0jhMoOg
         1GTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=6TrgjAhO6ZAK/fo21aoT5+j5KScnfYl+8cYDqaqsMh4=;
        b=tGyzx3SHFNxWEhP87CdytYuZctcf1VdP3x9LaaSwEQImmgQx1Akr93KdaPuMwlJCfv
         dQYnQkTdJ5/IdBCsN3CZJxmj2kVVYOikHloJI91hRQILx1Jb2Ewdcrg7E2i/DhohO8Xs
         4F6y3CeVUh6O1MmPUZy7eIXVQTkNjlmxaQUwPSAqfKl5UBO+rESTnfnMZHkHQCRDP45y
         lMbf9IWOVWN25wMBott01Quo/5G1r6HCU4C2mNJGEZObK7h4HoN+W/GGhndy2pH8QT3G
         DIx4d4pT4f/h6HzwKpPbZACb96laVetb7/if/0H+I22F25jg0R0AXN04R3YwQxfLVfkT
         +mYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MENHCNXh;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w6si23127174pfn.84.2019.07.26.14.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 14:01:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MENHCNXh;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=6TrgjAhO6ZAK/fo21aoT5+j5KScnfYl+8cYDqaqsMh4=; b=MENHCNXh0hqrsob3hlt+d00qB
	nfM0JF+kMfPyZ5JVbURsrT+IVJrWngwU2T0bzJzlBAOmHpmNPhPDLGxVieIunJ8eThrCQgvz/CwFN
	M/yUNGYh+qJ5uT2fUnW4/tKEhBcdLdw1/o93sEeLu8SJChCmiIiTvvKKVCqq13qEaEvrYt4rQbgy9
	7UXzudt5YD493nTF0gKFsJi9oreMJonw3YEv0guLzQAPpv7sSGVoqkb/E6lktGyYuNPpmvhFFgEWk
	uapStiHDA/YuvnuIX40VmND7sse71J+dVQo1Swg6gkVmhhNDuZIfjjipfwaJhvgPkt3GGXZuEGlZa
	Ygd4oHFBg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hr7LT-0006HR-3X; Fri, 26 Jul 2019 21:01:43 +0000
From: Matthew Wilcox <willy@infradead.org>
To: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jeff Layton <jlayton@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Henriques <lhenriques@suse.com>,
	Christoph Hellwig <hch@lst.de>,
	Carlos Maiolino <cmaiolino@redhat.com>
Subject: [PATCH] mm: Make kvfree safe to call
Date: Fri, 26 Jul 2019 14:01:37 -0700
Message-Id: <20190726210137.23395-1-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Since vfree() can sleep, calling kvfree() from contexts where sleeping
is not permitted (eg holding a spinlock) is a bit of a lottery whether
it'll work.  Introduce kvfree_safe() for situations where we know we can
sleep, but make kvfree() safe by default.

Reported-by: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Luis Henriques <lhenriques@suse.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Carlos Maiolino <cmaiolino@redhat.com>
Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 mm/util.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index bab284d69c8c..992f0332dced 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -470,6 +470,28 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 }
 EXPORT_SYMBOL(kvmalloc_node);
 
+/**
+ * kvfree_fast() - Free memory.
+ * @addr: Pointer to allocated memory.
+ *
+ * kvfree_fast frees memory allocated by any of vmalloc(), kmalloc() or
+ * kvmalloc().  It is slightly more efficient to use kfree() or vfree() if
+ * you are certain that you know which one to use.
+ *
+ * Context: Either preemptible task context or not-NMI interrupt.  Must not
+ * hold a spinlock as it can sleep.
+ */
+void kvfree_fast(const void *addr)
+{
+	might_sleep();
+
+	if (is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
+EXPORT_SYMBOL(kvfree_fast);
+
 /**
  * kvfree() - Free memory.
  * @addr: Pointer to allocated memory.
@@ -478,12 +500,12 @@ EXPORT_SYMBOL(kvmalloc_node);
  * It is slightly more efficient to use kfree() or vfree() if you are certain
  * that you know which one to use.
  *
- * Context: Either preemptible task context or not-NMI interrupt.
+ * Context: Any context except NMI.
  */
 void kvfree(const void *addr)
 {
 	if (is_vmalloc_addr(addr))
-		vfree(addr);
+		vfree_atomic(addr);
 	else
 		kfree(addr);
 }
-- 
2.20.1

