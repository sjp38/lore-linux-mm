Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69ADDC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1626A222D9
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="JGI4HvBY";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="7LBY7jFR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1626A222D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 909DE8E001F; Fri, 15 Feb 2019 17:09:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B8CA8E0014; Fri, 15 Feb 2019 17:09:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75A838E001F; Fri, 15 Feb 2019 17:09:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2AB8E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:43 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so10199179qte.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=shCZ1iSGYyBc0QtOy4OOg2NHBqv6Cu7B1aYGh3Lj914=;
        b=RMkKBhbeWv9tprz6tX7v8O3q1cI1AUWFYGzrVBJQvorp2QueyM/j715kmcLPk+QDiJ
         d8WF45crq8HOhToE7cgnJQA3FS04UjDTCoKtZwt7EPTryQ1jZvShbsVDOFVEWyZG6Y5P
         3qwSrOfJ+DlI6pOJ+sceffVkfukiMHQS+gkJy5T6K6cmm08SDrhbQO56n/J3uxpOtdh6
         UiYPtFOwyk+pfkMiAMOlOzoet9rufwFBB/OkBqgNac337LNI+H+lW+PWfpucL2ieU7WR
         YZmyOI5geHqDGhlglx/I7pWoJ4xRe+pPNVh5fU4kSYr5RXFAhlYrf//QllOqrixTlxmZ
         UsUQ==
X-Gm-Message-State: AHQUAuagpE6z1q9HpIfi6ARS8/54nvV20Bp1JN6HcF3ebKYw6bwrewxj
	Lkq2FXCpx8d89fcK9eCQaFxVH20us5xq/bsDbnEr1bvRqa61ZyWEH9xRUvErvlldNzSLjnBrfH4
	Mht/npBRiHUXPN+U+k17N1iG0hHEggovwU5+k9A2zpEwboY7nqkRhicADAbNvzrsvuA==
X-Received: by 2002:a37:c85d:: with SMTP id c90mr8967761qkj.7.1550268583069;
        Fri, 15 Feb 2019 14:09:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYPTUt/f5kUI8G4ZK5I4WL2xDWM8Vcn9LwjP9CxERXJDWmCkHhV1j/AN/n4PHHQvbnkdgpN
X-Received: by 2002:a37:c85d:: with SMTP id c90mr8967736qkj.7.1550268582525;
        Fri, 15 Feb 2019 14:09:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268582; cv=none;
        d=google.com; s=arc-20160816;
        b=ASDSyaw2mojhVUdBBW/WerIP+wv8nH/WCDNDQpYrQYI2lM/SF4pDBzx9HBElobWhF8
         jP6kqLVRr5O31Gs2DK8D8C3O6pJkIKye8gRZzgEfKEsp0k22F0am3SWQqN6JLOz1TmWL
         mHXfySgRGEq2mAUWpsKj8IokrKbaYrdMjIErwM8txVU13sfJZkJWp+ksO4DKJuqjTiJb
         lmmu30pNZT+26YFeC9+WJ7u/GFGDu47sXLqGxwNMiXLpuazasbmaHbXETQldxh/1U/0+
         Op3PfkgaDmMNpmVa/8eoHpxHc8x1sy4Qr4539UASNaW9S+0jlZlPPIFrUcUz1hmQ9vQX
         us6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=shCZ1iSGYyBc0QtOy4OOg2NHBqv6Cu7B1aYGh3Lj914=;
        b=K6ytCaId+bUnNLUsAJieJY7A9f/8k5BMEnQsXv5So7FoN3RzIYz2dYJDufSSzJwyxE
         syaiCQ8mN2xpQfV5HobDOLFidO8hFAoRRA1LgJyuNOqBiK5gKKpfLqXkNni+MvQAFGDW
         7HO25Fp32qJ2UiNoNw+dUeDjk2e3sf/EIvapttRL6sohteR1eegNybC6pVKCr09Iuve5
         mhb08z2bVEr+4oJu9Nc17lNR03SJeAVwtTdJX9ZYBB41D2ffw8TJ/gW8vwpLZF5H3XpL
         dCiJJwybGIVL9LEu1sVDV6tHdfFVaYFUXzXvG5kAu5NdB/NvzEg53fYk46E4B2vbTaa7
         7N6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=JGI4HvBY;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=7LBY7jFR;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id x32si1046628qta.47.2019.02.15.14.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:42 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=JGI4HvBY;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=7LBY7jFR;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id BCE9F32A2;
	Fri, 15 Feb 2019 17:09:40 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:41 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=shCZ1iSGYyBc0
	QtOy4OOg2NHBqv6Cu7B1aYGh3Lj914=; b=JGI4HvBYMMqsmw33Ld98dJrsDB1V9
	eA5YY/5aymibWj3GCK2ZBnkSanqlVNR9KcGe5P7tk9qq5GnUifO5nV4HwD6wMY2O
	TnBHiA/MCr6o2UrwKCfJ1MXqTmx+l5fWXalUKXfMUFPf8VhAtmXWak99iVu9TCmW
	swFXWRKzblPSqu4RhbrqErajr+wH09P7q2M+A+vYMWc8eDq5sHwSy5Nls1Zj9DMU
	pLTQ4BJ+KVGl5yZ2h1mNF+O6I8Yb2HQJBTnPEYWC3PrA8UIOZSuddQGia+euS1EN
	9Y8hsOSKtNwrR0AbF5AB02bfXkPOSlxpwPs9qRxF6A+N1EtUy0T3cNyrw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=shCZ1iSGYyBc0QtOy4OOg2NHBqv6Cu7B1aYGh3Lj914=; b=7LBY7jFR
	gIXY6xtbU8OGarWtbnuAaiWCo3dFDFVQQca/BX7rdBvGPfSMGieDPVc+0gFJYRs9
	Qk8EagwAb2TOX8lPvaaM1i7Zv2S+p9yD+OdQk2WNOEd0l+GygVYDeLLUwRlEcdYK
	dAKMV/snTNYp0A/YZpwmkWpklS6NzZ+ZLx3EwSwkMkDXYga01k5bYx8CD55L0dOW
	QtPUJ1HH95ud2bOfeHcsJTQmQJUqSw/NEOwWic2VVNl9VlbYiE7MTxwwVxpe1bxT
	JMUPhQJNgHOjFbuxVTcIk7lADUi6wNskAEv9KyWnh4lq25C388QU4nqzPjx2Iy5N
	y3GoeqFHYM4kAw==
