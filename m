Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D48D1C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 963E9208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 963E9208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E24D66B026C; Fri,  9 Aug 2019 18:59:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFEA86B026D; Fri,  9 Aug 2019 18:59:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA14D6B026E; Fri,  9 Aug 2019 18:59:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 828AE6B026C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so62398422pfv.18
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1thzjoQSYXOYbtTHZ+iJ6Zmx5pcWMzps+60/Qk4fNhc=;
        b=RrhHe+Uw6S3zZcR0Lpqua++oRbrUReL+gN2n5c0TW4DHoZh2ufyaQLX2ws9Fp3S/q5
         lgoxFv6aMpTdIKJo5DK9EA2zgBBNbSa8BVSUr0doe89qW5q9s5E8D0L6t6DWVeC98jZl
         p71IabLh2+MwsjOfdkdSujNTDo3Qqd5eOz3JI2veUNsn87TMYVLfEhzN57BEFm50/6jn
         KujflQlQQc9H1BKEzMJQgc4Gz3TcgzTSnDF3ft3zcesS8gBzT7BCH1E1hQWNF+AtFMw9
         D9ajTxQBaPIACMlQyJLPop/wKz0lSXB8VNOIwJJcyEVDPQYduArlaaynOiz6Zas8w1KZ
         9qQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU7H24WyO6TScG4j/WeptZpe3I3j7xWrWdOYN7FRyeLDEEyy9gb
	+BTDtNRUDBB1QtM/quberFROlm3bVcxDW5TmZpepzD3dUn7orMbUBMKDuomYibS/SUcP1W1tvbz
	hp0xlmq2aUjXScFHudxCifHBtMBgsjURqV+F4mu/hj1aIAUfbosafBxyWLTjAzSV8dw==
X-Received: by 2002:a63:4c21:: with SMTP id z33mr19679812pga.418.1565391544075;
        Fri, 09 Aug 2019 15:59:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcwcRffzyf9ZV2RUswZVBdhZw8UdPcvVrnfXeqvf+2rDCQXPabGYGmuTKybG79kxSAP1Fn
X-Received: by 2002:a63:4c21:: with SMTP id z33mr19679765pga.418.1565391543235;
        Fri, 09 Aug 2019 15:59:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391543; cv=none;
        d=google.com; s=arc-20160816;
        b=DqxAIqhZouvqc0FhF2vOTEDdwynIKj83SDBMCZfINo6tA/FIFhAZB7oyB6pJYMYdbb
         TlFtIP3vNoXWwABzgsToB6NckKVAAMnf2mh4diDPbA7bVCxRAJOjWXyQ1lg6QfZwqmLs
         0APT0Xd04wJzQIF8CCY9N+JCC92JpSFYixYf1u2cUzQTzJ5Vy012kTmHkAvc69EtLLDx
         7LzVPVmmBXqMT6Kr7tIICMNwGMZcunye1vXHSQen9trVNspAWVSDkxhNyPo6uWsADkTX
         5vgsVWg+dghzqULR6mW3u0Wh9yq+cxtxavBjXqCVnCQRmSunnH5j7QdOrHbpZdok6ON2
         wqqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1thzjoQSYXOYbtTHZ+iJ6Zmx5pcWMzps+60/Qk4fNhc=;
        b=nJC603UBYLnQZK9Wg3D7hv4pkL8Js2Jo/lqu2KG38Yuxg6O7iKRezPwoU5NXx8lmq2
         92/uRzv0VMD18fz4YrZNNwJRwRcHxUnj5g2MJ7B/sbzPNCUrEOFXkFr+hbX/Tqxs0Ll6
         d3ghWQ+N5YK/jI7BluiXo4En63Fx85fSk+cV5RzQiainmMcXgex00rzTjP7kBuHMK65J
         0qYktqpP8tVtjjHMt4uJcENGAa8A3zikAZlOcM1plenYESjpyq/o4FmSt9vbbETgqjHp
         V6AcSCZKp7UQo5p3SJAn6g6TwqCw+0QenjiZZ0Dp5fDzV7XQy5gcDO/0bAJ3d4yhyvxt
         RAlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 21si59278041pfo.138.2019.08.09.15.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:59:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:02 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="259172583"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:01 -0700
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
Subject: [RFC PATCH v2 13/19] {mm,file}: Add file_pins objects
Date: Fri,  9 Aug 2019 15:58:27 -0700
Message-Id: <20190809225833.6657-14-ira.weiny@intel.com>
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

User page pins (aka GUP) needs to track file information of files being
pinned by those calls.  Depending on the needs of the caller this
information is stored in 1 of 2 ways.

1) Some subsystems like RDMA associate GUP pins with file descriptors
   which can be passed around to other process'.  In this case a file
   being pined must be associated with an owning file object (which can
   then be resolved back to any of the processes which have a file
   descriptor 'pointing' to that file object).

