Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 556BBC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:48:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5C7E20820
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:48:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="M2Hk8avN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5C7E20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8682E6B0006; Mon, 12 Aug 2019 17:48:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 819896B0007; Mon, 12 Aug 2019 17:48:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 708D26B0008; Mon, 12 Aug 2019 17:48:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 490376B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:48:00 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E07F88248AA1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:47:59 +0000 (UTC)
X-FDA: 75815113878.17.mark17_45be30a2ce838
X-HE-Tag: mark17_45be30a2ce838
X-Filterd-Recvd-Size: 11975
Received: from mail-pl1-f201.google.com (mail-pl1-f201.google.com [209.85.214.201])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:47:59 +0000 (UTC)
Received: by mail-pl1-f201.google.com with SMTP id y9so61859044plp.12
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:47:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=+RjtCqVpVQHEQV5UWqwn329eqcVzZZeuadC4ZfZTt8A=;
        b=M2Hk8avNfUyA4J7Cb+Yy1mCRbgvxX8fzA6I2scRBaZ/M7miuptIwa6HTxyGVLPoKT9
         W7h9Ad0djc6KxqaUl9cEenPCr+z+4hCFLxJakGR4jGzttbHbvtxOeMHbqtq8HkQJmWyS
         ZxM1koknAzyYGEsUhOifQV20nqR8zB1gw7ATQnhBxn+g5clg+b0eU2c/ZgeSCn411W67
         nCno95N6NgmkPGKoOfy48BZoSo9GqzPNrQhkXZo04sVJ1zMYG5MEJjoO4XK9+6v/1Bhz
         Sw2rn9zN5pJe9E+3MByXg/CuxT6CJ8tftnhUo7PFqAdGLxh3Xsbr8nwEa/Ncu2iboK+6
         VcCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:message-id:mime-version:subject:from:to:cc;
        bh=+RjtCqVpVQHEQV5UWqwn329eqcVzZZeuadC4ZfZTt8A=;
        b=M/oXzW+7wP+vN/fNdWDka831j5npeuG7ivuwNZiiJ7sBk6BQG6Zkg4q3Se1yhFpLLW
         YRpmLaY/XUnhyyak7zymVsv+lYhdTUf+K+gl0tzRX1BMNpvtjY3GjvaUdbj/njxq8AXY
         aHEnmsjpzwsvsM6BB+iVBL3VhgIaMBypNrEzAc5QDQzki/64bh7ukwlzfcfx/W6QASmN
         x2T1CLnP8ypcA26pJwgMrmy6gkUjGo0GZDUreGx837wEQA7kSBawdhvYlBSwM5Q+F0Cl
         Af1XGa1DfyvZlQOzijhW8Ag5KvMKAML4xR/W2P9OcFJYWyEJSc8fC7nvd+dNbAAktWg/
         LrWA==
X-Gm-Message-State: APjAAAUPaARSA39vY8dyU8N/Qd9tFHOdDri6xudnTyCCM816K8LjIMsw
	CmPYlKx+YWJEUywsXll/UDqdvsp/WQ==
X-Google-Smtp-Source: APXvYqzzm8oWuZjIhx1FRg61W1F33xTwmFo8dZGb00GMhyZTJutqJgfJt7xt0vzGqPOWEM0SoYtcxiC5cA==
X-Received: by 2002:a63:ee08:: with SMTP id e8mr32361203pgi.70.1565646477641;
 Mon, 12 Aug 2019 14:47:57 -0700 (PDT)
Date: Mon, 12 Aug 2019 14:47:11 -0700
Message-Id: <20190812214711.83710-1-nhuck@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [PATCH] kbuild: Change fallthrough comments to attributes
From: Nathan Huckleberry <nhuck@google.com>
To: yamada.masahiro@socionext.com, michal.lkml@markovi.net
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, clang-built-linux@googlegroups.com, 
	Nathan Huckleberry <nhuck@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Clang does not support the use of comments to label
intentional fallthrough. This patch replaces some uses
of comments to attributesto cut down a significant number
of warnings on clang (from ~50000 to ~200). Only comments
in commonly used header files have been replaced.

Since there is still quite a bit of noise, this
patch moves -Wimplicit-fallthrough to
Makefile.extrawarn if you are compiling with
clang.

Signed-off-by: Nathan Huckleberry <nhuck@google.com>
---
 Makefile                   |  4 +++
 include/linux/jhash.h      | 60 ++++++++++++++++++++++++++++----------
 include/linux/mm.h         |  9 ++++--
 include/linux/signal.h     | 14 +++++----
 include/linux/skbuff.h     | 12 ++++----
 lib/zstd/bitstream.h       | 10 +++----
 scripts/Makefile.extrawarn |  3 ++
 7 files changed, 77 insertions(+), 35 deletions(-)

