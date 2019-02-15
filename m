Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E001BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91918222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="A4ujf58V";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ZBrE7Vyw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91918222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A69668E000F; Fri, 15 Feb 2019 17:09:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A19748E0009; Fri, 15 Feb 2019 17:09:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2938E000F; Fri, 15 Feb 2019 17:09:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2018E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:21 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id u197so9234787qka.8
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=rMjYn468lmWbJJ/Y9UnoFTDhCSw4u+AQXz4D4ksBw0s=;
        b=KZJ9C8N9UXNF6uRT35U8lm8b0uwvZz32iUY+0Df+URw7+lQZAwtHMO/sA4xdkbJFob
         H0i6gLSLkGeM4/iqtgnWUu0PNdpPoIoF+xTidDuXfqPn9ZSoqt5bKyM4V4PQtZ0oROzz
         oMqACVmsp/u7u5nHLlukxQ2m/Fsfmx3ck+jJtPDUdgb+nH1JLkxVIzIfq1NX3r44uFi0
         ONQ46z8ogl/VntUy5AsmjbNf3oxEoGgvF7x6YE3sGEspbUC4g84VZrehmrdB/ZC5OVPa
         FtSnkTkXFKn53SznGXl9YC/6oWHTr6yJZ0bBrUfbIENCbYLjMaxMuZMsXwgt3j3seukR
         pqiA==
X-Gm-Message-State: AHQUAuZOZAL9PKvD5me0mjuZhZf+6hpZV37p53/iRfqB7PDBYPoNM492
	9/H1QsiAiTx1oammscbPW9/NGgBsl9QOfLPOiHKBXVwtpPKSj+TRmGIu/xDAfrOZfCsXlhGcqoL
	2aRVIExWhoB/3TouZxs0L6vwkjbeth3SR5JhnJOyNxTSewlNdxLTNyzgDxwLgQW3P7g==
X-Received: by 2002:a37:4a84:: with SMTP id x126mr8750419qka.326.1550268561149;
        Fri, 15 Feb 2019 14:09:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYRC5yz7gIudHkD6aJeEzrKNC5qlxCOTc5eDh8+kYkzvx+RCCNVqsFTQCq9ju22RjIIm/dQ
X-Received: by 2002:a37:4a84:: with SMTP id x126mr8750390qka.326.1550268560665;
        Fri, 15 Feb 2019 14:09:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268560; cv=none;
        d=google.com; s=arc-20160816;
        b=Q7VmJBrwoBsYpUvxcHO53lU/+yBF76Qu4nYa94J9rZ9KOEZeokaOqJroa0FqxUcHA1
         cSgLiO6Uv5U2r49toRA9+YcDx71YP6wj9WltkhcWhjSQ4qX87He1Za5oy+tjJY1lCcVv
         Jn7xfbxXwqafvlLzRhUk6BCkb6HNrlTqBEw4psVTrx4PROJoSd0sLj/BgAR757U9rmZr
         tLmMDIUfYL1nS1of5FCvhqP6h7lLv4CzdUn4R+vDlI4Xy+lPKfkhTZUuEARG+kBYwRbl
         rMrcLjqvuc6rRIS5/X6dAuHrty2On5z05SodEmVAS1qmIF6oFxhs5gGgvKROTK8JRgB9
         QB+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=rMjYn468lmWbJJ/Y9UnoFTDhCSw4u+AQXz4D4ksBw0s=;
        b=COcm4zIzMgwdDJUNwYxQ6Q5/0ItrT62qNe41b+ycArxlW0nSd4UhyjkQLrvvbgMhsG
         7T5huS8fCoNgly0jk1ze44Q2fw4WYMLOqsMF9C4CwmipDuLhqgTmqAX2nA1agJs+bP1x
         dvd+Q9TAacqXISg+mE+LtHzla82RomhcVNNiEw3cGHgiBm1qLmEwxdIOIua4pbw8Ze+w
         kTL3ZMfV5chM+YtrKYcpmwqEtVli2/dOCmTNZr2ZMllbBnJViS/KKScmCFbvzl5qVYSN
         uxyICVBSt3KyktEbRjTfMKn25JQCfFy6phOl7AG7McU48bmL2nOECifbZJorL7NkbISZ
         MjOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=A4ujf58V;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ZBrE7Vyw;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id j8si1303751qth.175.2019.02.15.14.09.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:20 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=A4ujf58V;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ZBrE7Vyw;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id DA113328F;
	Fri, 15 Feb 2019 17:09:18 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:19 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=rMjYn468lmWbJ
	J/Y9UnoFTDhCSw4u+AQXz4D4ksBw0s=; b=A4ujf58V1MFEFOPLdNKwAJHAyesXQ
	SQ34q5PKA3J4Rfuw1dW3pWYteDdWQpzuBYEfB2WGmgiveEW3p4lqNVtmgs3lpeOW
	Ci8Jcp72+T1q/C3kicjr86sJfKICROGfrf0apD97U8oL4oZFwv00Ln3SOdNh+pe/
	r9D18oGy9SvezbjLwItFw05IvtZUm5rokh02KTUv4s7RgYZeX8tEgDzoBx7qYzA0
	zBDHwRlzmNqpp3ZyEGlnP7N/ROp+WMG5I5nVbM3O0pU9FWsHK3KH6WBuVk128JeW
	Kb8HclfadEkbyofFGyq1j7qXN5Fyx4dGJCo2pVRqAVOJbPJd+t44nI9aA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=rMjYn468lmWbJJ/Y9UnoFTDhCSw4u+AQXz4D4ksBw0s=; b=ZBrE7Vyw
	38eugooyUyUUG1AKmaXNOP5GWjtIEhS3NB3jWp1ADXoCuy1Q0TFL5ISc7QS4RNaG
	jxGOdKluNN4kFtDYvt6CRg5Pbm6PhRPGq2+6PP4uy0Uc1DqGcuxI0e3OtSSna69K
	OEOYi1czI4SoArwx51Dp+B/JbNRF7o2a5/MwnnAF7QBnR5jU315NYwGEsPViMxVB
	ilI5UfGFIz1mDVzdzE2bk6LrO3aPzShgbIfylrbGLviAI/sFJQVAXKD5NqhlcbML
	QD+DKp15ej7KfEnMbcCzIATWLfPJ9jVfdzIlX58sHegkX2ncao6ZfVKgsGXls7wr
	0HZXDk0SLwJQgQ==
