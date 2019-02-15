Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27158C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF1E5222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="H7QS7MH5";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="COCQw14/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF1E5222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E50508E0004; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9EF88E000B; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A67148E0004; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70B378E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:14 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id q15so9395342qki.14
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=YB7G8kYGI8bRnBYacSSGAZcz9slxKgMGLPhOLzrEt8M=;
        b=ujzSxHTHRmuezParrY/8ugFUuqnN4Vi+6R1YIDkxOYE6sRgt8h58hu4ZX6U0m3L9ys
         W+dudlBzJ5AnDPFMiirj7Zk0LWUM/QiSSCXb2/NJGrjUmeyZv8ZuCEminKtvspKRaisj
         DwmK7UhXDvOvv+5DtjG1MGzO5JaPFbYkV+oyUOwbqcD20PuZ5xDhis7WrZHA4w/W1Qjq
         +lN073waW0fBT52B9yrBRknrsVljqZM4zSOCKfWn0ltF+Q1XbpDv34fhQtGx9ozub8a1
         2Kqd7Z6gsrmdOKSPFQz0cR9tWPGijyK1+ou5r3ECYBWRNmqiBYNet6dLgj2s9tPdsxXL
         bjQA==
X-Gm-Message-State: AHQUAub2wjEk3bTGGQ+ef7GBkundXAl+uiOmqhO8Zj2Elc43vgyDugzp
	M9N0es2vW12+SvHdn0z4JAYG3mr3nRbK/bp9xJVi+qYVPJfg2MYKDIaawLSbF6QZWu7zkhg6jEG
	Kyj5GSE7vTm4S6bIgLMNaxTKbt1EGpJ2vNOS1+K6YmBCoHn7AfOiNka6b5FBdPQUKBA==
X-Received: by 2002:a37:8882:: with SMTP id k124mr8544274qkd.1.1550268554230;
        Fri, 15 Feb 2019 14:09:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZIXq2dVgwNCZwVhRj9MiwSWK9tx9nJXVQ6NjedyIJivU1HuBJdFHSNJ/t9pK/dc9Y8j2Ad
X-Received: by 2002:a37:8882:: with SMTP id k124mr8544241qkd.1.1550268553534;
        Fri, 15 Feb 2019 14:09:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268553; cv=none;
        d=google.com; s=arc-20160816;
        b=HaUjqt4ddYLy79nhIdz02/TZll1m616ev2TDsOZ9fu1TeQY+vaFvXPwapnLf7Cj4ur
         5LMy/PIpdhzcLc6udICRjTvaDCbOt9zgkmNHbrSQkHsuUsWHJ/Afpm1SOYZYinyPgjnR
         491XlF51mqpraDzTWPEaHt3mWxbNXpTeoc22Ji4SnFPaIQzF0D0SO2xk+PJi/RzdNwD6
         SE4LiV765ecNd8CCMywV4DC21Ma+DoEbdOwpqXG6y/wofJTXThfxkBlfHKEokYTWxeHf
         9QgZUrI2RkdsGpC5VSfWLl/S5XZLE+jGm1lt5XtJL5/D4OBACVMU+r9YrbJlxjMr24bQ
         sZSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=YB7G8kYGI8bRnBYacSSGAZcz9slxKgMGLPhOLzrEt8M=;
        b=gTHK7GdGfnlkroIYbOZemv5+8IhXLmPmkPmqUAEOr/E75D+ih+Tc1SKKx23NP0jonD
         meMqmSw4jmyBI+xif3ti+H4XfqH/jKZecBycspZMZ+9D4VN37B0Ft7vYMey5xUjlwpkv
         RPZd7JUSJkPJh2/CDYz2g3kicQAZl6iFfQK9Nhhg8q1Pyo8pnDLZTc2ClR0fCZi75ysA
         819WyOoWXKhmZCQ885pGAwjBELt6VRuHTUO4aagr2e9oajebpb4J04gLZ71gGg565CG0
         y9X37jXhNqQVMUrsd3Yqq/ixcqai8/hG9WvsyGiIDo4yJ7pEHT4WCjD2OKU6SFoYdpKo
         kfhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=H7QS7MH5;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="COCQw14/";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id z18si2925262qti.297.2019.02.15.14.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:13 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=H7QS7MH5;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="COCQw14/";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id B9B8F3299;
	Fri, 15 Feb 2019 17:09:11 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:12 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=YB7G8kYGI8bRn
	BYacSSGAZcz9slxKgMGLPhOLzrEt8M=; b=H7QS7MH59u8xwucq0Z1GHNPXlaQRC
	FHeYGCF1tAMxxXP403wg/3pcu+/Qod0JH10zVxAksBVNfZokneF7fPoWXeikvNBF
	iH6blrzJNdL3s1JvOgRHKdzOfP/PgsVcoIjflgyuzwwG++f7WuSfQUXjy9KO5GND
	WV0oWxdRZqahNjyVEPk0miHYhtF9HcRWQuQ1uxn+filUOUAf24WLtoBGwqU5+IHv
	bGptQory6nGB3qjJGbu30AcQ94zmv4OegwV/mOo5oO7imkgnh6W/yVzHlthZ7Qij
	l+Yn6h5uDHJDeuUM0kJZJdlQ3LiBkTGODdWgnaKTvxpQ2Tgc0KP/xAhrw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=YB7G8kYGI8bRnBYacSSGAZcz9slxKgMGLPhOLzrEt8M=; b=COCQw14/
	OnB2gMlAGBaEv2afOVWzIFuk76BGlb4G/8ob3jmC8kdWDb3wM/OULj/7wB2jRCRl
	DWsRFMwU71vAmreUChlz7cUU8S+4CYjlwNnXBRS/B/9agl6rlHaF72VmKkOtSIUi
	ca6bFjH0vbxC+jHeE5+alLiihoAMbp0WnVysOCB71tJx2l86dXNFbq4NnB1rHfnz
	+0RwROQ4V/xM1lKxz3zE1SyW5lZvMDJKjJQVIjIuLIQqihCEcNHAoVEKgnuI/0pZ
	chLn0SG84GIKVqYSCApaFt2y5ulkKk7q0f4OA9gWEf7DkuMUpJdSfe7IlX5lm0m7
	z4JhtXzq2GAmEw==
