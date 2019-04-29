Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42233C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 096F82087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 096F82087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E2CD6B000E; Mon, 29 Apr 2019 00:54:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BA136B0266; Mon, 29 Apr 2019 00:54:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 809BF6B0269; Mon, 29 Apr 2019 00:54:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 49C566B000E
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q73so1048308pfi.17
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1NcGQfT68bRLARokF2ic6pl901L5JbBUCSjwGa+uDhY=;
        b=Hj/Q3hmwBnYHkK++GvcVwNPBi0RSjSRgTi8q9j+i5nIl+jkWma7hnWCK7gprZwoNA3
         dyRzURev+bhAzvLSC+MyH6bnu+jaI7uOfHMimHcvg4aOmqqe8VuJ4PkTed2eimgFA+M0
         tt7BF2vs4XO1qPce0tBspHCSx+O1LhaXBW8SFH0TAA8pHoSbKozkjDUrXOoK7i8t+pOa
         OHKyrKbjgWiGgkET6NYiA2bv23yp+fck+QS0oi9/CSLt3vNixjgN1O0Fe9Z6HbKYeEYd
         Y5kMP90DHDwNkzjT4rZa084/Sre/R1WiqSr8MyvMIom345zeYbpXSC+qBAYwxwUXcb91
         3u4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV55wlqVAfmymKd4IpC+z+9WDqFXvLnP8Ke/uUKSt73Msns6aZw
	WJb3lEMY5puyys+DHAa8GNUgX5vOATY0Zo9TwaW35bk2CHSNufIqIs/eg0dWObqFOKEMkrrPwhf
	nTP87FL4waRLHyYmvHQnl8ej9hfSooZ2KmUJrx3/Y76XZmkeBRhks3N5Qn+kZuWNy+Q==
X-Received: by 2002:a65:4341:: with SMTP id k1mr55771149pgq.88.1556513649959;
        Sun, 28 Apr 2019 21:54:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydgfHGf2DlghvLKs9yVggugrcri1IkSXiZC+mbgga/UsgVTscz5ZxWtkkDaqP6S4A6P5ds
X-Received: by 2002:a65:4341:: with SMTP id k1mr55771117pgq.88.1556513649221;
        Sun, 28 Apr 2019 21:54:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513649; cv=none;
        d=google.com; s=arc-20160816;
        b=tbiosHMBU7OLgClQHI/aGlnjO/4m/kYEqv2pMUXIxC59noWRB/Sn6jkbCHiF9Sutgh
         nS82G0GIu49XyeDnlmlpdAQNSZk39qA0mCqQxRG5Sy25pxCySuDS44IjZwRylXoD0eH7
         s5uU+8OHdTbExELgpfGAbbT4OABTiNGtVzbhAmpIrFZT02t5YYGfLiYNeJ05TG6x91SE
         uNf1tHSLtGI2M7BNhAVOi/JEkRpMe+EUhJ4toQXPBho0/4F3sJiE69Y5iIZWZnIO2CkB
         c48jp4MySW3L87nRo2gxjJohE0o+rlLUtSG+2+AFUKqYtEuIKLQ8MLe9Qiitgmi6/qYA
         Ab8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1NcGQfT68bRLARokF2ic6pl901L5JbBUCSjwGa+uDhY=;
        b=rbkc2uZdQoKUkRSCFhCfwroh1a31/aRvGYtSotL6qSTLQZj0TGQMXkI1wPc7iZofU4
         SF/OjCFOiFo94ZrDe9dI8iIwD/MojjQN2+q+86QYjcXx7cB1vm5qUDai3/GcBbaoSp63
         sxLlAa62xtOuRNpeEVOam5F3HpjEOBDeNWJ1kIzgxJ+qixr/3mFqeOc+g2SK8RiVuD9I
         T+7cJtshaQBYYbvQMzFydTIqP/xr4Y7g3bG/glh229offL9Ta0iu7HUoMrMVoWm+GB3n
         H4lXA93iLxi1o9nogsVC88VxQAs0nGyaKiDSsPGEocvekRpAQJ4qUXEmPQKrf9SnWrLc
         SaVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566299"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:08 -0700
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
Subject: [RFC PATCH 06/10] fs/locks: Add longterm lease traces
Date: Sun, 28 Apr 2019 21:53:55 -0700
Message-Id: <20190429045359.8923-7-ira.weiny@intel.com>
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
 fs/locks.c                      |  5 +++++
 include/trace/events/filelock.h | 37 ++++++++++++++++++++++++++++++++-
 2 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/fs/locks.c b/fs/locks.c
