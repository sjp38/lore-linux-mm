Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A361C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 110D820656
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Lh4gbz54"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 110D820656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B35E16B02C2; Wed,  8 May 2019 11:38:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6706B02C4; Wed,  8 May 2019 11:38:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DD656B02C2; Wed,  8 May 2019 11:38:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 711C56B02C2
	for <linux-mm@kvack.org>; Wed,  8 May 2019 11:38:26 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id h186so7347990oia.13
        for <linux-mm@kvack.org>; Wed, 08 May 2019 08:38:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=RIGrkpXui4ckU6KCy/63QA2I+IpeSDYCf/ua2n+WtmM=;
        b=k2GUu9k+JQqm45MS5oizIhHSBbSphtJfl4H+9CnMj770B+jr9NySrcdl0jwh94AbRL
         iVDlV5JMDMI9HAknLLc1dbqAFPDpj+ezhrB1mTcln+puTNla7XI/DM9539X0EG6PfuoE
         TFvSFAnSd+CW2xgk8MT0PAgFURLQtM7RXlAuCQl9GuTL2KmckJS2E26pvIU9rJv22ByL
         nji/TY8rzi02EX8ObWtYeV04Lc3omQ5pksSzNO6tnUP42bRgVBRguVxLnIMlmHmu97tt
         mTs4TSOO2URuDznMHW5wlzgWtpas/hDIiuBhPUCq0/vEzrRsIsy7l0OGgTDlNGNLeIEO
         0E7w==
X-Gm-Message-State: APjAAAVFcHLvdKH0oEeJzjvKzdf6VRBGqxXrIUVASsMFgbpx4QbNTATz
	ecNXrMYe4+jZnAhr7gJVyQtFmrnPD1t1K5Q0yd5hnMkHVir5W9Nxvux3ctNoya/PbYa39fl9kTp
	Iu/Xo4ZNOXdFShaKKZYhvl5/7KtTB99CWNXq5TTWMVGvXH3QKkegLMnrpVrWgo9EonQ==
X-Received: by 2002:a9d:7445:: with SMTP id p5mr8388597otk.26.1557329906123;
        Wed, 08 May 2019 08:38:26 -0700 (PDT)
