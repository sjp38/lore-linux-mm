Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56EA7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0543F222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="VFUKyEKq";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="L9R6iOLb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0543F222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 513548E0018; Fri, 15 Feb 2019 17:09:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49AA58E0014; Fri, 15 Feb 2019 17:09:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B4228E0018; Fri, 15 Feb 2019 17:09:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 102FB8E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:34 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a11so9325642qkk.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=Mql9ve4UDV93VXmSDRn0eYbPSMabzYnGVtBZe6Hc3wQ=;
        b=bKa3RQR2q4LqfUQvS+vKs/P0BozSLmml/8e9GfZrp6mfs9HF16AQ3WEqLchqoLSTPO
         A+97+gqVbmL2pjIvM/VckcqeuwwuiGjx2BfLlkuyTx/+OQ9mwEXMoqBg3Ag0L5gQ1U4D
         QAhxYb0p6dw8cTae/vkJIPjsu4M/9x7mjjEv+9yDWjhCt15fGQLZbStofFHzbKt7d4s1
         3OeBJ7GwvQYhEPkyFh8oQ8XuE1lOOnKlGzWcyje/6saL6/clRWM3gONgkUkEwe1a5CwJ
         EseyBB6ycVc37WIjTmpdlFk4OCpCA8FXQuSYS5GKA5ZxkgrICh42sVMhrALfyL2OG7Kx
         j89g==
X-Gm-Message-State: AHQUAuY1oCT8bI2dv9dqFMWZ4ulNPovqPU7wnK4HxM2SsO9ka9RXiYPS
	TWnzQjWXZHqR3PKajv4X6FStpYI4dEHaVAPQ79HsPNwcnxeGRihIQKD02Qu1WpSVeVlgYjVYS2K
	DMKZ8cApTol16JBFIemVZ2u+Mjvr81TBAN2SRS7jcLd8RB3pbSSQvxEGzlAqt6/WAnw==
X-Received: by 2002:ac8:100e:: with SMTP id z14mr9290158qti.293.1550268573849;
        Fri, 15 Feb 2019 14:09:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib126vg6fD/AXhdZ+mVkW4wg1kiWU4qZ/rhVMSUUUE4kcvJgTVa2gfFYOAqZRvAHi9r8Xy4
X-Received: by 2002:ac8:100e:: with SMTP id z14mr9290110qti.293.1550268572983;
        Fri, 15 Feb 2019 14:09:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268572; cv=none;
        d=google.com; s=arc-20160816;
        b=foZcI4PIfunR4+K3nTxEDGQramPxmnGFy9ju41JomOcTrzWLLu/8qmEY8H+kub7GvN
         4OFB1Z8zl3wahSfhtuBdoH9lpDE2PCta6fjntfRugcV8a8Gj31kA8fYdNv6ToHu85EIv
         lpq7geM/LJzFhiwBk5pfgm1xJ4MP8eQTyb1GqtRQov4Wx+lSw7Y32uoZPf29K0VpcbPQ
         66kTSmtwbuawLX2+bP+AzGa7ToUrdZi4+Yu8f0NfsCk7JgtvWkgWStI8ij5BS2JYcYi0
         ngvoQowmjKzVOOnClSEMp+4vklkyILrHrXpWFQrpt5c69UKtAdRQDRis0P4MTWTkHmD0
         tHbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=Mql9ve4UDV93VXmSDRn0eYbPSMabzYnGVtBZe6Hc3wQ=;
        b=nJK7UUokgOV0wJas7peYzFgyFTpZC0DAjz8k+Y+tqPL6DzFgg8BydAogiEMLAa7Jm+
         E4yv+d0rKHXASvWC74nZa426EJOC96DzRMsDMr0+WcvX3/Sy+W68QU7GAo3X10tMYFMc
         emDMgr5zFexYIbH7bDtf2V/jzrgvIzVx/Xb1kZmSPfiAXDJ3pcWF/gDNJpmdR7tDHkAH
         O5DO1xQUs/83b5dLnZMz8NLoj3e75aTxZ9eGxHxunObPGq7LcLxekoQuV3sNE8xV+BDD
         gWmQ9iiskZavVLUtCTjDYRhKzlrDvwSZvKNS4VjDa2Mqe8TIgbZxkZpQ0EMv24KzJXRA
         nCjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=VFUKyEKq;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=L9R6iOLb;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id y19si2766935qki.241.2019.02.15.14.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:32 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=VFUKyEKq;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=L9R6iOLb;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 3178C3058;
	Fri, 15 Feb 2019 17:09:31 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:32 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=Mql9ve4UDV93V
	XmSDRn0eYbPSMabzYnGVtBZe6Hc3wQ=; b=VFUKyEKqzz/0iG/0dF5ekrZ9RwQod
	gNG5oHcb2NvSIDd+Rl9isNZlF5VgGKlJ4Olj2aicC4M/9Sn+EoR7fV4DQl3SJUd2
	DgWLETjIDsPKPR0OUdEJEURAHMG0FexsIKnOZEuuAZtaZ+xk94F2LsZlJwoKiiMV
	UUR3X1EpJwT2JHKKicMLPPi6+H7Y3yvc2EZZLXndyFSkRwVsMwKGNOnxV6fldG4e
	DApV/ZDSmQmUpI90aeLEYN8aFquAr0SUpa0Swn8154uPWdbzgcyeXBQnYqf3tE1o
	kC5+4JN2B8jhE3zm9mTPJ9n7dgz3QEHhYXy4DI9j9Zmn4a5fH3nRfAKdw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=Mql9ve4UDV93VXmSDRn0eYbPSMabzYnGVtBZe6Hc3wQ=; b=L9R6iOLb
	+1fx/XQVSYC4Jd+HRI9FMFrNQAJ2x8avz1sCrPrCicNu0wDk/XmNq/CojPSXTl6X
	wmQUTCjl7MEjMlmBz2jvN95txuTU8IxNOVLmOhE9GJdpdevWQnli7p6mG0hudAu4
	vaOcgB6DH6XFpX0/6PGv1OM/aDZbokapTVvm/+wjJ8oz4DOvHKBYxpEzCp8SYAso
	6Li+nN4pM7dz9276IONc2xX7cfy3hx4fgp7dqL0RT14bIqQNLZxtjxKzxo15MD8t
	1r/EZwsP3oCmVrgSCsSYMwkmnr9SiNju/BV2HYNBSi4HVaBwle/5G/hqxWO7Fukd
	HCEMDHd5Idjofg==
