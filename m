Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1565FC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5F6F222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="ZAWqHFVS";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="7EJVwMDl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5F6F222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4079A8E0008; Fri, 15 Feb 2019 17:09:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 362F68E0004; Fri, 15 Feb 2019 17:09:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22C078E0008; Fri, 15 Feb 2019 17:09:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECF008E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:12 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id a11so9324880qkk.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=6ymhdlS0PDEIxuW6nq05LKSmTCjvZyCs+nOTiikq+3M=;
        b=Q/mhhqCnSCBF65jvx47vojLx2gqJwrdokwreQyDvTiO+tBXgp42jWP7QDdHhCMbxS6
         UMTpFJHtBOwAABMNSEoIFhGoetzQ8fSLhRiU/CE5+lm7KVJgWAiQElxdSfexdaeLPs5N
         rZKhMzvbUXXKAlNMhwzCFSE/sDc2VELx1JzbXN4V+2LfZW1E5oCShWN+uJ/pKUkWGFSO
         Kj2tsHnAs7I1cotB5ISY3uyx4WP5KDPQTNJI0kYZDQIcNMEz3EdmSrezumsZ0WLLAC2v
         CHwJfk8ZNWD/XWHeSEkiGfaP9j1OQQTOlmS6Gymmfh0X5xSE6wKMrtKEKPSIlR63FrKy
         8K+A==
X-Gm-Message-State: AHQUAub9rCQHBJvVsIah3ICU/Z7FrErhH9UXlHIIc9qqZrJhkbpx9fac
	e9Mn9lhH4qigTP5YS4Qisj/2FWbVgtRR3FulgrLBj91ATo25am6E8rbuDBEa+2A1o8CXuZC68lS
	AjeT2kh7/R8EpZ3KoGcrYL+OYrnfHrAB2CHQmbzma2QCMt/FJUDQrkZkkIhCWKsrg0A==
X-Received: by 2002:a37:7fc6:: with SMTP id a189mr8744317qkd.12.1550268552733;
        Fri, 15 Feb 2019 14:09:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia7No94nS7XrWS58izy7H3xO7qp9lxagvl5DhoAsj3VYh9enUl3+PlSSlfFET124PhAolQ1
X-Received: by 2002:a37:7fc6:: with SMTP id a189mr8744288qkd.12.1550268552123;
        Fri, 15 Feb 2019 14:09:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268552; cv=none;
        d=google.com; s=arc-20160816;
        b=swZvVcNGj/7jAAbQUHVvOPRDWN5FM7K8gdjgx00dkGjeJsZQFTDPGAOwZlHJu76vzb
         ABe8P/CQ9ACKEIPKlgU2ZcvLlP067jC1n6svsYseHvIJG1T6+tMbdGmALp45XsdovHrG
         B0Clbs4kcG/ldOkoKQ0QunPVp1AcWej05QJDrxsE4sfMl0RNb1XHLhK9GKWES9DGJKJb
         zPD4U+Wczorlag4I1a3HXRJaDdCLY2XdSMSx1Jxf6T4PuEpuMLVycmUsQrIhyOj1vK1x
         KnOB8UKJT8TAyhr2dB3TAs2rJ/RhUB2Jtsh6CZ49tUCMIYYqsoO+4gKtKnEEIKytENvZ
         iNug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=6ymhdlS0PDEIxuW6nq05LKSmTCjvZyCs+nOTiikq+3M=;
        b=Uf2eHMA5F6TkFkptcEtJv2juYrnr++xluEdY7enw5TzpD2takCi2i55g8OKcQcePfu
         XLlmw5rrc05gYI9LLNiYHOTPxglikNFYDZZPNrR7JJaPOZiu3HbDhkq2IuOSJpkKXyB2
         llZPSnohAUsrqWl/WtYt5phtMv6OuRtsSMvqL/ZC0Z/4Rk7ePCAbadH3A04m3bNG/etM
         JJiyHdaE/ScChrE4OW2ozim1x75+osbMZZXCVagJolKbs/RjxqlbjSLLqdODTxNL0t83
         VgBJx5pjdaHh1n0NVQVXO+Yj3j6u4AH5qQQZ5GtbOP4y6cUUZpLp+hqwava5brLgjGDY
         McqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=ZAWqHFVS;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=7EJVwMDl;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id x54si3162137qth.374.2019.02.15.14.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:12 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=ZAWqHFVS;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=7EJVwMDl;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 4F0A6310A;
	Fri, 15 Feb 2019 17:09:10 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:11 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=6ymhdlS0PDEIx
	uW6nq05LKSmTCjvZyCs+nOTiikq+3M=; b=ZAWqHFVSjc7AMUIPUmVIUa6hcCX+X
	Ob2ZssfT10pMRBWr/zR+1ObMQyajh8+qwCJbD8rMpMudIV3IqGfK1Cg/nQdlV9X5
	uIRNDPywDowLQM82w8SRqIl+V+nmHXLqfcR87ullpaMMqpgUKbPupsPfr3yKWANX
	U1F6UJs2FYVBVyQMkgdkzL0Z/qxfXQfdGhNjDwt+TLajRm4T9kjYLu+Sjrn8wbox
	3LvgzM8ysGXv0Ufm+CQQhR02liZ0JCrEeY9o02prDi5UZEGRt405Oi3sDRTBYs5+
	JSaOM8nzV8Ue+yR+bytxuZMoOAhV9NBeut//pOp162k9zHp7GcjH/jzeg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=6ymhdlS0PDEIxuW6nq05LKSmTCjvZyCs+nOTiikq+3M=; b=7EJVwMDl
	uKYJsQjnqcYbihQy6KGbt8K216aqhCQYZkKwRZFkYKgtNqSWaQ/SZyJPShOxPff/
	0Mbqh/2JNwJsciSqnw3c0E5taomwFv97PvP3Pc+XYX63SLve1Idd9/knB8gMB94n
	l4/kD/8BhizsJ+QhLLQWAwxgSKpyINs+cmJieie+HgbhmcwuZCBF+k5eIJ1NBgSb
	ZYco42z77qgkk9zZhhW2N6wbWUWI6eFZbE+BCqxgaugva08jcfbaBK6ZZuq0LAF8
	t4WaMzFjcGweQcEd7ZWu9XdsVbk/62OQWwabrrwS5sZ3ct8x27RO56pqMD4lv3U1
	W9ZbmDFDgBpTkQ==
