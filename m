Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 956E66B029C
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so7368750pga.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p7sor1644509pga.91.2017.09.20.13.46.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:14 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 20/31] caif: Define usercopy region in caif proto slab cache
Date: Wed, 20 Sep 2017 13:45:26 -0700
Message-Id: <1505940337-79069-21-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The CAIF channel connection request parameters need to be copied to/from
userspace. In support of usercopy hardening, this patch defines a region
in the struct proto slab cache in which userspace copy operations are
allowed.

example usage trace:

    net/caif/caif_socket.c:
        setsockopt(...):
            ...
            copy_from_user(&cf_sk->conn_req.param.data, ..., ol)

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
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/caif/caif_socket.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 632d5a416d97..c76d513b9a7a 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1032,6 +1032,8 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 	static struct proto prot = {.name = "PF_CAIF",
 		.owner = THIS_MODULE,
 		.obj_size = sizeof(struct caifsock),
+		.useroffset = offsetof(struct caifsock, conn_req.param),
+		.usersize = sizeof_field(struct caifsock, conn_req.param)
 	};
 
 	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
