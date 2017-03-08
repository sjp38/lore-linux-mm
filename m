Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3A8831FA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 11:30:34 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id f191so77128321qka.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 08:30:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t188si3293022qkh.308.2017.03.08.08.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 08:30:19 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v2 7/9] mm: ensure that we set mapping error if writeout() fails
Date: Wed,  8 Mar 2017 11:29:32 -0500
Message-Id: <20170308162934.21989-8-jlayton@redhat.com>
In-Reply-To: <20170308162934.21989-1-jlayton@redhat.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

If writepage fails during a page migration, then we need to ensure that
fsync will see it by flagging the mapping.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/migrate.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 9a0897a14d37..a9c0b46865b7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -789,7 +789,11 @@ static int writeout(struct address_space *mapping, struct page *page)
 		/* unlocked. Relock */
 		lock_page(page);
 
-	return (rc < 0) ? -EIO : -EAGAIN;
+	if (rc < 0) {
+		mapping_set_error(mapping, rc);
+		return -EIO;
+	}
+	return -EAGAIN;
 }
 
 /*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
