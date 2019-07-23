Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CA9EC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43576227B7
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gvBkOkwz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43576227B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D80038E0008; Tue, 23 Jul 2019 13:59:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D32E28E0002; Tue, 23 Jul 2019 13:59:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C21668E0008; Tue, 23 Jul 2019 13:59:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id A05F88E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:10 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id i70so33952721ybg.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=uxuxpoqA/C7rk06bc2rM9al5Hb55km4kp2za7lpV0D8=;
        b=VDrHwuNY56y/7To2ydIpaeudUrbJtV3LKKSPHDt7XXIpSo9JSixU8ikmobtzAdHIq6
         Z9TZKAIpEpRH4DIJRPkUiKpiKaoLJVfuT1lAv90tfn2tFqNFtMDVXtu4fzbz6ZDJ6GGz
         VY6bLX6yLiVFaj/dMXYYYKQjImnQqfxSm7h3Bpgj/PuokF1ZHZ1ypkMng65DifiYH8EF
         uARBgXU+gTFp/7Wduy7vD/sM1YJkW7uZEWZf/vjq86EY3senGJl4OmpGrv5JE47GEfyK
         1t4s40USL7uDF8IZB+iesPCR8aLdeXkHMBOcXrahqOpgcIxmAIL+gZkmMGeSVM3RYtNH
         9VNA==
X-Gm-Message-State: APjAAAXXKkWBX6P0TJ6O9JDqaUzQHz4XbOLc781v5gTkWZpCEOZoGBNb
	4tlRdeirYv+a3IOpTRmG6N4tHSVur0t66YGxMAlkMikY+H9uB4SP+MhwEFuqDzyADxaAQZBWGjO
	KjJaN28WpxNP49xckK2UIUu4K2zeCru7jiy/kl74oMxqaKx4GC1HQIJ+E2EPE/CzWEQ==
X-Received: by 2002:a81:23ca:: with SMTP id j193mr46703873ywj.332.1563904750341;
        Tue, 23 Jul 2019 10:59:10 -0700 (PDT)
X-Received: by 2002:a81:23ca:: with SMTP id j193mr46703851ywj.332.1563904749719;
        Tue, 23 Jul 2019 10:59:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904749; cv=none;
        d=google.com; s=arc-20160816;
        b=TulpxJyj4GWMOfqRmPkNjYNxzABCuqT/stIjVKNhqAvERa2KPcC+bBwUjuLpGYKCoU
         hyPJDSkhA8kyN/EUi8ScNTjYRv12IUYGsYi7YGws8z68Ol0DMA1CNidvaUvq2gGO7cHI
         TmcLDnzgS9+voD1PAVLXgz3Y/X3M9J8gAAtgEbcz5Z8YqDKmRYt3UC73MVkUEcMAjhYb
         Bvx2HfInFKwTLaOdIxI68uPajw0XQX128FOKOhgSJfRWXrOgQJZNj8HB+l5BAuPqC1rY
         CrNz2/eCboD3qvp9eKjyIhpu7ct5NvzKX6uIHyroiOlpQRyecFAtqePZUY8+Q/F/e4sW
         YTRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=uxuxpoqA/C7rk06bc2rM9al5Hb55km4kp2za7lpV0D8=;
        b=smfF9yG1av8bzVLrn+dyE+7B7736OAHsCWaTbxSgGThS8Ed7VfISUy2AHQfkcTOSL7
         l98frl100REGGN8RJhQW7zOFsNvSvRic5XICuiNlsopPJGihLLLyD4iqWSxUT3qotO9x
         DNTv/EJVW5/U9gT+V7tx2CRifCnNCQB7jUAj7GgADzzW1x8M2CVxXRynsN5Op6WfIemF
         /bBfeDRhKDgCQWgO3HtzY4AszGTdo/blXkcsbsPaNCOz5JggdrL00dxMqQGe5sapFsx/
         L7aF1OjljpTX3BU77GoK8KcjJMmg3nt9GfwyP3TDx8sSUXxGk7Ahq2PfCtA+2x+/hJTU
         OcTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gvBkOkwz;
       spf=pass (google.com: domain of 37uo3xqokcfas5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37Uo3XQoKCFAs5v9wG25D3y66y3w.u64305CF-442Dsu2.69y@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 187sor5817519ybu.19.2019.07.23.10.59.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 37uo3xqokcfas5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gvBkOkwz;
       spf=pass (google.com: domain of 37uo3xqokcfas5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37Uo3XQoKCFAs5v9wG25D3y66y3w.u64305CF-442Dsu2.69y@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=uxuxpoqA/C7rk06bc2rM9al5Hb55km4kp2za7lpV0D8=;
        b=gvBkOkwzaYNLh+oGcJAVB7MjFm6ggJ16J7ZtFWSs5smrgxbyTgnFANakPKwfHBaKJo
         Z3AeBj5hFUm+GIYoHcLDXyEq448i3WGfVM80s/ZYt3Ff7Lnffb2whFy1iyiq0vNB8tme
         ZgEAhcj6PmMNwScnzwOlSrD9vrs9BWD5XfY+Jc7tfz6fIGBdIIOc361XhF1FnJ2J5gIc
         R3XqyRsgPc72AURET11IAyvFYp4TC8kAAhKarnjk3baGMHuxZXMV89tXjZO+C8I9PfEc
         YEGyFP+vd3pK7Yts8v+bEOrkzxv2fC0rSmwv0ECVx3Gypru+tBZwBnoAh4W0hQ7k4cn/
         8ScQ==
X-Google-Smtp-Source: APXvYqw9DwaHVI19t/YbteMrcIZMKltNbSnI88dDsWcfp8XIUhxn9zscDjBOZxYqaezV+ZapgNfd0Az5q5SxMU+h
X-Received: by 2002:a5b:951:: with SMTP id x17mr48178059ybq.511.1563904749116;
 Tue, 23 Jul 2019 10:59:09 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:38 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <bc53284e2c95fd5b65809a1fb8169d4c1618c61b.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 01/15] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
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
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

copy_from_user (and a few other similar functions) are used to copy data
from user memory into the kernel memory or vice versa. Since a user can
provided a tagged pointer to one of the syscalls that use copy_from_user,
we need to correctly handle such pointers.

Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr,
before performing access validity checks.

Note, that this patch only temporarily untags the pointers to perform the
checks, but then passes them as is into the kernel internals.

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/uaccess.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 5a1c32260c1f..a138e3b4f717 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -62,6 +62,8 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 {
 	unsigned long ret, limit = current_thread_info()->addr_limit;
 
+	addr = untagged_addr(addr);
+
 	__chk_user_ptr(addr);
 	asm volatile(
 	// A + B <= C + 1 for all A,B,C, in four easy steps:
@@ -215,7 +217,8 @@ static inline void uaccess_enable_not_uao(void)
 
 /*
  * Sanitise a uaccess pointer such that it becomes NULL if above the
- * current addr_limit.
+ * current addr_limit. In case the pointer is tagged (has the top byte set),
+ * untag the pointer before checking.
  */
 #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
 static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
@@ -223,10 +226,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
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
2.22.0.709.g102302147b-goog

