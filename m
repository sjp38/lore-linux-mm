Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D8A4C10F05
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 069EF218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 069EF218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FD496B026C; Sat, 23 Mar 2019 00:45:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 934FE6B026E; Sat, 23 Mar 2019 00:45:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AE936B026F; Sat, 23 Mar 2019 00:45:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD266B026C
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a72so4229358pfj.19
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Ipb+kryOclOsdI7bZtqHOlDm7ELTlnRdbAsmhRsy3rE=;
        b=e1GEyIyjjHIGIji7el30kwr9m04ymlx0EhF95l65T4WBS+NBWecEv6WY5U8n2jaVDn
         XKBLg714wmEmlK6vOI1YCn59G3Rcfv8ULMJUa0XJfphGVeGFiFTX3ZapB8tbHBbh5xUP
         lw62GGOg4H4gpj+bncjbiHoKYLRoo9sR8wVjr2hKOMlfdRMekNbC2E0VOnz/xhl/SZ+q
         yBFDEjZzt7bGUXVBRTltD2wq3YYT49hl/H42tCdeJovsmywWtAAj90rK+46EeUpr0UcF
         JYVnt2DUNjB+H3xcpR24PiWetR6laMjLuTIjS9iDQJrtlEeviM1WckVx78X+qO9Xmab6
         zYeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWVFw+Tz0imFzV4+SoX2jh3bnHZMifVYdDXCdGw1NeuKBvRhtCI
	MdzOB9Fj7FbCiK+t4WFQ8+rfJs4z/+koHg8YemcKGiiKjTd4HcpHCVrNw8odXmD1X/RJvqLB9We
	6Hr0QreuvBAuKEM4rE4r6e/0I06fStJZ2LAhLsjCrApyeftrnKuUqFtUVSe1jlIkcSA==
X-Received: by 2002:a17:902:a413:: with SMTP id p19mr13386851plq.337.1553316337810;
        Fri, 22 Mar 2019 21:45:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJrHlQJkNwLjAH2jY6C2sv0VVICYermC2j2dzgNIuRRbMXJ+BlXtQQB3ccVCtqhkaAx2Ml
X-Received: by 2002:a17:902:a413:: with SMTP id p19mr13386780plq.337.1553316336557;
        Fri, 22 Mar 2019 21:45:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316336; cv=none;
        d=google.com; s=arc-20160816;
        b=Q8z0exUcvzez9a34T9iUY6cyETNp8Rm5XzcaymZGNYZZkmRFPOa/HUWFgrryY2ZUSP
         l072VbUfitj3AuSY+JRWoliYWc7JQvp+hiCU3U24I2GVNC2jk5lnnsrrgfTrO5r1D75C
         /ZkIGuaqp0wdq5EuS5zvanlj+N1vZG85tDGJrlNu0bD4xYt9EN8mXoHzn4telKhAqj/6
         Yy3ua7g4MytWhtI/gH6WmNDHT12vjCnDN1bq34Df4d1Fp8NVqOO2hdr6pvtGcd4aFoZY
         g6JIdf1TtB06FNUIR+xX/J6xOFrAX9yRZsb5O6mjlpuzg/HKV9/bPillh+kPZjXEtOtI
         FOhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Ipb+kryOclOsdI7bZtqHOlDm7ELTlnRdbAsmhRsy3rE=;
        b=vOfISO+bnASQGNBd0wW2Tqby3bv5P+2GoRs6TK1FRvr5DjblQQV7KycILbAGixTv5T
         VCvRjf0VajU5FTOE0fIYolR2x8hK3ctKLipIrBn93/xbmIkSPGE/4z4+NO6t9Uf6kbJR
         03ALTEMgOT5WJEtWuiKoxRVjnU+YSRYSJha9uhaRQElrrHIdmAzg63nLhQVMe5JrJ8Py
         7LzPwB1DV9eKzNxNU3f2qbkmZknc8PJy1/2t74NIroCe6U4QVj6eBZsTPwIpjYwWrO6m
         EK2zARwMziU+aLGzimKxw6j98ZauDcYPYti+OLlf24lus3tp9RqH7LVXUppkZ7+XdHNw
         MIzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id h35si9138722plb.180.2019.03.22.21.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04389;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNPuxAM_1553316293)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 23 Mar 2019 12:45:02 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/10] mm: numa: promote pages to DRAM when it is accessed twice
