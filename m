Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E85236B027F
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:09:39 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m7so1683344pgv.17
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:09:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 95sor6061378pld.90.2018.01.10.18.09.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:09:38 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 23/38] net: Define usercopy region in struct proto slab cache
Date: Wed, 10 Jan 2018 18:02:55 -0800
Message-Id: <1515636190-24061-24-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>, David Howells <dhowells@redhat.com>, netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

In support of usercopy hardening, this patch defines a region in the
struct proto slab cache in which userspace copy operations are allowed.
Some protocols need to copy objects to/from userspace, and they can
declare the region via their proto structure with the new usersize and
useroffset fields. Initially, if no region is specified (usersize ==
0), the entire field is marked as whitelisted. This allows protocols
to be whitelisted in subsequent patches. Once all protocols have been
annotated, the full-whitelist default can be removed.

This region is known as the slab cache's usercopy region. Slab caches
can now check that each dynamically sized copy operation involving
cache-managed memory falls entirely within the slab's usercopy region.

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
index 79e1a2c7912c..b77a710ee831 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1112,6 +1112,8 @@ struct proto {
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
 	slab_flags_t		slab_flags;
+	size_t			useroffset;	/* Usercopy region offset */
+	size_t			usersize;	/* Usercopy region size */
 
 	struct percpu_counter	*orphan_count;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index c0b5b2f17412..261e6dbf0259 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3151,8 +3151,12 @@ static int req_prot_init(const struct proto *prot)
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
