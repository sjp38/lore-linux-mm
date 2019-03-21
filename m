Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B7B4C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:19:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 096BC21900
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:19:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 096BC21900
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63AE36B0003; Thu, 21 Mar 2019 13:19:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E8D46B0006; Thu, 21 Mar 2019 13:19:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D9A26B0007; Thu, 21 Mar 2019 13:19:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEEB06B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:19:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s27so2491943eda.16
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:19:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=jmfx/JSXYecJsOvctr+SJKXE4hPgzOWGP3I1Kbn2drM=;
        b=dB5W6V1tF61DJ0YHzL0vuG93PMYzpTYpD9DDfjZouBjHXBq98Muu2YTJX7OHZ7ZC16
         aUNVdzwevTS3FGSQebRWp83yIi7dlsN+E/W9ewokqBTOGTT0jHhZbhg4toIGaA+cR72p
         SbKYil9S7f4u6Qbs7RNE/DjMEuCjzj5jyBbYHo1MeRfPugV1HI9eYTY4E454v0nYhgTy
         Ywkaeo3FMR53PfZYmyLhktGTBFjubNZt8T+eia18EY0J0wBQB6pHbo6keG/MMdcPGBCi
         yb4SX4qZFWiB7/9Kc4/uIV6iXEDw4fcBty8om9H+3PmZ/gAETN/cXBCZZhaJrVN1ybKx
         Hgnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX0CU3Ybqr3r/jDmOjtibS8LD7grsDep6Ge55hFu7Z32FOT4Q/w
	96+hwrSnrkNw/XqaeXDvfsjdrNnv2KcU/7+u4pWZhkntvii2GyFmfRGZKyOE8aRn0M2C90So7fQ
	j7J6y942C1itNJqL5VscrudLApb6yxP+nb4qiXtNGW/aRlNTsCBD0NyqRJ+REreKMVg==
X-Received: by 2002:a17:906:37d2:: with SMTP id o18mr2993771ejc.112.1553188769429;
        Thu, 21 Mar 2019 10:19:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv0chBVG5TghsLTYwdb/Gbr4yS8kmXc0yIMY1R5jlTkxFH9I+1AzRMeNjgBBfT7pzVc+Rd
X-Received: by 2002:a17:906:37d2:: with SMTP id o18mr2993717ejc.112.1553188768274;
        Thu, 21 Mar 2019 10:19:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553188768; cv=none;
        d=google.com; s=arc-20160816;
        b=vxGGSV0Vg4kfvmUZHeBJgGFJtbrGE0IxlPNml2rOQ/lKPR1oIz2kyeZsZRs54/VBlR
         sFKs5H73Kk876dpEnl4kQl3mHcEb569BdGl3MYUxzMncIVmG+vdgW8B97WZY6YSDsIlK
         7IO0e/jf6SK75XhuXfc/n5nABbC8qjqi3R62jZHjYO3uYrt3C/yy3rLCsIRkIEVyokXW
         KhztjhoBy50EGO0GaPphiPCsl6lvNf6P80mUjX2nwZHtg1bStBf24Y2oy7hNy6MQi9mC
         kwgwjUdwEgbOEzdVMypZ7OfUECUy+A1MyzSvcXUJ3TxRrDBmKXCpRjvoSIbXFraxod8e
         pH5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=jmfx/JSXYecJsOvctr+SJKXE4hPgzOWGP3I1Kbn2drM=;
        b=I/6HGMUN303iqMU+S26HeXC+rfK4aycIgiYHLG8v1yaQ69J0yv4UNknXj2OkcdZ7V9
         oQFRoKPpIRArG4w0FRgzMEdSbVAaL0/uwGpygQF679MrBfJND39rgv2rByggc6Y+IId7
         gCEbiVOB6UQqvjxFiWVVvu46T5JsqWbvnvzML7OOxA1unwL5971l4o4/d2A4GriC6CSu
         adO2Qn35dLjbANYN0ZJeptMcxV+oK5AD5eNKpfFvVGVAgAPQ76S3CEIIL+7OTF1vmtcW
         GC+6Wep2V0rm8x2anky4jIcbobR/17Snrqeoia8CHs3anHfkkvVjVKbnkyF+vwyuPWRv
         Tf8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i18si305534ede.28.2019.03.21.10.19.27
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 10:19:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0C606374;
	Thu, 21 Mar 2019 10:19:27 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 853EB3F614;
	Thu, 21 Mar 2019 10:19:25 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	Michael Ellerman <mpe@ellerman.id.au>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] kmemleak: powerpc: skip scanning holes in the .bss section
