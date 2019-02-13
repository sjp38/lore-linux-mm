Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42ADEC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6970222CC
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="htxDPkLV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6970222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B22E8E0003; Wed, 13 Feb 2019 17:42:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660A18E0001; Wed, 13 Feb 2019 17:42:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5772C8E0003; Wed, 13 Feb 2019 17:42:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01A118E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:05 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e2so1420081wrv.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=kjAa+t6wY/NU2SY0EM7WFSE8Fn53OhOBDHc4ci8NYm0=;
        b=AYmeFB33jNHfkzWYd/dlIdhuCzzPTzGoYeiDyX5HC/8R77vH2pTjWqp8dKnSgVAbpS
         /gryM4t58miFGasLBoJ3+kRi8QXeOY0XU2OQY/ivIRCDqRpHjRPsEB+KIlNOy4Qh6F35
         gSlbLnhKw+yBk4l/p1+BLJnjxrsmUMeFJyanBpG1+DHsTy8Q8eG9pqM8cYnoxRHI3TaM
         RgZ86iK3BCTY7idwybwPM66PqLz8zdOnh+VZ8fwX+wgAjeALDmlZDKV/VIM0fn95CCS2
         nYnN80vk+MqxfU2cvjJwVFpapgLQy7alGtvdNmo8ljKs5wciwZNd6uIS/1dSo2xkej0+
         TR4Q==
X-Gm-Message-State: AHQUAubjE/FDQF+SIhaNCNCVYG8WGVaQpH934QTG/Q164jA/zHsvlduS
	LFPIdwgvtABSNi5luQnuAat+6xkZdSqZMF8g6gVw4590MZ6kbSvSPR7osM+kfipdirDklYFF9a9
	IAkawzilvCSBVc2ghng4AlDYnSHKlOupY46eksh3olULBusOUXZRX9dR52THvJYnstkzbLaCItR
	0/GOhJr3q+t3y7hvK02F1llRFe/Y3+eCdtEvWO7B0BvG1l/4Afczsjmz8Lasmw/ZSEerheAH3cd
	vWQqo/Hi3Gdisd7U87GXwrgj+UHvvK1TrdUlr2K+ecYUcDQDmLoDTyYeuu5pUm1GJ/FQih6+oxQ
	TlRYFKymXxUIhP+67Rk1Z/71ZUkmhwWJXUU3cxqvCdnm2HuipqvPLuQLxQFR1FmVrXXCRDkKYlf
	i
X-Received: by 2002:a1c:4406:: with SMTP id r6mr285806wma.114.1550097724432;
        Wed, 13 Feb 2019 14:42:04 -0800 (PST)
X-Received: by 2002:a1c:4406:: with SMTP id r6mr285756wma.114.1550097723042;
        Wed, 13 Feb 2019 14:42:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097723; cv=none;
        d=google.com; s=arc-20160816;
        b=U3FPondsc40989MtdXVdPM9hBRX5hBXPnuQHEsJxvE2zmceV66v0bKvjmj9/ECwh+4
         Qf/qVgDwulwZKJL8Aqp1CrJXyn4ykouwv41eHpu+NVweLS2fXcm8HW55wD+5+W4FSDgv
         50Ltz96ClJKzXPFHWpHpHZoMxYswvEbbZrvgMoBnsvPRQ59S4SqdOYn6ddmyvZzjrPAA
         pQZLao/+7w016lMyXeOi8jzBQuvDejrwt7HAG7fUFzaVAebpi+qSPUaxR++U6ROLzsF2
         c+21Sn+l1UEzlMLitRIffsF7RHvuorrpJc2iYe/pkhLjq6rNGyuumppnZwtCphZ6hduI
         oH3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=kjAa+t6wY/NU2SY0EM7WFSE8Fn53OhOBDHc4ci8NYm0=;
        b=KVIM/lfvAd/et+vK8/eSmuyajQ+fZGkkT/Nhfcv08Tw7pKxj3xNQVwPw4K5fG8mkIJ
         yVNOyREcXXZ5qKJYg9GNxd9U+/THiQhdSPiJgwE12zih+xe+OdNcrGoiI4ySUKBWhQGK
         ODPNAlsERfuzO4ewuqBwB/9Xk8egQYf4JU/9E1cShyNxIbgWNXnSZjuZOS7twXdRaqBp
         uo2NH9avnLnMYuTKiBcNejcjdEDkNQMa5hpI2Hq2ZvCgkeCuwZqWLcd9vEkcbepo8roH
         nGGUqKwMhNopM5s8UU6AsZpPJbkofUp+rGKo/ZiRqiQdHrRSjcfRMLBT5+j07yuTFtnH
         bN0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=htxDPkLV;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor375027wrr.32.2019.02.13.14.42.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:03 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=htxDPkLV;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=kjAa+t6wY/NU2SY0EM7WFSE8Fn53OhOBDHc4ci8NYm0=;
        b=htxDPkLVivpCFTEypIPdGV2Vzcy/7XwcJiFvkwrG1psnxGi0fwBH5MLtVcas4TkNf5
         2COfLAp/A9wWDZh7H5gt102tb7USgrH5kt07OADZ62iZ43snyIC276rQR5VrT/1El2/W
         xjBunUpUkSW+Qh91l934BeWTDHAQcJWiFP/kYDazdDd4vbtSNU+FJAvWw+fLPq7EvfFU
         Arlb671GTpQ1x/rP/Cvm4uNqUkB4YrSanMLjKsj5w2WO7E0A83BivOFJjTGARHAfpbCF
         WRHIGFlgf5iu7w8wz8WdPjUo1vptVV3XpP9jWK9oNCS8+VV96xSKRv+x4spertOFgrkH
         24iw==