X-ME-Sender: <xms:mjhnXMhAmy0Q38rW25Xj3yD_CdXtTRIyMbV7aSgKtcEqKd1EZipa4Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeduke
X-ME-Proxy: <xmx:mjhnXNSPK37oj3EgRoxtOjUP2sfkxTRERr3cZAwPTe7M5StISaUjyw>
    <xmx:mjhnXJ8FEkmO8r-0STCXp1RbnqXeNUgEeKLoeN6B3mS0BGOKgeM_aw>
    <xmx:mjhnXO9ap9nvDo3Vvs-bvZlmklcK8W48My1w-yOXp0rrTNqhJl5xdQ>
    <xmx:mjhnXCVsKR8ZuGMK0UBH_gWlspQx5BTgUE6eIRH1O7L2Og6W9NG07g>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 37CFEE46AD;
	Fri, 15 Feb 2019 17:09:29 -0500 (EST)
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
Subject: [RFC PATCH 21/31] mm: thp: 1GB zero page shrinker.
Date: Fri, 15 Feb 2019 14:08:46 -0800
Message-Id: <20190215220856.29749-22-zi.yan@sent.com>
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

Remove 1GB zero page when we are under memory pressure.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/huge_memory.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bbdbc9ae06bf..41adc103ead1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -207,6 +207,32 @@ static struct shrinker huge_zero_page_shrinker = {
 	.seeks = DEFAULT_SEEKS,
 };
 
+static unsigned long shrink_huge_pud_zero_page_count(struct shrinker *shrink,
+					struct shrink_control *sc)
+{
+	/* we can free zero page only if last reference remains */
+	return atomic_read(&huge_pud_zero_refcount) == 1 ? HPAGE_PUD_NR : 0;
+}
+
+static unsigned long shrink_huge_pud_zero_page_scan(struct shrinker *shrink,
+				       struct shrink_control *sc)
+{
+	if (atomic_cmpxchg(&huge_pud_zero_refcount, 1, 0) == 1) {
+		struct page *zero_page = xchg(&huge_pud_zero_page, NULL);
+		BUG_ON(zero_page == NULL);
+		__free_pages(zero_page, compound_order(zero_page));
+		return HPAGE_PUD_NR;
+	}
+
+	return 0;
+}
+
+static struct shrinker huge_pud_zero_page_shrinker = {
+	.count_objects = shrink_huge_pud_zero_page_count,
+	.scan_objects = shrink_huge_pud_zero_page_scan,
+	.seeks = DEFAULT_SEEKS,
+};
+
 #ifdef CONFIG_SYSFS
 static ssize_t enabled_show(struct kobject *kobj,
 			    struct kobj_attribute *attr, char *buf)
@@ -474,6 +500,9 @@ static int __init hugepage_init(void)
 	err = register_shrinker(&huge_zero_page_shrinker);
 	if (err)
 		goto err_hzp_shrinker;
+	err = register_shrinker(&huge_pud_zero_page_shrinker);
+	if (err)
+		goto err_hpzp_shrinker;
 	err = register_shrinker(&deferred_split_shrinker);
 	if (err)
 		goto err_split_shrinker;
@@ -496,6 +525,8 @@ static int __init hugepage_init(void)
 err_khugepaged:
 	unregister_shrinker(&deferred_split_shrinker);
 err_split_shrinker:
+	unregister_shrinker(&huge_pud_zero_page_shrinker);
+err_hpzp_shrinker:
 	unregister_shrinker(&huge_zero_page_shrinker);
 err_hzp_shrinker:
 	khugepaged_destroy();
-- 
2.20.1

