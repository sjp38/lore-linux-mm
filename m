Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 896A16B0343
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:42:29 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id s33so42781924qtg.1
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:42:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p65si8454567qkc.231.2017.06.12.05.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:42:28 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [xfstests PATCH v4 4/5] ext3: allow it to put journal on a separate device when doing scratch_mkfs
Date: Mon, 12 Jun 2017 08:42:12 -0400
Message-Id: <20170612124213.14855-5-jlayton@redhat.com>
In-Reply-To: <20170612124213.14855-1-jlayton@redhat.com>
References: <20170612124213.14855-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 common/rc | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/common/rc b/common/rc
index 08807ac7c22a..46b890cbff6a 100644
--- a/common/rc
+++ b/common/rc
@@ -832,7 +832,16 @@ _scratch_mkfs()
 		mkfs_cmd="$MKFS_BTRFS_PROG"
 		mkfs_filter="cat"
 		;;
-	ext2|ext3)
+	ext3)
+		mkfs_cmd="$MKFS_PROG -t $FSTYP -- -F"
+		mkfs_filter="grep -v -e ^Warning: -e \"^mke2fs \""
+
+		# put journal on separate device?
+		[ "$USE_EXTERNAL" = yes -a ! -z "$SCRATCH_LOGDEV" ] && \
+		$mkfs_cmd -O journal_dev $SCRATCH_LOGDEV && \
+		mkfs_cmd="$mkfs_cmd $MKFS_OPTIONS -J device=$SCRATCH_LOGDEV"
+		;;
+	ext2)
 		mkfs_cmd="$MKFS_PROG -t $FSTYP -- -F"
 		mkfs_filter="grep -v -e ^Warning: -e \"^mke2fs \""
 		;;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
