Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB7C54404A3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:36:46 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 48so42660801qts.7
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:36:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s2si2743857qtg.280.2017.06.16.12.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:36:46 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [xfstests PATCH v5 2/5] ext3: allow it to put journal on a separate device when doing scratch_mkfs
Date: Fri, 16 Jun 2017 15:36:16 -0400
Message-Id: <20170616193619.14576-3-jlayton@redhat.com>
In-Reply-To: <20170616193619.14576-1-jlayton@redhat.com>
References: <20170616193619.14576-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 common/rc | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/common/rc b/common/rc
index 57001b47a8b7..43e160e91360 100644
--- a/common/rc
+++ b/common/rc
@@ -840,7 +840,16 @@ _scratch_mkfs()
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
+		$mkfs_cmd -O journal_dev $MKFS_OPTIONS $SCRATCH_LOGDEV && \
+		mkfs_cmd="$mkfs_cmd -J device=$SCRATCH_LOGDEV"
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
