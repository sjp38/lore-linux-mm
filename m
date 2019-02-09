Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77B5FC282CC
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 17:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B3E12192B
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 17:31:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B3E12192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A96C58E00CD; Sat,  9 Feb 2019 12:31:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A46348E00CC; Sat,  9 Feb 2019 12:31:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 935AB8E00CD; Sat,  9 Feb 2019 12:31:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 529628E00CC
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 12:31:32 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id j32so4721101pgm.5
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 09:31:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=nvj+7reFMkFLvbKZaeDSxZMOo553VBlZHr9t/sOOozc=;
        b=BP5LL/WZiaeyrtY6iGVXhGw5qdg3C8wEbgo3IIC9hIrQh9mqqdb9QXqDtj2PZQbeq+
         mrMklM35Ags8JNthcLQXMzXJhyZKBckpdDzM8kZV+XKpE62xqLfUTRzZ6aNW87ijQ+K+
         s3PxHrx0zowSeWXdnT4mnGPv/ETQFrRGmZkNL/Wtth9Ju/U73b4yhLCKTy714djCMMMv
         UCZAg9PaSHfSNDIyVumRQmS+yc5jmdkVrnWhaeCQsECedMDdGep+DgnXU1ywcoGwGQHn
         255Jnb/0GLqr4V2OO9K64AbOFvvDezSP84UYP/zRoNPZRiJA7RdLii1QX5wQDWSg5gRn
         eagQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubRuiho64Nr5Sc4NTCCJYCK/BF22vW2Od0eoFtLC2WTnXlkE+J9
	j5Ki1CENCu75Xtrn2dw6k5DpT6Udkrkd5H2Tb549R2ezYDCmc7XiK8BgXNH29QnKRPMjLfZyTbK
	rg2SQzL8g1CXyVWeUnUcSpjSfaAz9SlgRklfcWaiNshteS1k5y+rAn9oSWCOOTuM3mA==
X-Received: by 2002:a62:1d8f:: with SMTP id d137mr28339472pfd.11.1549733491720;
        Sat, 09 Feb 2019 09:31:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZXle2e09BQPa6uWEeEiy8VEVcoJ3+k8x2f4dQZTvd8ueTGSTLFM5ehm12jSHMitjsPB0S9
X-Received: by 2002:a62:1d8f:: with SMTP id d137mr28339418pfd.11.1549733490925;
        Sat, 09 Feb 2019 09:31:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549733490; cv=none;
        d=google.com; s=arc-20160816;
        b=GWJ0Ps7ZnRbgtVyn/94S2wGF55xqq5sitHwdVXKpVFapvfgHoQlBY1wyX4WD9wSIWe
         2Q2VEKi1BzHaYCH3htAQRPTUqoIP37BgyO0f6xJHREuWAE7lOPJDNqXvIsOuqJiaHPEA
         7iZMZW6x60eNL9JvmB3jmB+kOpjKn1QxKNma4RuVGnATUDXSaaVvUizXt0NRh6vDqndo
         dNpCMixRYqDn5p5XI4rbmlwKSsxxIt2uurfiEDWhofJJTtKLSu7l/f6SCuJqASsomSHP
         /NEr3XAydUNs9KuBU66G9GKUPy4eTTgrHbLt0Bbxx/7xpAc3ht3WAvoUiMbZScMtyS3d
         BaTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=nvj+7reFMkFLvbKZaeDSxZMOo553VBlZHr9t/sOOozc=;
        b=xdnVRn3w6NHGnQCJLx/f/8Ih5cMiGlfBwe3BSxljz8DHjgoqKadPTFlQ2VKCUAiyOb
         l8mz7R3ndcZ3OpC2jIxuyCix8PvQoj3YTRiVGrWtiNMOJumKuIeQnEP5RoYzis0aXhFH
         rZ46wSRE6IZZCw/bWpBErOPPxbRNMoGuvEDEUTJvxhPH09X17wfa+dxd8Wi99pYDF47O
         EPi8Y9apUy5C8pvN/i6fqBbIPip/B03iiL/y6/yqOTv1Leyt31Szzk6+rvvGFlzcxd9/
         AndPRm7f3eQ0NmZN/pNSfvRy3nK7KnZTKfjqCmEXh1LWjp74a7yRoFfVKlXy8KH9Z9sd
         2tyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g8si5958960pgo.166.2019.02.09.09.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Feb 2019 09:31:30 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Feb 2019 09:31:30 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,352,1544515200"; 
   d="scan'208";a="132330281"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 09 Feb 2019 09:31:29 -0800
From: ira.weiny@intel.com
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	x86@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH] mm/gup.c: Remove unused write variable
Date: Sat,  9 Feb 2019 09:31:09 -0800
Message-Id: <20190209173109.9361-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

write is unused in gup_fast_permitted so remove it.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 arch/x86/include/asm/pgtable_64.h | 3 +--
 mm/gup.c                          | 6 +++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 9c85b54bf03c..0bb566315621 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -259,8 +259,7 @@ extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
 #define gup_fast_permitted gup_fast_permitted
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages,
-		int write)
+static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
diff --git a/mm/gup.c b/mm/gup.c
index 05acd7e2eb22..b63e88eca31b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1786,7 +1786,7 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
  * we need to fall back to the slow version:
  */
-bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
+bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
@@ -1828,7 +1828,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write, pages, &nr);
 		local_irq_restore(flags);
@@ -1870,7 +1870,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return -EFAULT;
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
 		gup_pgd_range(addr, end, write, pages, &nr);
 		local_irq_enable();
-- 
2.20.1

