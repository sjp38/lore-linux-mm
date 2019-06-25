Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E787FC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A98A220656
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Keh2XF04"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A98A220656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAB3A8E0008; Tue, 25 Jun 2019 10:37:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D62478E0002; Tue, 25 Jun 2019 10:37:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C20FA8E0008; Tue, 25 Jun 2019 10:37:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8763F8E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:37:58 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so9297819pla.18
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:37:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NpWcgZzp3PVAHx6KOALQeB51c2SoNPG0lnYZA6y2f1k=;
        b=ZDz+izpTnM9+0ylSnAwUZm6M2S1hZvfeisOkVKJyUPpiEdz3GdK3KXn3hbPixGwxUI
         ej7UFGa9p+kZSlT2+G45n5SHTWyJMWQpeY34OaSANKh3DNwSKECb8ZSN5/UKLDmyUd9E
         yDcV6hQhzyHg8PalqRnXzU3ghkad297dEGYfxtGDiFKGTqefn3hAUJK5KqnnUmd787R3
         rdTSuy7sxYUKVKOjC30A+UkW19aPDpyyYZi6z6h467xgYfZLj1HNHKdaZmO+3ER2QqzD
         OMHnc0alriNhnCL7HU4oF+HWu+877sux5XKKbrjs4uNUjY4cqkx7Qys6h6yyZeq++/C4
         sHFg==
X-Gm-Message-State: APjAAAViYzvDbMISUGqdjYlFwtY4zg2QuE/C4WPXiIlfYNORALJ6cLmd
	Bx2rG+1olW+Hqw6Y1ZkCANpthBEFO+tUmabgaMqeeEEarwDTXr0idkQP466W2CZHFT+TfLHfkk1
	cbVM8Crjx6UCljURllQVZc5ptI3rIorDYUWeaSi9OvqxgGe10MABMb12MyXlTf+E=
X-Received: by 2002:a63:2ad5:: with SMTP id q204mr34586535pgq.140.1561473478058;
        Tue, 25 Jun 2019 07:37:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMZVno4g0bcJbOymzyqQzLBLNphZ8rhBb9vHgWIR/KEz8FNpzSfCvZXIZ4sPXyKg3RAkqw
X-Received: by 2002:a63:2ad5:: with SMTP id q204mr34586478pgq.140.1561473477339;
        Tue, 25 Jun 2019 07:37:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473477; cv=none;
        d=google.com; s=arc-20160816;
        b=NnQ33YrKUKSjemRf5AiWV1rA/vP+SxqW1vfGIVm2bJjUoyjv9ZAIMxmYTVl+dn1ncI
         /Qh+V3FvrCbJWJLYFho7nGQOm3okg5DVcnfZjyfbamiQd1GnuVQoTQeznNJDLeYaY4n1
         h/ltP/KQA9PihOrACJZm8O0ziRn5OafzSS7DGWCrk6HiFmklN3U8Ahx9VrL6rQD14g9a
         hhyjejT1X0Y8CSp6C9rV8TFyRM46aVNsSmcGZfU6cJ9EjHzcnnZp8H6zHWvywpKeT+nr
         xZoHPqHfdYpqqHp+SDbKW3t5T397VxuYJeWTk4uVrXClv80rccho4/Is7WdkIN727Vlh
         ZU2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NpWcgZzp3PVAHx6KOALQeB51c2SoNPG0lnYZA6y2f1k=;
        b=NNqKPrq/L47F//1xab+dHJsLZgYOzfV8EHG8s1W0TqkU1nFoLb5ZfoKzid8iVXx/sr
         npHGDTj/4CA/TRnhCyfgnSO3AsrOlibgYVOdw5E2TMX1kLflllJmXJbCuFDvm6rQU6p2
         YR7RvmSCWHjRc8ebxXVhVxVZmc0FiqnlqzLesmbBVfDTCEfTA8MH7UVUEJgacuinRK1s
         AnQLL13OWX5klHp8i5ud+m3seDzngPPrkSEC87dZH85x+N48bl17Yov3WCgvoB75Cea1
         96G3HcTDzGZ4lbCD7InXXbelHrvfT6mF8eFX8ixiWu9MI3NWp0/KPx/3kKDxPRQ+HMOm
         9R6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Keh2XF04;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a4si459032plm.209.2019.06.25.07.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:37:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Keh2XF04;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=NpWcgZzp3PVAHx6KOALQeB51c2SoNPG0lnYZA6y2f1k=; b=Keh2XF04rYJBlmYFK/V1pjf4+Z
	GacaiK2qKGFfFq0VOKJups+BoxTxOncbwrZf0/xWJuKoUiWG4YeYFfpr3SiYPoJC8U/dbGoUDXmyh
	XIdVBUnEB0YY3qxphb4Xtcu0GQlXcjQew7pmLqpaNn/kXHgTEASgSMLqIJh3MhS35P0Za/HGZyMjr
	bx4eNn/zmrRqq4U02dtZoX8zEDxCVGc2XmtVSGuAvMVp5bGINxS2F59woTRzV/RuoNyz1ePLP0hEg
	cn6P9VkulgFCyClnJ775lejevCQsT9Y4SEwxzCPEQqFOHpoNw4Qxgy0KbynZrQNRTYqWNNv0GXvl9
	Itq0FMAg==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZh-0007z1-O1; Tue, 25 Jun 2019 14:37:34 +0000
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
Subject: [PATCH 05/16] sh: add the missing pud_page definition
Date: Tue, 25 Jun 2019 16:37:04 +0200
Message-Id: <20190625143715.1689-6-hch@lst.de>
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

sh only had pud_page_vaddr, but not pud_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sh/include/asm/pgtable-3level.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 7d8587eb65ff..3c7ff20f3f94 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -37,6 +37,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 {
 	return pud_val(pud);
 }
+#define pud_page(pud)		pfn_to_page(pud_pfn(pud))
 
 #define pmd_index(address)	(((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
-- 
2.20.1

