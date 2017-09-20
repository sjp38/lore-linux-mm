Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D83486B02BB
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:53:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so6471707pff.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:53:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t137sor2329356pgb.211.2017.09.20.13.53.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:53:00 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 19/31] ip: Define usercopy region in IP proto slab cache
Date: Wed, 20 Sep 2017 13:45:25 -0700
Message-Id: <1505940337-79069-20-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The ICMP filters for IPv4 and IPv6 raw sockets need to be copied to/from
userspace. In support of usercopy hardening, this patch defines a region
in the struct proto slab cache in which userspace copy operations are
allowed.

example usage trace:

    net/ipv4/raw.c:
        raw_seticmpfilter(...):
            ...
            copy_from_user(&raw_sk(sk)->filter, ..., optlen)

        raw_geticmpfilter(...):
            ...
            copy_to_user(..., &raw_sk(sk)->filter, len)

    net/ipv6/raw.c:
        rawv6_seticmpfilter(...):
            ...
            copy_from_user(&raw6_sk(sk)->filter, ..., optlen)

        rawv6_geticmpfilter(...):
            ...
            copy_to_user(..., &raw6_sk(sk)->filter, len)

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: split from network patch, provide usage trace]
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/ipv4/raw.c | 2 ++
 net/ipv6/raw.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 33b70bfd1122..1b6fa4195ac9 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -970,6 +970,8 @@ struct proto raw_prot = {
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw_sock),
+	.useroffset	   = offsetof(struct raw_sock, filter),
+	.usersize	   = sizeof_field(struct raw_sock, filter),
 	.h.raw_hash	   = &raw_v4_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_raw_setsockopt,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e4462b0ff801..041d1cd5e774 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1268,6 +1268,8 @@ struct proto rawv6_prot = {
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw6_sock),
+	.useroffset	   = offsetof(struct raw6_sock, filter),
+	.usersize	   = sizeof_field(struct raw6_sock, filter),
 	.h.raw_hash	   = &raw_v6_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_rawv6_setsockopt,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
