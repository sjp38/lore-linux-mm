Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61C12C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10470222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="aMljrvdA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Wk4BxuV8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10470222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B53328E0022; Fri, 15 Feb 2019 17:09:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2E5D8E0014; Fri, 15 Feb 2019 17:09:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1A7C8E0022; Fri, 15 Feb 2019 17:09:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 719B88E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:47 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id m37so10332688qte.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=Oh7GULCOLWRjmjhuSKnyAXxTibOklN87jGLHPOsAqeM=;
        b=FK4xJZ++m/gaWQ7Hnb1XKwrrc9w6nfVPaMMhk8jdEbfp1u4CxJqCaEnbyCoTIDC02g
         srOTfy5Ngi/qaGbKh65j3hcn0XrD3Bl+VY/2GY7nLPScPYeECysaundrN6qL9+7T/9ha
         V61Wrv0fUSwv2eywo2YVK55fj747hyWh/F8EbK4H+waCmh+9G4Z8N8OWy2veyOYi0sio
         Jzlo9OkwCh0A1GzfUO4Mn07EVOZtScTcUx3jgkIbtXwuWkUUGXjBUuX3duV+byjHSekE
         pf28z7WGAybHA9tknrsLcqMMo5hmhLo/ZX3I67AVi3C9Tz8lZPYFXAVPEeKFWU1Y1bCC
         wKbA==
X-Gm-Message-State: AHQUAua3XHL8kuQ2m3sStG67LIbLkWOeVrR9a+IBQmDodR/uyPjV7ai7
	YfrNIu0jdDB80pBKrND7hVeNRj++FNQwAuxrumc0CAQNPw+j8UBRJYX0hurnHkGt2dV558zF4Lp
	5yY29TCqSRtmkMzqMAJxbcUPT2FxPFMfg/jMtWrbgt8UXqSUTM5VMwZeTdO8YrK/g8Q==
X-Received: by 2002:a0c:8204:: with SMTP id h4mr9015353qva.85.1550268587232;
        Fri, 15 Feb 2019 14:09:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iatp59kp1YEU8NUwSEBAIQYnx4yYPREvT8qKffegeS6ioFPmslU4v8tBQgGqBIlRa7wSFhj
