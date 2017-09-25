Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3A066B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 14:48:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 6so17575006pgh.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:48:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f10si4527532pgr.778.2017.09.25.11.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 11:48:06 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 03/22] mm/shmem: parse mount options for MS_KERNMOUNT
Date: Mon, 25 Sep 2017 19:47:18 +0100
Message-Id: <20170925184737.8807-4-matthew.auld@intel.com>
In-Reply-To: <20170925184737.8807-1-matthew.auld@intel.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

In i915 we now have our own tmpfs mount, so ensure that shmem_fill_super
also calls shmem_parse_options when dealing with a kernel mount.
Otherwise we have to clumsily call remount_fs when we want to supply our
mount options.

Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 mm/shmem.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ae2e46291ffa..6074e527b9b9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3781,13 +3781,15 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	if (!(sb->s_flags & MS_KERNMOUNT)) {
 		sbinfo->max_blocks = shmem_default_max_blocks();
 		sbinfo->max_inodes = shmem_default_max_inodes();
-		if (shmem_parse_options(data, sbinfo, false)) {
-			err = -EINVAL;
-			goto failed;
-		}
 	} else {
 		sb->s_flags |= MS_NOUSER;
 	}
+
+	if (shmem_parse_options(data, sbinfo, false)) {
+		err = -EINVAL;
+		goto failed;
+	}
+
 	sb->s_export_op = &shmem_export_ops;
 	sb->s_flags |= MS_NOSEC;
 #else
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
