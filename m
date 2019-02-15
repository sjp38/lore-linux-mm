Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8893BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A1EC222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="a2C8a6h+";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="6VerkcaJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A1EC222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D31998E001B; Fri, 15 Feb 2019 17:09:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C668C8E0014; Fri, 15 Feb 2019 17:09:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADCC78E001B; Fri, 15 Feb 2019 17:09:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 822DD8E0014
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:38 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u32so10483781qte.1
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=zmEt0fRNgPgER4hv784eatILoHkzLDvws83cRovtJ3M=;
        b=jc4+QMps0HId8LHusaVG6FJoR3x02HsDPMC8pXxuXw2nouJ6jp7lqkdB6kpDQsPLYu
         vc8Yn5rvvpxeEvWZwX71XGN+MojTbsViy12eYNduJTfnot4/NV7ddHKBUQ2qP4omeUqx
         wQp+MjaFJLf7QVLxRt4zjlg61RYCyANyfivJtTXXF12bFY0hxC/cZGTWYdPikraUhsdo
         Jfhp+avonLKcE8Eo03qKArPRwlbMdXUkV+3O9ZTGMU9o+i7mFON7mELIRNHrLZU9P8xL
         trhjSq2QsSOvtrPBWrTyaclg+SEb59lHeG6cMRrjUt4aUJSRfAiGr7VD/W1ULgncgIWY
         rSpQ==
X-Gm-Message-State: AHQUAuZT0lF1/TgkUSZE2qIw9hHVqKm1y+i7iyPNpKg3kcFaedlqCLLW
	3/5ht4DM3HhVEwhEx72ayt9uzZ1qQWfkzw29M7uTx9WwnFUUnkxkbfguGpLSZsp3PdYtd57z6fH
	1zzh3wLLWH+g1LUej2u+pK2QoTfmsxR741TZ1ZW0ac+I2xAf2koCrOr1tnHbXPbWB2g==
X-Received: by 2002:a0c:becd:: with SMTP id f13mr9168592qvj.72.1550268578254;
        Fri, 15 Feb 2019 14:09:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYRwjFz5iSAuMn4qX3D63bcwTl2zE14+j/0iGhPNZdTeQSP1856QM9jImdGYKGmP6PzqzRr
X-Received: by 2002:a0c:becd:: with SMTP id f13mr9168526qvj.72.1550268577363;
        Fri, 15 Feb 2019 14:09:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268577; cv=none;
        d=google.com; s=arc-20160816;
        b=UlPXXPSUEoKKXzMOY+jKMAWWolzdDUQp+i/n+tQwx30Df0Kl59fyg/N/n1+C+5ijrd
         fVS8hRDCY2OcyX3P70iVfufZjLnTtjGDbDSE7mVqo9dLgER86eTvr0EgclPo8uSPSHFT
         L727WzhjUDfp6w7lIRencwMjKmY/EarNQ+eHKApyuM0/42989zD0/x8q6w1UnsOWngv/
         KFWKO/uJKKD4ATcnvfxVXvkvhOoBpD0UfklDhBHnIIpXtSCaVbJwhuRL6Ia8dTuz53VH
         paLP+BbQB/uucJjCRqcXD94ji5XiOJrk/xY9nCT+FrJMH5XCx2FVsFqnbn1ekmcC1ysX
         s/Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=zmEt0fRNgPgER4hv784eatILoHkzLDvws83cRovtJ3M=;
        b=XvMeCuToT3qjHVs4j4WthsKjkhb+fS6iRSpFjJvxmzdfvB7l15XWcAkGHf0VMGAKn9
         ArKoNtpJN3zSrYXx9Z9WtAx2ln4Tu7Ysf9hbCECP9fqBOBxNQSvMhtcsHwSJZwCCP7Jb
         xayfqz6GA6gLR96vDWikUnUxP39S4VFdduK77vTqpMCxAO7UtZeFrf7VcNsBagmLd7Ng
         eHthVfrlCPgNMxSsU7JCFLTwQbLTiq5lr+GkqD/KOeXYmf3IE2nTZHij/3pWqZFmKq2N
         eIZ9ejGegAKICqGwhBC1zBRS4GPZPNXaDac4b6yfe68NIy9hS8LYqmhdkQYhJbxKrMft
         D04Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=a2C8a6h+;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=6VerkcaJ;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id 14si3345182qtp.203.2019.02.15.14.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:37 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=a2C8a6h+;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=6VerkcaJ;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 941633058;
	Fri, 15 Feb 2019 17:09:35 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:36 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=zmEt0fRNgPgER
	4hv784eatILoHkzLDvws83cRovtJ3M=; b=a2C8a6h+OCVnJPyA6br24ZDIMtT/4
	HxsvOyPtTmxUhej0NWrj8rt94TobWnKwr8i4Md7CO2HPmwnerMDTFk1o5P8SIfxv
	HxzjphrsoTN5V81L9+pk5QjxVHROeA3ld4gR49ioThnIHf6bOtwFi3EeiiwyHWP0
	TJkbwrkXWupDYaMDi05+Ev+c1owX22MCiNiJ7xegdQArMic8wgRCZrWR0PdeKzmD
	UklSeXVbM7f8JlUQEp5YNMvRUpsMTIiw/P3ATRs2co8sTX/+QmHPnvUVI4ZPMT0F
	uZCjzsaR3Yd3liQlOYFC4JyhmH9kPMRK55oiJiif5qJwEuN9j2bZAqvJg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=zmEt0fRNgPgER4hv784eatILoHkzLDvws83cRovtJ3M=; b=6VerkcaJ
	/F+cDmhrn9NoTNMMQDk3BJFpVT8oJ5+ZTIE4GO2xU68JAo3Kg+zl9e420DccEsjj
	pTyVBEJm56cXk9LMVVrkQBVd9zqsrZ88uGFgOfNnFS1kY7EU54OUfGrW/zklmEGU
	WqaCi3omLfW4LCeT25oGxRQKVMXW1mPt4QYzv1/q+X5Ze/KZyYbO0fSUmLXb5SUO
	TUrt6RU8UvHx1zH1CE3w8eD3ilAkesCO74XHolmnP7dugmWMrAq9cAU8jkNCrP5i
	s0ZoydUj+27s2X+Gs0iEJeExfBjyxbWg/wDOI/szFXFJTlDzkHNGlq7XY/edWfLe
	NZOe434CAAzRcw==
