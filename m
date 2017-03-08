Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8CD831FA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 11:30:33 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id v125so84871172qkh.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 08:30:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u62si3322010qkh.38.2017.03.08.08.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 08:30:22 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v2 9/9] Documentation: document what to do on a writeback error
Date: Wed,  8 Mar 2017 11:29:34 -0500
Message-Id: <20170308162934.21989-10-jlayton@redhat.com>
In-Reply-To: <20170308162934.21989-1-jlayton@redhat.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

There's no real guidance on this for filesystem authors, so add a
paragraph to vfs.txt that explains how this should be handled.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/vfs.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 569211703721..527370fbab39 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -577,6 +577,13 @@ should clear PG_Dirty and set PG_Writeback.  It can be actually
 written at any point after PG_Dirty is clear.  Once it is known to be
 safe, PG_Writeback is cleared.
 
+If there is an error during writeback, then the address_space should be
+marked with an AS_EIO or AS_ENOSPC error, in order to ensure that the
+error will be reported to the application at fsync or close.  Most
+writepage callers will do this automatically if writepage returns an
+error, but writepages implementations generally need to ensure this
+themselves.
+
 Writeback makes use of a writeback_control structure...
 
 struct address_space_operations
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
