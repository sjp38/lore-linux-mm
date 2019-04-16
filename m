Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1C5FC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:24:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67F202087C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:24:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KiG0cUxH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67F202087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D42F66B02BA; Tue, 16 Apr 2019 11:24:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF3686B02BC; Tue, 16 Apr 2019 11:24:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBA836B02BD; Tue, 16 Apr 2019 11:24:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF996B02BA
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:24:53 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id 68so15791235ywb.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:24:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=k+wMVld4zmxabS+pCP9AhnVauur2/KBow8NxktCy9lU=;
        b=DFupXXioxMFxe1s/yLY0sQ33cMjQlfNU/DEiX/6Cdwg3fjrS/3duUaZEgI27rQEfdN
         Tk+TOONW0ksPpjRhE0QPc7MPG1ZO+9S5jegpA1s6FxMHYKGJp8w9bkWGCVaoekz8oUoT
         uqzs7qs9xpt+oHsSQ+f1Sm3HeJgA6nimZad0rm+P1qQREWvS4ybBkKqxcb1pioK9cX9l
         YZihcSkD5282CiKmLJElbKyLrNOW2b8KiZIvCzcpb6Kep6JOldgk/7G+ZaqGGsTcWA8b
         SmeP76Mce/gO5BZqx8Jxn1BnQWtlirzARiUuNeyP2s3BHvu2kt8AK8gI8/MW49VPIjdg
         Cuig==
X-Gm-Message-State: APjAAAVl9fH/6nt7/x60fzJTTMKFGRn7DEPcj2X61AOZW1QjdPa4yaWx
	piVZ3SAxSu9aZbalmxaLLvo/hPkgKnGtisCcpqI8kn6bOq4TAY82UjdnNY6kBeqi3YC14C8CMpy
	7khq73mTvvtC3qJz5BgBc8ohyDAtKfM102RpgtglHMtF5XBwNfLfSgEfgCODgnrrnhg==
X-Received: by 2002:a25:c0d6:: with SMTP id c205mr66910589ybf.61.1555428293185;
        Tue, 16 Apr 2019 08:24:53 -0700 (PDT)