X-ME-Sender: <xms:njhnXK3zBT1zZylT8NrMYVLNr6jD753u4CVCpNj3LzTiJeiMReNgyQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedvvd
X-ME-Proxy: <xmx:nzhnXA2WwCIJLPRAzxTzwS8pdyGefH-hvz-TJ0b7-YHjFJCG757FXQ>
    <xmx:nzhnXCp-OkdIA6NfvIm5wjtInXfah7X4V3pxAk7jHoMotih2QMyBog>
    <xmx:nzhnXLKKBD7PJE1ywXa7E0qIEHaIVi_D-BoNcdZXiJQwIH440NuKgg>
    <xmx:nzhnXJfEqQCC5efTYdzkbDuTIHxWCXagvJKu0wkOj2rpcf_v8-J0RA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 4491BE46AD;
	Fri, 15 Feb 2019 17:09:33 -0500 (EST)
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
Subject: [RFC PATCH 24/31] sysctl: add an option to only print the head page virtual address.
Date: Fri, 15 Feb 2019 14:08:49 -0800
Message-Id: <20190215220856.29749-25-zi.yan@sent.com>
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

It can help distinguish between PUD-mapped, PMD-mapped THPs, and
PTE-mapped THPs.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 fs/proc/task_mmu.c |  7 +++++--
 kernel/sysctl.c    | 11 +++++++++++
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ccf8ce760283..5106d5a07576 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -27,6 +27,9 @@
 
 #define SEQ_PUT_DEC(str, val) \
 		seq_put_decimal_ull_width(m, str, (val) << (PAGE_SHIFT-10), 8)
+
+int only_print_head_pfn;
+
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
 	unsigned long text, lib, swap, anon, file, shmem;
@@ -1308,7 +1311,7 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 				flags |= PM_SOFT_DIRTY;
 			if (pm->show_pfn)
 				frame = pmd_pfn(pmd) +
-					((addr & ~PMD_MASK) >> PAGE_SHIFT);
+					(only_print_head_pfn?0:((addr & ~PMD_MASK) >> PAGE_SHIFT));
 		}
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 		else if (is_swap_pmd(pmd)) {
@@ -1394,7 +1397,7 @@ static int pagemap_pud_range(pud_t *pudp, unsigned long addr, unsigned long end,
 			flags |= PM_SOFT_DIRTY;
 		if (pm->show_pfn)
 			frame = pud_pfn(pud) +
-				((addr & ~PMD_MASK) >> PAGE_SHIFT);
+				(only_print_head_pfn?0:((addr & ~PUD_MASK) >> PAGE_SHIFT));
 	}
 
 	if (page && page_mapcount(page) == 1)
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6bf0be1af7e0..762535a2c7d1 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -122,6 +122,8 @@ extern int vma_no_repeat_defrag;
 extern int num_breakout_chunks;
 extern int defrag_size_threshold;
 
+extern int only_print_head_pfn;
+
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
 static int sixty = 60;
@@ -1750,6 +1752,15 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
 	},
+	{
+		.procname	= "only_print_head_pfn",
+		.data		= &only_print_head_pfn,
+		.maxlen		= sizeof(only_print_head_pfn),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	{ }
 };
 
-- 
2.20.1