X-ME-Sender: <xms:pDhnXKrRFL8VIJyRZvlNReKemazB5HYZmnQTlTaoi0qIfVNL28uiFg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehlecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedt
X-ME-Proxy: <xmx:pDhnXEFPihNU3cGKFL_WYX3erm0h-tMJQWfkASfvF-NaGWS2iPktvQ>
    <xmx:pDhnXCs474p7ILWXnQzXTpKEDTtNfZyJN_UBJt23OwcDFkfhLmH3Yg>
    <xmx:pDhnXOVyIkG9OELuH1C1tIRuLgok9u4U-bzZEVTCPBoCYMmKbu-91A>
    <xmx:pDhnXGsmXe54iYI0JhDwdCqtCbIiA5bNFcpnwa76Nop_ymZyuENOKQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id C30E4E4511;
	Fri, 15 Feb 2019 17:09:38 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 28/31] mm: vmstats: add page promotion stats.
Date: Fri, 15 Feb 2019 14:08:53 -0800
Message-Id: <20190215220856.29749-29-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Count all four types of page promotion.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/vm_event_item.h | 4 ++++
 mm/huge_memory.c              | 8 ++++++++
 mm/vmstat.c                   | 4 ++++
 3 files changed, 16 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index df619262b1b4..f352e5cbfc9c 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -81,6 +81,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_SPLIT_PAGE_FAILED,
 		THP_DEFERRED_SPLIT_PAGE,
 		THP_SPLIT_PMD,
+		THP_PROMOTE_PMD,
+		THP_PROMOTE_PAGE,
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 		THP_FAULT_ALLOC_PUD,
 		THP_FAULT_FALLBACK_PUD,
@@ -89,6 +91,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_SPLIT_PUD_PAGE_FAILED,
 		THP_ZERO_PUD_PAGE_ALLOC,
 		THP_ZERO_PUD_PAGE_ALLOC_FAILED,
+		THP_PROMOTE_PUD,
+		THP_PROMOTE_PUD_PAGE,
 #endif
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 67fd1821f4dc..911463c98bcc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -4403,6 +4403,8 @@ int promote_huge_pmd_address(struct vm_area_struct *vma, unsigned long haddr)
 out_unlock:
 	anon_vma_unlock_write(vma->anon_vma);
 out:
+	if (!ret)
+		count_vm_event(THP_PROMOTE_PMD);
 	return ret;
 }
 
@@ -4644,6 +4646,8 @@ int promote_list_to_huge_page(struct page *head, struct list_head *list)
 		put_anon_vma(anon_vma);
 	}
 out:
+	if (!ret)
+		count_vm_event(THP_PROMOTE_PAGE);
 	return ret;
 }
 
@@ -4842,6 +4846,8 @@ int promote_huge_pud_address(struct vm_area_struct *vma, unsigned long haddr)
 out_unlock:
 	anon_vma_unlock_write(vma->anon_vma);
 out:
+	if (!ret)
+		count_vm_event(THP_PROMOTE_PUD);
 	return ret;
 }
 
@@ -5169,6 +5175,8 @@ int promote_list_to_huge_pud_page(struct page *head, struct list_head *list)
 		unlock_page(p);
 		putback_lru_page(p);
 	}
+	if (!ret)
+		count_vm_event(THP_PROMOTE_PUD_PAGE);
 	return ret;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1d185cf748a6..7dd1ff5805ef 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1259,6 +1259,8 @@ const char * const vmstat_text[] = {
 	"thp_split_page_failed",
 	"thp_deferred_split_page",
 	"thp_split_pmd",
+	"thp_promote_pmd",
+	"thp_promote_page",
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 	"thp_fault_alloc_pud",
 	"thp_fault_fallback_pud",
@@ -1267,6 +1269,8 @@ const char * const vmstat_text[] = {
 	"thp_split_pud_page_failed",
 	"thp_zero_pud_page_alloc",
 	"thp_zero_pud_page_alloc_failed",
+	"thp_promote_pud",
+	"thp_promote_pud_page",
 #endif
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
-- 
2.20.1

