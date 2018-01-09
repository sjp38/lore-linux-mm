Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B412E6B0274
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q1so9368960pgv.4
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor5395934plv.132.2018.01.09.12.57.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:09 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 25/36] net: Restrict unwhitelisted proto caches to size 0
Date: Tue,  9 Jan 2018 12:55:54 -0800
Message-Id: <1515531365-37423-26-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>, David Howells <dhowells@redhat.com>, netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
index 261e6dbf0259..f39206b41b32 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3154,9 +3154,7 @@ int proto_register(struct proto *prot, int alloc_slab)
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
