Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F6B0C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6BD22186A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gbUaG2SU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6BD22186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B27A6B0008; Wed, 20 Mar 2019 10:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5381A6B000A; Wed, 20 Mar 2019 10:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 428256B000C; Wed, 20 Mar 2019 10:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFEF6B0008
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:51:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u2so2643842pgi.10
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=k1ksHzqcIFCs0rlhYrsau26vl3ocVueBBoKnHNKxr50=;
        b=S4SoG1RTlixQSyDfkgBeV6Hc1LM1daV4JUEvhbXD+d/wGzAaxpagyGGAxr8gM5x8IL
         gVdZKRjQpcmrCamv5o9ohGHhCtiDFJ/Jv1hXKE6MDgEcxlrrmHWTem3VgiTkWYWl3xFw
         Zn/Ea8y02hFJ0nU7VMP7w8MXiIn0RL18xYT7GN57lYkJre3SlwnLUQwRfPLMOTnjxvsa
         tSLRnzXEpqF+ragSOoBrga9O+3YvVtfy0CreP29PnW11ZwKguVgisSew2J2wdwJ2xxDK
         IXfas5VKs/3IpfxwQFbey8u2damaj2fwQi64eoKwxTj/+XodU95HmC+SJDBGmCcthIv+
         ia5w==
X-Gm-Message-State: APjAAAVAIKImuaQyQhPG7HsAy2GhI02pRNNpJz9xpGNzaI9yKVpxLt2x
	Nfe4bcDg9XeM6ECUjNG7RNbJFfPHrhhMOQ5p5IBz/0Ow4feRCUYPJsCZUtqBEmr31g58q94Iz1p
	lo0u0ZytT7PgmmLgi7j4HcjuslNlMZIL3D+EahF3F5ZhFThlEaNdO/7q9MRAREPRRFg==
X-Received: by 2002:a62:12c8:: with SMTP id 69mr8188795pfs.184.1553093514553;
        Wed, 20 Mar 2019 07:51:54 -0700 (PDT)
X-Received: by 2002:a62:12c8:: with SMTP id 69mr8188723pfs.184.1553093513583;
        Wed, 20 Mar 2019 07:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093513; cv=none;
        d=google.com; s=arc-20160816;
        b=NjgHU5pJFr+Pw+2NRJ0sK2czLBWfPpahTj965ukiMOqlAbXTeo+6xMaf/7fLzRDN5X
         qhCNMXcGSRlvcxvp2O0d0DN3p2ykgU744NLAnvIZz2HrIHQvDQ24Lxw3I5EZEKM5hAvs
         NsjDPnWJNQVL1gDyI7dp3GrmjGrr4+vhcHIFNs1kaQSQKhtxjJanDH8GHeNyTTmUkx6H
         2wpRI8j42Akm0QxDUSbBCgpBHY6/flK2eUA9gQBGzF8a9HHdsYAyCkMuKt/dhG+ab1PG
         aQF/gDjXNophMV70wIdmRhvM7lOJ6VWxAvP8nUTzS+Z9Gw8yMyG9k6KrdzW7/dcrJ0YB
         gvng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=k1ksHzqcIFCs0rlhYrsau26vl3ocVueBBoKnHNKxr50=;
        b=HSYB8kUbRDJn8i4lwksFvzW4KyuZK7JqFaRJ1T0EYNELnVqR0ZVhL221rozd3UkYyd
         u2QKCKQ7yqb8e1KuPXpAcDNStIATC7Lu/dgLiV2GADifdG7+kHdlnJeeyrYXuTDkadn0
         BqDVgvNTOaCLXZXPr6N8eORTSk9dkg0bqwWk2R4aeKaKjyPey3sECtfGpwLlgmqr6Zh6
         yf5Ndg9BbeIQUg+QmMbURIUwqcrLqU76U7jsNwLKNVMxUOX0OWK27d7ccBiqw7mF986g
         UIl+ScT4PzA24Xnm8VNMfBCSX8zcz/de+xuUc83ZStfnKhDxmQ+/ZsiRWLmHVz6QwSHs
         6cZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gbUaG2SU;
       spf=pass (google.com: domain of 3ifosxaokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3iFOSXAoKCGMBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n14sor2500255pgb.67.2019.03.20.07.51.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:51:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ifosxaokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gbUaG2SU;
       spf=pass (google.com: domain of 3ifosxaokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3iFOSXAoKCGMBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=k1ksHzqcIFCs0rlhYrsau26vl3ocVueBBoKnHNKxr50=;
        b=gbUaG2SUmK0LgYPWKNjtqqNqra0Dj2I7PW9z90Jwp3BbFr6Ygh4VDAsBxA5gDOongd
         +7CxcUNls+IlKo+JGYjfKyQrfYRtO4Z47SxpoLW/8mbPq3NLKcCBVFUfMf1O6lo5lyQS
         Xjgdf+hI7Y/bA1D0SA8rH8Eu8XxBhdBy5VVMEbbfPWY8xA3Sb5oG0H4SEAubrB034XoX
         QEsR92P8+ORdJnszt4DIVx7Fa/WP9kGWpGO4+l3UfQFEGOIoLoqxYh83b5fPG2to4T2Y
         zFPE52PhA9pJC7TqxInYx4207DCj5+fCOTEW3biD/iclPyCXcoUirtevwOL47SHpdgsx
         zTpA==
X-Google-Smtp-Source: APXvYqyDQEPwUnTSsgi/gUBKfoSs2QhRiDzA2VJUjgLM5tdiS/YJBnhxYd/PCUUZbtlvisMRP7lT9bGN6AETareo
X-Received: by 2002:a63:2ac2:: with SMTP id q185mr3933097pgq.119.1553093512985;
 Wed, 20 Mar 2019 07:51:52 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:17 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <3faedcd2495a07e13b8611b2c63779d1d6d2b3f0.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 03/20] lib, arm64: untag user pointers in strn*_user
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

strncpy_from_user and strnlen_user accept user addresses as arguments, and
do not go through the same path as copy_from_user and others, so here we
need to handle the case of tagged user addresses separately.

Untag user pointers passed to these functions.

Note, that this patch only temporarily untags the pointers to perform
validity checks, but then uses them as is to perform user memory accesses.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 lib/strncpy_from_user.c | 3 ++-
 lib/strnlen_user.c      | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 58eacd41526c..6209bb9507c7 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -6,6 +6,7 @@
 #include <linux/uaccess.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 #include <asm/byteorder.h>
 #include <asm/word-at-a-time.h>
@@ -107,7 +108,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)src;
+	src_addr = (unsigned long)untagged_addr(src);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 1c1a1b0e38a5..8ca3d2ac32ec 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -2,6 +2,7 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/uaccess.h>
+#include <linux/mm.h>
 
 #include <asm/word-at-a-time.h>
 
@@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)str;
+	src_addr = (unsigned long)untagged_addr(str);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
-- 
2.21.0.225.g810b269d1ac-goog

