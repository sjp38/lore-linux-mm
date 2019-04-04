Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39E3BC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF35C20820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="uNeajQ0V";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="st5240RR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF35C20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5EDC6B0269; Wed,  3 Apr 2019 22:01:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E393B6B026A; Wed,  3 Apr 2019 22:01:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8B766B026B; Wed,  3 Apr 2019 22:01:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 934836B0269
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:22 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w124so928507qkb.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=lg2BrG+7fYw7q7Cq2sx/23jUXOHpzN8JkKb4HEWmLsw=;
        b=nlR1DenPUhQv022O1YngUtclhQp1xTUL9x/o7QHC3cxEWY5xD/7Golvb/p1Z6bNi+s
         bnuR3aHP1Rfq2puXQgYigRXiywm6L6lITR8CyMgL0Gk50x8FUYD2LOoZfulvc3BkrX0i
         L9FomuzHzvRTj8MtychLgXFpHeGZTu4gmUklqt/PTD31xhTkLA6TQ8K6VTmkHisdipsy
         VgWKgWOC9OQMveDbibZsslZd+T217nGcVEQRP5dVqldqYoGX8Nt5/GEVp/j7FMto7uIZ
         5+arFxd8TCxeCOdO5mVJx3lbJ/UPmKsN7vuUfp04T1k5+VkxFEXKRE9BiXFKfJJsmzjW
         9jVQ==
X-Gm-Message-State: APjAAAWfp+nuIhdHt0lBiJGsumnjO/+kbrq82ksEPDihJkpaHWpuwPqn
	qXQ3sbNM3qr3UV4H28tw5yR07FiXA0vY6bwZAMHBBh/Kw0NSDJ6eKIpxESyko0zXnXkFNQdZFOt
	PzPSaH5OJedqrdvrKWlLje7LZX4zpJuYjPE41nNANOzamA/xWSQC4CJ+aFVAZ83b2Lg==
X-Received: by 2002:a37:b444:: with SMTP id d65mr2887097qkf.125.1554343282332;
        Wed, 03 Apr 2019 19:01:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDFyUIUBttcSz6zGtGZI7XgsFjJJ+YVkAAlUDFF9jsrmv3xxi2RIRLwahdGRZWNlgNkb7s
X-Received: by 2002:a37:b444:: with SMTP id d65mr2887058qkf.125.1554343281735;
        Wed, 03 Apr 2019 19:01:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343281; cv=none;
        d=google.com; s=arc-20160816;
        b=g0Iq0IwhNm8BBhPVK1A+bhrB1BLvyED7UPnqfL0nQywhQ7xBQsFQDS0nelm22/NdoP
         ktr88E9WTj5iMptuJJjWNYAN1rMPGXVEc68MtK7rbN0QoBXnV6Wp3Ock5Jg0gNnmkl7C
         SJW4llsmBph0mB6ZnlvgdXNtn6RL9v0CZYp3KvJVHjCpyMOS9tOnQ+ueCOvModZtG9d+
         tRTaBE8Nw8tqwC/vRm43wmPDuxgsvnZDFxviNCkSUNkebBk3CipC7vvVgnK4DAWq5Ukd
         6PeCycAfSyZOK4wK2VFfMKg0Fdg3yDKtOJvmtS6UpckBebDAL3tZKI4elaCIwdcbSW36
         oZLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=lg2BrG+7fYw7q7Cq2sx/23jUXOHpzN8JkKb4HEWmLsw=;
        b=gAllh3ZnzxyMuTjG2URZ7AgDo7d0HnIYcf0WnLvMpwk/apjd49qKJDvz/JLRJQ7PVr
         4ZgXOsgGeNXxttbII+PFkszmUAnCKf4T8o/HtlVgb5sAKCS2M3wWxDzcvcwpKX91ZS1r
         F5pTnlTOk8UW4+7XNUqs/ZKtYu+9It+E/nDkFcvnovF0BhJtOF3Yhoec4B6gNAhmoPav
         DLoE37Y64Jy525FNJYFi+R1TVgHpWU9uEy1HDO6GumxkBMpwbiK3yAnmoK0lW9Volzcz
         fGjenlZAjuKbm2f4iqu4LPJu1vQ76cjm5c5imYrcMJdU1EsmZUqotBd2qSfWpyISr+7T
         HkzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=uNeajQ0V;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=st5240RR;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id d58si1954952qtk.97.2019.04.03.19.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=uNeajQ0V;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=st5240RR;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 73C3222205;
	Wed,  3 Apr 2019 22:01:21 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=lg2BrG+7fYw7q
	7Cq2sx/23jUXOHpzN8JkKb4HEWmLsw=; b=uNeajQ0VmyZrTaaKNxl7RQ6fUnbft
	HfoH4ce85/rJbvEi+CBqtoLJtqZyFMMlQlEStmcyVUcAjrVglB+yyZbiZo24q6L1
	KQTQUHeJA/wzXfBDhYRXZADV2wN6UPVYjXI9yvcURTE1qn/I5n2NROOjS6/nSgu+
	qgzKPIJPVf0AYKvnce2HOqcQthA7gXL29ObEO/J8kn9BELEPsJvj2KWK/4ep7r3h
	CEzAUvxtYO8JHjbO5FCasFxIzZA2cogG/bxz2DRpBkl3Z98GlFRJcgVpmCI07J2m
	rLBju+P4I7ACY3XmHB9i6Bf0ene5A+R9Efnra7Kbpt9ygm978Hgrf9BYA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=lg2BrG+7fYw7q7Cq2sx/23jUXOHpzN8JkKb4HEWmLsw=; b=st5240RR
	dYFUN5ooCSyxrStwKafWNdgADoCKkzOnri6niAKYhRbzjvvmOB2n/IGnbhzs3Rdr
	BzFAI7LWFHIaSfd4C1wnUYKAjfCRjYPSiZr2T6l9a7AtPuvd/Wc+c5iMwLi5TJ/8
	3FbeCLHf8/+YCi+Kfq1+meQ1qMQncoTqjUr8eUBhYnfyqSRN0L83PwDnahGfVrFj
	KSS9R6Ebdc5Mdjz2oGrlKUfR8yTa+AhU22GyAFAn4nyUwKKrB5i+U9yExQRb5ejx
	F5jr4MpsizRiOzgjGUqu/7yx/HlMEc4xbZbbXQP/Yi+lhMx+dIKT+/fKyeaumUic
	8C4Nqe6TaDtLzQ==
