Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 505186B0257
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:32:45 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so55143313pfn.3
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:32:45 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id yq2si8240933pac.19.2016.01.30.01.32.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:32:44 -0800 (PST)
Date: Sat, 30 Jan 2016 01:31:46 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-05fee7cfab7fa9d57e71f00bdd8fcff0cf5044a0@git.kernel.org>
Reply-To: bp@suse.de, toshi.kani@hp.com, k.kozlowski@samsung.com,
        torvalds@linux-foundation.org, tglx@linutronix.de,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        toshi.kani@hpe.com, bp@alien8.de, hpa@zytor.com, mcgrof@suse.com,
        peterz@infradead.org, brgerst@gmail.com, linux-mm@kvack.org,
        dvlasenk@redhat.com, kgene@kernel.org, mingo@kernel.org,
        luto@amacapital.net
In-Reply-To: <1453841853-11383-12-git-send-email-bp@alien8.de>
References: <1453841853-11383-12-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] arm/samsung: Change s3c_pm_run_res()
  to use System RAM type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: bp@suse.de, toshi.kani@hp.com, tglx@linutronix.de, k.kozlowski@samsung.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, bp@alien8.de, hpa@zytor.com, mcgrof@suse.com, toshi.kani@hpe.com, akpm@linux-foundation.org, brgerst@gmail.com, linux-mm@kvack.org, peterz@infradead.org, kgene@kernel.org, dvlasenk@redhat.com, luto@amacapital.net, mingo@kernel.org

Commit-ID:  05fee7cfab7fa9d57e71f00bdd8fcff0cf5044a0
Gitweb:     http://git.kernel.org/tip/05fee7cfab7fa9d57e71f00bdd8fcff0cf5044a0
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:27 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:58 +0100

arm/samsung: Change s3c_pm_run_res() to use System RAM type

Change s3c_pm_run_res() to check with IORESOURCE_SYSTEM_RAM,
instead of strcmp() with "System RAM", to walk through System
RAM ranges in the iomem table.

No functional change is made to the interface.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Kukjin Kim <kgene@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-samsung-soc@vger.kernel.org
Link: http://lkml.kernel.org/r/1453841853-11383-12-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/arm/plat-samsung/pm-check.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/plat-samsung/pm-check.c b/arch/arm/plat-samsung/pm-check.c
index 04aff2c..70f2f69 100644
--- a/arch/arm/plat-samsung/pm-check.c
+++ b/arch/arm/plat-samsung/pm-check.c
@@ -53,8 +53,8 @@ static void s3c_pm_run_res(struct resource *ptr, run_fn_t fn, u32 *arg)
 		if (ptr->child != NULL)
 			s3c_pm_run_res(ptr->child, fn, arg);
 
-		if ((ptr->flags & IORESOURCE_MEM) &&
-		    strcmp(ptr->name, "System RAM") == 0) {
+		if ((ptr->flags & IORESOURCE_SYSTEM_RAM)
+				== IORESOURCE_SYSTEM_RAM) {
 			S3C_PMDBG("Found system RAM at %08lx..%08lx\n",
 				  (unsigned long)ptr->start,
 				  (unsigned long)ptr->end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
