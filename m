Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B199C46460
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8237208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8237208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23C466B0270; Wed,  5 Jun 2019 21:45:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A0EC6B0271; Wed,  5 Jun 2019 21:45:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBE496B0272; Wed,  5 Jun 2019 21:45:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEBED6B0270
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so483599plt.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RwseoB0hw/rDqmwrfSdhujbgyOh6rWSvNFjMF8DwG0o=;
        b=ET/tJmMUyDl7HvGvQbq1XiQL2EIWAb++FXVoR287VJ17Ir17MGw0EpPELzaJ9Gzwcc
         K+WjI3EpadxyB4WSk75b/P2lcjKwjMDbI1geXF0BVd3DjcWo482Csa3UaPnc6SukF2wL
         UaWQ5Cy+6Ln0Ygbj395mvWcIRraA8PGzJmfzIDJqJo0pW6pC1GT3QjJf3vvZEpvtc2Ms
         AEKBMgMqwPQQnzkHH9psXr/U3RDtCfznOiUy4xITZIhPEphP1rEVjuOs+hTJ9AMbkKQc
         XiqlXora9VpmyLvdUc1TU2uKKhrK2QhB+oMFh0FlRdjq3jXWjD7dJ4wkKi3t8/wPPU5/
         alrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVNxpWKcTrpKl3PB7aEOrc6WRNZhNIxbwQjxNwa7JIJxN3tigw5
	/bQC4InHH3U1fbtK/SgNXW+P6fCRafwFFwmSJE3XdehCwr3RqY8GOmSSw+/3/0NnvMwXzdPCkTj
	gdtK4MBomsQ4VTffAGfHeHSbY+TKRytkN5HWuZg53HBt32UO/JRRru4h314So2YzY2A==
X-Received: by 2002:aa7:9a8c:: with SMTP id w12mr49714468pfi.187.1559785513319;
        Wed, 05 Jun 2019 18:45:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyE2TTVpf+b2d4I1TM/JpVT7/sveV8qOZ4DxhMTYiWBy+lgoB9RqET6qsnXc5B6E+UgyMEN
X-Received: by 2002:aa7:9a8c:: with SMTP id w12mr49714388pfi.187.1559785512099;
        Wed, 05 Jun 2019 18:45:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785512; cv=none;
        d=google.com; s=arc-20160816;
        b=fyRTPluJXtQg6sC/mUQdC2+fGwc8x536CCObfzZ89XQbKH58OgBEpIQqB3ZxOqpGPX
         2cvglbLkDXq2UlA/AH6F5/sJ1OG12CxJRFdL0hHYWrQC+Vf2Qqeb+xT8DI7K1m/wcZhP
         5zYSTjkHAiyseDSsbDhydlA2YNeDDaej8z+x/TzWBEbH9DYaTcN8OYitge1fU+IMTcr0
         dqIW7k9eNEI34/xqdlcdpb0vgp+Oq8pRYvkW2fqr1WfXFCdjL7Pmw0MdrBeMZKoG/tGx
         jgMSe9vr9/IOWlvO23+HmWdVNOVaDv0xiHMgFtgXVJJRw5wnJxMYYJutwsh2iH388baG
         /7Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RwseoB0hw/rDqmwrfSdhujbgyOh6rWSvNFjMF8DwG0o=;
        b=TH2xLDxWbpNOC2azgZgjCUSNzyOxCm7BcVJMOUc6lduiGUezmU3q1szKhyAKwxlRYQ
         wUgPV/Becx1BZwXNiWSllHd47oZrRKwynhyG968sf5jDY+sL1tdNt1KcdL+yUx8+gqi7
         73TbCeGgTOUZuhoJQO+kdW+mWVorLAiwtfAn53MalJ1tSzYYaropJy406EV5w2IoVwPF
         Wk7ubAywu6p1pDI8oHaxdfeCmqF5cKL6YP3h7LsoLp8SCASM4/+2Rgm14ZLuDDVnXQm1
         9W2XZbtkf32IUOopE+OD/YJlXzil6yTcy563xL/FqxHYL5GkRjh29grrRqRBf4vScLSE
         4r7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si276921pfk.103.2019.06.05.18.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:11 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:11 -0700
From: ira.weiny@intel.com
To: Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH RFC 02/10] fs/locks: Export F_LAYOUT lease to user space
Date: Wed,  5 Jun 2019 18:45:35 -0700
Message-Id: <20190606014544.8339-3-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190606014544.8339-1-ira.weiny@intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

GUP longterm pins of non-pagecache file system pages (eg FS DAX) are
currently disallowed because they are unsafe.

The danger for pinning these pages comes from the fact that hole punch
and/or truncate of those files results in the pages being mapped and
pinned by a user space process while DAX has potentially allocated those
pages to other processes.

Most (All) users who are mapping FS DAX pages for long term pin purposes
(such as RDMA) are not going to want to deallocate these pages while
those pages are in use.  To do so would mean the application would lose
data.  So the use case for allowing truncate operations of such pages
is limited.

However, the kernel must protect itself and users from potential
mistakes and/or malicious user space code.  Rather than disabling long
term pins as is done now.   Allow for users who know they are going to
be pinning this memory to alert the file system of this intention.
Furthermore, allow users to be alerted such that they can react if a
truncate operation occurs for some reason.

Example user space pseudocode for a user using RDMA and wanting to allow
a truncate would look like this:

lease_break_sigio_handler() {
...
	if (sigio.fd == rdma_fd) {
		complete_rdma_operations(...);
		ibv_dereg_mr(mr);
		close(rdma_fd);
		fcntl(rdma_fd, F_SETLEASE, F_UNLCK);
	}
}

