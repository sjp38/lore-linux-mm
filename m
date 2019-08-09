Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A843C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFDFE20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFDFE20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB09A6B0007; Fri,  9 Aug 2019 18:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D630A6B0008; Fri,  9 Aug 2019 18:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD94A6B000A; Fri,  9 Aug 2019 18:58:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 891E76B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x10so62402834pfa.23
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X5K84N7Wtvc2gT7NHzM01KBStTXqgtGW5hDxI8bSTaM=;
        b=srV5ZSTJd0clE+l+/HoMAwBH8BB4cRqkHB700g8vIZRf+1knd/z420N273NfCRia/k
         MeGj9wxV5jah51qIYHSKvSQMSoWN6WDw8neFJi67PzOe2ZmBFnzuKHRiBHQSTfZXveL9
         eYdH/6Rx5WvpVUK88CMqcq/KIMILe+pSO3s0EXJRBlSp7x51XSOoOfMy0LD+zKBnmnGy
         1i13X9Vh+wX3pMTXXa23bC1Bo2WY/Xlj6YLGfDl4zmdLcW+XNmDVwSWI0gnBReu5fCLl
         3nYplM9AUM8oCzZvgx2xo4DNpFQJMNMVYMptidQy9boO+hLoCPmbID4n0lgA4tdiTbs/
         Qn/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVxRiBKrZu9Idv8MvYReb3V3O9yyHSwdwljykCUezXX4m/2tNTr
	UlB40dqRiF+UtlWEezuIpr6B1kS9mDAfmsXwylbTmfOlzboc+CHVwoNg2YS9HlJ8fJ4hP9ChvqJ
	Yq0teH/pkC6ClHSlHxXbsZogQ6C8wkjOTxUQu7jQeM4Nxo1KqxEMETXaE3domjisxYg==
X-Received: by 2002:a17:902:1024:: with SMTP id b33mr11989619pla.325.1565391525237;
        Fri, 09 Aug 2019 15:58:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyuBXbbb7e6zJeuZ+iUcZ716TVPSSO39BjUCelsKBvZW1yjGdPxEnje4mp7nk+jUh9LzO3
X-Received: by 2002:a17:902:1024:: with SMTP id b33mr11989566pla.325.1565391524375;
        Fri, 09 Aug 2019 15:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391524; cv=none;
        d=google.com; s=arc-20160816;
        b=Mhf/hedJeUe3ipK5h3CGe7EAyVassR5/hvN1i4XUbVS/papwm6/2KWo6/Bhft01qwr
         z9zn3jStkFOeZPd4tATmO3U5MaMEzwkjZXHYJOZQiD+Dn14I+tmd7Gv9j3lM5CqpWo+y
         xyvjQ18e1hVRMty2e4qdFmBfLWGsX+qtkhh4MZz90a4r8hB/O29a8/ucXA+8E3cxSkPE
         x3lNUaGjHM+d1AxyG/G5YcIE0PioAvBUjB/rl6iVDRkjBeiT8jj114HETQ3mhv5P/KlJ
         8cORgEqnI5eD6qyf+o36Ol5Nvbs6xpWJN+vCcxc6IfyiNx4fJi3hP602i0s+HYSSMDVe
         IMlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=X5K84N7Wtvc2gT7NHzM01KBStTXqgtGW5hDxI8bSTaM=;
        b=cU0tNxWfw4sR4LhKIaoOrbn6HjfCLaPdrbvcAZvZb14PVfiSIoMPWN73thUYCU3cNV
         CxVUYNFFjvBF+3YLwQ+qpWwMq+HVCKyQTAY/XhSINjxgSchsjO/lt6J9SLT0D2A0jyWq
         NAd7l2L6OADZy/E8XLVuR+7LM4hVAB/u58JER7TNqY78/GyFm2dJQHORF6MSkDtPRtAF
         t8VJZwnDUe+EFbabtC3tqQ7GZP3IdMQNmNIM02TdMhwsqyE+aIzDgT5aBy+DhaamAJxl
         Hof5oynzTT47X2ESwijGDVBK+nSD8R5/3t8SzrK7h3DeZE0e7tVw89WemBGpiD2mN89Y
         MglA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f131si52945262pgc.265.2019.08.09.15.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:43 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="199539184"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga004-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:43 -0700
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
Subject: [RFC PATCH v2 02/19] fs/locks: Add Exclusive flag to user Layout lease
Date: Fri,  9 Aug 2019 15:58:16 -0700
Message-Id: <20190809225833.6657-3-ira.weiny@intel.com>
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

