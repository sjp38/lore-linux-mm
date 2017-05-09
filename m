Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B94B7280730
	for <linux-mm@kvack.org>; Tue,  9 May 2017 12:13:00 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u13so1835362qku.11
        for <linux-mm@kvack.org>; Tue, 09 May 2017 09:13:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f123si458679qkd.196.2017.05.09.09.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 09:13:00 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [xfstests PATCH v2 2/3] ext4: allow ext4 to use $SCRATCH_LOGDEV
Date: Tue,  9 May 2017 12:12:44 -0400
Message-Id: <20170509161245.29908-3-jlayton@redhat.com>
In-Reply-To: <20170509161245.29908-1-jlayton@redhat.com>
References: <20170509161245.29908-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, fstests@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

The writeback error handling test requires that you put the journal on a
separate device. This allows us to use dmerror to simulate data
writeback failure, without affecting the journal.

xfs already has infrastructure for this (a'la $SCRATCH_LOGDEV), so wire
up the ext4 code so that it can do the same thing when _scratch_mkfs is
called.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 common/rc | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/common/rc b/common/rc
index 257b1903359d..8b815d9c8c33 100644
--- a/common/rc
+++ b/common/rc
@@ -675,6 +675,9 @@ _scratch_mkfs_ext4()
 	local tmp=`mktemp`
 	local mkfs_status
 
+	[ "$USE_EXTERNAL" = yes -a ! -z "$SCRATCH_LOGDEV" ] && \
+	    $mkfs_cmd -O journal_dev $SCRATCH_LOGDEV && \
+	    mkfs_cmd="$mkfs_cmd -J device=$SCRATCH_LOGDEV"
 
 	_scratch_do_mkfs "$mkfs_cmd" "$mkfs_filter" $* 2>$tmp.mkfserr 1>$tmp.mkfsstd
 	mkfs_status=$?
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
