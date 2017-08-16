Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 13F686B0313
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:51:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so53967675pge.9
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:51:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f35si178334plh.656.2017.08.16.00.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 00:50:58 -0700 (PDT)
Subject: [PATCH v5 5/5] fs, fcntl: add F_MAP_DIRECT
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Aug 2017 00:44:33 -0700
Message-ID: <150286947385.8837.2630371125726376087.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

A common pattern for granting a privilege to an unprivileged process is
to pass it an established file descriptor over a unix domain socket.
This enables fine grained access to the MAP_DIRECT mechanism instead of
requiring the mapping process have CAP_LINUX_IMMUTABLE.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/fcntl.c                 |   15 +++++++++++++++
 include/linux/fs.h         |    5 +++--
 include/uapi/linux/fcntl.h |    5 +++++
 mm/mmap.c                  |    3 ++-
 4 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 3b01b646e528..f2375c406e6f 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -318,6 +318,18 @@ static long fcntl_rw_hint(struct file *file, unsigned int cmd,
 	}
 }
 
+static int fcntl_map_direct(struct file *filp)
+{
+	if (!capable(CAP_LINUX_IMMUTABLE))
+		return -EACCES;
+
+	spin_lock(&filp->f_lock);
+	filp->f_map_direct = 1;
+	spin_unlock(&filp->f_lock);
+
+	return 0;
+}
+
 static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 		struct file *filp)
 {
@@ -425,6 +437,9 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 	case F_SET_FILE_RW_HINT:
 		err = fcntl_rw_hint(filp, cmd, arg);
 		break;
+	case F_MAP_DIRECT:
+		err = fcntl_map_direct(filp);
+		break;
 	default:
 		break;
 	}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index db42da9f98c4..3f7026974dd2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -855,11 +855,12 @@ struct file {
 	const struct file_operations	*f_op;
 
 	/*
-	 * Protects f_ep_links, f_flags.
+	 * Protects f_ep_links, f_flags, f_write_hint, and f_map_direct.
 	 * Must not be taken from IRQ context.
 	 */
 	spinlock_t		f_lock;
-	enum rw_hint		f_write_hint;
+	enum rw_hint		f_write_hint:3;
+	int			f_map_direct:1;
 	atomic_long_t		f_count;
 	unsigned int 		f_flags;
 	fmode_t			f_mode;
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index ec69d55bcec7..2a57a503174e 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -53,6 +53,11 @@
 #define F_SET_FILE_RW_HINT	(F_LINUX_SPECIFIC_BASE + 14)
 
 /*
+ * Enable MAP_DIRECT on the file without CAP_LINUX_IMMUTABLE
+ */
+#define F_MAP_DIRECT		(F_LINUX_SPECIFIC_BASE + 15)
+
+/*
  * Valid hint values for F_{GET,SET}_RW_HINT. 0 is "not set", or can be
  * used to clear any hints previously set.
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index 32417b2a668c..cf5e0cb7d0e3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1399,7 +1399,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			if (flags & MAP_DIRECT) {
 				if (!(prot & PROT_WRITE))
 					return -EACCES;
-				if (!capable(CAP_LINUX_IMMUTABLE))
+				if (!file->f_map_direct
+						&& !capable(CAP_LINUX_IMMUTABLE))
 					return -EACCES;
 			}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