setup_rdma_to_dax_file() {
...
	rdma_fd = open(...)
	fcntl(rdma_fd, F_SETLEASE, F_LAYOUT);
	sigaction(SIGIO, ...  lease_break ...);
	ptr = mmap(rdma_fd, ...);
	mr = ibv_reg_mr(ptr, ...);
	do_rdma_stuff(...);
}

Follow on patches implement the notification of the lease holder on
truncate as well as failing the truncate if the GUP pin is not released.

This first patch exports the F_LAYOUT lease type and allows the user to set
and get it.

After the complete series:

1) Failure to obtain a F_LAYOUT lease on an open FS DAX file will result
   in a failure to GUP pin any pages in that file.  An example of a call
   which results in GUP pin is ibv_reg_mr().
2) While the GUP pin is in place (eg MR is in use) truncates of the
   affected pages will fail.
3) If the user registers a sigaction they will be notified of the
   truncate so they can react.  Failure to react will result in the
   lease being revoked after <sysfs>/lease-break-time seconds.  After
   this time new GUP pins will fail without a new lease being taken.
4) A truncate will work if the pages being truncated are not actively
   pinned at the time of truncate.  Attempts to pin these pages after
   will result in a failure.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/locks.c                       | 36 +++++++++++++++++++++++++++-----
 include/linux/fs.h               |  2 +-
 include/uapi/asm-generic/fcntl.h |  3 +++
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 0cc2b9f30e22..de9761c068de 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -191,6 +191,8 @@ static int target_leasetype(struct file_lock *fl)
 		return F_UNLCK;
 	if (fl->fl_flags & FL_DOWNGRADE_PENDING)
 		return F_RDLCK;
+	if (fl->fl_flags & FL_LAYOUT)
+		return F_LAYOUT;
 	return fl->fl_type;
 }
 
@@ -611,7 +613,8 @@ static const struct lock_manager_operations lease_manager_ops = {
 /*
  * Initialize a lease, use the default lock manager operations
  */
-static int lease_init(struct file *filp, long type, struct file_lock *fl)
+static int lease_init(struct file *filp, long type, unsigned int flags,
+		      struct file_lock *fl)
 {
 	if (assign_type(fl, type) != 0)
 		return -EINVAL;
@@ -621,6 +624,8 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
 
 	fl->fl_file = filp;
 	fl->fl_flags = FL_LEASE;
+	if (flags & FL_LAYOUT)
+		fl->fl_flags |= FL_LAYOUT;
 	fl->fl_start = 0;
 	fl->fl_end = OFFSET_MAX;
 	fl->fl_ops = NULL;
@@ -629,7 +634,8 @@ static int lease_init(struct file *filp, long type, struct file_lock *fl)
 }
 
 /* Allocate a file_lock initialised to this type of lease */
-static struct file_lock *lease_alloc(struct file *filp, long type)
+static struct file_lock *lease_alloc(struct file *filp, long type,
+				     unsigned int flags)
 {
 	struct file_lock *fl = locks_alloc_lock();
 	int error = -ENOMEM;
@@ -637,7 +643,7 @@ static struct file_lock *lease_alloc(struct file *filp, long type)
 	if (fl == NULL)
 		return ERR_PTR(error);
 
-	error = lease_init(filp, type, fl);
+	error = lease_init(filp, type, flags, fl);
 	if (error) {
 		locks_free_lock(fl);
 		return ERR_PTR(error);
@@ -1588,7 +1594,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 	LIST_HEAD(dispose);
 
-	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
+	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK, 0);
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
 	new_fl->fl_flags = type;
@@ -1725,6 +1731,8 @@ EXPORT_SYMBOL(lease_get_mtime);
  *
  *	%F_UNLCK to indicate no lease is held.
  *
+ *	%F_LAYOUT to indicate a layout lease is held.
+ *
  *	(if a lease break is pending):
  *
  *	%F_RDLCK to indicate an exclusive lease needs to be
@@ -2015,8 +2023,26 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 	struct file_lock *fl;
 	struct fasync_struct *new;
 	int error;
+	unsigned int flags = 0;
+
+	/*
+	 * NOTE on F_LAYOUT lease
+	 *
+	 * LAYOUT lease types are taken on files which the user knows that
+	 * they will be pinning in memory for some indeterminate amount of
+	 * time.  Such as for use with RDMA.  While we don't know what user
+	 * space is going to do with the file we still use a F_RDLOCK level of
+	 * lease.  This ensures that there are no conflicts between
+	 * 2 users.  The conflict should only come from the File system wanting
+	 * to revoke the lease in break_layout()  And this is done by using
+	 * F_WRLCK in the break code.
+	 */
+	if (arg == F_LAYOUT) {
+		arg = F_RDLCK;
+		flags = FL_LAYOUT;
+	}
 
-	fl = lease_alloc(filp, arg);
+	fl = lease_alloc(filp, arg, flags);
 	if (IS_ERR(fl))
 		return PTR_ERR(fl);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f7fdfe93e25d..9e9d8d35ee93 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -998,7 +998,7 @@ static inline struct file *get_file(struct file *f)
 #define FL_DOWNGRADE_PENDING	256 /* Lease is being downgraded */
 #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
 #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
-#define FL_LAYOUT	2048	/* outstanding pNFS layout */
+#define FL_LAYOUT	2048	/* outstanding pNFS layout or user held pin */
 
 #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
 
diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index 9dc0bf0c5a6e..baddd54f3031 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -174,6 +174,9 @@ struct f_owner_ex {
 #define F_SHLCK		8	/* or 4 */
 #endif
 
+#define F_LAYOUT	16      /* layout lease to allow longterm pins such as
+				   RDMA */
+
 /* operations for bsd flock(), also used by the kernel implementation */
 #define LOCK_SH		1	/* shared lock */
 #define LOCK_EX		2	/* exclusive lock */
-- 
2.20.1

