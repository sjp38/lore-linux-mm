Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB284C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C0B020811
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="XaRXIc7e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C0B020811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 289558E0004; Wed, 13 Feb 2019 08:28:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20F9D8E0001; Wed, 13 Feb 2019 08:28:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B7D28E0004; Wed, 13 Feb 2019 08:28:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5788E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:28:38 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id n12so958240wmc.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:28:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Pcq+KlYpunIsRMvl5N8urLfnQtGhYRhha0Fk42l8s1s=;
        b=URcUM+A/O9W5evAuPVVpovuGR9aXFbmUkAsOpi8ste9VpByyiq45WbV2V6Y5RVxRv5
         XoJ4kjjGU7GfFRb1T+pPx/iPbJUNYVXwLdgnKByy8Y6rmFo1YaN6UhxfqA3dzLrmUHXy
         /WzsmZoqa+L7rsil18NDinrIIyXrxtfKjYHce1PwozYgtdadX+oxod7efVaHGpLVGpVp
         UPMmAillf1t+K8blJRaGJVwQ3WabW0K0j47cXu/Xz5jSJ0chFQtaJH30rD7heXtvtilw
         9pukvQlvV9jTtjNhQwKwTEuT9UGWkfCDZ/RC9oZQWrS2HlhpBADA1ln0kAoreFv+9sZW
         GQ2Q==
X-Gm-Message-State: AHQUAuY6TQtDo2hD7TLUFDUPtbrHQIAVOcsJhQkcbUqLeeO+wQdfh4m+
	euMx8d9zizVWSDI8npq+V4K60z20JcW+2k3NdacUAoxnSfKG1QEMGYaHTcfAxSm//7fjHZo6sbj
	ZaVA5KcZ61+KnY2dxNlQdLlrqMVSIW7BKw1jFHXMkD8OPQp4BL8AnzoN0SiDG1GgQLgS1RQCXAi
	2QDuee2WXQzIjd0iSuj8LbvPD560Gj8C9tB1LHeml/JSMsQzpMu4Uh65zIRaJHgzIeld42Ya9P5
	ZxzzIRHjoOhAlBPMUVm8HJXXlldskvsLrJPRsJJSSLCwXZaFSiVN9hAzmFm8Ftybb4I59zN5ZdB
	dDLx6f2PPo4W3bqh7V1Kj7q6S7a0pP5wYuUx61sd+sMq8XHYk4OHFsEhquWm9SqnpaunNLBI5BT
	5
X-Received: by 2002:adf:e34b:: with SMTP id n11mr384041wrj.91.1550064518150;
        Wed, 13 Feb 2019 05:28:38 -0800 (PST)
X-Received: by 2002:adf:e34b:: with SMTP id n11mr383990wrj.91.1550064517183;
        Wed, 13 Feb 2019 05:28:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550064517; cv=none;
        d=google.com; s=arc-20160816;
        b=MIqaLnXnv/ve+4OcPxJFamIfSb3oBkPKFA1RX0OKf+EQqG+al4l7lh5ZIq+3r6ncAG
         x3/W/NzHlMsIn1sOaw85GLuV7JWftF03U+ejKZl3hWXQ0CmmQ1iPKHmWlv/OF8vTBWi9
         JfLEdmxGzQ7QgtzdiDNMaVD7qN930luYBW5TE7lfFNWUzES8L0zwjWb4vmenDTAbRWZV
         xfzzy7999QgCWd9wSytEdOyTmZYvuQzZ+yFIXinWRNFVeFjoG3MtGmdUK3+bdpmiIaKW
         GdfTJ9YT0LLs6bu2lnjAPv4WKWKMceVe7Fm+XCGw5+8YrSzs9aN1LYBtmcxCxWGyHGRW
         8KwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Pcq+KlYpunIsRMvl5N8urLfnQtGhYRhha0Fk42l8s1s=;
        b=HA7lvU4fuZ5MQ7Be9G75Ah4F3Kvd12c1rfTzZw8JW6l4NlW38nRZobXQEeXFNp5uu7
         P/5zM2N+GgapXYOffdbV+s3J+gIT2A0IhorTvHFPynQowIP41/0z+B31b2emK7ELMCpV
         4kk43L5Enq8BfauGdL/7UVMgyZc2WXqsLoZdX9jU3mT180qhQFXMnDDNbWJM27C7CFPe
         cVhYyYd3Pqvh1OydcqiDtlm9pZJTLU/AZroOYaw8D7txPV29NpDVgZOFgBsXXD2jUuv5
         xjvRKng5YlCbuqdsHnPEZI2FHf9DqAAcgX8nmiJsQgsPs1LH7SyquRdT/xAKwrJ3K+SQ
         D63w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=XaRXIc7e;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor3928905wmg.10.2019.02.13.05.28.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:28:37 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=XaRXIc7e;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Pcq+KlYpunIsRMvl5N8urLfnQtGhYRhha0Fk42l8s1s=;
        b=XaRXIc7epzKjHIVTj6gNKn5+cxg7Ghkp8lZNxiYHbAyxUEaVN56j4iYJwSBGp4aE5+
         3QtsoOGwtDEjEIWOIxO1KELBeSJsoPvpZMWwAUZuWkbyE4hL/iaEYYytZI7LdiWJNp4F
         zBvvY+Cg6ZwoATNYw5MH5Bol6+5YIWz5bpQgSbmH95qUuNmW47KjjSJBZ0yhPWl3/7yh
         JPpMXlDJW78MtIMTb8ofOkCuN+g+myvHgWJD1FWwJfHAHrXvU72K/0lO18i4HwWZEBWN
         qH2ecbpVXEo0QXCAaOEjBKcKuOPjgBjuJN9UtejMwy8ysfzsSZ0ljex08BxoljXBg7NW
         WNCQ==
