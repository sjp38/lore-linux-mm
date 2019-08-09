Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE496C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ED88217F5
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ED88217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 300C96B0006; Fri,  9 Aug 2019 18:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28A116B0007; Fri,  9 Aug 2019 18:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 179D16B0008; Fri,  9 Aug 2019 18:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2E6A6B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g185so118580pfb.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tZ+u5eRVmAN1mjnSWZ32Srp51m427DgazdZtvtoveps=;
        b=tWxZfaY/rFBmdSuj6gXplQhpk+fHyL9lmLoliPUQTDMXGiTv5epiEBFXxB2FtqL0Wq
         UxlDOz2rCRdteczep6j9d3Tg8qa9p3W6nlGsMTizVq5DkJHUU3TYKSRjPcmawDF41gF8
         w81KQL9fttgneYwSgMvY9CBtMNDYXz0DuazYEekPhs4AZ9RT83ZBG80siUCWJjSsKu/s
         cDRUo2J3l7xe+sKj7m3hPxBCSi4UmRNshX4QfIJB7l0p2yw8rXKu8fVIZk2Bja5dpfkc
         SijL7vsvusI9x+VZqPIrmoUxSPY50imxqyRi4LeprQb+ZI/wHem0tTxHzDGpB2NhDux/
         rI6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX4vgO/Tmasz0P0Uz/6DiHTCdqiSxaKxHxytEUR3fQYAJg58r8F
	Gp/P5F6z0js48p7xa1twN/SZE1rkwUp85m6pZQhdA68dsyhL2FQLNKPggJtsiQ9XpXEc8XRmuy6
	B+PPGUWVytYg2KqJgxA5x1jLDWRmCLU3SV/3seSNZcQbASkD7I1rJw/weC5ar/4OKYA==
X-Received: by 2002:a17:902:20cc:: with SMTP id v12mr9254046plg.188.1565391523507;
        Fri, 09 Aug 2019 15:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7Uz2hhr/itCjfLPYnpxbATN0RIhI+vyB6OQNdE6/SeI2thFn3dkaPwEjmGSB4DCbIxhbJ
X-Received: by 2002:a17:902:20cc:: with SMTP id v12mr9254000plg.188.1565391522467;
        Fri, 09 Aug 2019 15:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391522; cv=none;
        d=google.com; s=arc-20160816;
        b=A2QXeTFM0O6eO2PaP4BTZRFp3VFgghhJAbjPtrcdvlcBPtWw51LqXhjX23D4qDKCqe
         SiTp9TmiqrxdnLsr8LLcmbFnBs/BMo7dHiGR7dXm1QdT2SB//OsyiplJTNNaWLwJVe/p
         NLwC5hzTSIznh2DaUtZ2g3mRMI9CKU5QwHy64cV4UBOpjkPxrhsIgsE5Ynk8K35Klgao
         LT6LQXUa+7T/YC0UtDwADgitRBCP01H/EjpptCcjSZVJZAQ1yvbOeAa6v7OAh62kRSeu
         Ci+gm5BRFk7eN4sJkh5OzFzUOsi/V4L94A/qen9i2H4VKrs3TeDw15QcM0l5NXw/b8vU
         +kfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tZ+u5eRVmAN1mjnSWZ32Srp51m427DgazdZtvtoveps=;
        b=ou4NQx/7Mk+NTu23CZzHILdq03S9SopWgnBVFHNTZOiyID2QrP9Dx3ydQoAjMJ8Xic
         1fiLSgCUVGKGC57Q6S+sfLOFnxey6v72nRrv1mwkBFxT6p13jbuIXPevRG66w0s0bzLs
         mO5SUC+/gDnuzNcCihRkHvIwdDPJiuWUQY6WvFLqTugWJoQV6uTQq+PIzwg8hrau5Wo+
         7DKNQ1A6xsuuDrvFD7+LddGD1JyFttvKAdDghROBatSjUlBIeg6+bkojX57F7RjvMR55
         9UP6+m1vcX0ZcHfzsawCf2Tje2A8Pt+Q0/sVUuoaT7p/dffcFzCCJQOnDnKuV2TU+J4d
         ntbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id i133si55033550pgc.109.2019.08.09.15.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:41 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="374631453"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga005-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:41 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH v2 01/19] fs/locks: Export F_LAYOUT lease to user space
Date: Fri,  9 Aug 2019 15:58:15 -0700
Message-Id: <20190809225833.6657-2-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190809225833.6657-1-ira.weiny@intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In order to support an opt-in policy for users to allow long term pins
of FS DAX pages we need to export the LAYOUT lease to user space.

This is the first of 2 new lease flags which must be used to allow a
long term pin to be made on a file.

After the complete series:

0) Registrations to Device DAX char devs are not affected

1) The user has to opt in to allowing page pins on a file with an exclusive
   layout lease.  Both exclusive and layout lease flags are user visible now.

2) page pins will fail if the lease is not active when the file back page is
   encountered.

3) Any truncate or hole punch operation on a pinned DAX page will fail.

4) The user has the option of holding the lease or releasing it.  If they
   release it no other pin calls will work on the file.

5) Closing the file is ok.

6) Unmapping the file is ok

7) Pins against the files are tracked back to an owning file or an owning mm
   depending on the internal subsystem needs.  With RDMA there is an owning
   file which is related to the pined file.

8) Only RDMA is currently supported

9) Truncation of pages which are not actively pinned nor covered by a lease
   will succeed.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/locks.c                       | 36 +++++++++++++++++++++++++++-----
 include/linux/fs.h               |  2 +-
 include/uapi/asm-generic/fcntl.h |  3 +++
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 24d1db632f6c..ad17c6ffca06 100644
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
@@ -1583,7 +1589,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 	LIST_HEAD(dispose);
 
-	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK);
+	new_fl = lease_alloc(NULL, want_write ? F_WRLCK : F_RDLCK, 0);
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
 	new_fl->fl_flags = type;
@@ -1720,6 +1726,8 @@ EXPORT_SYMBOL(lease_get_mtime);
  *
  *	%F_UNLCK to indicate no lease is held.
  *
+ *	%F_LAYOUT to indicate a layout lease is held.
+ *
  *	(if a lease break is pending):
  *
  *	%F_RDLCK to indicate an exclusive lease needs to be
@@ -2022,8 +2030,26 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
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
index 046108cd4ed9..dd60d5be9886 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1004,7 +1004,7 @@ static inline struct file *get_file(struct file *f)
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