X-Google-Smtp-Source: AHgI3IZj/GseIu78wPoR51yZNgKKZ1+PWmXGjgVTEqwtadfMaSne4o21po7GtJbpbfy7KQjSsZdPYA==
X-Received: by 2002:adf:dbc4:: with SMTP id e4mr322496wrj.320.1550097722567;
        Wed, 13 Feb 2019 14:42:02 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.41.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:01 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 02/12] __wr_after_init: linker section and attribute
Date: Thu, 14 Feb 2019 00:41:31 +0200
Message-Id: <c4c7df22ab55956bd8b0fee8bb38c3f543b478a0.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1550097697.git.igor.stoppa@huawei.com>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce a linker section and a matching attribute for statically
allocated write rare data. The attribute is named "__wr_after_init".
After the init phase is completed, this section will be modifiable only by
invoking write rare functions.
The section occupies a set of full pages, since the granularity
available for write protection is of one memory page.

The functionality is automatically activated by any architecture that sets
CONFIG_ARCH_HAS_PRMEM

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/Kconfig                      | 15 +++++++++++++++
 include/asm-generic/vmlinux.lds.h | 25 +++++++++++++++++++++++++
 include/linux/cache.h             | 21 +++++++++++++++++++++
 init/main.c                       |  3 +++
 4 files changed, 64 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 4cfb6de48f79..b0b6d176f1c1 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -808,6 +808,21 @@ config VMAP_STACK
 	  the stack to map directly to the KASAN shadow map using a formula
 	  that is incorrect if the stack is in vmalloc space.
 
+config ARCH_HAS_PRMEM
+	def_bool n
+	help
+	  architecture specific symbol stating that the architecture provides
+	  a back-end function for the write rare operation.
+
+config PRMEM
+	bool "Write protect critical data that doesn't need high write speed."
+	depends on ARCH_HAS_PRMEM
+	default y
+	help
+	  If the architecture supports it, statically allocated data which
+	  has been selected for hardening becomes (mostly) read-only.
+	  The selection happens by labelling the data "__wr_after_init".
+
 config ARCH_OPTIONAL_KERNEL_RWX
 	def_bool n
 
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 3d7a6a9c2370..ddb1fd608490 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -311,6 +311,30 @@
 	KEEP(*(__jump_table))						\
 	__stop___jump_table = .;
 
+/*
+ * Allow architectures to handle wr_after_init data on their
+ * own by defining an empty WR_AFTER_INIT_DATA.
+ * However, it's important that pages containing WR_RARE data do not
+ * hold anything else, to avoid both accidentally unprotecting something
+ * that is supposed to stay read-only all the time and also to protect
+ * something else that is supposed to be writeable all the time.
+ */
+#ifndef WR_AFTER_INIT_DATA
+#ifdef CONFIG_PRMEM
+#define WR_AFTER_INIT_DATA(align)					\
+	. = ALIGN(PAGE_SIZE);						\
+	__start_wr_after_init = .;					\
+	. = ALIGN(align);						\
+	*(.data..wr_after_init)						\
+	. = ALIGN(PAGE_SIZE);						\
+	__end_wr_after_init = .;					\
+	. = ALIGN(align);
+#else
+#define WR_AFTER_INIT_DATA(align)					\
+	. = ALIGN(align);
+#endif
+#endif
+
 /*
  * Allow architectures to handle ro_after_init data on their
  * own by defining an empty RO_AFTER_INIT_DATA.
@@ -332,6 +356,7 @@
 		__start_rodata = .;					\
 		*(.rodata) *(.rodata.*)					\
 		RO_AFTER_INIT_DATA	/* Read only after init */	\
+		WR_AFTER_INIT_DATA(align) /* wr after init */	\
 		KEEP(*(__vermagic))	/* Kernel version magic */	\
 		. = ALIGN(8);						\
 		__start___tracepoints_ptrs = .;				\
diff --git a/include/linux/cache.h b/include/linux/cache.h
index 750621e41d1c..09bd0b9284b6 100644
--- a/include/linux/cache.h
+++ b/include/linux/cache.h
@@ -31,6 +31,27 @@
 #define __ro_after_init __attribute__((__section__(".data..ro_after_init")))
 #endif
 
+/*
+ * __wr_after_init is used to mark objects that cannot be modified
+ * directly after init (i.e. after mark_rodata_ro() has been called).
+ * These objects become effectively read-only, from the perspective of
+ * performing a direct write, like a variable assignment.
+ * However, they can be altered through a dedicated function.
+ * It is intended for those objects which are occasionally modified after
+ * init, however they are modified so seldomly, that the extra cost from
+ * the indirect modification is either negligible or worth paying, for the
+ * sake of the protection gained.
+ */
+#ifndef __wr_after_init
+#ifdef CONFIG_PRMEM
+#define __wr_after_init \
+		__attribute__((__section__(".data..wr_after_init")))
+#else
+#define __wr_after_init
+#endif
+#endif
+
+
 #ifndef ____cacheline_aligned
 #define ____cacheline_aligned __attribute__((__aligned__(SMP_CACHE_BYTES)))
 #endif
diff --git a/init/main.c b/init/main.c
index c86a1c8f19f4..965e9fbc5452 100644
--- a/init/main.c
+++ b/init/main.c
@@ -496,6 +496,8 @@ void __init __weak thread_stack_cache_init(void)
 
 void __init __weak mem_encrypt_init(void) { }
 
+void __init __weak wr_init(void) { }
+
 bool initcall_debug;
 core_param(initcall_debug, initcall_debug, bool, 0644);
 
@@ -713,6 +715,7 @@ asmlinkage __visible void __init start_kernel(void)
 	cred_init();
 	fork_init();
 	proc_caches_init();
+	wr_init();
 	uts_ns_init();
 	buffer_init();
 	key_init();
-- 
2.19.1

