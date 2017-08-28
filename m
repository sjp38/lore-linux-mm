Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2CA6B03B4
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r133so2569680pgr.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:28 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id s185si963788pgb.382.2017.08.28.14.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:27 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id t3so5024317pgt.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:27 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 16/30] cifs: Define usercopy region in cifs_request slab cache
Date: Mon, 28 Aug 2017 14:34:57 -0700
Message-Id: <1503956111-36652-17-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
Cc: samba-technical@lists.samba.org
Signed-off-by: Kees Cook <keescook@chromium.org>
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
