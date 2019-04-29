Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0538CC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B501D2087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B501D2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C116D6B0266; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACB3D6B026C; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877806B026A; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBFA6B0269
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d21so6675825pfr.3
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pjBeeJZT6LdZUB1Re7wG7pjUntDc+ChdTNfWf20WHa0=;
        b=FOQxJaBYRHF1k1eaHkhiwIf0IM4FW8I0+qAUMjP+you2qHkeRtslACjOCSlQw2FEln
         hsHHTI0JGuIIE2pi3ycaoOGD0d7tWU7UbjcBAdk6T4aoVDMdcMNFiqJYn0XRGWKd6k2y
         TbD891CK0UEaq7yWUcQ0Ueq9gfqHOZEPA6yueU17zn5A34dNJT85LdTaNVbdt+QTuqus
         IjeTzVOgagEBRSsJsPBCOR/03SDknjN3tJm3aBg+BYA6hAWo0fwkdT0TNNdJM4YxT95M
         1ctDqDmvAUbRVu//tUJKeCO2yD0AtfPyq9tPRGAZNwgifuQFNV60jmRXAnztpQr3/eUd
         NY9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVS9sxjgmI3GMrUBrThRAEWePbU5/vv5VnOQ4f9MXyK1ep10goT
	cehTWJkP16lt3winRds8yMNDQ5fWHcPuxHfwMjM2KCvpEc4IlhxtijRCO5rLmYzg9TlW/EhIjWt
	HjjvTc6xFRDiCnJ+fOSwYGsYmY6MTwhUJpBSXQVB4IIABF+kL9XaCBuPCTJhLktt9Tg==
X-Received: by 2002:a63:4721:: with SMTP id u33mr26695927pga.199.1556513651003;
        Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzCtax7SBeg4htvSgqP+BqPN3RdPCtGBu2HPih1nBDamR0216BpEMjfyoqiu/Jh9rTBi02
X-Received: by 2002:a63:4721:: with SMTP id u33mr26695888pga.199.1556513650244;
        Sun, 28 Apr 2019 21:54:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513650; cv=none;
        d=google.com; s=arc-20160816;
        b=l/Kh8/lz0OtE8lFdT37Cg6Scj56Dqn9f5/Gp+8K3aIDPOElCPeJAgW/n76P8VmxQZZ
         IQhaenUvj+VyEvBfOVK+PWUDc31edQ9X2caBT3qdeWmacY92y51PLoIwgzw7nGHf5jBJ
         v0C5VmeXmnVzYVWsr4PqxKdzKHl8cizEhgF9Q2Nl50GLcLKMgTHMvSyYSM/GlAL/vK7y
         Kg/N55B7qqBp/Nz4xJHV5NYeSB5mCzn4YIzVL5J38An0npDXOyqJGpAJo89SFBArscz6
         qp/rmtCEir0gAWZZlKRdDbrxfANWVP3GlOKJxdMWX1pPHUvSrvvYJJGTjo8s9VAhK6we
         fGhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=pjBeeJZT6LdZUB1Re7wG7pjUntDc+ChdTNfWf20WHa0=;
        b=k0KluQij2RYAUZz7s3/zVogoE2CCK7WM5nAQMIFcmtMOMUS2SvgXvkHemJPyKFd6Am
         9m9USOoLNEe99LD8RId8zzQQAcqbZMdes/Npn3pkTzxHnsoUmbyUMIIW2P3gCRZvzAIh
         HEK8flLQFPyz6LnDEwUGMuw5R6cTu788X1XLoMaI+8yxEjph/2EzlTlJ/W5tJXhUkmYY
         rPUlbujj71FG44cwPFkn1dkHELq2t8W9bMXwUrg9B31iT32Xc46l7MlkLIUOIAEUJOsV
         MtV6i3R5KplEeomIEQpYmmj62jrtqM6ym1rJnqjQQQ0eARo3MTSrhbcpm6709FW083ZV
         SMeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566310"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:09 -0700
From: ira.weiny@intel.com
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH 08/10] mm/gup: fs: Send SIGBUS on truncate of active file
Date: Sun, 28 Apr 2019 21:53:57 -0700
Message-Id: <20190429045359.8923-9-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190429045359.8923-1-ira.weiny@intel.com>
References: <20190429045359.8923-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Now that the taking of LONGTERM leases is in place we can now facilitate
sending a SIGBUS to process if a file truncate or hole punch is
performed and they do not respond by releasing the lease.

The standard file lease_break_time is used to time out the LONGTERM
lease which is in place on the inode.
---
 fs/ext4/inode.c    |  4 ++++
 fs/locks.c         | 13 +++++++++++--
 fs/xfs/xfs_file.c  |  4 ++++
 include/linux/fs.h | 13 +++++++++++++
 4 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b32a57bc5d5d..bee456c8c805 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4237,6 +4237,10 @@ int ext4_break_layouts(struct inode *inode)
 	if (WARN_ON_ONCE(!rwsem_is_locked(&ei->i_mmap_sem)))
 		return -EINVAL;
 
+	/* Break longterm leases */
+	if (dax_mapping_is_dax(inode->i_mapping))
+		break_longterm(inode);
+
 	do {
 		page = dax_layout_busy_page(inode->i_mapping);
 		if (!page)
diff --git a/fs/locks.c b/fs/locks.c
index 58c6d7a411b6..c77eee081d11 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1580,6 +1580,7 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 {
 	struct file_lock_context *ctx = inode->i_flctx;
 	struct file_lock *fl, *tmp;
+	struct task_struct *tsk;
 
 	lockdep_assert_held(&ctx->flc_lock);
 
@@ -1587,8 +1588,16 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 		trace_time_out_leases(inode, fl);
 		if (past_time(fl->fl_downgrade_time))
 			lease_modify(fl, F_RDLCK, dispose);
-		if (past_time(fl->fl_break_time))
-			lease_modify(fl, F_UNLCK, dispose);
+		if (past_time(fl->fl_break_time)) {
+			if (fl->fl_flags & FL_LONGTERM) {
+				tsk = find_task_by_vpid(fl->fl_pid);
+				fl->fl_break_time = 1 + jiffies + lease_break_time * HZ;
+				lease_modify_longterm(fl, F_UNLCK, dispose);
+				kill_pid(tsk->thread_pid, SIGBUS, 0);
+			} else {
+				lease_modify(fl, F_UNLCK, dispose);
+			}
+		}
 	}
 }
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 1f2e2845eb76..ebd310f3ae65 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -739,6 +739,10 @@ xfs_break_dax_layouts(
 
 	ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
 
+	/* Break longterm leases */
+	if (dax_mapping_is_dax(inode->i_mapping))
+		break_longterm(inode);
+
 	page = dax_layout_busy_page(inode->i_mapping);
 	if (!page)
 		return 0;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index be2d08080aa5..0e8b21240a71 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2459,6 +2459,14 @@ static inline int break_layout(struct inode *inode, bool wait)
 	return 0;
 }
 
+static inline int break_longterm(struct inode *inode)
+{
+	smp_mb();
+	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
+		return __break_lease(inode, O_WRONLY, FL_LONGTERM);
+	return 0;
+}
+
 #else /* !CONFIG_FILE_LOCKING */
 static inline int break_lease(struct inode *inode, unsigned int mode)
 {
@@ -2486,6 +2494,11 @@ static inline int break_layout(struct inode *inode, bool wait)
 	return 0;
 }
 
+static inline int break_longterm(struct inode *inode, bool wait)
+{
+	return 0;
+}
+
 #endif /* CONFIG_FILE_LOCKING */
 
 /* fs/open.c */
-- 
2.20.1