X-ME-Sender: <xms:hzhnXL69dlxmbrI0m-3ynuD-L0T_lazgElZ9QPDNlOYUJpRwicB9cA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeeh
X-ME-Proxy: <xmx:hzhnXHPGmE_54ehQ-iGCAsWDrmx7-rGWr1beaU4hfP-RzIfOhcWoAA>
    <xmx:hzhnXIdG6MMGeTPFrAQQyrVmbufoybYBS7ixtxxIF82DFQUI9eJ54A>
    <xmx:hzhnXJfys44KqfuFyUXK5plLS1mgiUfijyZv_Cl5DXm1e72rOLLBIg>
    <xmx:hzhnXPDoRW4G0LxQxWr34JfiqChaalxhp-aIEVl1mRYAp9uc9WUsyg>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id C8156E4680;
	Fri, 15 Feb 2019 17:09:09 -0500 (EST)
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
Subject: [RFC PATCH 07/31] mm: deallocate pages with order > MAX_ORDER.
Date: Fri, 15 Feb 2019 14:08:32 -0800
Message-Id: <20190215220856.29749-8-zi.yan@sent.com>
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

When MAX_ORDER is not set to allocate 1GB pages and 1GB THPs are created
from in-place promotion, we need this to properly free 1GB THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/page_alloc.c | 36 ++++++++++++++++++++++++++++++------
 1 file changed, 30 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9ba2cdc320f2..cfa99bb54bd6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1287,6 +1287,24 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
 	}
 }
 
+static void destroy_compound_gigantic_page(struct page *page,
+					unsigned int order)
+{
+	int i;
+	int nr_pages = 1 << order;
+	struct page *p = page + 1;
+
+	atomic_set(compound_mapcount_ptr(page), 0);
+	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
+		clear_compound_head(p);
+		set_page_refcounted(p);
+	}
+
+	set_compound_order(page, 0);
+	__ClearPageHead(page);
+	set_page_refcounted(page);
+}
+
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
@@ -1296,11 +1314,16 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	if (!free_pages_prepare(page, order, true))
 		return;
 
-	migratetype = get_pfnblock_migratetype(page, pfn);
-	local_irq_save(flags);
-	__count_vm_events(PGFREE, 1 << order);
-	free_one_page(page_zone(page), page, pfn, order, migratetype);
-	local_irq_restore(flags);
+	if (order > MAX_ORDER) {
+		destroy_compound_gigantic_page(page, order);
+		free_contig_range(page_to_pfn(page), 1 << order);
+	} else {
+		migratetype = get_pfnblock_migratetype(page, pfn);
+		local_irq_save(flags);
+		__count_vm_events(PGFREE, 1 << order);
+		free_one_page(page_zone(page), page, pfn, order, migratetype);
+		local_irq_restore(flags);
+	}
 }
 
 static void __init __free_pages_boot_core(struct page *page, unsigned int order)
@@ -8281,6 +8304,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	return ret;
 }
 
+#endif
+
 void free_contig_range(unsigned long pfn, unsigned nr_pages)
 {
 	unsigned int count = 0;
@@ -8293,7 +8318,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 	}
 	WARN(count != 0, "%d pages are still in use!\n", count);
 }
-#endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
-- 
2.20.1

