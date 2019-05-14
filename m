Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0995DC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:36:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1E592085A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:36:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pikeD1jl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E592085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28F216B0008; Tue, 14 May 2019 10:36:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2408D6B000A; Tue, 14 May 2019 10:36:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 132606B000C; Tue, 14 May 2019 10:36:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id D983E6B0008
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:36:11 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id x10so524902vsj.19
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:36:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Go4t+yeK4FmEV47RVV/K/R0RvYRio180dlBaNN/E/uc=;
        b=o8rmyJsQY92QWBDaoNTqtmHh5qfk+RmWAZ4696EQy2zNpMq3ulLqnztEhZBBTVfLh3
         cOlnLfRPNm54ulSpQojQ5REdC7bzWaq4ljuPG7LB/bVW8hwiKB3z9JNGcadu54y3TCBB
         VBNsFd7gtDdNHvu+I7zC+owJjlQMF+cfWfbpVb4CWcrv1N5VlXss9SJchAy3Fa7JNkQe
         3wbO6WhR/wP9Vlwtx03eBbYI+ND08++c/wzZ7NyfUOiO5+kiGdUaIou7XeHTAMwTOK0K
         N2vQ3jEWgdrE4oJY7qBUGnKeoG/hKoU2sUs/HhmSCl/lpm8DoBdT6fxc1eY78ULxRZcd
         EZVQ==
X-Gm-Message-State: APjAAAXYW9KfI83sHaBKQDmFvs6Daio/krnB1TlZnA9/pQJ+H/AQANtb
	Cra5dYd5IZ51u3EIU0tFAn1ombN1Zk6scwF4w8D4sXFpsC46sSr0B5glx363aR5Fl/ZJ3RSy6s6
	ShffB/VHeG/ZwVYTTBssu0BspYjeDLgyvy5krOfy1mET+Y0CM1kcfE9jpW51p11Y0JA==
X-Received: by 2002:a1f:8991:: with SMTP id l139mr15593253vkd.49.1557844571455;
        Tue, 14 May 2019 07:36:11 -0700 (PDT)