diff --git a/Makefile b/Makefile
index c391fbb07195..875930c19619 100644
--- a/Makefile
+++ b/Makefile
@@ -847,7 +847,11 @@ NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
 KBUILD_CFLAGS += -Wdeclaration-after-statement
 
 # Warn about unmarked fall-throughs in switch statement.
+# If the compiler is clang, this warning is only enabled if W=1 in
+# Makefile.extrawarn
+ifndef CONFIG_CC_IS_CLANG
 KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,)
+endif
 
 # Variable Length Arrays (VLAs) should not be used anywhere in the kernel
 KBUILD_CFLAGS += -Wvla
diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index ba2f6a9776b6..6cb2381501d1 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -86,19 +86,43 @@ static inline u32 jhash(const void *key, u32 length, u32 initval)
 	}
 	/* Last block: affect all 32 bits of (c) */
 	switch (length) {
-	case 12: c += (u32)k[11]<<24;	/* fall through */
-	case 11: c += (u32)k[10]<<16;	/* fall through */
-	case 10: c += (u32)k[9]<<8;	/* fall through */
-	case 9:  c += k[8];		/* fall through */
-	case 8:  b += (u32)k[7]<<24;	/* fall through */
-	case 7:  b += (u32)k[6]<<16;	/* fall through */
-	case 6:  b += (u32)k[5]<<8;	/* fall through */
-	case 5:  b += k[4];		/* fall through */
-	case 4:  a += (u32)k[3]<<24;	/* fall through */
-	case 3:  a += (u32)k[2]<<16;	/* fall through */
-	case 2:  a += (u32)k[1]<<8;	/* fall through */
-	case 1:  a += k[0];
+	case 12:
+		c += (u32)k[11]<<24;
+		__attribute__((fallthrough));
+	case 11:
+		c += (u32)k[10]<<16;
+		__attribute__((fallthrough));
+	case 10:
+		c += (u32)k[9]<<8;
+		__attribute__((fallthrough));
+	case 9:
+		c += k[8];
+		__attribute__((fallthrough));
+	case 8:
+		b += (u32)k[7]<<24;
+		__attribute__((fallthrough));
+	case 7:
+		b += (u32)k[6]<<16;
+		__attribute__((fallthrough));
+	case 6:
+		b += (u32)k[5]<<8;
+		__attribute__((fallthrough));
+	case 5:
+		b += k[4];
+		__attribute__((fallthrough));
+	case 4:
+		a += (u32)k[3]<<24;
+		__attribute__((fallthrough));
+	case 3:
+		a += (u32)k[2]<<16;
+		__attribute__((fallthrough));
+	case 2:
+		a += (u32)k[1]<<8;
+		__attribute__((fallthrough));
+	case 1:
+		a += k[0];
 		 __jhash_final(a, b, c);
+		break;
 	case 0: /* Nothing left to add */
 		break;
 	}
@@ -132,10 +156,16 @@ static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
 
 	/* Handle the last 3 u32's */
 	switch (length) {
-	case 3: c += k[2];	/* fall through */
-	case 2: b += k[1];	/* fall through */
-	case 1: a += k[0];
+	case 3:
+		c += k[2];
+		__attribute__((fallthrough));
+	case 2:
+		b += k[1];
+		__attribute__((fallthrough));
+	case 1:
+		a += k[0];
 		__jhash_final(a, b, c);
+		break;
 	case 0:	/* Nothing left to add */
 		break;
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..52d99f263ca3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -158,11 +158,14 @@ static inline void __mm_zero_struct_page(struct page *page)
 
 	switch (sizeof(struct page)) {
 	case 80:
-		_pp[9] = 0;	/* fallthrough */
+		_pp[9] = 0;
+		__attribute__((fallthrough));
 	case 72:
-		_pp[8] = 0;	/* fallthrough */
+		_pp[8] = 0;
+		__attribute__((fallthrough));
 	case 64:
-		_pp[7] = 0;	/* fallthrough */
+		_pp[7] = 0;
+		__attribute__((fallthrough));
 	case 56:
 		_pp[6] = 0;
 		_pp[5] = 0;
diff --git a/include/linux/signal.h b/include/linux/signal.h
index b5d99482d3fe..4fb0a0041a37 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -129,11 +129,11 @@ static inline void name(sigset_t *r, const sigset_t *a, const sigset_t *b) \
 		b3 = b->sig[3]; b2 = b->sig[2];				\
 		r->sig[3] = op(a3, b3);					\
 		r->sig[2] = op(a2, b2);					\
-		/* fall through */					\
+		__attribute__((fallthrough));				\
 	case 2:								\
 		a1 = a->sig[1]; b1 = b->sig[1];				\
 		r->sig[1] = op(a1, b1);					\
-		/* fall through */					\
+		__attribute__((fallthrough));				\
 	case 1:								\
 		a0 = a->sig[0]; b0 = b->sig[0];				\
 		r->sig[0] = op(a0, b0);					\
@@ -163,9 +163,9 @@ static inline void name(sigset_t *set)					\
 	switch (_NSIG_WORDS) {						\
 	case 4:	set->sig[3] = op(set->sig[3]);				\
 		set->sig[2] = op(set->sig[2]);				\
-		/* fall through */					\
+		__attribute__((fallthrough));				\
 	case 2:	set->sig[1] = op(set->sig[1]);				\
-		/* fall through */					\
+		__attribute__((fallthrough));				\
 	case 1:	set->sig[0] = op(set->sig[0]);				\
 		    break;						\
 	default:							\
@@ -186,7 +186,7 @@ static inline void sigemptyset(sigset_t *set)
 		memset(set, 0, sizeof(sigset_t));
 		break;
 	case 2: set->sig[1] = 0;
-		/* fall through */
+		__attribute__((fallthrough));
 	case 1:	set->sig[0] = 0;
 		break;
 	}
@@ -199,7 +199,7 @@ static inline void sigfillset(sigset_t *set)
 		memset(set, -1, sizeof(sigset_t));
 		break;
 	case 2: set->sig[1] = -1;
-		/* fall through */
+		__attribute__((fallthrough));
 	case 1:	set->sig[0] = -1;
 		break;
 	}
@@ -230,6 +230,7 @@ static inline void siginitset(sigset_t *set, unsigned long mask)
 		memset(&set->sig[1], 0, sizeof(long)*(_NSIG_WORDS-1));
 		break;
 	case 2: set->sig[1] = 0;
+		__attribute__((fallthrough));
 	case 1: ;
 	}
 }