Date: Thu, 21 Mar 2019 17:19:17 +0000
Message-Id: <20190321171917.62049-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 2d4f567103ff ("KVM: PPC: Introduce kvm_tmp framework") adds
kvm_tmp[] into the .bss section and then free the rest of unused spaces
back to the page allocator.

kernel_init
  kvm_guest_init
    kvm_free_tmp
      free_reserved_area
        free_unref_page
          free_unref_page_prepare

With DEBUG_PAGEALLOC=y, it will unmap those pages from kernel. As the
result, kmemleak scan will trigger a panic when it scans the .bss
section with unmapped pages.

This patch creates dedicated kmemleak objects for the .data, .bss and
potentially .data..ro_after_init sections to allow partial freeing via
the kmemleak_free_part() in the powerpc kvm_free_tmp() function.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

Posting as a proper patch following the inlined one here:

http://lkml.kernel.org/r/20190320181656.GB38229@arrakis.emea.arm.com

Changes from the above:

- Added comment to the powerpc kmemleak_free_part() call

- Only register the .data..ro_after_init in kmemleak if not contained
  within the .data sections (which seems to be the case for lots of
  architectures)

I preserved part of Qian's original commit message but changed the
author since I rewrote the patch.

 arch/powerpc/kernel/kvm.c |  7 +++++++
 mm/kmemleak.c             | 16 +++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 683b5b3805bd..cd381e2291df 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -22,6 +22,7 @@
 #include <linux/kvm_host.h>
 #include <linux/init.h>
 #include <linux/export.h>
+#include <linux/kmemleak.h>
 #include <linux/kvm_para.h>
 #include <linux/slab.h>
 #include <linux/of.h>
@@ -712,6 +713,12 @@ static void kvm_use_magic_page(void)
 
 static __init void kvm_free_tmp(void)
 {
+	/*
+	 * Inform kmemleak about the hole in the .bss section since the
+	 * corresponding pages will be unmapped with DEBUG_PAGEALLOC=y.
+	 */
+	kmemleak_free_part(&kvm_tmp[kvm_tmp_index],
+			   ARRAY_SIZE(kvm_tmp) - kvm_tmp_index);
 	free_reserved_area(&kvm_tmp[kvm_tmp_index],
 			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
 }
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 707fa5579f66..6c318f5ac234 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1529,11 +1529,6 @@ static void kmemleak_scan(void)
 	}
 	rcu_read_unlock();
 
-	/* data/bss scanning */
-	scan_large_block(_sdata, _edata);
-	scan_large_block(__bss_start, __bss_stop);
-	scan_large_block(__start_ro_after_init, __end_ro_after_init);
-
 #ifdef CONFIG_SMP
 	/* per-cpu sections scanning */
 	for_each_possible_cpu(i)
@@ -2071,6 +2066,17 @@ void __init kmemleak_init(void)
 	}
 	local_irq_restore(flags);
 
+	/* register the data/bss sections */
+	create_object((unsigned long)_sdata, _edata - _sdata,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	create_object((unsigned long)__bss_start, __bss_stop - __bss_start,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	/* only register .data..ro_after_init if not within .data */
+	if (__start_ro_after_init < _sdata || __end_ro_after_init > _edata)
+		create_object((unsigned long)__start_ro_after_init,
+			      __end_ro_after_init - __start_ro_after_init,
+			      KMEMLEAK_GREY, GFP_ATOMIC);
+
 	/*
 	 * This is the point where tracking allocations is safe. Automatic
 	 * scanning is started during the late initcall. Add the early logged