X-Received: by 2002:a1f:8991:: with SMTP id l139mr15593196vkd.49.1557844570611;
        Tue, 14 May 2019 07:36:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557844570; cv=none;
        d=google.com; s=arc-20160816;
        b=g2BzOCE73d0MLxBwMFzlmyUcG3WH4j/uw1zc+gwLv0PNjrfn+pQ6p7fj6+u/+/uZoE
         JRL+fWMZUXT8Umo6H3MLQGXEbX241A75gQ5ZS2o8iB2Q6GqFn2xGdriHKG+FjqsD1Ypo
         z2a0+Fxl8EfK016uwTQTf8PcVVDttXuBQ8c5UxFEaLvHj+dVlq8+SK8W0foCbsqFsdFr
         3Ctc0j+ge5F60kMmLvpli+l+Oc8mJk8HtVw8LtkuvGjcMg+LdvDMZyh8p9Vb+1vlQRFM
         DRC9qeE3UcULs8EE7LzJ1lOGvmoAIc8KIbOJR6JXCt0Hrg5bOmi/tCPqPKvHBk38moqy
         FSdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Go4t+yeK4FmEV47RVV/K/R0RvYRio180dlBaNN/E/uc=;
        b=bWw1BuAsY0lUKD+cL+WbjSjIJgJpMaRr+0Mv7wYn58RuVRLRVDuAq2fJqOk+ZxzODX
         23ZWMBT7A9sZ6XBVhjfYYCqEAtkxyE2f2OY3bcIpjB9z4hauWssylrxj4O4uYasa2U+k
         2UDn2n6vqWHguKIjVklSxv1TsuLT57mgE6Rur/V+YJ0M2UD0GASyu19tzJVts+UcR3nL
         fiyIqg+txO3vFExnMIHyrlUVdxlhAxmV34vtWAj474mj/oDMIoqyeckKDr0EgymyPO/E
         MAq136PKDuVPh9MJC7EIuHZKTVKsNiFDwqGDrM/1KeZFMwAcaTjAFPKmUKwRvpn5wKD1
         jp2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pikeD1jl;
       spf=pass (google.com: domain of 3wtlaxaykcfc5a723g5dd5a3.1dba7cjm-bb9kz19.dg5@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WtLaXAYKCFc5A723G5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x4sor8164313vsk.29.2019.05.14.07.36.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 07:36:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wtlaxaykcfc5a723g5dd5a3.1dba7cjm-bb9kz19.dg5@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pikeD1jl;
       spf=pass (google.com: domain of 3wtlaxaykcfc5a723g5dd5a3.1dba7cjm-bb9kz19.dg5@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WtLaXAYKCFc5A723G5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Go4t+yeK4FmEV47RVV/K/R0RvYRio180dlBaNN/E/uc=;
        b=pikeD1jlvnTEk+uey8TbYun2V8C/qn4NetuazfEjFSiIKXfvKb/Y0U2HoOWYrcxEIV
         RE5qYPWIkYK3IPMiDScQeSxK/srM5ptI7dU2jw4oxcInPVP6DLkKA9s1SNWvB2og986s
         NIFLfXn07Iz5SdRS75NF4d20AWJ5nnn1P7j3lT5arszZfOIm7sh/AGz7F0MmvLClYAZn
         cIlQ/W4XGYhtJCeuCcbxJGVNh5q+guM3Rv3w1yAkzVnieYfruF0+p9N4wanKkn7/p/SW
         BszdBhtZ3MtpABxG0+mAR5ZuJsszQrRt2f6CbWb34BCMWiBptbrnvbZ6TunbLM8L5NWs
         jCsA==
X-Google-Smtp-Source: APXvYqzAvmFIr0uQeT7SswT+cvcHP8YHOoi7bCs4Uurq0vvk2jm2KoyvFDp206pk1BoSOeKx0QNC4J5Rkl8=
X-Received: by 2002:a67:ed11:: with SMTP id l17mr17817001vsp.154.1557844570196;
 Tue, 14 May 2019 07:36:10 -0700 (PDT)
Date: Tue, 14 May 2019 16:35:37 +0200
In-Reply-To: <20190514143537.10435-1-glider@google.com>
Message-Id: <20190514143537.10435-5-glider@google.com>
Mime-Version: 1.0
References: <20190514143537.10435-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v2 4/4] net: apply __GFP_NO_AUTOINIT to AF_UNIX sk_buff allocations
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add sock_alloc_send_pskb_noinit(), which is similar to
sock_alloc_send_pskb(), but allocates with __GFP_NO_AUTOINIT.
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
To: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
To: Kees Cook <keescook@chromium.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: James Morris <jmorris@namei.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Sandeep Patil <sspatil@android.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com
---
 v2:
  - changed __GFP_NOINIT to __GFP_NO_AUTOINIT
---
 include/net/sock.h |  5 +++++
 net/core/sock.c    | 29 +++++++++++++++++++++++++----
 net/unix/af_unix.c | 13 +++++++------
 3 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4d208c0f9c14..0dcb90a0c14d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1626,6 +1626,11 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
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
index 9ceb90c875bc..7c24b70b7069 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2192,9 +2192,11 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
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
@@ -2223,7 +2225,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		timeo = sock_wait_for_wmem(sk, timeo);
 	}
 	skb = alloc_skb_with_frags(header_len, data_len, max_page_order,
-				   errcode, sk->sk_allocation);
+				   errcode, sk->sk_allocation | gfp);
 	if (skb)
 		skb_set_owner_w(skb, sk);
 	return skb;
@@ -2234,8 +2236,27 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
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
+		noblock, errcode, max_page_order, /*gfp*/__GFP_NO_AUTOINIT);
+}
+EXPORT_SYMBOL(sock_alloc_send_pskb_noinit);
+
 struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 				    int noblock, int *errcode)
 {
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e68d7454f2e3..a4c15620b66d 100644
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