2) Other subsystems do not have an owning file and can therefore
   associate the file pin directly to the mm of the process which
   created them.

This patch introduces the new file pin structures and ensures struct
file and struct mm_struct are prepared to store them.

In subsequent patches the required information will be passed into new
pin page calls and procfs is enhanced to show this information to the user.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/file_table.c          |  4 ++++
 include/linux/file.h     | 49 ++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h       |  2 ++
 include/linux/mm_types.h |  2 ++
 kernel/fork.c            |  3 +++
 5 files changed, 60 insertions(+)

diff --git a/fs/file_table.c b/fs/file_table.c
index b07b53f24ff5..38947b9a4769 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -46,6 +46,7 @@ static void file_free_rcu(struct rcu_head *head)
 {
 	struct file *f = container_of(head, struct file, f_u.fu_rcuhead);
 
+	WARN_ON(!list_empty(&f->file_pins));
 	put_cred(f->f_cred);
 	kmem_cache_free(filp_cachep, f);
 }
@@ -118,6 +119,9 @@ static struct file *__alloc_file(int flags, const struct cred *cred)
 	f->f_mode = OPEN_FMODE(flags);
 	/* f->f_version: 0 */
 
+	INIT_LIST_HEAD(&f->file_pins);
+	spin_lock_init(&f->fp_lock);
+
 	return f;
 }
 
diff --git a/include/linux/file.h b/include/linux/file.h
index 3fcddff56bc4..cd79adad5b23 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -9,6 +9,7 @@
 #include <linux/compiler.h>
 #include <linux/types.h>
 #include <linux/posix_types.h>
+#include <linux/kref.h>
 
 struct file;
 
@@ -91,4 +92,52 @@ extern void fd_install(unsigned int fd, struct file *file);
 extern void flush_delayed_fput(void);
 extern void __fput_sync(struct file *);
 
+/**
+ * struct file_file_pin
+ *
+ * Associate a pin'ed file with another file owner.
+ *
+ * Subsystems such as RDMA have the ability to pin memory which is associated
+ * with a file descriptor which can be passed to other processes without
+ * necessarily having that memory accessed in the remote processes address
+ * space.
+ *
+ * @file file backing memory which was pined by a GUP caller
+ * @f_owner the file representing the GUP owner
+ * @list of all file pins this owner has
+ *       (struct file *)->file_pins
+ * @ref number of times this pin was taken (roughly the number of pages pinned
+ *      in the file)
+ */
+struct file_file_pin {
+	struct file *file;
+	struct file *f_owner;
+	struct list_head list;
+	struct kref ref;
+};
+
+/*
+ * struct mm_file_pin
+ *
+ * Some GUP callers do not have an "owning" file.  Those pins are accounted for
+ * in the mm of the process that called GUP.
+ *
+ * The tuple {file, inode} is used to track this as a unique file pin and to
+ * track when this pin has been removed.
+ *
+ * @file file backing memory which was pined by a GUP caller
+ * @mm back point to owning mm
+ * @inode backing the file
+ * @list of all file pins this owner has
+ *       (struct mm_struct *)->file_pins
+ * @ref number of times this pin was taken
+ */
+struct mm_file_pin {
+	struct file *file;
+	struct mm_struct *mm;
+	struct inode *inode;
+	struct list_head list;
+	struct kref ref;
+};
+
 #endif /* __LINUX_FILE_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2e41ce547913..d2e08feb9737 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -963,6 +963,8 @@ struct file {
 #endif /* #ifdef CONFIG_EPOLL */
 	struct address_space	*f_mapping;
 	errseq_t		f_wb_err;
+	struct list_head        file_pins;
+	spinlock_t              fp_lock;
 } __randomize_layout
   __attribute__((aligned(4)));	/* lest something weird decides that 2 is OK */
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6a7a1083b6fb..4f6ea4acddbd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -516,6 +516,8 @@ struct mm_struct {
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
 #endif
+		struct list_head file_pins;
+		spinlock_t fp_lock; /* lock file_pins */
 	} __randomize_layout;
 
 	/*
diff --git a/kernel/fork.c b/kernel/fork.c
index 0e2f9a2c132c..093f2f2fce1a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -675,6 +675,7 @@ void __mmdrop(struct mm_struct *mm)
 	BUG_ON(mm == &init_mm);
 	WARN_ON_ONCE(mm == current->mm);
 	WARN_ON_ONCE(mm == current->active_mm);
+	WARN_ON(!list_empty(&mm->file_pins));
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
@@ -1013,6 +1014,8 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->pmd_huge_pte = NULL;
 #endif
 	mm_init_uprobes_state(mm);
+	INIT_LIST_HEAD(&mm->file_pins);
+	spin_lock_init(&mm->fp_lock);
 
 	if (current->mm) {
 		mm->flags = current->mm->flags & MMF_INIT_MASK;
-- 
2.20.1

