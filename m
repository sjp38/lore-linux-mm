Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FDB4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56F252184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lLOPAVeM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56F252184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFFFB6B0007; Wed, 20 Mar 2019 10:51:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB0FB6B0008; Wed, 20 Mar 2019 10:51:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7B566B000A; Wed, 20 Mar 2019 10:51:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 909BB6B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:51:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 14so2748667pfh.10
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:51:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=UykDW4hFaDHfzyUH5xSGMBQs4gGYEgUL/nC+SEDYWFU=;
        b=WB6JKB5qwA65B3lOPXBIEVLUXXUiyQV1CxOdZGOP8lWCUPfkgEo0TrNcXbiUxKpMGa
         cSLvhK81tAcoxjMGaMLUkZJ1TNkyLjwHXYzukHK7sFy/1Pv38xC5d3eozR8ytfwdz2To
         NR9bGqzxLYDB+09UPCwcE7VryYIz0oZfV+SL0L4b2GGIJcbT1KaVdiX7jP1rF23c1kBc
         v8+nrrvV3C13ZZsihVRhe53ALT8TgwXWkclfouczPwJ190rG0HE978xjJZ55buQbyYsW
         NQEIQSZf0qlMc2acqFaEpaNNghfb27IH9KwjNH3O0LOTAy88L0LUjB5JPbwYwL/GBeqr
         y2JQ==
X-Gm-Message-State: APjAAAVKfLpd530HMLF/SGgGyNy7CR8fkEh/vwNd9KhzZ3QWHvkXsDhh
	io1MrHnb2hSA2TWz32NliESA3N6tP2fJfpAkSULS0qLQAc5QCJw9zyYE2JWLjSrdUkrGIBfnxt+
	oDjfeQkVU6+fs3QOcGg1qD3IqGSBDJs4XjuxpRQpsHgnx1p09JAp+UmeKq54EgFRQzA==
X-Received: by 2002:aa7:8150:: with SMTP id d16mr8273794pfn.172.1553093511104;
        Wed, 20 Mar 2019 07:51:51 -0700 (PDT)
X-Received: by 2002:aa7:8150:: with SMTP id d16mr8273718pfn.172.1553093510136;
        Wed, 20 Mar 2019 07:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093510; cv=none;
        d=google.com; s=arc-20160816;
        b=cp4Tnu9fM/dHz7qRzbnrKSs24O3oi0+F8eKAL75GtHjDqoVg8Wkhk9flvVpBFUp5q+
         QCm4i4EyDqaF1OmATezITYBaQNkSYMQvvWkTXGtxusYLpAYkBgEgXjvTvkNjpJRwrxBi
         SPVV0uAtNRCI0jxXHWpDwllrDPVlzqNfEypK3QTIdNOV/v5Uy/VSdFWvxCT49+/VcGP5
         HVBY/zO5UhmYATWZ+NdIlv3nHLDd7rbFhcpD7AqwrFCaR29Xc4aHi3XKuxQvAbf+1Nts
         H5oIHxP6WOQT255iFPrDxruCLTP0Y91hfsWxqX4D+ns8m/BXzAqnAmpY2IWRGcXgYOoM
         Hlgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=UykDW4hFaDHfzyUH5xSGMBQs4gGYEgUL/nC+SEDYWFU=;
        b=GJSAEwP12M6ObmNuoGGGF7zEd+gRc2SB58HgVd99Tgnxa1Uk08IZv7auwKGkLq4dCh
         7flUdCVxfxGAxvPJXCFW9rIzWRTDO/w/C6eTF8UptruJ5eDfjMeiETZUNROvCy6jEqO4
         QHb3732mUw4aEU9t/0aMBdNXVqO/u9YkKF1L7AxywpK5axcQJRQriikEGnka5MOKM+2W
         n6pFqBYYmvFgIxuyV0R0f1+avyrRcjcK3gxBybyD2dbZhZkhCtcWDuoOf9X+PTFpWReW
         DteCX7I3VPHxOLM0SP9sQYcTUrF6MRi4wr3ExLvHh78LFOtLkbkoQsU8S6d/rYonOGJ7
         RcFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lLOPAVeM;
       spf=pass (google.com: domain of 3hvosxaokcga8lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hVOSXAoKCGA8LBPCWILTJEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id q6sor3267946pls.68.2019.03.20.07.51.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hvosxaokcga8lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lLOPAVeM;
       spf=pass (google.com: domain of 3hvosxaokcga8lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hVOSXAoKCGA8LBPCWILTJEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=UykDW4hFaDHfzyUH5xSGMBQs4gGYEgUL/nC+SEDYWFU=;
        b=lLOPAVeMgo+XU+M3v80cbkFtJQeM54XdFXR91eQRqzShgxQoLUxc49Mv6tDL/lyP9d
         bgM5wXcc+UcWDqcma43kXoRsqCQ4cVo10CfmLWdFsse63XShdwfXmbPVT9elwyshSFqm
         3aoRxWR1Uh9L7drItG2unQXmHge3xKzTVpJJ8D8oAphSWdRAjloJPbESFPuGCVO/sDFb
         6mVE567BCjCvlZvPSCPLnyB2QjsBIS0qKoYvEoFEyLFeHxmHam4y9QqgGoJxeVmp0dja
         BPplonkDtACoNdi6bO4xJviq7/EY8LkNxirmV8sgKJVS9NjaOl+5r0KeFLTijrbowQB1
         Qk9Q==
X-Google-Smtp-Source: APXvYqysrJm0FOsucxhPTIfv5ylb6jXxonLbBq7EGX5VG0V0DdEDjimmAvOMfGLGyepmIvFpwPxTl6UOr//YIIN5
X-Received: by 2002:a17:902:10d:: with SMTP id 13mr3984080plb.50.1553093509499;
 Wed, 20 Mar 2019 07:51:49 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:16 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <786b57d74d3ed58480117a8f67dda1e0839b5ea0.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 02/20] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
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
2.21.0.225.g810b269d1ac-goog