X-ME-Sender: <xms:hThnXG13NdlOX8pIQ4M4JG8GPIJueRDkHhG7UVYxopadmLmH9ZLbGw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeeh
X-ME-Proxy: <xmx:hThnXMF4wrKi-0nHAgs2eH7A3T_KZc0aRKwRXSKSxjhu2ynHw187Fw>
    <xmx:hThnXIysuxWrmZ54OK41Ntcev2gp7ZLE9bXoKoTYJ7TdJpJybDWIjw>
    <xmx:hThnXC5ZmaKeBJn1ndDN6EynJS-LBjIInWVhMW-gw1tE5TLY5AX3-Q>
    <xmx:hThnXNeYwAluH7YpHJQIwfc8LhWr8F433CzqI_QEsUP6nW9QGochXw>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 7598FE4599;
	Fri, 15 Feb 2019 17:09:08 -0500 (EST)
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
Subject: [RFC PATCH 06/31] mm: Make MAX_ORDER configurable in Kconfig for buddy allocator.
Date: Fri, 15 Feb 2019 14:08:31 -0800
Message-Id: <20190215220856.29749-7-zi.yan@sent.com>
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

To test 1GB THP implemented in the following patches, this patch enables
changing MAX_ORDER of the buddy allocator.

It should be dropped later when we solely rely on mem_defrag to generate
1GB THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/Kconfig                 | 15 +++++++++++++++
 arch/x86/include/asm/sparsemem.h |  4 ++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 68261430fe6e..f766ff5651d5 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1665,6 +1665,21 @@ config X86_PMEM_LEGACY
 
 	  Say Y if unsure.
 
+config FORCE_MAX_ZONEORDER
+	int "Maximum zone order"
+	range 11 20
+	default "11"
+	help
+	  The kernel memory allocator divides physically contiguous memory
+	  blocks into "zones", where each zone is a power of two number of
+	  pages.  This option selects the largest power of two that the kernel
+	  keeps in the memory allocator.  If you need to allocate very large
+	  blocks of physically contiguous memory, then you may need to
+	  increase this value.
+
+	  This config option is actually maximum order plus one. For example,
+	  a value of 11 means that the largest free memory block is 2^10 pages.
+
 config HIGHPTE
 	bool "Allocate 3rd-level pagetables from highmem"
 	depends on HIGHMEM
diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index 199218719a86..2df61d5ccc2d 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -21,12 +21,12 @@
 #  define MAX_PHYSADDR_BITS	36
 #  define MAX_PHYSMEM_BITS	36
 # else
-#  define SECTION_SIZE_BITS	26
+#  define SECTION_SIZE_BITS	31
 #  define MAX_PHYSADDR_BITS	32
 #  define MAX_PHYSMEM_BITS	32
 # endif
 #else /* CONFIG_X86_32 */
-# define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
+# define SECTION_SIZE_BITS	31 /* matt - 128 is convenient right now */
 # define MAX_PHYSADDR_BITS	(pgtable_l5_enabled() ? 52 : 44)
 # define MAX_PHYSMEM_BITS	(pgtable_l5_enabled() ? 52 : 46)
 #endif
-- 
2.20.1

