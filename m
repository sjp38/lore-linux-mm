Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 974176B0338
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:05 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u30so40517974qtu.14
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v88si18057898qte.114.2017.04.24.06.24.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:03 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 08/20] mm: ensure that we set mapping error if writeout() fails
Date: Mon, 24 Apr 2017 09:22:47 -0400
Message-Id: <20170424132259.8680-9-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

If writepage fails during a page migration, then we need to ensure that
fsync will see it by flagging the mapping.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/migrate.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 738f1d5f8350..3a59830bdae2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -792,7 +792,11 @@ static int writeout(struct address_space *mapping, struct page *page)
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
