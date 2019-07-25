Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5C31C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C7252064A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:55:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="mV9UVVGI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C7252064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AE2D8E0034; Thu, 25 Jul 2019 01:55:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35E238E0031; Thu, 25 Jul 2019 01:55:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24DA88E0034; Thu, 25 Jul 2019 01:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3C078E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:55:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i27so30185436pfk.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fd9tgVPBKUqxW6buoyzOmO3+gT+PGf3wAT0jqJRA9iY=;
        b=L48LeN2cSoif1dDcrkXolpw/IjHSJ1Y7p8F9HSFDFUSI7Mdvp4M80SZtumKaZ3VAhM
         e7NvrxABYv6ghPi0uJCp4o3axJkKaiUwQAYUpFdnyPZ0jUYRIe2pAB3hBldeGErMzs3X
         d0gJoEFcVFIkmc20pHl7Z26suZb0rtiJLSk6atyOVh9tCu/ins9PTQYlaMgWLgD2HbTW
         b9+vD2gQcyTFIF0iwV4pm8dmcRQp2cSYIv8gaQbfDKpT6WY6qzGuw1DygvAfX4ti2hsh
         M/alk0ByvcpfcuuzfUQtTjrIbhVMqUQkfTB2jVe26u/tb9DKBOyksy1OMV70RZLr+sTy
         RtMw==
X-Gm-Message-State: APjAAAU5ZGUapNbOII8FGGIBh1TWRxlQE60h3S99yyNRvuheyGPsXQ2E
	LrTHZLBvBOYp6mPLpKIsyBQmRHK4hoyOE/xown/AYjE3cR8qoFAJhsDo4bBF635HpiPlLEP2O3X
	klAxZo+zykuXbyZV+M0amLYoTAp33OPDpRwAZnvnYq5RQlgvgvFaAa21DDfAnu8g77Q==
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr87027519plo.157.1564034125601;
        Wed, 24 Jul 2019 22:55:25 -0700 (PDT)
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr87027472plo.157.1564034124437;
        Wed, 24 Jul 2019 22:55:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564034124; cv=none;
        d=google.com; s=arc-20160816;
        b=LjfEfp1Q+kP9GpGFFBNZG2cHvaLcM+NfNV5XxO6djt8ZrOA0R4o21xLjqD5bNyjmqj
         /EdbMBdJpGe+zdQa2WnMEd+0QOeUKSfAlvQnjvXO11MuelWeRMBqux+JjjuPf2LF7tv/
         RdWqFFhLcPhfZFcCO7VX87RH7HIzBA3y2+c6ySnfpDQ0ImtZaSRwGdQPw2ubSGJVawIl
         eJC926/CSYd6VYWUQ6aPZdjqKd/CDUkE+UmjOLu/dts7iOJqcI0o/WMAfkNNopooMeHy
         rQWyQ+aKhqfcMWK5OjY6TGJ/QbbuGFmXubimcVsJ1OhS5kNVGdSz737XkbySrMNmTaZ9
         xf9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fd9tgVPBKUqxW6buoyzOmO3+gT+PGf3wAT0jqJRA9iY=;
        b=zAWgiqYkrneGVrHjA9IclQB8s9DLCP5v97iuTqud1R4tw/QyZMMA0JaCGAnX28tN/a
         f7kcsrq0dCPq7H42QxIaCi4aZ7OxbgAGxPoYGgMkADRJUcMyKPrC/6nZfuOz3dfKVBuA
         l0GeZLakvKLZuI1LhM/6vorPzcRtJOrfMJaAlEBGI6uFc47o65T/SN0Q+8mUdG0bxpEe
         LZp0NZFgIxVYtsiIZ0EeMnCG0bzn+ymPzTsNURTrcLoOE6tkQ/IVtpf2AvDUbrvq60mJ
         W+XYrVruIyf5n0MRKMfPFZvsl6zjqbXJJqIdRBKvbuC+LYaS6kd0XbHrjzYo0UMcPREX
         AO5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=mV9UVVGI;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 75sor29587080pfv.11.2019.07.24.22.55.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 22:55:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=mV9UVVGI;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=fd9tgVPBKUqxW6buoyzOmO3+gT+PGf3wAT0jqJRA9iY=;
        b=mV9UVVGI+xt2yAtNlOCu8jWDR3+lwd/qarP0po2PnSCSU5Qbnn34tQGNICY6BgxlOj
         PQueIXv55HqN/yENbObFDmSWWSnK0R+BSln+4enp7zf3xJNRD2JUxJ8cNyyvLjmjGTty
         OI9BBHZ62J0/sWkKNULjj0ja3mZPUb2ZoEYWU=
X-Google-Smtp-Source: APXvYqx2Mgx7FvMc041NyzXGKKLbyKTm8YM0vLJkj/NrWMCFDYP7fwckYovigRCONPXxLn90kxUOBw==
X-Received: by 2002:a62:2f04:: with SMTP id v4mr14551918pfv.14.1564034124163;
        Wed, 24 Jul 2019 22:55:24 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id p20sm75540475pgj.47.2019.07.24.22.55.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 22:55:23 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	dvyukov@google.com
Cc: Daniel Axtens <dja@axtens.net>
Subject: [PATCH 2/3] fork: support VMAP_STACK with KASAN_VMALLOC
Date: Thu, 25 Jul 2019 15:55:02 +1000
Message-Id: <20190725055503.19507-3-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190725055503.19507-1-dja@axtens.net>
References: <20190725055503.19507-1-dja@axtens.net>
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

