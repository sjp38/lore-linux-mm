Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 605F5C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:36:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D3F1218D3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:36:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D3F1218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0CB16B0007; Wed, 24 Apr 2019 06:36:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE2A36B0008; Wed, 24 Apr 2019 06:36:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CF1D6B000A; Wed, 24 Apr 2019 06:36:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49BED6B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:36:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f42so9629621edd.0
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:36:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=1BkxVNs+cGMQdjaUFsy6B4R6u7Bfe1a9kCj/aoC2Kfo=;
        b=AUjTl8I3raM+jxqHLhcEX1HME+X/jvoeX7hU9HIDYthFRqvd3KCefX3iqeqpUU1K57
         iHxFwlgTyg40XuBpuLLuhmXtRDHshd9OtwOo8MZxux388OPRVVZYYvnfXUE8oKZNQUUJ
         44Dr0FfLgpsYmDX4hPMgKasG5Scq7Bo/coR6x6rJhH6te+fLGrsXV5+nMNGM5rzt8PB/
         +bVRTWASnYZWjtxJGzmTxfH3sdyAs9k6xsxJevJX8Zl2r2RPhRCVHuXAzWkoSVvOBjse
         3hWGlia6ilYpWmgKdhJrPCCrAGcsuARUlTG0/2jLSVdDgkD5UPU6poJeHzNqT17SR3eP
         b5Zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUnzPirORGbKPaopTCftGfyiPZL24FNqeCVYuxrzfJvJCQqoVz6
	RXi1+DYZcaNBA6+ISICE8tG4jVQNeE8a0RSPIe85cfwu1ugqYuIG0FGn+MwUkBi0TOxJTzQ51Zi
	dKlWEgrwEVsd55aQytpN79+HmzuY2adu/zFtooRDgeQvs+TY8ZFe4CwmHe//CADR3bw==
X-Received: by 2002:a17:906:6a8e:: with SMTP id p14mr2521720ejr.295.1556102171664;
        Wed, 24 Apr 2019 03:36:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpR97uXetGNrGgQmPCh0QIXUj8wuiW9jMYtn6ic8zo7IZFVoaEYHDBqyDlEtpFO78JELjV
X-Received: by 2002:a17:906:6a8e:: with SMTP id p14mr2521645ejr.295.1556102169931;
        Wed, 24 Apr 2019 03:36:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556102169; cv=none;
        d=google.com; s=arc-20160816;
        b=WUWBbyxLMq4LCqlsG3guME9932SIaqo8lOlLuK7KYxtv6yiIrUs6uYstNXcfzUM41J
         +ewofpLXDO0LX/+kVRHnv+0a+5eIgWK2wk5pwdRVXyoTvwAhjB7N0tj/paehBsdkPrUI
         wXKh7xcAAMIRWkIPKcfo3rgaupnXHc1fd+wxCbnqQ+U97/7eyV7hvn6TUg6Hwbff/Lax
         fCEUE+kvhljT/rXKZGVH0SfaA+VGnGnqaKn+C1/XP/Dr8/yTL9UTgJH6KXeRyDTP1YDv
         mVb3rGmMhNmE5yBna89HMBBARMDsNLQP4tLzdc15/Lyqa3rmEYxQgdTfd69Yi5e2Vv/3
         vMRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=1BkxVNs+cGMQdjaUFsy6B4R6u7Bfe1a9kCj/aoC2Kfo=;
        b=0+Bg2e98sw0Et3LCwtomh+K+/bHgLZHMA/wgy7NlMRdMXNt0G+edbNO5qevJsgyESh
         ZDukRhMf04Q5DpIbHR4DqnyKswXmfQQln3fo84xDPMYfLAcf3mtUDaW3mBJRUZycZrQ6
         Fp0GRHps8COuhw1bswS9r79u96H9hRw82aOiiproxrt3qEu+yww/NsypKtTIRp9/Fh/7
         TuxyZTp4eaEKXg3uJcGiF710R8QTx+0JOQNLhgDyff+Veg8LJ2VOq2AvXm80Hult1hNM
         TYhcGJ7xfmAEPiF9J4pKBCBGAaG2vx/wWtvZ0tip5JOgfTkvr5MerfkIjxuLKOZNGXUV
         lnIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a17si1196744ejj.128.2019.04.24.03.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:36:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OAXlLV026554
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:36:08 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s2m7668es-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:36:07 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 11:36:04 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 11:35:56 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OAZtRN50987200
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 10:35:55 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3206B4C04A;
	Wed, 24 Apr 2019 10:35:55 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BBBA04C046;
	Wed, 24 Apr 2019 10:35:51 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 24 Apr 2019 10:35:51 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 24 Apr 2019 13:35:51 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>,
        Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>,
        James Hogan <jhogan@kernel.org>, Ley Foon Tan <lftan@altera.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
        Eric Biederman <ebiederm@xmission.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org,
        linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
        linux-mm@kvack.org, kexec@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] memblock: make keeping memblock memory opt-in rather than opt-out