Date: Sat, 23 Mar 2019 12:44:29 +0800
Message-Id: <1553316275-21985-5-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

NUMA balancing would promote the pages to DRAM once it is accessed, but
it might be just one off access.  To reduce migration thrashing and
memory bandwidth pressure, introduce PG_promote flag to mark promote
candidate.  The page will be promoted to DRAM when it is accessed twice.
This might be a good way to filter out those one-off access pages.

PG_promote flag will be inherited by tail pages when THP gets split.
But, it will not be copied to the new page once the migration is done.

This approach is not definitely the optimal one to distinguish the
hot or cold pages.  It may need much more sophisticated algorithm to
distinguish hot or cold pages accurately.  Kernel may be not the good
place to implement such algorithm considering the complexity and potential
overhead.  But, kernel may still need such capability.

With NUMA balancing the whole workingset of the process may end up being
promoted to DRAM finally.  It depends on the page reclaim to demote
inactive pages to PMEM implemented by the following patch.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/page-flags.h     |  4 ++++
 include/trace/events/mmflags.h |  3 ++-
 mm/huge_memory.c               | 10 ++++++++++
 mm/memory.c                    |  8 ++++++++
 4 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a..2d53166 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -131,6 +131,7 @@ enum pageflags {
 	PG_young,
 	PG_idle,
 #endif
+	PG_promote,		/* Promote candidate for NUMA balancing */
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -348,6 +349,9 @@ static inline void page_init_poison(struct page *page, size_t size)
 PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
 	TESTCLEARFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
 
+PAGEFLAG(Promote, promote, PF_ANY) __SETPAGEFLAG(Promote, promote, PF_ANY)
+	__CLEARPAGEFLAG(Promote, promote, PF_ANY)
+
 /*
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a1675d4..f13c2a1 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -100,7 +100,8 @@
 	{1UL << PG_mappedtodisk,	"mappedtodisk"	},		\
 	{1UL << PG_reclaim,		"reclaim"	},		\
 	{1UL << PG_swapbacked,		"swapbacked"	},		\
-	{1UL << PG_unevictable,		"unevictable"	}		\
+	{1UL << PG_unevictable,		"unevictable"	},		\
+	{1UL << PG_promote,		"promote"	}		\
 IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 404acdc..8268a3c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1589,6 +1589,15 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 					      haddr + HPAGE_PMD_SIZE);
 	}
 
+	/* Promote page to DRAM when referenced twice */
+	if (!(node_isset(page_nid, def_alloc_nodemask)) &&
+	    !PagePromote(page)) {
+		SetPagePromote(page);
+		put_page(page);
+		page_nid = -1;
+		goto clear_pmdnuma;
+	}
+
 	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and access rights restored.
@@ -2396,6 +2405,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_workingset) |
 			 (1L << PG_locked) |
 			 (1L << PG_unevictable) |
+			 (1L << PG_promote) |
 			 (1L << PG_dirty)));
 
 	/* ->mapping in first tail page is compound_mapcount */
diff --git a/mm/memory.c b/mm/memory.c
index 47fe250..2494c11 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3680,6 +3680,14 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 		goto out;
 	}
 
+	/* Promote the non-DRAM page when it is referenced twice */
+	if (!(node_isset(page_nid, def_alloc_nodemask)) &&
+	    !PagePromote(page)) {
+		SetPagePromote(page);
+		put_page(page);
+		goto out;
+	}
+
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, vma, target_nid);
 	if (migrated) {
-- 
1.8.3.1