@@ -242,6 +243,7 @@ static inline void siginitsetinv(sigset_t *set, unsigned long mask)
 		memset(&set->sig[1], -1, sizeof(long)*(_NSIG_WORDS-1));
 		break;
 	case 2: set->sig[1] = -1;
+		__attribute__((fallthrough));
 	case 1: ;
 	}
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d8af86d995d6..4a1df6714dfe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3639,19 +3639,19 @@ static inline bool __skb_metadata_differs(const struct sk_buff *skb_a,
 #define __it(x, op) (x -= sizeof(u##op))
 #define __it_diff(a, b, op) (*(u##op *)__it(a, op)) ^ (*(u##op *)__it(b, op))
 	case 32: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__attribute__((fallthrough));
 	case 24: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__attribute__((fallthrough));
 	case 16: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__attribute__((fallthrough));
 	case  8: diffs |= __it_diff(a, b, 64);
 		break;
 	case 28: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__attribute__((fallthrough));
 	case 20: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__attribute__((fallthrough));
 	case 12: diffs |= __it_diff(a, b, 64);
-		 /* fall through */
+		__attribute__((fallthrough));
 	case  4: diffs |= __it_diff(a, b, 32);
 		break;
 	}
diff --git a/lib/zstd/bitstream.h b/lib/zstd/bitstream.h
index 3a49784d5c61..cc311bae44da 100644
--- a/lib/zstd/bitstream.h
+++ b/lib/zstd/bitstream.h
@@ -259,15 +259,15 @@ ZSTD_STATIC size_t BIT_initDStream(BIT_DStream_t *bitD, const void *srcBuffer, s
 		bitD->bitContainer = *(const BYTE *)(bitD->start);
 		switch (srcSize) {
 		case 7: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[6]) << (sizeof(bitD->bitContainer) * 8 - 16);
-			/* fall through */
+			__attribute__((fallthrough));
 		case 6: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[5]) << (sizeof(bitD->bitContainer) * 8 - 24);
-			/* fall through */
+			__attribute__((fallthrough));
 		case 5: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[4]) << (sizeof(bitD->bitContainer) * 8 - 32);
-			/* fall through */
+			__attribute__((fallthrough));
 		case 4: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[3]) << 24;
-			/* fall through */
+			__attribute__((fallthrough));
 		case 3: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[2]) << 16;
-			/* fall through */
+			__attribute__((fallthrough));
 		case 2: bitD->bitContainer += (size_t)(((const BYTE *)(srcBuffer))[1]) << 8;
 		default:;
 		}
diff --git a/scripts/Makefile.extrawarn b/scripts/Makefile.extrawarn
index a74ce2e3c33e..e12359d69bb7 100644
--- a/scripts/Makefile.extrawarn
+++ b/scripts/Makefile.extrawarn
@@ -30,6 +30,9 @@ warning-1 += $(call cc-option, -Wunused-but-set-variable)
 warning-1 += $(call cc-option, -Wunused-const-variable)
 warning-1 += $(call cc-option, -Wpacked-not-aligned)
 warning-1 += $(call cc-option, -Wstringop-truncation)
+ifdef CONFIG_CC_IS_CLANG
+KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,)
+endif
 # The following turn off the warnings enabled by -Wextra
 warning-1 += -Wno-missing-field-initializers
 warning-1 += -Wno-sign-compare
-- 
2.23.0.rc1.153.gdeed80330f-goog