Date: Wed, 24 Apr 2019 13:35:50 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19042410-4275-0000-0000-0000032C01A3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042410-4276-0000-0000-0000383B49D5
Message-Id: <1556102150-32517-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=708 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Most architectures do not need the memblock memory after the page allocator
is initialized, but only few enable ARCH_DISCARD_MEMBLOCK in the
arch Kconfig.

Replacing ARCH_DISCARD_MEMBLOCK with ARCH_KEEP_MEMBLOCK and inverting the
logic makes it clear which architectures actually use memblock after system
initialization and skips the necessity to add ARCH_DISCARD_MEMBLOCK to the
architectures that are still missing that option.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm/Kconfig         |  2 +-
 arch/arm64/Kconfig       |  1 +
 arch/hexagon/Kconfig     |  1 -
 arch/ia64/Kconfig        |  1 -
 arch/m68k/Kconfig        |  1 -
 arch/mips/Kconfig        |  1 -
 arch/nios2/Kconfig       |  1 -
 arch/powerpc/Kconfig     |  1 +
 arch/s390/Kconfig        |  1 +
 arch/sh/Kconfig          |  1 -
 arch/x86/Kconfig         |  1 -
 include/linux/memblock.h |  3 ++-
 kernel/kexec_file.c      | 16 ++++++++--------
 mm/Kconfig               |  2 +-
 mm/memblock.c            |  6 +++---
 mm/page_alloc.c          |  3 +--
 16 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 850b480..7073436 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -4,7 +4,6 @@ config ARM
 	default y
 	select ARCH_32BIT_OFF_T
 	select ARCH_CLOCKSOURCE_DATA
-	select ARCH_DISCARD_MEMBLOCK if !HAVE_ARCH_PFN_VALID && !KEXEC
 	select ARCH_HAS_DEBUG_VIRTUAL if MMU
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
@@ -21,6 +20,7 @@ config ARM
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAVE_CUSTOM_GPIO_H
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_KEEP_MEMBLOCK if HAVE_ARCH_PFN_VALID || KEXEC
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_NO_SG_CHAIN if !ARM_HAS_SG_CHAIN
 	select ARCH_OPTIONAL_KERNEL_RWX if ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7e34b9e..d71f043 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -58,6 +58,7 @@ config ARM64
 	select ARCH_INLINE_SPIN_UNLOCK_BH if !PREEMPT
 	select ARCH_INLINE_SPIN_UNLOCK_IRQ if !PREEMPT
 	select ARCH_INLINE_SPIN_UNLOCK_IRQRESTORE if !PREEMPT
+	select ARCH_KEEP_MEMBLOCK
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
diff --git a/arch/hexagon/Kconfig b/arch/hexagon/Kconfig
index ac44168..bbe3819 100644
--- a/arch/hexagon/Kconfig
+++ b/arch/hexagon/Kconfig
@@ -22,7 +22,6 @@ config HEXAGON
 	select GENERIC_IRQ_SHOW
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_TRACEHOOK
-	select ARCH_DISCARD_MEMBLOCK
 	select NEED_SG_DMA_LENGTH
 	select NO_IOPORT_MAP
 	select GENERIC_IOMAP
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8d7396b..bd51d3b 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -33,7 +33,6 @@ config IA64
 	select ARCH_HAS_DMA_COHERENT_TO_PFN if SWIOTLB
 	select ARCH_HAS_SYNC_DMA_FOR_CPU if SWIOTLB
 	select VIRT_TO_BUS
-	select ARCH_DISCARD_MEMBLOCK
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PENDING_IRQ if SMP
 	select GENERIC_IRQ_SHOW
diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index b542064..7d1e5d9 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -27,7 +27,6 @@ config M68K
 	select MODULES_USE_ELF_RELA
 	select OLD_SIGSUSPEND3
 	select OLD_SIGACTION
-	select ARCH_DISCARD_MEMBLOCK
 
 config CPU_BIG_ENDIAN
 	def_bool y
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 4a5f5b0..8b9298b 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -5,7 +5,6 @@ config MIPS
 	select ARCH_32BIT_OFF_T if !64BIT
 	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
 	select ARCH_CLOCKSOURCE_DATA
-	select ARCH_DISCARD_MEMBLOCK
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
index 4ef15a6..dc4239c 100644
--- a/arch/nios2/Kconfig
+++ b/arch/nios2/Kconfig
@@ -23,7 +23,6 @@ config NIOS2
 	select SPARSE_IRQ
 	select USB_ARCH_HAS_HCD if USB_SUPPORT
 	select CPU_NO_EFFICIENT_FFS
-	select ARCH_DISCARD_MEMBLOCK
 
 config GENERIC_CSUM
 	def_bool y
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2d0be82..39877b9 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -143,6 +143,7 @@ config PPC
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_HAS_ZONE_DEVICE		if PPC_BOOK3S_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
+	select ARCH_KEEP_MEMBLOCK
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select ARCH_OPTIONAL_KERNEL_RWX		if ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index b6e3d06..3eaf660 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -106,6 +106,7 @@ config S390
 	select ARCH_INLINE_WRITE_UNLOCK_BH
 	select ARCH_INLINE_WRITE_UNLOCK_IRQ
 	select ARCH_INLINE_WRITE_UNLOCK_IRQRESTORE