X-Received: by 2002:a25:c0d6:: with SMTP id c205mr66910366ybf.61.1555428290818;
        Tue, 16 Apr 2019 08:24:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555428290; cv=none;
        d=google.com; s=arc-20160816;
        b=wFtgWP+vvr9Zh150CtJHZ4memgVhXVhHfdqQIBBHsQ1o5dcFpFDmPTz6IYVNkwkzte
         YTLQ3WjJb5n9U0HL5UwZwAq82qc5hQVs9a2xk+cp8YSIOidmCr6dr7oouzaxYunwysZV
         cEiyXpONJUD0f6Fi4aNRRDePLOoCpqYzoX3U7Z1yVhYF2PLK9GrP9YNTohP62R68Rsd3
         bbYdnXyrMOgOdxe261eWdQxAjlZsnjJZk/FfnZ/Eec1/HjeHju2y2dniDWAaPWgjXfXI
         grhdNYzaWAEV3K0813cnvwyPzvSf/RFDEvGPryxU308PLhT4vYytTo+JwKkkt7ZpChWs
         6DlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=k+wMVld4zmxabS+pCP9AhnVauur2/KBow8NxktCy9lU=;
        b=zcuKYoSD3n1OM4/IrGgLYbnNb8fGU9Ey9cpTXNRFPIwUF2m/HMgcs+vXvf5v6/lU81
         tV74vwF84Mw+dQgCd+bFWXqizPK1iw2Ebz1y727SqyzFyJ3lXIOi1oSB/i20K48e+2JK
         cov7pX1olLZdcFss0QtMxnudDwKg6gk/UQ7qpWPagEiZ2LuKGQF6XjDUa9LROfzAKAjt
         vdXWRm+2Rjf+EQrP2bs+6LF4wEt5YGAH3xDElnjaiG5dE/K6LrVujXeqXU36BnKbJM++
         UIzJv0Oi9lFXLFlDFJuuMbsUcn1v9QLP0mENdj/OtUzq8Go8/ZIMgKFQEHn8A6NO80jh
         CFuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KiG0cUxH;
       spf=pass (google.com: domain of nishadkamdar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nishadkamdar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d136sor23143684ybh.49.2019.04.16.08.24.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 08:24:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of nishadkamdar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KiG0cUxH;
       spf=pass (google.com: domain of nishadkamdar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nishadkamdar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=k+wMVld4zmxabS+pCP9AhnVauur2/KBow8NxktCy9lU=;
        b=KiG0cUxHIiCDuCwPTb5UDQogoMF4T7oRuM1EaS9kS2qrhwAofCeS0Ftt6rarqCfMYq
         exAViQT1LuAXuGnQ/CseZ2fByuvvAmCweidWaHZA9+2WC7//UNDJc9CH/a4GTMB2lYNb
         zHpC8GLVKXhU+q2tgjVkRCyhCXuxz62aB/tLfmme7X+oUdxXOOHgAzWi9PgGWmqdXmX7
         LBT9yKGvL+DGE9y5j41cTwbwnc1kO382vr0CXnGEutdQJaDQhu9LyXpx4x9kZ+u9Ps8F
         anj0cWI5SPwMN1hqDt9caG1+6oRx46BHWbRduAQ8bcfu0syugDaOQhZ9Qq04ccynejar
         QxOg==
X-Google-Smtp-Source: APXvYqzEhwuefjZFPiYe50yoISo4oV4E+YvR9IoG9+Nr3R58tQtmLSbBzHenvAa9uId9VDefL4weVw==
X-Received: by 2002:a25:e757:: with SMTP id e84mr68447719ybh.259.1555428290146;
        Tue, 16 Apr 2019 08:24:50 -0700 (PDT)
Received: from nishad ([2406:7400:54:eb3:d9be:857a:cd1e:eb7f])
        by smtp.gmail.com with ESMTPSA id q6sm24123343ywq.77.2019.04.16.08.24.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 08:24:48 -0700 (PDT)
Date: Tue, 16 Apr 2019 20:54:35 +0530
From: Nishad Kamdar <nishadkamdar@gmail.com>
To: Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joe Perches <joe@perches.com>,
	Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v3 2/5] nds32: Use the correct style for SPDX License
 Identifier
Message-ID: <f6a7c31f4e8b743a2877875ac3fc49ecb8b9eb0c.1555427419.git.nishadkamdar@gmail.com>
References: <cover.1555427418.git.nishadkamdar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1555427418.git.nishadkamdar@gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch corrects the SPDX License Identifier style
in the nds32 Hardware Architecture related files.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Nishad Kamdar <nishadkamdar@gmail.com>
---
 arch/nds32/include/asm/assembler.h       | 2 +-
 arch/nds32/include/asm/barrier.h         | 2 +-
 arch/nds32/include/asm/bitfield.h        | 2 +-
 arch/nds32/include/asm/cache.h           | 2 +-
 arch/nds32/include/asm/cache_info.h      | 2 +-
 arch/nds32/include/asm/cacheflush.h      | 2 +-
 arch/nds32/include/asm/current.h         | 2 +-
 arch/nds32/include/asm/delay.h           | 2 +-
 arch/nds32/include/asm/elf.h             | 2 +-
 arch/nds32/include/asm/fixmap.h          | 2 +-
 arch/nds32/include/asm/futex.h           | 2 +-
 arch/nds32/include/asm/highmem.h         | 2 +-
 arch/nds32/include/asm/io.h              | 2 +-
 arch/nds32/include/asm/irqflags.h        | 2 +-
 arch/nds32/include/asm/l2_cache.h        | 2 +-
 arch/nds32/include/asm/linkage.h         | 2 +-
 arch/nds32/include/asm/memory.h          | 2 +-
 arch/nds32/include/asm/mmu.h             | 2 +-
 arch/nds32/include/asm/mmu_context.h     | 2 +-
 arch/nds32/include/asm/module.h          | 2 +-
 arch/nds32/include/asm/nds32.h           | 2 +-
 arch/nds32/include/asm/page.h            | 2 +-
 arch/nds32/include/asm/pgalloc.h         | 2 +-
 arch/nds32/include/asm/pgtable.h         | 2 +-
 arch/nds32/include/asm/proc-fns.h        | 2 +-
 arch/nds32/include/asm/processor.h       | 2 +-
 arch/nds32/include/asm/ptrace.h          | 2 +-
 arch/nds32/include/asm/shmparam.h        | 2 +-
 arch/nds32/include/asm/string.h          | 2 +-
 arch/nds32/include/asm/swab.h            | 2 +-
 arch/nds32/include/asm/syscall.h         | 2 +-
 arch/nds32/include/asm/syscalls.h        | 2 +-
 arch/nds32/include/asm/thread_info.h     | 2 +-
 arch/nds32/include/asm/tlb.h             | 2 +-
 arch/nds32/include/asm/tlbflush.h        | 2 +-
 arch/nds32/include/asm/uaccess.h         | 2 +-
 arch/nds32/include/asm/unistd.h          | 2 +-
 arch/nds32/include/asm/vdso.h            | 2 +-
 arch/nds32/include/asm/vdso_datapage.h   | 2 +-
 arch/nds32/include/asm/vdso_timer_info.h | 2 +-
 arch/nds32/include/uapi/asm/auxvec.h     | 2 +-
 arch/nds32/include/uapi/asm/byteorder.h  | 2 +-
 arch/nds32/include/uapi/asm/cachectl.h   | 2 +-
 arch/nds32/include/uapi/asm/param.h      | 2 +-
 arch/nds32/include/uapi/asm/ptrace.h     | 2 +-
 arch/nds32/include/uapi/asm/sigcontext.h | 2 +-
 arch/nds32/include/uapi/asm/unistd.h     | 2 +-
 47 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/arch/nds32/include/asm/assembler.h b/arch/nds32/include/asm/assembler.h
index c3855782a541..5e7c56926049 100644
--- a/arch/nds32/include/asm/assembler.h
+++ b/arch/nds32/include/asm/assembler.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_ASSEMBLER_H__
diff --git a/arch/nds32/include/asm/barrier.h b/arch/nds32/include/asm/barrier.h
index faafc373ea6c..16413172fd50 100644
--- a/arch/nds32/include/asm/barrier.h
+++ b/arch/nds32/include/asm/barrier.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_ASM_BARRIER_H
diff --git a/arch/nds32/include/asm/bitfield.h b/arch/nds32/include/asm/bitfield.h
index 7414fcbbab4e..e75212c76b20 100644
--- a/arch/nds32/include/asm/bitfield.h
+++ b/arch/nds32/include/asm/bitfield.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_BITFIELD_H__
diff --git a/arch/nds32/include/asm/cache.h b/arch/nds32/include/asm/cache.h
index 347db4881c5f..fc3c41b59169 100644
--- a/arch/nds32/include/asm/cache.h
+++ b/arch/nds32/include/asm/cache.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_CACHE_H__
diff --git a/arch/nds32/include/asm/cache_info.h b/arch/nds32/include/asm/cache_info.h
index 38ec458ba543..e89d8078f3a6 100644
--- a/arch/nds32/include/asm/cache_info.h
+++ b/arch/nds32/include/asm/cache_info.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 struct cache_info {
diff --git a/arch/nds32/include/asm/cacheflush.h b/arch/nds32/include/asm/cacheflush.h
index 8b26198d51bb..d9ac7e6408ef 100644
--- a/arch/nds32/include/asm/cacheflush.h
+++ b/arch/nds32/include/asm/cacheflush.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_CACHEFLUSH_H__
diff --git a/arch/nds32/include/asm/current.h b/arch/nds32/include/asm/current.h
index b4dcd22b7bcb..65d30096142b 100644
--- a/arch/nds32/include/asm/current.h
+++ b/arch/nds32/include/asm/current.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASM_NDS32_CURRENT_H
diff --git a/arch/nds32/include/asm/delay.h b/arch/nds32/include/asm/delay.h
index 519ba97acb6e..56ea3894f8f8 100644
--- a/arch/nds32/include/asm/delay.h
+++ b/arch/nds32/include/asm/delay.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_DELAY_H__
diff --git a/arch/nds32/include/asm/elf.h b/arch/nds32/include/asm/elf.h
index 02250626b9f0..1c8e56d7013d 100644
--- a/arch/nds32/include/asm/elf.h
+++ b/arch/nds32/include/asm/elf.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASMNDS32_ELF_H
diff --git a/arch/nds32/include/asm/fixmap.h b/arch/nds32/include/asm/fixmap.h
index 0e60e153a71a..5a4bf11e5800 100644
--- a/arch/nds32/include/asm/fixmap.h
+++ b/arch/nds32/include/asm/fixmap.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_FIXMAP_H
diff --git a/arch/nds32/include/asm/futex.h b/arch/nds32/include/asm/futex.h
index baf178bf1d0b..5213c65c2e0b 100644
--- a/arch/nds32/include/asm/futex.h
+++ b/arch/nds32/include/asm/futex.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_FUTEX_H__
diff --git a/arch/nds32/include/asm/highmem.h b/arch/nds32/include/asm/highmem.h
index 425d546cb059..b3a82c97ded3 100644
--- a/arch/nds32/include/asm/highmem.h
+++ b/arch/nds32/include/asm/highmem.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASM_HIGHMEM_H
diff --git a/arch/nds32/include/asm/io.h b/arch/nds32/include/asm/io.h
index 5ef8ae5ba833..16f262322b8f 100644
--- a/arch/nds32/include/asm/io.h
+++ b/arch/nds32/include/asm/io.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_IO_H
diff --git a/arch/nds32/include/asm/irqflags.h b/arch/nds32/include/asm/irqflags.h
index 2bfd00f8bc48..fb45ec46bb1b 100644
--- a/arch/nds32/include/asm/irqflags.h
+++ b/arch/nds32/include/asm/irqflags.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #include <asm/nds32.h>
diff --git a/arch/nds32/include/asm/l2_cache.h b/arch/nds32/include/asm/l2_cache.h
index 37dd5ef61de8..3ea48e19e6de 100644
--- a/arch/nds32/include/asm/l2_cache.h
+++ b/arch/nds32/include/asm/l2_cache.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef L2_CACHE_H
diff --git a/arch/nds32/include/asm/linkage.h b/arch/nds32/include/asm/linkage.h
index e708c8bdb926..a696469abb70 100644
--- a/arch/nds32/include/asm/linkage.h
+++ b/arch/nds32/include/asm/linkage.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_LINKAGE_H
diff --git a/arch/nds32/include/asm/memory.h b/arch/nds32/include/asm/memory.h
index 60efc726b56e..3f4b5eeb5be2 100644
--- a/arch/nds32/include/asm/memory.h
+++ b/arch/nds32/include/asm/memory.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_MEMORY_H
diff --git a/arch/nds32/include/asm/mmu.h b/arch/nds32/include/asm/mmu.h
index 88b9ee8c1064..89d63afee455 100644
--- a/arch/nds32/include/asm/mmu.h
+++ b/arch/nds32/include/asm/mmu.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_MMU_H
diff --git a/arch/nds32/include/asm/mmu_context.h b/arch/nds32/include/asm/mmu_context.h
index fd7d13cefccc..b8fd3d189fdc 100644
--- a/arch/nds32/include/asm/mmu_context.h
+++ b/arch/nds32/include/asm/mmu_context.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_MMU_CONTEXT_H
diff --git a/arch/nds32/include/asm/module.h b/arch/nds32/include/asm/module.h
index 16cf9c7237ad..a3a08e993c65 100644
--- a/arch/nds32/include/asm/module.h
+++ b/arch/nds32/include/asm/module.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASM_NDS32_MODULE_H
diff --git a/arch/nds32/include/asm/nds32.h b/arch/nds32/include/asm/nds32.h
index 68c38151c3e4..4994f6a9e0a0 100644
--- a/arch/nds32/include/asm/nds32.h
+++ b/arch/nds32/include/asm/nds32.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASM_NDS32_NDS32_H_
diff --git a/arch/nds32/include/asm/page.h b/arch/nds32/include/asm/page.h
index 947f0491c9a7..8feb1fa12f01 100644
--- a/arch/nds32/include/asm/page.h
+++ b/arch/nds32/include/asm/page.h
@@ -1,5 +1,5 @@
+/* SPDX-License-Identifier: GPL-2.0 */
 /*
- * SPDX-License-Identifier: GPL-2.0
  * Copyright (C) 2005-2017 Andes Technology Corporation
  */
 
diff --git a/arch/nds32/include/asm/pgalloc.h b/arch/nds32/include/asm/pgalloc.h
index 3c5fee5b5759..3cbc749c79aa 100644
--- a/arch/nds32/include/asm/pgalloc.h
+++ b/arch/nds32/include/asm/pgalloc.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASMNDS32_PGALLOC_H
diff --git a/arch/nds32/include/asm/pgtable.h b/arch/nds32/include/asm/pgtable.h
index ee59c1f9e4fc..c70cc56bec09 100644
--- a/arch/nds32/include/asm/pgtable.h
+++ b/arch/nds32/include/asm/pgtable.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASMNDS32_PGTABLE_H
diff --git a/arch/nds32/include/asm/proc-fns.h b/arch/nds32/include/asm/proc-fns.h
index bedc4f59e064..27c617fa77af 100644
--- a/arch/nds32/include/asm/proc-fns.h
+++ b/arch/nds32/include/asm/proc-fns.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_PROCFNS_H__
diff --git a/arch/nds32/include/asm/processor.h b/arch/nds32/include/asm/processor.h
index 72024f8bc129..b82369c7659d 100644
--- a/arch/nds32/include/asm/processor.h
+++ b/arch/nds32/include/asm/processor.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_PROCESSOR_H
diff --git a/arch/nds32/include/asm/ptrace.h b/arch/nds32/include/asm/ptrace.h
index c4538839055c..919ee223620c 100644
--- a/arch/nds32/include/asm/ptrace.h
+++ b/arch/nds32/include/asm/ptrace.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_PTRACE_H
diff --git a/arch/nds32/include/asm/shmparam.h b/arch/nds32/include/asm/shmparam.h
index fd1cff64b68e..3aeee946973d 100644
--- a/arch/nds32/include/asm/shmparam.h
+++ b/arch/nds32/include/asm/shmparam.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASMNDS32_SHMPARAM_H
diff --git a/arch/nds32/include/asm/string.h b/arch/nds32/include/asm/string.h
index 179272caa540..cae8fe16de98 100644
--- a/arch/nds32/include/asm/string.h
+++ b/arch/nds32/include/asm/string.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_STRING_H
diff --git a/arch/nds32/include/asm/swab.h b/arch/nds32/include/asm/swab.h
index e01a755a37d2..362a466f2976 100644
--- a/arch/nds32/include/asm/swab.h
+++ b/arch/nds32/include/asm/swab.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_SWAB_H__
diff --git a/arch/nds32/include/asm/syscall.h b/arch/nds32/include/asm/syscall.h
index 174b8571d362..899b2fb4b52f 100644
--- a/arch/nds32/include/asm/syscall.h
+++ b/arch/nds32/include/asm/syscall.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2008-2009 Red Hat, Inc.  All rights reserved.
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
diff --git a/arch/nds32/include/asm/syscalls.h b/arch/nds32/include/asm/syscalls.h
index da32101b455d..f3b16f602cb5 100644
--- a/arch/nds32/include/asm/syscalls.h
+++ b/arch/nds32/include/asm/syscalls.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_SYSCALLS_H
diff --git a/arch/nds32/include/asm/thread_info.h b/arch/nds32/include/asm/thread_info.h
index bff741ff337b..3734b1c1cf82 100644
--- a/arch/nds32/include/asm/thread_info.h
+++ b/arch/nds32/include/asm/thread_info.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_THREAD_INFO_H
diff --git a/arch/nds32/include/asm/tlb.h b/arch/nds32/include/asm/tlb.h
index d5ae571c8d30..a8aff1c8b4f4 100644
--- a/arch/nds32/include/asm/tlb.h
+++ b/arch/nds32/include/asm/tlb.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASMNDS32_TLB_H
diff --git a/arch/nds32/include/asm/tlbflush.h b/arch/nds32/include/asm/tlbflush.h
index 38ee769b18d8..97155366ea01 100644
--- a/arch/nds32/include/asm/tlbflush.h
+++ b/arch/nds32/include/asm/tlbflush.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASMNDS32_TLBFLUSH_H
diff --git a/arch/nds32/include/asm/uaccess.h b/arch/nds32/include/asm/uaccess.h
index 116598b47c4d..8916ad9f9f13 100644
--- a/arch/nds32/include/asm/uaccess.h
+++ b/arch/nds32/include/asm/uaccess.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASMANDES_UACCESS_H
diff --git a/arch/nds32/include/asm/unistd.h b/arch/nds32/include/asm/unistd.h
index b586a2862beb..bf5e2d440913 100644
--- a/arch/nds32/include/asm/unistd.h
+++ b/arch/nds32/include/asm/unistd.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #define __ARCH_WANT_SYS_CLONE
diff --git a/arch/nds32/include/asm/vdso.h b/arch/nds32/include/asm/vdso.h
index af2c6afc2469..89b113ffc3dc 100644
--- a/arch/nds32/include/asm/vdso.h
+++ b/arch/nds32/include/asm/vdso.h
@@ -1,5 +1,5 @@
+/* SPDX-License-Identifier: GPL-2.0 */
 /*
- * SPDX-License-Identifier: GPL-2.0
  * Copyright (C) 2005-2017 Andes Technology Corporation
  */
 
diff --git a/arch/nds32/include/asm/vdso_datapage.h b/arch/nds32/include/asm/vdso_datapage.h
index 79db5a12ca5e..cd1dda3da0f9 100644
--- a/arch/nds32/include/asm/vdso_datapage.h
+++ b/arch/nds32/include/asm/vdso_datapage.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2012 ARM Limited
 // Copyright (C) 2005-2017 Andes Technology Corporation
 #ifndef __ASM_VDSO_DATAPAGE_H
diff --git a/arch/nds32/include/asm/vdso_timer_info.h b/arch/nds32/include/asm/vdso_timer_info.h
index 50ba117cff12..328439ce37db 100644
--- a/arch/nds32/include/asm/vdso_timer_info.h
+++ b/arch/nds32/include/asm/vdso_timer_info.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 extern struct timer_info_t timer_info;
diff --git a/arch/nds32/include/uapi/asm/auxvec.h b/arch/nds32/include/uapi/asm/auxvec.h
index 2d3213f5e595..b5d58ea8decb 100644
--- a/arch/nds32/include/uapi/asm/auxvec.h
+++ b/arch/nds32/include/uapi/asm/auxvec.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_AUXVEC_H
diff --git a/arch/nds32/include/uapi/asm/byteorder.h b/arch/nds32/include/uapi/asm/byteorder.h
index a23f6f3a2468..511e653c709d 100644
--- a/arch/nds32/include/uapi/asm/byteorder.h
+++ b/arch/nds32/include/uapi/asm/byteorder.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __NDS32_BYTEORDER_H__
diff --git a/arch/nds32/include/uapi/asm/cachectl.h b/arch/nds32/include/uapi/asm/cachectl.h
index 4cdca9b23974..73793662815c 100644
--- a/arch/nds32/include/uapi/asm/cachectl.h
+++ b/arch/nds32/include/uapi/asm/cachectl.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 1994, 1995, 1996 by Ralf Baechle
 // Copyright (C) 2005-2017 Andes Technology Corporation
 #ifndef	_ASM_CACHECTL
diff --git a/arch/nds32/include/uapi/asm/param.h b/arch/nds32/include/uapi/asm/param.h
index e3fb723ee362..2977534a6bd3 100644
--- a/arch/nds32/include/uapi/asm/param.h
+++ b/arch/nds32/include/uapi/asm/param.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __ASM_NDS32_PARAM_H
diff --git a/arch/nds32/include/uapi/asm/ptrace.h b/arch/nds32/include/uapi/asm/ptrace.h
index 358c99e399d0..1a6e01c00e6f 100644
--- a/arch/nds32/include/uapi/asm/ptrace.h
+++ b/arch/nds32/include/uapi/asm/ptrace.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef __UAPI_ASM_NDS32_PTRACE_H
diff --git a/arch/nds32/include/uapi/asm/sigcontext.h b/arch/nds32/include/uapi/asm/sigcontext.h
index 58afc416473e..628ff6b75825 100644
--- a/arch/nds32/include/uapi/asm/sigcontext.h
+++ b/arch/nds32/include/uapi/asm/sigcontext.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #ifndef _ASMNDS32_SIGCONTEXT_H
diff --git a/arch/nds32/include/uapi/asm/unistd.h b/arch/nds32/include/uapi/asm/unistd.h
index 4ec8f543103f..c691735017ed 100644
--- a/arch/nds32/include/uapi/asm/unistd.h
+++ b/arch/nds32/include/uapi/asm/unistd.h
@@ -1,4 +1,4 @@
-// SPDX-License-Identifier: GPL-2.0
+/* SPDX-License-Identifier: GPL-2.0 */
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #define __ARCH_WANT_STAT64
-- 
2.17.1

