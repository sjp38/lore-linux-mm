Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61D6EC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A3C8216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="kZwz3XiA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A3C8216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A58A28E0007; Mon, 29 Jul 2019 10:21:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E0AA8E0002; Mon, 29 Jul 2019 10:21:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F7EC8E0007; Mon, 29 Jul 2019 10:21:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6C88E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:21:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b18so38335877pgg.8
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:21:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=Zf3jc8HWC2FhBJTkFsSU0AZw5tKbElkfkf9gyrMCly7EwKD2pqBRMmxbL2L5oOOiBk
         xV7/7s2LIzV96W9xKWCxlh/uXc4baKaYTKkr72oRjBTRLCYFoEjDkPMaVdGBgJuDKgKY
         rdoA31hlXofpKN2x6KN94B1JPezEsRLJ5PFyyu26yl36tHyhrq2/hciUIfLgd+T/1lWy
         rLtPWKuMnW+40SB2D4hx/nuFM3+5z920mXxxEmw+vhkg7SgYoEaFLZM4tRSxZpE1/BKo
         o7EBH8Y4HWIpLhGBbkZQUl4USCQ+wnqhLnvVMigx0pwxe8K8qw0G/4lMVmI2qNLgsPRI
         khvQ==
X-Gm-Message-State: APjAAAVRcurSMzV1qwM0u06p3JKbaFgPyK3L3bLYtNC04K3rVlpsGGUV
	w14MNyTJPG/KaGApkdjNJGSMvkXyzlaZlDzB9J2FtyA6ecHjJHTQP6Yisy7UvUmUTiO2UrH9Lea
	VeqjaMBV4o0b9Eq2ii8jJ0t6ll8iBXxidS6pfwSGKnqIisSWhIhLubeVtSDPWynLlZQ==
X-Received: by 2002:a17:90a:ac11:: with SMTP id o17mr113774036pjq.134.1564410086015;
        Mon, 29 Jul 2019 07:21:26 -0700 (PDT)
X-Received: by 2002:a17:90a:ac11:: with SMTP id o17mr113773978pjq.134.1564410085303;
        Mon, 29 Jul 2019 07:21:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410085; cv=none;
        d=google.com; s=arc-20160816;
        b=sxGQqQ1RbzerwQLyfl0dPzPwkqYfLlHcjj3MFxTjzx+RNRBSGQNNNuWpz2FJMOC7L6
         evY2XkoZOcS/adWRZjfSsiQHfOrEOixflNGC6PPOIThDQC7mfZt9drRUc3o+EjTEtdnm
         rZmW4bur9dBScO6GR/TqdOUaBO9/82axeVPoeUZ9VfTTv3DHcrn/WLY99ogN/RmanJVb
         idEzacuAg/R0YeEf1Oy2VoUIVuSyrspp0FIBAOW4r5ZkoMabcGkA0ozFZ6yDu7L/DpRA
         P08LF1B0akvC78+4jvdYOBbXISmAg3ICahtsaJZTNUNfPsJKibQ+SqVW2/cDtT0iBtYg
         vBvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=eDeaih8wlCHwRZmZCWtbnSfgPIpwUwoF+W7kAy0y7CuL4fXWGrtqZdvr7d56zVV4DW
         9p/AUUJvGq7JC/8bM9oy5z1CtFfcw1icveWwCdzhHbWgSweYTFVEuPavnEpbbkn9uer9
         gvoIHZyIlakFS0VgrwiflxL2YlWjr75ytuyms7/ZrPfRaVAEswSGPT1tksPWLIv3Tt6t
         8qpYpnkhICuQwp7QkPyQRQu4iKwq2Z2lNJx8hyWF0k/7CTpkSmT61E9CeI0s35mMobTf
         lMMR/TP8pH2Zf/oj5gl1SwMCgmC8iBTO3R0w4h+QFbXVxmorncT34sNHi3N/SRdNvfnH
         6H0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=kZwz3XiA;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor43104860pfa.53.2019.07.29.07.21.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 07:21:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=kZwz3XiA;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=kZwz3XiA2dsXPzcGr8BMeHi0Q8r5Ij+/PBK8Vx8c8QCcKJhFrrDBFKITSMR5uQ5Pi8
         nKH417WV7u4OJz4rjzW35RiQ402Jwzfx9u4n7eFeVKMP82hZx/7ua8ZWY2bYaTDYcnh3
         5FAoGTMbKLPZv0MVBB4IdczUX73bm6ZnSs15E=
X-Google-Smtp-Source: APXvYqyh8hzXYVlRyPGlq4xtJAc38Emiq/syXzPg0A0KUJS5nwkYSCuqEx8dzzwpR52NEl2vN1VgIw==
X-Received: by 2002:aa7:8502:: with SMTP id v2mr36039354pfn.98.1564410085043;
        Mon, 29 Jul 2019 07:21:25 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id x14sm78684881pfq.158.2019.07.29.07.21.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:21:24 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com
Cc: Daniel Axtens <dja@axtens.net>
Subject: [PATCH v2 2/3] fork: support VMAP_STACK with KASAN_VMALLOC
Date: Tue, 30 Jul 2019 00:21:07 +1000
Message-Id: <20190729142108.23343-3-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190729142108.23343-1-dja@axtens.net>
References: <20190729142108.23343-1-dja@axtens.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Supporting VMAP_STACK with KASAN_VMALLOC is straightforward:

 - clear the shadow region of vmapped stacks when swapping them in
 - tweak Kconfig to allow VMAP_STACK to be turned on with KASAN

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>
---
 arch/Kconfig  | 9 +++++----
 kernel/fork.c | 4 ++++
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index a7b57dd42c26..e791196005e1 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -825,16 +825,17 @@ config HAVE_ARCH_VMAP_STACK
 config VMAP_STACK
 	default y
 	bool "Use a virtually-mapped stack"
-	depends on HAVE_ARCH_VMAP_STACK && !KASAN
+	depends on HAVE_ARCH_VMAP_STACK
+	depends on !KASAN || KASAN_VMALLOC
 	---help---
 	  Enable this if you want the use virtually-mapped kernel stacks
 	  with guard pages.  This causes kernel stack overflows to be
 	  caught immediately rather than causing difficult-to-diagnose
 	  corruption.
 
-	  This is presently incompatible with KASAN because KASAN expects
-	  the stack to map directly to the KASAN shadow map using a formula
-	  that is incorrect if the stack is in vmalloc space.
+	  To use this with KASAN, the architecture must support backing
+	  virtual mappings with real shadow memory, and KASAN_VMALLOC must
+	  be enabled.
 
 config ARCH_OPTIONAL_KERNEL_RWX
 	def_bool n
diff --git a/kernel/fork.c b/kernel/fork.c
index d8ae0f1b4148..ce3150fe8ff2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -94,6 +94,7 @@
 #include <linux/livepatch.h>
 #include <linux/thread_info.h>
 #include <linux/stackleak.h>
+#include <linux/kasan.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -215,6 +216,9 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		if (!s)
 			continue;
 
+		/* Clear the KASAN shadow of the stack. */
+		kasan_unpoison_shadow(s->addr, THREAD_SIZE);
+
 		/* Clear stale pointers from reused stack. */
 		memset(s->addr, 0, THREAD_SIZE);
 
-- 
2.20.1

