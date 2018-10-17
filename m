Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3AFF6B028F
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:47:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2-v6so21048435pgr.8
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:47:04 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id bb10-v6si18506072plb.359.2018.10.17.15.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:47:03 -0700 (PDT)
Subject: [PATCH 23/29] xfs: add a per-xfs trace_printk macro
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 17 Oct 2018 15:46:59 -0700
Message-ID: <153981641972.5568.6155004838582569988.stgit@magnolia>
In-Reply-To: <153981625504.5568.2708520119290577378.stgit@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

Add a "xfs_tprintk" macro so that developers can use trace_printk to
print out arbitrary debugging information with the XFS device name
attached to the trace output.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_error.h |    6 ++++++
 1 file changed, 6 insertions(+)


diff --git a/fs/xfs/xfs_error.h b/fs/xfs/xfs_error.h
index 246d3e989c6c..5caa8bdf6c38 100644
--- a/fs/xfs/xfs_error.h
+++ b/fs/xfs/xfs_error.h
@@ -76,6 +76,11 @@ extern int xfs_errortag_set(struct xfs_mount *mp, unsigned int error_tag,
 		unsigned int tag_value);
 extern int xfs_errortag_add(struct xfs_mount *mp, unsigned int error_tag);
 extern int xfs_errortag_clearall(struct xfs_mount *mp);
+
+/* trace printk version of xfs_err and friends */
+#define xfs_tprintk(mp, fmt, args...) \
+	trace_printk("dev %d:%d " fmt, MAJOR((mp)->m_super->s_dev), \
+			MINOR((mp)->m_super->s_dev), ##args)
 #else
 #define xfs_errortag_init(mp)			(0)
 #define xfs_errortag_del(mp)
@@ -83,6 +88,7 @@ extern int xfs_errortag_clearall(struct xfs_mount *mp);
 #define xfs_errortag_set(mp, tag, val)		(ENOSYS)
 #define xfs_errortag_add(mp, tag)		(ENOSYS)
 #define xfs_errortag_clearall(mp)		(ENOSYS)
+#define xfs_tprintk(mp, fmt, args...)		do { } while (0)
 #endif /* DEBUG */
 
 /*
