Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CAE96B0011
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 23:02:52 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u188so4572949pfb.6
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 20:02:52 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v6si3434356pgq.146.2018.03.01.20.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 20:02:50 -0800 (PST)
Subject: [PATCH v5 02/12] dax: introduce IS_DEVDAX() and IS_FSDAX()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:53:44 -0800
Message-ID: <151996282448.28483.10415125852182473579.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>Jan Kara <jack@suse.cz>, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The current IS_DAX() helper that checks if a file is in DAX mode serves
two purposes. It is a control flow branch condition for DAX vs
non-DAX paths and it is a mechanism to perform dead code elimination. The
dead code elimination is required in the CONFIG_FS_DAX=n case since
there are symbols in fs/dax.c that will be elided. While the
dead code elimination can be addressed with nop stubs for the fs/dax.c
symbols that does not address the need for a DAX control flow helper
where fs/dax.c symbols are not involved.

Moreover, the control flow changes, in some cases, need to be cognizant
of whether the DAX file is a typical file or a Device-DAX special file.
Introduce IS_DEVDAX() and IS_FSDAX() to simultaneously address the
file-type control flow and dead-code elimination use cases. IS_DAX()
will be deleted after all sites are converted to use the file-type
specific helper.

Note, this change is also a pre-requisite for fixing the definition of
the S_DAX inode flag in the CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case.
The flag needs to be defined, non-zero, if either DAX facility is
enabled.

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Reported-by: Jan Kara <jack@suse.cz>
Reviewed-by: Jan Kara <jack@suse.cz>
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
