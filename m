Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09B2C831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 11:30:20 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id a189so93804901qkc.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 08:30:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z59si3310532qtc.147.2017.03.08.08.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 08:30:12 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v2 4/9] nilfs2: set the mapping error when calling SetPageError on writeback
Date: Wed,  8 Mar 2017 11:29:29 -0500
Message-Id: <20170308162934.21989-5-jlayton@redhat.com>
In-Reply-To: <20170308162934.21989-1-jlayton@redhat.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

In a later patch, we're going to want to make the fsync codepath not do
a TestClearPageError call as that can override the error set in the
address space. To do that though, we need to ensure that filesystems
that are relying on the PG_error bit for reporting writeback errors
also set an error in the address space.

Ensure that this is set in nilfs2.

Cc: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nilfs2/segment.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index febed1217b3f..612d4b446793 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -1745,6 +1745,7 @@ static void nilfs_end_page_io(struct page *page, int err)
 	} else {
 		__set_page_dirty_nobuffers(page);
 		SetPageError(page);
+		mapping_set_error(page_mapping(page), err);
 	}
 
 	end_page_writeback(page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
