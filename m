Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C882C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2D48217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uz44LnEk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2D48217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 934FE6B0010; Thu, 18 Apr 2019 11:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E5D26B0266; Thu, 18 Apr 2019 11:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D7016B0269; Thu, 18 Apr 2019 11:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54C016B0010
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:42:46 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id l85so957388vke.15
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=wAzPZXrwubmWQmF9WVABuPChIdQrJJ+ZBr0dE550aoQ=;
        b=OMN5sLF4M6uE9jmlXOKu32u6pJaP97TYhvZT6sEfRPy6jpgSzOh+fFUvgQvQ4DDm3H
         ik/uIV5bltXBkA5J6GNopMhWqke4vJSO4mTuuD2FHiuO5DBO4UpbI/AJ55Q/kaLjj90h
         LklNGpT0DwOKzUJr+I0hnWkAzq/WyXBZp9I5zn9R0G/1Yj63hXVTq6Tu8sZyvKq/4ob9
         VNXilKES3Q0FporeyNOZ1zwMBPjqRGnjdp6sZ8NL1s24zx+t4dOtUZiSxl3oTm6QxAGr
         Ui/FGxP5eG2dWt4xjiADYBZZ9pYGmwfkUYFVojWW0sDbABzQDp+cky4eXwo63TCE7Hrp
         Rh6w==
X-Gm-Message-State: APjAAAVZbW9OxZCC/YChtFYHYvfg9lLBQZ2Y5RhQ72wqsWGjm2D9MIuz
	NqLEiEZM8AHnY0oKM8DSa7n8Cy6IqqTRs10Nq2CHlkrE+syxvj8hQQ1dR0iNRODs7zbQ+RSzEao
	dswWNJfry1/5NeGmqEY/qp4Pm/N52GqUaoRZoGsTTrqiwofO9vrxH1xALS3tOE+wjOw==
X-Received: by 2002:a67:e3cf:: with SMTP id k15mr51052765vsm.185.1555602165934;
        Thu, 18 Apr 2019 08:42:45 -0700 (PDT)
X-Received: by 2002:a67:e3cf:: with SMTP id k15mr51052725vsm.185.1555602165155;
        Thu, 18 Apr 2019 08:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602165; cv=none;
        d=google.com; s=arc-20160816;
        b=GHUl7cjtqB8GGp9tG9D06N6LSXcnvnx0lKC9SswAMa75FUQ//A9eOPQlTGixgcxkNQ
         yI/eJ9I5N6U/Rrd1G/iVybKT1SGfvGa+8jBi2TELY7ymN2lE8LC8c40E/nKo3Ky2WhuL
         Qrx4YphUMb/B3pYpMbWYIzlNdK834qBVIqY3+JHD1vHg80vYMnJlasVyR5/kNnQiU4SU
         /++GFXuxWq/DICnDruT9nOG32o4eEzPNSsEOEiHP5rv67LBkciNp2ht74H8Ihiu8uaJt
         PNoMLwYlR5hcZPb347zuvE77qXmDHbYVxd4hzVKKfB/e/H4k+zgTvIELUfPMT1DHtLEH
         hQ8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=wAzPZXrwubmWQmF9WVABuPChIdQrJJ+ZBr0dE550aoQ=;
        b=ZrAv0dNIT2AcDsInEtHmk6awap0AXvjfrSePgtS1uSVDKmHPGuHug3ztNXF/s1mZ3e
         9yhCGEkCkp555/oPTjxtfbWyJXmuXXoxJ15u56+aQLUeP8SjNlCoApidrOFHyMiBJm40
         45asgWIgim0gvaWlPdTMA/+KVS5re8fPpxK4BSERI1kwPaMFw9ORpoTSioEmhznGZPGI
         cMF4A/kOU3ycRoZyuMBlvYfaNQBVsM6Kkkg4KPj5xooWrSOzTRH3hr58v082XqjRgIo3
         naTiO9fl7CoY5V/xcyJc3izpYUlehXff2e3awHib5nu3Z5W3mMGKoQzWM6//dpnTS7oI
         12AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uz44LnEk;
       spf=pass (google.com: domain of 39jq4xaykcpcfkhcdqfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=39Jq4XAYKCPcfkhcdqfnnfkd.bnlkhmtw-lljuZbj.nqf@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i15sor1352937uan.25.2019.04.18.08.42.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 08:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of 39jq4xaykcpcfkhcdqfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uz44LnEk;
       spf=pass (google.com: domain of 39jq4xaykcpcfkhcdqfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=39Jq4XAYKCPcfkhcdqfnnfkd.bnlkhmtw-lljuZbj.nqf@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=wAzPZXrwubmWQmF9WVABuPChIdQrJJ+ZBr0dE550aoQ=;
        b=uz44LnEkT/HTvu3a4Wew6M3VjtSaNjOPAV8IN3679cQGnDIKZPAY5UEh6r2rpz7ttY
         mMl3o4SwPUEN2ofrfX3B0/LWAnL+RPx9lzPcuaqTrmrcSmlARl9V1n1DoKFbvSJGzft0
         6H0/dBM/WwbApZ+lzUY8DC1Wl+UbflS1eUi+68yXwwQWB+YKRoOtMMYXAHQsKTpu/pnn
         LSdeJgCWccEPe8WNpebhj5En/NqxVTcptMohp6f288qWX32M+IcfqNcPhSwSzwQBNTix
         qmG7T2aSp8g3xTX5pBmhi3ZhghhDIO5DbBC0B/sT5BxS/AO/RZEdc9pecFFoI/oOINKv
         J6vw==
X-Google-Smtp-Source: APXvYqwHmXjFzMWCMAI7HOZrq6fzDFcA552ul92tFMFuwikUvnM6lV/3lV2pYXjBJL2nc139P7EnlIzMCyk=
X-Received: by 2002:ab0:348a:: with SMTP id c10mr45283321uar.79.1555602164536;
 Thu, 18 Apr 2019 08:42:44 -0700 (PDT)
Date: Thu, 18 Apr 2019 17:42:08 +0200
In-Reply-To: <20190418154208.131118-1-glider@google.com>
Message-Id: <20190418154208.131118-4-glider@google.com>
Mime-Version: 1.0
References: <20190418154208.131118-1-glider@google.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH 3/3] RFC: net: apply __GFP_NOINIT to AF_UNIX sk_buff allocations
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, dvyukov@google.com, 
	keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add sock_alloc_send_pskb_noinit(), which is similar to
sock_alloc_send_pskb(), but allocates with __GFP_NOINIT.
This helps reduce the slowdown on hackbench from 9% to 0.1%.

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
Cc: Qian Cai <cai@lca.pw>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com

---
 include/net/sock.h |  5 +++++
 net/core/sock.c    | 29 +++++++++++++++++++++++++----
 net/unix/af_unix.c | 13 +++++++------
 3 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8de5ee258b93..37fcdda23884 100644
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
index 99b288a19b39..0a2af1e1fa1c 100644
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
2.21.0.392.gf8f6787159e-goog