X-ME-Sender: <xms:jjhnXMy4FuyMaJcKEe46UiCuRvL1FgVJBaTTELGrKcoaGKZtTDHyIQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeel
X-ME-Proxy: <xmx:jjhnXDtVpWgZMVc4Lxeulwl1ZlxUyRX9jTcd97wTr5Vdthim9sXCqA>
    <xmx:jjhnXKkoL3NSZLrSJhwSC1Gr48XY7ofmUfQ-zBTbX7XBhCDLtNZkRA>
    <xmx:jjhnXDjVtViafyp8hzIWLw-0oE7rYQzXT4q6d3U-YVMdywz4Dsv55Q>
    <xmx:jjhnXN0L8XQ-OZWS4w97pXFH5Ul6_BkC89bCz8fXpLAC4hTFyVH4ww>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id E7EA2E462B;
	Fri, 15 Feb 2019 17:09:16 -0500 (EST)
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
Subject: [RFC PATCH 12/31] mm: stats: Separate PMD THP and PUD THP stats.
Date: Fri, 15 Feb 2019 14:08:37 -0800
Message-Id: <20190215220856.29749-13-zi.yan@sent.com>
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

PMD THPs and PUD THPs are shown in separate stats.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 drivers/base/node.c | 5 +++--
 fs/proc/meminfo.c   | 3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index f21d2235bf97..5d947a17b61b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -127,6 +127,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d SUnreclaim:     %8lu kB\n"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       "Node %d AnonHugePages:  %8lu kB\n"
+		       "Node %d AnonHugePages(1GB):  %8lu kB\n"
 		       "Node %d ShmemHugePages: %8lu kB\n"
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
 #endif
@@ -150,8 +151,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       ,
 		       nid, K(node_page_state(pgdat, NR_ANON_THPS) *
-				       HPAGE_PMD_NR) +
-				    K(node_page_state(pgdat, NR_ANON_THPS_PUD) *
+				       HPAGE_PMD_NR),
+			   nid, K(node_page_state(pgdat, NR_ANON_THPS_PUD) *
 				       HPAGE_PUD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 9d127e440e4c..44a4d2dbd1d4 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -131,7 +131,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	show_val_kb(m, "AnonHugePages:  ",
-		    global_node_page_state(NR_ANON_THPS) * HPAGE_PMD_NR +
+		    global_node_page_state(NR_ANON_THPS) * HPAGE_PMD_NR);
+	show_val_kb(m, "AnonHugePages(1GB):  ",
 			global_node_page_state(NR_ANON_THPS_PUD) * HPAGE_PUD_NR);
 	show_val_kb(m, "ShmemHugePages: ",
 		    global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR);
-- 
2.20.1