Add an exclusive lease flag which indicates that the layout mechanism
can not be broken.

Exclusive layout leases allow the file system to know that pages may be
GUP pined and that attempts to change the layout, ie truncate, should be
failed.

A process which attempts to break it's own exclusive lease gets an
EDEADLOCK return to help determine that this is likely a programming bug
vs someone else holding a resource.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/locks.c                       | 23 +++++++++++++++++++++--
 include/linux/fs.h               |  1 +
 include/uapi/asm-generic/fcntl.h |  2 ++
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ad17c6ffca06..0c7359cdab92 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -626,6 +626,8 @@ static int lease_init(struct file *filp, long type, unsigned int flags,
 	fl->fl_flags = FL_LEASE;
 	if (flags & FL_LAYOUT)
 		fl->fl_flags |= FL_LAYOUT;
+	if (flags & FL_EXCLUSIVE)
+		fl->fl_flags |= FL_EXCLUSIVE;
 	fl->fl_start = 0;
 	fl->fl_end = OFFSET_MAX;
 	fl->fl_ops = NULL;
@@ -1619,6 +1621,14 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	list_for_each_entry_safe(fl, tmp, &ctx->flc_lease, fl_list) {
 		if (!leases_conflict(fl, new_fl))
 			continue;
+		if (fl->fl_flags & FL_EXCLUSIVE) {
+			error = -ETXTBSY;
+			if (new_fl->fl_pid == fl->fl_pid) {
+				error = -EDEADLOCK;
+				goto out;
+			}
+			continue;
+		}
 		if (want_write) {
 			if (fl->fl_flags & FL_UNLOCK_PENDING)
 				continue;
@@ -1634,6 +1644,13 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			locks_delete_lock_ctx(fl, &dispose);
 	}
 
+	/* We differentiate between -EDEADLOCK and -ETXTBSY so the above loop
+	 * continues with -ETXTBSY looking for a potential deadlock instead.
+	 * If deadlock is not found go ahead and return -ETXTBSY.
+	 */
+	if (error == -ETXTBSY)
+		goto out;
+
 	if (list_empty(&ctx->flc_lease))
 		goto out;
 
@@ -2044,9 +2061,11 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 	 * to revoke the lease in break_layout()  And this is done by using
 	 * F_WRLCK in the break code.
 	 */
-	if (arg == F_LAYOUT) {
+	if ((arg & F_LAYOUT) == F_LAYOUT) {
+		if ((arg & F_EXCLUSIVE) == F_EXCLUSIVE)
+			flags |= FL_EXCLUSIVE;
 		arg = F_RDLCK;
-		flags = FL_LAYOUT;
+		flags |= FL_LAYOUT;
 	}
 
 	fl = lease_alloc(filp, arg, flags);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd60d5be9886..2e41ce547913 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1005,6 +1005,7 @@ static inline struct file *get_file(struct file *f)
 #define FL_UNLOCK_PENDING	512 /* Lease is being broken */
 #define FL_OFDLCK	1024	/* lock is "owned" by struct file */
 #define FL_LAYOUT	2048	/* outstanding pNFS layout or user held pin */
+#define FL_EXCLUSIVE	4096	/* Layout lease is exclusive */
 
 #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
 
diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index baddd54f3031..88b175ceccbc 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -176,6 +176,8 @@ struct f_owner_ex {
 
 #define F_LAYOUT	16      /* layout lease to allow longterm pins such as
 				   RDMA */
+#define F_EXCLUSIVE	32      /* layout lease is exclusive */
+				/* FIXME or shoudl this be F_EXLCK??? */
 
 /* operations for bsd flock(), also used by the kernel implementation */
 #define LOCK_SH		1	/* shared lock */
-- 
2.20.1