+	select ARCH_KEEP_MEMBLOCK
 	select ARCH_SAVE_PAGE_KEYS if HIBERNATION
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_SUPPORTS_NUMA_BALANCING
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index b1c91ea..418e928 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -10,7 +10,6 @@ config SUPERH
 	select DMA_DECLARE_COHERENT
 	select HAVE_IDE if HAS_IOPORT_MAP
 	select HAVE_MEMBLOCK_NODE_MAP
-	select ARCH_DISCARD_MEMBLOCK
 	select HAVE_OPROFILE
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_PERF_EVENTS
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 62fc3fd..80bc582 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -48,7 +48,6 @@ config X86
 	select ARCH_32BIT_OFF_T			if X86_32
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_CLOCKSOURCE_INIT
-	select ARCH_DISCARD_MEMBLOCK
 	select ARCH_HAS_ACPI_TABLE_UPGRADE	if ACPI
 	select ARCH_HAS_DEBUG_VIRTUAL
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 294d5d8..6ba69ba 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -96,13 +96,14 @@ struct memblock {
 extern struct memblock memblock;
 extern int memblock_debug;
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+#ifndef CONFIG_ARCH_KEEP_MEMBLOCK
 #define __init_memblock __meminit
 #define __initdata_memblock __meminitdata
 void memblock_discard(void);
 #else
 #define __init_memblock
 #define __initdata_memblock
+static inline void memblock_discard(void) {}
 #endif
 
 #define memblock_dbg(fmt, ...) \
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index f1d0e00..623b022 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -500,13 +500,7 @@ static int locate_mem_hole_callback(struct resource *res, void *arg)
 	return locate_mem_hole_bottom_up(start, end, kbuf);
 }
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-static int kexec_walk_memblock(struct kexec_buf *kbuf,
-			       int (*func)(struct resource *, void *))
-{
-	return 0;
-}
-#else
+#ifdef CONFIG_ARCH_KEEP_MEMBLOCK
 static int kexec_walk_memblock(struct kexec_buf *kbuf,
 			       int (*func)(struct resource *, void *))
 {
@@ -550,6 +544,12 @@ static int kexec_walk_memblock(struct kexec_buf *kbuf,
 
 	return ret;
 }
+#else
+static int kexec_walk_memblock(struct kexec_buf *kbuf,
+			       int (*func)(struct resource *, void *))
+{
+	return 0;
+}
 #endif
 
 /**
@@ -589,7 +589,7 @@ int kexec_locate_mem_hole(struct kexec_buf *kbuf)
 	if (kbuf->mem != KEXEC_BUF_MEM_UNKNOWN)
 		return 0;
 
-	if (IS_ENABLED(CONFIG_ARCH_DISCARD_MEMBLOCK))
+	if (!IS_ENABLED(CONFIG_ARCH_KEEP_MEMBLOCK))
 		ret = kexec_walk_resources(kbuf, locate_mem_hole_callback);
 	else
 		ret = kexec_walk_memblock(kbuf, locate_mem_hole_callback);
diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb..1e1c6ce 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -136,7 +136,7 @@ config HAVE_MEMBLOCK_PHYS_MAP
 config HAVE_GENERIC_GUP
 	bool
 
-config ARCH_DISCARD_MEMBLOCK
+config ARCH_KEEP_MEMBLOCK
 	bool
 
 config MEMORY_ISOLATION
diff --git a/mm/memblock.c b/mm/memblock.c
index e7665cf..d6b5755 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -94,7 +94,7 @@
  * :c:func:`mem_init` function frees all the memory to the buddy page
  * allocator.
  *
- * If an architecure enables %CONFIG_ARCH_DISCARD_MEMBLOCK, the
+ * Unless an architecure enables %CONFIG_ARCH_KEEP_MEMBLOCK, the
  * memblock data structures will be discarded after the system
  * initialization compltes.
  */
@@ -375,7 +375,7 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 	}
 }
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+#ifndef CONFIG_ARCH_KEEP_MEMBLOCK
 /**
  * memblock_discard - discard memory and reserved arrays if they were allocated
  */
@@ -1923,7 +1923,7 @@ unsigned long __init memblock_free_all(void)
 	return pages;
 }
 
-#if defined(CONFIG_DEBUG_FS) && !defined(CONFIG_ARCH_DISCARD_MEMBLOCK)
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_ARCH_KEEP_MEMBLOCK)
 
 static int memblock_debug_show(struct seq_file *m, void *private)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c6ce20a..a1825e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1831,10 +1831,9 @@ void __init page_alloc_init_late(void)
 	/* Reinit limits that are based on free pages after the kernel is up */
 	files_maxfiles_init();
 #endif
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+
 	/* Discard memblock private memory */
 	memblock_discard();
-#endif
 
 	for_each_populated_zone(zone)
 		set_zone_contiguous(zone);
-- 
2.7.4

