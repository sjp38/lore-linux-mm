Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC6E46B026E
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:07 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d199so7576906pfd.9
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n74sor3916730pfk.22.2018.01.09.12.57.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:06 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 22/36] caif: Define usercopy region in caif proto slab cache
Date: Tue,  9 Jan 2018 12:55:51 -0800
Message-Id: <1515531365-37423-23-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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

This region is known as the slab cache's usercopy region. Slab caches
can now check that each dynamically sized copy operation involving
cache-managed memory falls entirely within the slab's usercopy region.

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
