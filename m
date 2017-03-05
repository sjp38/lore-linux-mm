Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF4B86B038A
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 08:35:39 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n127so206767274qkf.3
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 05:35:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i58si13464498qti.175.2017.03.05.05.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Mar 2017 05:35:39 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/3] nilfs2: set the mapping error when calling SetPageError on writeback
Date: Sun,  5 Mar 2017 08:35:33 -0500
Message-Id: <20170305133535.6516-2-jlayton@redhat.com>
In-Reply-To: <20170305133535.6516-1-jlayton@redhat.com>
References: <20170305133535.6516-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org

In a later patch, we're going to want to make the fsync codepath not do
a TestClearPageError call as that can override the error set in the
address space. To do that though, we need to ensure that filesystems
that are relying on the PG_error bit for reporting writeback errors
also set an error in the address space.

The only place I've found that looks potentially problematic is this
spot in nilfs2. Ensure that it sets an error in the mapping in addition
to setting PageError.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nilfs2/segment.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index bedcae2c28e6..c1041b07060e 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -1743,6 +1743,7 @@ static void nilfs_end_page_io(struct page *page, int err)
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
