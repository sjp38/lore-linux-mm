Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E81A6B029E
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so6482217pfj.4
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k23sor1338735pli.21.2017.09.20.13.46.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:15 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 16/31] cifs: Define usercopy region in cifs_request slab cache
Date: Wed, 20 Sep 2017 13:45:22 -0700
Message-Id: <1505940337-79069-17-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

CIFS request buffers, stored in the cifs_request slab cache, need to be
copied to/from userspace.

cache object allocation:
    fs/cifs/cifsfs.c:
        cifs_init_request_bufs():
            ...
            cifs_req_poolp = mempool_create_slab_pool(cifs_min_rcv,
                                                      cifs_req_cachep);

    fs/cifs/misc.c:
        cifs_buf_get():
            ...
            ret_buf = mempool_alloc(cifs_req_poolp, GFP_NOFS);
            ...
            return ret_buf;

In support of usercopy hardening, this patch defines a region in the
cifs_request slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region.  Slab
caches can now check that each copy operation involving cache-managed
memory falls entirely within the slab's usercopy region.

This patch is verbatim from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: Steve French <sfrench@samba.org>
Cc: linux-cifs@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
I wasn't able to actually track down the _usage_ of the cifs_request where
it is copied to userspace. If any CIFS folks could help point that out, it
would be very welcome. :) I suspect it might be part of the debug routines,
but I never managed to exercise them.
---
 fs/cifs/cifsfs.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 180b3356ff86..09dfdf76c738 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1229,9 +1229,11 @@ cifs_init_request_bufs(void)
 	cifs_dbg(VFS, "CIFSMaxBufSize %d 0x%x\n",
 		 CIFSMaxBufSize, CIFSMaxBufSize);
 */
-	cifs_req_cachep = kmem_cache_create("cifs_request",
+	cifs_req_cachep = kmem_cache_create_usercopy("cifs_request",
 					    CIFSMaxBufSize + max_hdr_size, 0,
-					    SLAB_HWCACHE_ALIGN, NULL);
+					    SLAB_HWCACHE_ALIGN, 0,
+					    CIFSMaxBufSize + max_hdr_size,
+					    NULL);
 	if (cifs_req_cachep == NULL)
 		return -ENOMEM;
 
@@ -1257,9 +1259,9 @@ cifs_init_request_bufs(void)
 	more SMBs to use small buffer alloc and is still much more
 	efficient to alloc 1 per page off the slab compared to 17K (5page)
 	alloc of large cifs buffers even when page debugging is on */
-	cifs_sm_req_cachep = kmem_cache_create("cifs_small_rq",
+	cifs_sm_req_cachep = kmem_cache_create_usercopy("cifs_small_rq",
 			MAX_CIFS_SMALL_BUFFER_SIZE, 0, SLAB_HWCACHE_ALIGN,
-			NULL);
+			0, MAX_CIFS_SMALL_BUFFER_SIZE, NULL);
 	if (cifs_sm_req_cachep == NULL) {
 		mempool_destroy(cifs_req_poolp);
 		kmem_cache_destroy(cifs_req_cachep);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