X-Received: by 2002:a9d:7445:: with SMTP id p5mr8388541otk.26.1557329905408;
        Wed, 08 May 2019 08:38:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557329905; cv=none;
        d=google.com; s=arc-20160816;
        b=rSVZtvKD3Dhl66ewuUaWUlOSixF4P48jv0swkEa9R6QTVPveMk/Jbii/loP3WFqzst
         dAs5FXowdJelSyJpbgTHId/NEhuS7f/UcsxsqkJXRlmMY0LjTCHVBbJ8hJ+uWlkk4bfs
         Ggt0mBPZVvET32p2iT4cktjDocPfz7NpGQ1pVOMUboPUX2ECr8qHbIqEUjrzhJFJXBbj
         f7h3/PWOne6HMETdP+igoYaHiYsc47VATyHyzc/HJaMR7MiGNumbZ8GZCoWX8haZ4gUE
         CF6oqN4eSLiwe9mNe3rNqA+xPeWKB15qKO1C4sjw5mWqaJLph7OFNJAflaAqEAu1gzcZ
         iFsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=RIGrkpXui4ckU6KCy/63QA2I+IpeSDYCf/ua2n+WtmM=;
        b=R7EDj2OeA7bn6/JqG49cfYxoexdfMm98KLs4PC10yB+oBAxHEG39BKkqi2SS/NsNR+
         P9x8oZ0Q0BLr3dLoXujfdcLD3C5XA8e0C0b6FNZOWBRKvL+AQSQ/VKwPqqFr5EfZh6pa
         tM6mgVrxSMmqvtY3mLDEHoJaTi8vPKr6JVSUN/qhUqRbyA6erK0/8Q5zy3RKOvweoPTt
         3aIxKWszDYGv08x9P/YVIfsNDR7C1gOSWYvS43X9/Lmwt6GDl0IRYTUoGRppLlcxjtGv
         gN6p/H/pn/dlQ8Z00NaobmgiK+z9++T1lIsTYStKvXLyP1nAcIOzNOMRRoUUP6UQhVYG
         zb9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Lh4gbz54;
       spf=pass (google.com: domain of 38ffsxaykcbo6b834h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38ffSXAYKCBo6B834H6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r5sor2426226oib.20.2019.05.08.08.38.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 08:38:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of 38ffsxaykcbo6b834h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Lh4gbz54;
       spf=pass (google.com: domain of 38ffsxaykcbo6b834h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38ffSXAYKCBo6B834H6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=RIGrkpXui4ckU6KCy/63QA2I+IpeSDYCf/ua2n+WtmM=;
        b=Lh4gbz546dcJqnxb/eDP7gIvTS/U3Sjn4/hdUClwhT9SxcWv5vnHYNv8sDeXxKxQl5
         HWY/Du/t7KX50typbJC9QoSsp3/ofWI4dmRLjOyXZaZ1EeX2zhH2CcK5OEuPVJMDKYFs
         qQ0gkInhHzbSWl1A67524cMxGoOQDldas+NSCImyWvzkIwSVp2TQy5VUBDDcU2cxO22t
         z3T9NKC3D+RigZ3BhPreDEqo4+rAi9LYYDHxOwYHw8+8oINZxKZjLNucV4EuiIVqilr5
         cxaqn8Ito0dpG3xXGeCQXt+frKwrMSUM3Vp0kA0TWQj6IbGFxcKq9Ub8AVafdf/vZbeO
         V4Jg==
X-Google-Smtp-Source: APXvYqy1LM8fX/+wQzxFqgkjs9XEXQYvzWaOQ7CT1RHBIrXgmYVlrK6hD1FIqcIZUapxQZjgP2O9fyjMcmM=
X-Received: by 2002:aca:4ec5:: with SMTP id c188mr2833935oib.33.1557329905089;
 Wed, 08 May 2019 08:38:25 -0700 (PDT)
Date: Wed,  8 May 2019 17:37:36 +0200
In-Reply-To: <20190508153736.256401-1-glider@google.com>
Message-Id: <20190508153736.256401-5-glider@google.com>
Mime-Version: 1.0
References: <20190508153736.256401-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH 4/4] net: apply __GFP_NOINIT to AF_UNIX sk_buff allocations
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org, 
	labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com, yamada.masahiro@socionext.com, 
	jmorris@namei.org, serge@hallyn.com, ndesaulniers@google.com, kcc@google.com, 
	dvyukov@google.com, sspatil@android.com, rdunlap@infradead.org, 
	jannh@google.com, mark.rutland@arm.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add sock_alloc_send_pskb_noinit(), which is similar to
sock_alloc_send_pskb(), but allocates with __GFP_NOINIT.
This helps reduce the slowdown on hackbench in the init_on_alloc mode
from 6.84% to 3.45%.

Slowdown for the initialization features compared to init_on_free=0,
init_on_alloc=0:

hackbench, init_on_free=1:  +7.71% sys time (st.err 0.45%)
hackbench, init_on_alloc=1: +3.45% sys time (st.err 0.86%)

Linux build with -j12, init_on_free=1:  +8.34% wall time (st.err 0.39%)
Linux build with -j12, init_on_free=1:  +24.13% sys time (st.err 0.47%)
Linux build with -j12, init_on_alloc=1: -0.04% wall time (st.err 0.46%)
Linux build with -j12, init_on_alloc=1: +0.50% sys time (st.err 0.45%)

The slowdown for init_on_free=0, init_on_alloc=0 compared to the
baseline is within the standard error.

Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: James Morris <jmorris@namei.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Sandeep Patil <sspatil@android.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 include/net/sock.h |  5 +++++
 net/core/sock.c    | 29 +++++++++++++++++++++++++----
 net/unix/af_unix.c | 13 +++++++------
 3 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 341f8bafa0cf..64bfc4fd7940 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1612,6 +1612,11 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 				     unsigned long data_len, int noblock,
 				     int *errcode, int max_page_order);
