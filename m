Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFAE6B049E
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:43:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r133so2597614pgr.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:54 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id o63si1025983pfg.65.2017.08.28.14.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:43:53 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id h75so4745833pfh.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:53 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 23/30] net: Restrict unwhitelisted proto caches to size 0
Date: Mon, 28 Aug 2017 14:35:04 -0700
Message-Id: <1503956111-36652-24-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>, David Howells <dhowells@redhat.com>, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>

Now that protocols have been annotated (the copy of icsk_ca_ops->name
is of an ops field from outside the slab cache):

$ git grep 'copy_.*_user.*sk.*->'
caif/caif_socket.c: copy_from_user(&cf_sk->conn_req.param.data, ov, ol)) {
ipv4/raw.c:   if (copy_from_user(&raw_sk(sk)->filter, optval, optlen))
ipv4/raw.c:       copy_to_user(optval, &raw_sk(sk)->filter, len))
ipv4/tcp.c:       if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
ipv4/tcp.c:       if (copy_to_user(optval, icsk->icsk_ulp_ops->name, len))
ipv6/raw.c:       if (copy_from_user(&raw6_sk(sk)->filter, optval, optlen))
ipv6/raw.c:           if (copy_to_user(optval, &raw6_sk(sk)->filter, len))
sctp/socket.c: if (copy_from_user(&sctp_sk(sk)->subscribe, optval, optlen))
sctp/socket.c: if (copy_to_user(optval, &sctp_sk(sk)->subscribe, len))
sctp/socket.c: if (copy_to_user(optval, &sctp_sk(sk)->initmsg, len))

we can switch the default proto usercopy region to size 0. Any protocols
needing to add whitelisted regions must annotate the fields with the
useroffset and usersize fields of struct proto.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/core/sock.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 02dab98ca3e3..c7d0afa1d0b1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3112,9 +3112,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 		prot->slab = kmem_cache_create_usercopy(prot->name,
 					prot->obj_size, 0,
 					SLAB_HWCACHE_ALIGN | prot->slab_flags,
-					prot->usersize ? prot->useroffset : 0,
-					prot->usersize ? prot->usersize
-						       : prot->obj_size,
+					prot->useroffset, prot->usersize,
 					NULL);
 
 		if (prot->slab == NULL) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
