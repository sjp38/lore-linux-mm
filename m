Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39E21C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:16:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEEDE218A4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:16:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="Vb4l6hRe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEEDE218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F5688E0006; Wed, 31 Jul 2019 03:16:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A6838E0001; Wed, 31 Jul 2019 03:16:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A99B8E0006; Wed, 31 Jul 2019 03:16:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 328C08E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 03:16:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 21so42625010pfu.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 00:16:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=CKOvryPYk04F9vmWTH8vFPvJl85JUkDKvbkAf1ikB07N4cxTY1+fIu3TSZs3vQmCIx
         ClwjKvRGD7o4dk1aNusmiPBvPQ3jJAyj6Eo8lyuZZLE3WBLETT0GYCRSyIEC3IqRT8KP
         7E+rlvYx/3cI9dPIqkizyIyEaRiWgMEc/+Igx1YGqG5JPKS7Q4+2myaHhu8JdleYgnLo
         QS2g5AxGi14qG1RM+7O36KaNZGBtnNVDFjhatmWQWCO7k/W4Due7nogYg+6uVHEpfcuq
         o+saBlu6TB4d9fhM2lr1IzS6MKvNAg+MK8u81+stWstWMG7yF8lHv9o6zZfsCXxJjdUo
         nw8w==
X-Gm-Message-State: APjAAAWjVg2bFlxgWmH+DjXqj5UXqs7xwC04KZMYHi6h/y2DQW5tV886
	wxkSJJnMj/Mc7ifxV+znKA3yR4e82c6ZzkWutP57WhYFMzoEdwB6dDucgX3NAtgNHH8alpqOoZ6
	T//wsLk+KQxZVvkljhgI0mXnnO7e/76YNS0z5r/S0elJZMR6EDLzmFNVucqIhDOt7yg==
X-Received: by 2002:a63:31cc:: with SMTP id x195mr101010667pgx.147.1564557365781;
        Wed, 31 Jul 2019 00:16:05 -0700 (PDT)
X-Received: by 2002:a63:31cc:: with SMTP id x195mr101010615pgx.147.1564557364952;
        Wed, 31 Jul 2019 00:16:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564557364; cv=none;
        d=google.com; s=arc-20160816;
        b=zGAhjufIsqDLwziMqO5oxIMJDWhCwrYI2XODngvVfczrTetdKw2rdCH3jX3kV7i4J8
         sQgSHlkRTF/LdPAnx209IzZALmGWrc6o+Ai7mSRay22c2ctFpKSy2ki5Zt9+Q5TXDb2V
         RTiWMRbAWVrAVnn6QXj43Fa9qyBgWNeGsbZuw2qIIEFboRq9mo653g5of/B3Suxj+di8
         oIqLcIs8Xp4SzBXAbhPbfJgAw7iVw0lta1dJdjcQj2Sg72e0It/UtIXNf7qr3vYUrpSv
         Vzu+XOK9ZbkWuKrKsSc2fsBtl59r42QcDqnvdgNf9M6qMm+VZ55hepC0YVplqDilUPPC
         9hGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=a7wGYOG9fJd007rOLNCGLoPf4lQgQr5/dj6DUckc76j9fZyK9LayARR5ow+iKbtvAY
         BVCHuLXHs+gy7wL+TqfgPtlo8nRzkLIvqQvSJD4O1yzf8q9OVABOzj/MQoc8cK14VQNp
         97SkEea3x6Igw+IQz4P1Cr/QXzkpx/5YmFRazDWpv8zxh8Zuh523m5QK7Urs2wMHaRjX
         BsNNyQwcGlzmtuUZHD7LA3ZTVsvMqqKlXO60jqt709MQWq5e8Q1lq9nzRA2AnEcY4vZa
         mnYh3koMWykRafX3Ez+hE7RTso8UID77bFT7rjHRC5EqV0Q4O02LwUyvonpLY9h+AvLF
         GjoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=Vb4l6hRe;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8sor12385106pgs.47.2019.07.31.00.16.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 00:16:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=Vb4l6hRe;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=Vb4l6hReLTp+4x430W2Q9iCkhEPhmle92DV4T4Oq0+uq8zWtE92+0O6qof/DPoNPyF
         YdRUYu/PcneNAH0iqXabGkesddRL+oLpR9N90INnd+Y3Fss+aGSOqXY5POFTJWjEGn2i
         0MAVCK7UhOW7Qx8U8eyASdlV+21e9EzlwRo/E=
X-Google-Smtp-Source: APXvYqxRKmF2ao0UKMBSYVpd5vzwez7RUnrUwEAuK+c+NERvitf8/zrVX2MiXPL5uuDGm6YwnJfXug==
X-Received: by 2002:a63:e807:: with SMTP id s7mr109013541pgh.194.1564557364627;
        Wed, 31 Jul 2019 00:16:04 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id f32sm597045pgb.21.2019.07.31.00.16.03
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 00:16:03 -0700 (PDT)
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
Subject: [PATCH v3 2/3] fork: support VMAP_STACK with KASAN_VMALLOC
Date: Wed, 31 Jul 2019 17:15:49 +1000
Message-Id: <20190731071550.31814-3-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731071550.31814-1-dja@axtens.net>
References: <20190731071550.31814-1-dja@axtens.net>
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