X-Google-Smtp-Source: AHgI3IY0TrtAJNeV0o2sh6HPQrmepOLdzsvm4n2ugw3Q2kVjsFtdv4NzUra2Yf3t/+68plO2RUDw5A==
X-Received: by 2002:a7b:cb4a:: with SMTP id v10mr339024wmj.1.1550064516723;
        Wed, 13 Feb 2019 05:28:36 -0800 (PST)
Received: from localhost.localdomain (aputeaux-684-1-27-200.w90-86.abo.wanadoo.fr. [90.86.252.200])
        by smtp.gmail.com with ESMTPSA id x3sm22841195wrd.19.2019.02.13.05.28.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:28:35 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: linux-efi@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Marc Zyngier <marc.zyngier@arm.com>,
	James Morse <james.morse@arm.com>,
	linux-mm@kvack.org
Subject: [PATCH 1/2] arm64: account for GICv3 LPI tables in static memblock reserve table
Date: Wed, 13 Feb 2019 14:27:37 +0100
Message-Id: <20190213132738.10294-2-ard.biesheuvel@linaro.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the irqchip and EFI code, we have what basically amounts to a quirk
to work around a peculiarity in the GICv3 architecture, which permits
the system memory address of LPI tables to be programmable only once
after a CPU reset. This means kexec kernels must use the same memory
as the first kernel, and thus ensure that this memory has not been
given out for other purposes by the time the ITS init code runs, which
is not very early for secondary CPUs.

On systems with many CPUs, these reservations could overflow the
memblock reservation table, and this was addressed in commit
eff896288872 ("efi/arm: Defer persistent reservations until after
paging_init()"). However, this turns out to have made things worse,
since the allocation of page tables and heap space for the resized
memblock reservation table itself may overwrite the regions we are
attempting to reserve, which may cause all kinds of corruption,
also considering that the ITS will still be poking bits into that
memory in response to incoming MSIs.

So instead, let's grow the static memblock reservation table on such
systems so it can accommodate these reservations at an earlier time.
This will permit us to revert the above commit in a subsequent patch.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/include/asm/memory.h | 11 +++++++++++
 include/linux/memblock.h        |  3 ---
 mm/memblock.c                   | 10 ++++++++--
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index e1ec947e7c0c..7e2b13cdd970 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -332,6 +332,17 @@ static inline void *phys_to_virt(phys_addr_t x)
 #define virt_addr_valid(kaddr)		\
 	(_virt_addr_is_linear(kaddr) && _virt_addr_valid(kaddr))
 
+/*
+ * Given that the GIC architecture permits ITS implementations that can only be
+ * configured with a LPI table address once, GICv3 systems with many CPUs may
+ * end up reserving a lot of different regions after a kexec for their LPI
+ * tables, as we are forced to reuse the same memory after kexec (and thus
+ * reserve it persistently with EFI beforehand)
+ */
+#if defined(CONFIG_EFI) && defined(CONFIG_ARM_GIC_V3_ITS)
+#define INIT_MEMBLOCK_RESERVED_REGIONS	(INIT_MEMBLOCK_REGIONS + 2 * NR_CPUS)
+#endif
+
 #include <asm-generic/memory_model.h>
 
 #endif
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 64c41cf45590..859b55b66db2 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -29,9 +29,6 @@ extern unsigned long max_pfn;
  */
 extern unsigned long long max_possible_pfn;
 
-#define INIT_MEMBLOCK_REGIONS	128
-#define INIT_PHYSMEM_REGIONS	4
-
 /**
  * enum memblock_flags - definition of memory region attributes
  * @MEMBLOCK_NONE: no special request
diff --git a/mm/memblock.c b/mm/memblock.c
index 022d4cbb3618..a526c3ab8390 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -26,6 +26,12 @@
 
 #include "internal.h"
 
+#define INIT_MEMBLOCK_REGIONS		128
+#define INIT_PHYSMEM_REGIONS		4
+#ifndef INIT_MEMBLOCK_RESERVED_REGIONS
+#define INIT_MEMBLOCK_RESERVED_REGIONS	INIT_MEMBLOCK_REGIONS
+#endif
+
 /**
  * DOC: memblock overview
  *
@@ -92,7 +98,7 @@ unsigned long max_pfn;
 unsigned long long max_possible_pfn;
 
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
-static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
+static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_RESERVED_REGIONS] __initdata_memblock;
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
 static struct memblock_region memblock_physmem_init_regions[INIT_PHYSMEM_REGIONS] __initdata_memblock;
 #endif
@@ -105,7 +111,7 @@ struct memblock memblock __initdata_memblock = {
 
 	.reserved.regions	= memblock_reserved_init_regions,
 	.reserved.cnt		= 1,	/* empty dummy entry */
-	.reserved.max		= INIT_MEMBLOCK_REGIONS,
+	.reserved.max		= INIT_MEMBLOCK_RESERVED_REGIONS,
 	.reserved.name		= "reserved",
 
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
-- 
2.20.1

