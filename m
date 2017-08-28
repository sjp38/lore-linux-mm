Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00D416B04B1
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:53:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 128so2575565pgd.10
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:53:52 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id n2si958710pfj.599.2017.08.28.14.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:53:51 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id z87so4770700pfi.3
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:53:51 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 18/30] net: Define usercopy region in struct proto slab cache
Date: Mon, 28 Aug 2017 14:34:59 -0700
Message-Id: <1503956111-36652-19-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>, David Howells <dhowells@redhat.com>, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

In support of usercopy hardening, this patch defines a region in the
struct proto slab cache in which userspace copy operations are allowed.
Some protocols need to copy objects to/from userspace, and they can
declare the region via their proto structure with the new usersize and
useroffset fields. Initially, if no region is specified (usersize ==
0), the entire field is marked as whitelisted. This allows protocols
to be whitelisted in subsequent patches. Once all protocols have been
annotated, the full-whitelist default can be removed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, split off per-proto patches]
[kees: add logic for by-default full-whitelist]
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/net/sock.h | 2 ++
 net/core/sock.c    | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7c0632c7e870..170d5b2dbcb6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1106,6 +1106,8 @@ struct proto {
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
 	int			slab_flags;
+	size_t			useroffset;	/* Usercopy region offset */
+	size_t			usersize;	/* Usercopy region size */
 
 	struct percpu_counter	*orphan_count;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index ac2a404c73eb..02dab98ca3e3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3109,8 +3109,12 @@ static int req_prot_init(const struct proto *prot)
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	if (alloc_slab) {
-		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
+		prot->slab = kmem_cache_create_usercopy(prot->name,
+					prot->obj_size, 0,
 					SLAB_HWCACHE_ALIGN | prot->slab_flags,
+					prot->usersize ? prot->useroffset : 0,
+					prot->usersize ? prot->usersize
+						       : prot->obj_size,
 					NULL);
 
 		if (prot->slab == NULL) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