index ae508d192223..58c6d7a411b6 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2136,6 +2136,8 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 	}
 	new->fa_fd = fd;
 
+	trace_take_longterm_lease(fl);
+
 	error = vfs_setlease(filp, arg, &fl, (void **)&new);
 	if (fl)
 		locks_free_lock(fl);
@@ -3118,6 +3120,8 @@ bool page_set_longterm_lease(struct page *page)
 		kref_get(&existing_fl->gup_ref);
 	}
 
+	trace_take_longterm_lease(existing_fl);
+
 	spin_unlock(&ctx->flc_lock);
 	percpu_up_read(&file_rwsem);
 
@@ -3153,6 +3157,7 @@ void page_remove_longterm_lease(struct page *page)
 	percpu_down_read(&file_rwsem);
 	spin_lock(&ctx->flc_lock);
 	found = find_longterm_lease(inode);
+	trace_release_longterm_lease(found);
 	if (found)
 		kref_put(&found->gup_ref, release_longterm_lease);
 	spin_unlock(&ctx->flc_lock);
diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
index 4b735923f2ff..c6f39f03cb8b 100644
--- a/include/trace/events/filelock.h
+++ b/include/trace/events/filelock.h
@@ -27,7 +27,8 @@
 		{ FL_SLEEP,		"FL_SLEEP" },			\
 		{ FL_DOWNGRADE_PENDING,	"FL_DOWNGRADE_PENDING" },	\
 		{ FL_UNLOCK_PENDING,	"FL_UNLOCK_PENDING" },		\
-		{ FL_OFDLCK,		"FL_OFDLCK" })
+		{ FL_OFDLCK,		"FL_OFDLCK" },			\
+		{ FL_LONGTERM,		"FL_LONGTERM" })
 
 #define show_fl_type(val)				\
 	__print_symbolic(val,				\
@@ -238,6 +239,40 @@ TRACE_EVENT(leases_conflict,
 		show_fl_type(__entry->b_fl_type))
 );
 
+DECLARE_EVENT_CLASS(longterm_lease,
+	TP_PROTO(struct file_lock *fl),
+
+	TP_ARGS(fl),
+
+	TP_STRUCT__entry(
+		__field(void *, fl)
+		__field(void *, owner)
+		__field(unsigned int, fl_flags)
+		__field(unsigned int, cnt)
+		__field(unsigned char, fl_type)
+	),
+
+	TP_fast_assign(
+		__entry->fl = fl;
+		__entry->owner = fl ? fl->fl_owner : NULL;
+		__entry->fl_flags = fl ? fl->fl_flags : 0;
+		__entry->cnt = fl ? kref_read(&fl->gup_ref) : 0;
+		__entry->fl_type = fl ? fl->fl_type : 0;
+	),
+
+	TP_printk("owner=0x%p fl=%p(%d) fl_flags=%s fl_type=%s",
+		__entry->owner, __entry->fl, __entry->cnt,
+		show_fl_flags(__entry->fl_flags),
+		show_fl_type(__entry->fl_type))
+);
+DEFINE_EVENT(longterm_lease, take_longterm_lease,
+	TP_PROTO(struct file_lock *fl),
+	TP_ARGS(fl));
+DEFINE_EVENT(longterm_lease, release_longterm_lease,
+	TP_PROTO(struct file_lock *fl),
+	TP_ARGS(fl));
+
+
 #endif /* _TRACE_FILELOCK_H */
 
 /* This part must be outside protection */
-- 
2.20.1

