Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C6BDC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 570FF2087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 570FF2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34FB86B0269; Mon, 29 Apr 2019 00:54:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DDCA6B026C; Mon, 29 Apr 2019 00:54:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F59B6B026D; Mon, 29 Apr 2019 00:54:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C38286B0269
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o1so6611203pgv.15
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xOq42QtP/+AsL0/tWauXucC4OF0frWRM/1KsTrSyUI4=;
        b=X1N5SkCr7bTy4FudKpkf7maHk/NEhjboOHKZrQlTWuW3J9ciz/5s84iOVq+KOAwVFc
         gYZREoCRbqr7bkUtDJ6gFFDjXJLd7b5v5sVyQjagtEwQIqUjYzpMB24NW1Ug29sqWeWc
         R+4oV3S/VXiMBazZVGldVxH2WgE0WZZXVGJL/jCQZBU186a2p2ANCzzMs0MxpWQPRh7R
         oiA7CPrBNnfq0FUuunNaTgOQ1UxC1scSwphR25pAtA4Nq7RC9PxmpKnbiZT8b+RcwLp0
         7SiBx9GFATI9WJmZrpXO/NFC04I2gPEaGhZtho4pdxD+syFkE8AAspQyYrdSB3OAW3ZY
         LJqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWbBiJpDhAVamDAB9dXdfkotPni5qW5kRHoQ4oXONESI20N83LY
	X7Lwjd42hiMN4VWpgn1Kn6jfinVvQ6HQ1yIZ7WI3z1GXtSNuvC9YOa8IpQ+AfWaPQaT3ArNRC9+
	YiU+uRKGea84AecdOlMaLcaKG+nP3LQxtldpt3oqood9/6yZanN6puCQcgLeTyeJTnw==
X-Received: by 2002:a17:902:6b0b:: with SMTP id o11mr23484526plk.266.1556513651493;
        Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTF8GL/e9I19kF5feenZdUoOc5tztaCTS+8YWTTfmFAmRd0QbCMkVQtfCNjhUWHXae6+SA
X-Received: by 2002:a17:902:6b0b:: with SMTP id o11mr23484492plk.266.1556513650780;
        Sun, 28 Apr 2019 21:54:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513650; cv=none;
        d=google.com; s=arc-20160816;
        b=oXxd18q63xwurDsqxAsjYiFyqCuF3ZtirxFjUUdqALdmxBp6IPhiNApRp5jCicUCDt
         cPyohsFCFvk45x8m4YX0yVs7mM25J2Kx4ML/qKwlVJf4qpmEuSYd+cokWbPRXc5HTTaz
         wh+TsYFIdGZI4zuQr//evyyj688011lVSgqTXcJKf9X5W0eFW9Fsn0Y6RCvwZtMA0SKz
         MVG8stIB1enYSrU5EK04l6hJWWuo2efEuz+WYj115tYMj+M/RNNEmZH8XbNTn/Ig1dnT
         4PIv13YEh4oYDUK59DFFQMb183QMaWESZyu+rEnnsxpDJohr01TZvVU6C8B0TxgXpmd/
         mdnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xOq42QtP/+AsL0/tWauXucC4OF0frWRM/1KsTrSyUI4=;
        b=pWpauyK9dKw4KhVw8b2yn89vlC9njTLYDKtYxlyOg34AUpCcf5/tQpfZK+qRVnkNaE
         +28OBGaKGEQUAnv7eom7Kd4Xw53/ZfvClc2nRTSQ1f6txZ92BN3u8rRV21EVZqLEGrkz
         p3VKMswSoQbjUysiCkErqXVRwOw7zKWnKpuE7UhTmgXN42kz9S3uhVLVSVKldAleNf3S
         30lsuF0fkREZhq2kdiLYPycFRyr8QM+qs/GIF+supx2fXtHGQ9sSZluBVtLVTSY+cdOG
         XVD/1YvLGVXT+tcecWSttPhdtsH03KxSjGNByDwy6UEWoMs5j5Bt2Flr3IfpitGaadqg
         7QtA==
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
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:10 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566315"
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
Subject: [RFC PATCH 09/10] fs/locks: Add tracepoint for SIGBUS on LONGTERM expiration
Date: Sun, 28 Apr 2019 21:53:58 -0700
Message-Id: <20190429045359.8923-10-ira.weiny@intel.com>
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

---
 fs/locks.c                      | 1 +
 include/trace/events/filelock.h | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/locks.c b/fs/locks.c
index c77eee081d11..42b96bfc71fa 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1592,6 +1592,7 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 			if (fl->fl_flags & FL_LONGTERM) {
 				tsk = find_task_by_vpid(fl->fl_pid);
 				fl->fl_break_time = 1 + jiffies + lease_break_time * HZ;
+				trace_longterm_sigbus(fl);
 				lease_modify_longterm(fl, F_UNLCK, dispose);
 				kill_pid(tsk->thread_pid, SIGBUS, 0);
 			} else {
diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
index c6f39f03cb8b..626386dbe599 100644
--- a/include/trace/events/filelock.h
+++ b/include/trace/events/filelock.h
@@ -271,7 +271,9 @@ DEFINE_EVENT(longterm_lease, take_longterm_lease,
 DEFINE_EVENT(longterm_lease, release_longterm_lease,
 	TP_PROTO(struct file_lock *fl),
 	TP_ARGS(fl));
-
+DEFINE_EVENT(longterm_lease, longterm_sigbus,
+	TP_PROTO(struct file_lock *fl),
+	TP_ARGS(fl));
 
 #endif /* _TRACE_FILELOCK_H */
 
-- 
2.20.1

