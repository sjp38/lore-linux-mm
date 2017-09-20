Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B79D6B02AB
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:52:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p87so6504241pfj.4
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:52:55 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j91sor1328232pld.136.2017.09.20.13.52.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:52:54 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 17/31] scsi: Define usercopy region in scsi_sense_cache slab cache
Date: Wed, 20 Sep 2017 13:45:23 -0700
Message-Id: <1505940337-79069-18-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-scsi@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

SCSI sense buffers, stored in struct scsi_cmnd.sense and therefore
contained in the scsi_sense_cache slab cache, need to be copied to/from
userspace.

cache object allocation:
    drivers/scsi/scsi_lib.c:
        scsi_select_sense_cache(...):
            return ... ? scsi_sense_isadma_cache : scsi_sense_cache

        scsi_alloc_sense_buffer(...):
            return kmem_cache_alloc_node(scsi_select_sense_cache(), ...);

        scsi_init_request(...):
            ...
            cmd->sense_buffer = scsi_alloc_sense_buffer(...);
            ...
            cmd->req.sense = cmd->sense_buffer

example usage trace:

    block/scsi_ioctl.c:
        (inline from sg_io)
        blk_complete_sghdr_rq(...):
            struct scsi_request *req = scsi_req(rq);
            ...
            copy_to_user(..., req->sense, len)

        scsi_cmd_ioctl(...):
            sg_io(...);

In support of usercopy hardening, this patch defines a region in
the scsi_sense_cache slab cache in which userspace copy operations
are allowed.

This region is known as the slab cache's usercopy region.  Slab
caches can now check that each copy operation involving cache-managed
memory falls entirely within the slab's usercopy region.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: linux-scsi@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/scsi/scsi_lib.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index 9cf6a80fe297..88bfab251693 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -79,14 +79,15 @@ int scsi_init_sense_cache(struct Scsi_Host *shost)
 	if (shost->unchecked_isa_dma) {
 		scsi_sense_isadma_cache =
 			kmem_cache_create("scsi_sense_cache(DMA)",
-			SCSI_SENSE_BUFFERSIZE, 0,
-			SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA, NULL);
+				SCSI_SENSE_BUFFERSIZE, 0,
+				SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA, NULL);
 		if (!scsi_sense_isadma_cache)
 			ret = -ENOMEM;
 	} else {
 		scsi_sense_cache =
-			kmem_cache_create("scsi_sense_cache",
-			SCSI_SENSE_BUFFERSIZE, 0, SLAB_HWCACHE_ALIGN, NULL);
+			kmem_cache_create_usercopy("scsi_sense_cache",
+				SCSI_SENSE_BUFFERSIZE, 0, SLAB_HWCACHE_ALIGN,
+				0, SCSI_SENSE_BUFFERSIZE, NULL);
 		if (!scsi_sense_cache)
 			ret = -ENOMEM;
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