X-Received: by 2002:a0c:8204:: with SMTP id h4mr9015319qva.85.1550268586628;
        Fri, 15 Feb 2019 14:09:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268586; cv=none;
        d=google.com; s=arc-20160816;
        b=FCiUKSgI3kNa68kHaycKG6qDnmfMVhW14CN7UiEKFsvvu7JRqpyAhvN+jri0DREM2D
         /mkJeOvOT2WmeLQCObn0oUU9Tdc/3Zf6XqMjJIjTFYc4kdJJz+2Sk5pg6sqXXmCgxlk3
         Uj844xE3+5DdPcL0xff8dopu1/FbnJvCcCS375yt3mHKK7Ih9hwmqp4W7mGV/+HydKwK
         oy2hHLoNfe/uri1500HhxH6TxY4orYTNZsvmnILdfPS21/cPfIdmNRVAAUDROs/Sv9tY
         ZCnEzx3QIB/Xn7Ea1LPNMAtdaJVm6Qu5GQ5ouQLS8kesG8uFyk2GIduVAmRDlwS95DYo
         fWIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=Oh7GULCOLWRjmjhuSKnyAXxTibOklN87jGLHPOsAqeM=;
        b=joERkvg9JkJgOwP67SusW65+q7uHg0APBr/2cI2SqTf805VxsZeg5PoLmPG7F6XNlX
         blQhy+IuDz1wTIpZzVzQIEd07Oz2+7blwqwNc0iFh7MhDOcWKLSf8d5T6Qdzg4skfu9s
         2tM3QsChlhZ5eBTSlvWlHSvw1L8gGXvPtr5TZF1DDa57w3YCM3CK2q6KVN+JkpthYwoS
         p754RqimV6Qo1o4VIdGddwgwxl2unwBrkQgAv6i5LOnTXBhjVnz90ueAvlVp0Mmrh9Y9
         ihtIdvoF68zekmclvVgpRj+cjUrHbE8eEmzfXlvrJosWGOMQsYbCcrNotObp2r9/Sr7q
         zJng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=aMljrvdA;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Wk4BxuV8;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id n20si822937qvh.47.2019.02.15.14.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:46 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=aMljrvdA;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Wk4BxuV8;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id D2F7F310A;
	Fri, 15 Feb 2019 17:09:44 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:45 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=Oh7GULCOLWRjm
	jhuSKnyAXxTibOklN87jGLHPOsAqeM=; b=aMljrvdAcwoldsXjgO5yhN+UvVx3b
	xtMpZUikF3bhBc27IQwdHghiiPt57aD2XagmtanJzU4OJO08uxfX8eccKKcKLyQl
	cWo78u9Vxy8fbhM65Snhsq7J9epAhHPZ/68q1i8TetxogjvtsQdOgyE2b6D61rJ2
	aviVGagS+HDm/RWkikaQcz+3n1cf3h0NpFSHd2vYQa7krQWuJVarBn7OPKZV0sho
	K7sgtCHQBMM5g2kBIADd1ov0LYCmB8N7iu9IiorRaWcRGr7GWBt6jckraSt/Xuys
	6ttVkk/s5fDzcuIDmX1ilk5cujGubxuQ/jfyJPGf+akadbtTsnArp41xw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=Oh7GULCOLWRjmjhuSKnyAXxTibOklN87jGLHPOsAqeM=; b=Wk4BxuV8
	OWmOHmdNoqc9hHLktFqfkSznUBiLSiCxC0pJAtVVlHqjehVnz4ZMuLnSO62B+G44
	5l4Ii0kVi7gON8W5cEQgXfLWghI9YiupsUpV2lM8FZq0cah9kbQYyWu3iuCRncDa
	li91SR0Dctl5cxvHRSRRjbknzDtTtjXJQ6LDTlNHRuYiGm6Sg3scWw2/YGJ8fYNn
	O9kbwF6AAnrJ1aNcp1YuSu2wdIh4AGvXkLS/aGQpfEPxs/zA/ozSwFzxnKTtv1v9
	1d3aw0zSY8OpsQqOLj7/B9nVSYZlkUNB4uW+1o4KB7QKcQ9YAv0sV8uiiBlAbacN
	b9QrjdiBUa3qZA==
X-ME-Sender: <xms:qDhnXEX73txmNLtagzYVDzOsfJ3jNaBIV_mJPhbtAY3CfHIczjIqCg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehlecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedt
X-ME-Proxy: <xmx:qDhnXLv8cK1_0NWRaDSo9pmFTtWRF5M3-yt-IW3HNBkiVWQnFUAnKQ>
    <xmx:qDhnXF0v0KaOGUxQbT9if_57v86nKnG3b34Wmtu99qXLnDsoFJrxkg>
    <xmx:qDhnXH43EHAvEgINwr3bSElFM8a_DbAXrNcS8cFa1uwTj_SM7YVR3w>
    <xmx:qDhnXFn9MCUQWiuOpP0eA4LtcyWUN3I4Y4A0qo6mbBuDF1XeUSFS2Q>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id DBFB3E409D;
	Fri, 15 Feb 2019 17:09:42 -0500 (EST)
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
Subject: [RFC PATCH 31/31] sysctl: toggle to promote PUD-mapped 1GB THP or not.
Date: Fri, 15 Feb 2019 14:08:56 -0800
Message-Id: <20190215220856.29749-32-zi.yan@sent.com>
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

Only promotion PMD THP by default.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 kernel/sysctl.c | 11 +++++++++++
 mm/mem_defrag.c | 17 +++++++++++++----
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 762535a2c7d1..20263d2c39b9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -121,6 +121,7 @@ extern int vma_scan_threshold_type;
 extern int vma_no_repeat_defrag;
 extern int num_breakout_chunks;
 extern int defrag_size_threshold;