X-ME-Sender: <xms:cWWlXBJ0tCYwW-CZHqsy9eb_wxV2t7i_AxDMY_94c6klTDuw7SFErQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepge
X-ME-Proxy: <xmx:cWWlXInlS4YJ2bJx51uJAd8I58Np6Ahz-dcbJLO_el5beZXwMbQBIw>
    <xmx:cWWlXNPkwE5lW_JHQ2LQQXofcZZo96Llcy8IpEWPEyLBld69ibXTJw>
    <xmx:cWWlXG3mZ92JiwiFjpcEorcWW-t13CG1O-QxHfgjuRVGovID_i3XKg>
    <xmx:cWWlXEj2kykTJDNHdPnEC8mfx94DmUfX1OKWJxg_MBpkICnTIxJIKg>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 64B1610393;
	Wed,  3 Apr 2019 22:01:19 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 05/25] mm: migrate: Add vm.accel_page_copy in sysfs to control page copy acceleration.
Date: Wed,  3 Apr 2019 19:00:26 -0700
Message-Id: <20190404020046.32741-6-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Since base page migration did not gain any speedup from
multi-threaded methods, we only accelerate the huge page case.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 kernel/sysctl.c | 11 +++++++++++
 mm/migrate.c    |  6 ++++++
 2 files changed, 17 insertions(+)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e5da394..3d8490e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -101,6 +101,8 @@
 
 #if defined(CONFIG_SYSCTL)
 
+extern int accel_page_copy;
+
 /* External variables not in a header file. */
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1430,6 +1432,15 @@ static struct ctl_table vm_table[] = {
 		.extra2			= &one,
 	},
 #endif
+	{
+		.procname	= "accel_page_copy",
+		.data		= &accel_page_copy,
+		.maxlen		= sizeof(accel_page_copy),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	 {
 		.procname	= "hugetlb_shm_group",
 		.data		= &sysctl_hugetlb_shm_group,
diff --git a/mm/migrate.c b/mm/migrate.c
index dd6ccbe..8a344e2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -55,6 +55,8 @@
 
 #include "internal.h"
 
+int accel_page_copy = 1;
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -589,6 +591,10 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = hpage_nr_pages(src);
 	}
 
+	/* Try to accelerate page migration if it is not specified in mode  */
+	if (accel_page_copy)
+		mode |= MIGRATE_MT;
+
 	if (mode & MIGRATE_MT)
 		rc = copy_page_multithread(dst, src, nr_pages);
 
-- 
2.7.4