+struct sk_buff *sock_alloc_send_pskb_noinit(struct sock *sk,
+					    unsigned long header_len,
+					    unsigned long data_len,
+					    int noblock, int *errcode,
+					    int max_page_order);
 void *sock_kmalloc(struct sock *sk, int size, gfp_t priority);
 void sock_kfree_s(struct sock *sk, void *mem, int size);
 void sock_kzfree_s(struct sock *sk, void *mem, int size);
diff --git a/net/core/sock.c b/net/core/sock.c
index bd03e3a52f9d..8aabcb25fc6a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2187,9 +2187,11 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
  *	Generic send/receive buffer handlers
  */
 
-struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
-				     unsigned long data_len, int noblock,
-				     int *errcode, int max_page_order)
+struct sk_buff *sock_alloc_send_pskb_internal(struct sock *sk,
+					      unsigned long header_len,
+					      unsigned long data_len,
+					      int noblock, int *errcode,
+					      int max_page_order, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	long timeo;
@@ -2218,7 +2220,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		timeo = sock_wait_for_wmem(sk, timeo);
 	}
 	skb = alloc_skb_with_frags(header_len, data_len, max_page_order,
-				   errcode, sk->sk_allocation);
+				   errcode, sk->sk_allocation | gfp);
 	if (skb)
 		skb_set_owner_w(skb, sk);
 	return skb;
@@ -2229,8 +2231,27 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 	*errcode = err;
 	return NULL;
 }
+
+struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
+				     unsigned long data_len, int noblock,
+				     int *errcode, int max_page_order)
+{
+	return sock_alloc_send_pskb_internal(sk, header_len, data_len,
+		noblock, errcode, max_page_order, /*gfp*/0);
+}
 EXPORT_SYMBOL(sock_alloc_send_pskb);
 
+struct sk_buff *sock_alloc_send_pskb_noinit(struct sock *sk,
+					    unsigned long header_len,
+					    unsigned long data_len,
+					    int noblock, int *errcode,
+					    int max_page_order)
+{
+	return sock_alloc_send_pskb_internal(sk, header_len, data_len,
+		noblock, errcode, max_page_order, /*gfp*/__GFP_NOINIT);
+}
+EXPORT_SYMBOL(sock_alloc_send_pskb_noinit);
+
 struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 				    int noblock, int *errcode)
 {
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ddb838a1b74c..9a45824c3c48 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1627,9 +1627,9 @@ static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
 		BUILD_BUG_ON(SKB_MAX_ALLOC < PAGE_SIZE);
 	}
 
-	skb = sock_alloc_send_pskb(sk, len - data_len, data_len,
-				   msg->msg_flags & MSG_DONTWAIT, &err,
-				   PAGE_ALLOC_COSTLY_ORDER);
+	skb = sock_alloc_send_pskb_noinit(sk, len - data_len, data_len,
+					  msg->msg_flags & MSG_DONTWAIT, &err,
+					  PAGE_ALLOC_COSTLY_ORDER);
 	if (skb == NULL)
 		goto out;
 
@@ -1824,9 +1824,10 @@ static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 
 		data_len = min_t(size_t, size, PAGE_ALIGN(data_len));
 
-		skb = sock_alloc_send_pskb(sk, size - data_len, data_len,
-					   msg->msg_flags & MSG_DONTWAIT, &err,
-					   get_order(UNIX_SKB_FRAGS_SZ));
+		skb = sock_alloc_send_pskb_noinit(sk, size - data_len, data_len,
+						  msg->msg_flags & MSG_DONTWAIT,
+						  &err,
+						  get_order(UNIX_SKB_FRAGS_SZ));
 		if (!skb)
 			goto out_err;
 
-- 
2.21.0.1020.gf2820cf01a-goog