+extern int mem_defrag_promote_thp;
 
 extern int only_print_head_pfn;
 
@@ -135,6 +136,7 @@ static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
 static int __maybe_unused four = 4;
+static int __maybe_unused fifteen = 15;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
 static int one_thousand = 1000;
@@ -1761,6 +1763,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
+	{
+		.procname	= "mem_defrag_promote_thp",
+		.data		= &mem_defrag_promote_thp,
+		.maxlen		= sizeof(mem_defrag_promote_thp),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &fifteen,
+	},
 	{ }
 };
 
diff --git a/mm/mem_defrag.c b/mm/mem_defrag.c
index d7a579924d12..7cfa99351925 100644
--- a/mm/mem_defrag.c
+++ b/mm/mem_defrag.c
@@ -64,12 +64,18 @@ enum {
 	VMA_THRESHOLD_TYPE_SIZE,
 };
 
+#define PROMOTE_PMD_MAP  (0x8)
+#define PROMOTE_PMD_PAGE (0x4)
+#define PROMOTE_PUD_MAP  (0x2)
+#define PROMOTE_PUD_PAGE (0x1)
+
 int num_breakout_chunks;
 int vma_scan_percentile = 100;
 int vma_scan_threshold_type = VMA_THRESHOLD_TYPE_TIME;
 int vma_no_repeat_defrag;
 int kmem_defragd_always;
 int defrag_size_threshold = 5;
+int mem_defrag_promote_thp = (PROMOTE_PMD_MAP|PROMOTE_PMD_PAGE);
 static DEFINE_SPINLOCK(kmem_defragd_mm_lock);
 
 #define MM_SLOTS_HASH_BITS 10
@@ -1613,7 +1619,8 @@ static int kmem_defragd_scan_mm(struct defrag_scan_control *sc)
 						/* defrag works for the whole chunk,
 						 * promote to THP in place
 						 */
-						if (!defrag_result &&
+						if ((mem_defrag_promote_thp & PROMOTE_PMD_PAGE) &&
+							!defrag_result &&
 							/* skip existing THPs */
 							defrag_stats.aligned_max_order < HPAGE_PMD_ORDER &&
 							!(*scan_address & (HPAGE_PMD_SIZE-1)) &&
@@ -1628,7 +1635,8 @@ static int kmem_defragd_scan_mm(struct defrag_scan_control *sc)
 								 * still PTE pointed
 								 */
 								/* promote PTE-mapped THP to PMD-mapped */
-								promote_huge_pmd_address(vma, *scan_address);
+								if (mem_defrag_promote_thp & PROMOTE_PMD_MAP)
+									promote_huge_pmd_address(vma, *scan_address);
 							}
 							up_write(&mm->mmap_sem);
 						}
@@ -1654,7 +1662,8 @@ static int kmem_defragd_scan_mm(struct defrag_scan_control *sc)
 				}
 
 				/* defrag works for the whole chunk, promote to PUD THP in place */
-				if (!nr_fails_in_1gb_range &&
+				if ((mem_defrag_promote_thp & PROMOTE_PUD_PAGE) &&
+					!nr_fails_in_1gb_range &&
 					!skip_promotion && /* avoid existing THP */
 					!(defrag_begin & (HPAGE_PUD_SIZE-1)) &&
 					!(defrag_end & (HPAGE_PUD_SIZE-1))) {
@@ -1668,7 +1677,7 @@ static int kmem_defragd_scan_mm(struct defrag_scan_control *sc)
 						 * still PMD pointed
 						 */
 						/* promote PMD-mapped THP to PUD-mapped */
-						if (mem_defrag_promote_1gb_thp)
+						if (mem_defrag_promote_thp & PROMOTE_PUD_MAP)
 							promote_huge_pud_address(vma, defrag_begin);
 					}
 					up_write(&mm->mmap_sem);
-- 
2.20.1

