Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCB46B000C
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:29:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id r6so9570850pfk.9
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:29:13 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id c9-v6si7930940plk.216.2018.02.26.20.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 20:29:12 -0800 (PST)
Subject: [PATCH v4 02/12] dax: introduce IS_DEVDAX() and IS_FSDAX()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 26 Feb 2018 20:20:05 -0800
Message-ID: <151970520551.26729.12707678649514382892.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Theodore Ts'o <tytso@mit.edu>, "Darrick J. Wong" <darrick.wong@oracle.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "supporter:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>

The current IS_DAX() helper that checks the S_DAX inode flag is
ambiguous, and currently has the broken assumption that the S_DAX flag
is only non-zero in the CONFIG_FS_DAX=y case. In preparation for
defining S_DAX to non-zero in the  CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y
case, introduce two explicit helpers to replace IS_DAX().

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org (supporter:XFS FILESYSTEM)
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Reported-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/fs.h |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 79c413985305..bd0c46880572 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1909,6 +1909,28 @@ static inline bool sb_rdonly(const struct super_block *sb) { return sb->s_flags
 #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
 				 (inode)->i_rdev == WHITEOUT_DEV)
 
+static inline bool IS_DEVDAX(struct inode *inode)
+{
+	if (!IS_ENABLED(CONFIG_DEV_DAX))
+		return false;
+	if ((inode->i_flags & S_DAX) == 0)
+		return false;
+	if (!S_ISCHR(inode->i_mode))
+		return false;
+	return true;
+}
+
+static inline bool IS_FSDAX(struct inode *inode)
+{
+	if (!IS_ENABLED(CONFIG_FS_DAX))
+		return false;
+	if ((inode->i_flags & S_DAX) == 0)
+		return false;
+	if (S_ISCHR(inode->i_mode))
+		return false;
+	return true;
+}
+
 static inline bool HAS_UNMAPPED_ID(struct inode *inode)
 {
 	return !uid_valid(inode->i_uid) || !gid_valid(inode->i_gid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
