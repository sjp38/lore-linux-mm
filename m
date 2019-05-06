Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAECCC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90E4920C01
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rAOt6QkM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90E4920C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F0906B000D; Mon,  6 May 2019 12:31:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A1096B000E; Mon,  6 May 2019 12:31:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28DDA6B0010; Mon,  6 May 2019 12:31:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 019876B000D
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:15 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id h196so4517602oib.20
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/Xcm/dv07E6tB6Fg+Bd1uLrNx0q2WagwUZqys5y8XCQ=;
        b=d6RGvUgZWTBndJV4BP3T8ZBpEYpyOQD96MJP/vVe6YrtOz89uggqwIyyKk1MIFdYf0
         A7Vb+FAuhAPVhDRVyWLQVTSkuOsdkT+t1odjaYaY+P5OGJSAQnHuqJeZ97QBPjHroSFq
         fBwOBnKWQq+f9rYsNbMkmDVvHGvPebTi8rx0bKyFT+Jngw6PtTue1Jw9AWtVHxkrRmUf
         zDrR5SgNterOKM7D1jmDQIeNOd7qrPI8F6o6xyi582EO4BzNInk3vioDh4LC9pzPFbVU
         zq2m5Bscoq78d4R89fWyOLaJ/2NQSOJ6PmTaQ37IU+Dg6mdaeMp53Z2IdHMQKHiAOuHi
         4XHA==
X-Gm-Message-State: APjAAAU1Ntn9vF+s/wfXZcscTRFcmv57mzOUyDam0vISbH3iUBts9knw
	8PVny/GETK5Lb4XtJPdyfdcbfHxpwKGPAM7i0dB4WZ+McTRN9vN2oonN2qppHrz2lyNZU6lOqOu
	YzhDdBiyVxM8v81sADopa/q4mp54WfGfsvmFZMg291dRdh6drwxPte59bnDRa9zJ4QQ==
X-Received: by 2002:aca:cf46:: with SMTP id f67mr1722456oig.73.1557160274585;
        Mon, 06 May 2019 09:31:14 -0700 (PDT)
X-Received: by 2002:aca:cf46:: with SMTP id f67mr1722401oig.73.1557160273889;
        Mon, 06 May 2019 09:31:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160273; cv=none;
        d=google.com; s=arc-20160816;
        b=YhNp1rrcImYIxkvZbhd2+bs1KuJc/MHU8cOSVhb1F7/lIf07PAddWMhn5NGtf5yb9f
         vX0wF0vH0X62onX1bhgj1OehdI9gkaiEvnfdDeCNJZskEIh4RYoudvYTucdT9xqJm1LQ
         mk0fHzGGxIU8qOp3h9FyHqSYwhPhxkN9tFuyBUsJIuo+7l3pJHgc+VkTVMIcHA2P/wIu
         XqCHiefz4UzlXUeotf4ko3UJrsOn8jBly20GLQhoS0DGdjcwyTka4XBs7zgFJO/wp3gl
         uC2TfuWHquYMKUxuWdI6yJxEOLyMp5LCViTRbOk/GefCHQD7EtHYbktOspaYLHY5v0Pn
         KV1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/Xcm/dv07E6tB6Fg+Bd1uLrNx0q2WagwUZqys5y8XCQ=;
        b=a499f9zFtq+33O4lVW4PyRyS5vNRvgqIQPIDBVx4ffC5EY5ZrsPSWeodsF9OKv9OFF
         PnTEKlHN5y2BCab/2hJUHhlz+IKnHZqnubHWLqfj5e5J8TeocPQaEWFwwIoOsQroWlz1
         iwlv+ZSgRkgBZzainfh4zEVaDC9X/uIP3LCRCoM019QzMGlHqePmItsgJvvY4zRAcJQL
         ssDRnx6b80n8U7mO0cAmRLyMT1c+U2cxIVwofCPMW9qpyJzIF3qBJG3anOt0hDPpti/w
         7u8HFluPDawzdGIaFB91E1kpg0LF81BFb7CQ2ldp5bTIozZdRlCinuTHo8HVuvmxXdZX
         G86Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rAOt6QkM;
       spf=pass (google.com: domain of 3uwhqxaokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UWHQXAoKCEIerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b2sor3704075otp.66.2019.05.06.09.31.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3uwhqxaokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rAOt6QkM;
       spf=pass (google.com: domain of 3uwhqxaokceierhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UWHQXAoKCEIerhvi2orzpksskpi.gsqpmry1-qqozego.svk@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/Xcm/dv07E6tB6Fg+Bd1uLrNx0q2WagwUZqys5y8XCQ=;
        b=rAOt6QkMD/QKlKVog82fKw84EsQnaASzO/nI8W5EIDbrmmjV3gr6+15mZ10SMb6Rf5
         i/ZniLNvWV//CPRfADxSnSKtN/6Gg017m4Gik6Cenllh7RN6CfI/AKj72maW2yKQfmpN
         GrE1GcO1EKZaX0U+I3FWYiw4misL8V2knxuMTZnhd7+ifYq/drNNa4087ayYcqsu4RzV
         YnDg0sSjmZfX/PgQJ/vdVYIZT3u95MTKmAQy8Dfp2UhL6OXfBsqkSnVsPRCgY0ZcNTeM
         d3f8I7eWT+VKLfqWWZufhZUUDge/eC39ycIbKQ1fqVyQEg05Z5H0MBzHuW0wC/j81BOZ
         a7SA==
X-Google-Smtp-Source: APXvYqwsU29/a5rUuddp5tcfbPS3CQhzs1NWwE9FVJC7oUUpeYui7bu7Qsrr1jpZGFt27bCra6fHy1EBLcG5J9Rk
X-Received: by 2002:a9d:4917:: with SMTP id e23mr17423724otf.63.1557160273461;
 Mon, 06 May 2019 09:31:13 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:48 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <02e1242715cc1bf23a139e5e8152fb4feaa4b41d.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 02/17] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
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

copy_from_user (and a few other similar functions) are used to copy data
from user memory into the kernel memory or vice versa. Since a user can
provided a tagged pointer to one of the syscalls that use copy_from_user,
we need to correctly handle such pointers.

Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr,
before performing access validity checks.

Note, that this patch only temporarily untags the pointers to perform the
checks, but then passes them as is into the kernel internals.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/uaccess.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index e5d5f31c6d36..9164ecb5feca 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 	return ret;
 }
 
-#define access_ok(addr, size)	__range_ok(addr, size)
+#define access_ok(addr, size)	__range_ok(untagged_addr(addr), size)
 #define user_addr_max			get_fs
 
 #define _ASM_EXTABLE(from, to)						\
@@ -226,7 +226,8 @@ static inline void uaccess_enable_not_uao(void)
 
 /*
  * Sanitise a uaccess pointer such that it becomes NULL if above the
- * current addr_limit.
+ * current addr_limit. In case the pointer is tagged (has the top byte set),
+ * untag the pointer before checking.
  */
 #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
 static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
@@ -234,10 +235,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
 	void __user *safe_ptr;
 
 	asm volatile(
-	"	bics	xzr, %1, %2\n"
+	"	bics	xzr, %3, %2\n"
 	"	csel	%0, %1, xzr, eq\n"
 	: "=&r" (safe_ptr)
-	: "r" (ptr), "r" (current_thread_info()->addr_limit)
+	: "r" (ptr), "r" (current_thread_info()->addr_limit),
+	  "r" (untagged_addr(ptr))
 	: "cc");
 
 	csdb();
-- 
2.21.0.1020.gf2820cf01a-goog

