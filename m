Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AB36C28CC6
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D4A020866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D4A020866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DCE76B026F; Wed,  5 Jun 2019 21:45:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0677C6B0270; Wed,  5 Jun 2019 21:45:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D858B6B0271; Wed,  5 Jun 2019 21:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1C086B026F
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so465183pgh.11
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5uQsAX2pIUaH2J6K4wUHjO28qHMkSyLajY2GJr92kcE=;
        b=hJO+bKk489Ie6PA8VvMh0fidsKb90ZrkBFnzzJYH70/9Phu339csh6HbieBN7kC67n
         gVsJZQwaP9W5rFQnryQPkMM/uKOvXM+Srx+pC38qKU5u0dAlWTIIwYbeIa+2X2VUe9VW
         vXFJBM2A4Pp2HQFrxEFPzpaW+33CI3yaID7dv6DVa8lt689YAN6KhmBliLuFShRJT72y
         ycZl7ZN7U1Pk/ISeotvOizLNEt0BMchvS7fpH1iJlEZNY5El5sTOZDPPHKgCaHqAST/S
         eUsXvy96T3icxyYUb9TlZ8VCLc3DNOCv6I8fHAsNq1XSBfzhzf0/cXuz5g8t6f3Oi7aS
         xy/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXmKz6Rwzqj7Vzv16vSxx+8s8kj1Bys+Zwx3VDG+ausT5Bc9TQ4
	o9adN1vYOr2lg2MdUDEeOhYCawAz+CQQjS37TaEl8Dr1tLWCVhXWwr4v9qMPi+SEBdeAWK4FsCQ
	xEgnUU49JjOqUbwAEbs14ZNouWkjVHVyi1j1OuuPqA3Gc0H64bMhqaF4FgPnLk2wwzQ==
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr12656210pjv.52.1559785511186;
        Wed, 05 Jun 2019 18:45:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMy+FOcJMiHW2Nlo9PlRammUUA3X/fOYRmZbKrBxt4GVNMENJuXO3HhqsmNBvPzn+YObWe
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr12656142pjv.52.1559785509979;
        Wed, 05 Jun 2019 18:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785509; cv=none;
        d=google.com; s=arc-20160816;
        b=DxMoyz60EgIwlJcOl4roFE5Nw79dJxAy3vWMf1gXGR0cl8OYKB7/GXiNpeDyY3P+p3
         4UhXs5Pkz38waYWTHPtHFecj6nsjsVYcZCafwepwyRLCwf9oZQjD/IGx4kXrPkWx7dF3
         IY1KCsbEI8v2hhvpsnjbfnQOZaMd0YvCA5X5TU3+kBsswSrHNDnJNeXZYBexLFy5JGV5
         mtaMFKOQzciYbV/ySSVbF/HvpkICPYllT8FRzPyY2OfkatupO6YaDRIkbBCaQATooykE
         kgydNmsWPiAubHJfLsa+AU6tiUlSu8a5AsaqqzeqH0cHBP7j4ZCEzr4+B05cl0u5W7cO
         gsjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5uQsAX2pIUaH2J6K4wUHjO28qHMkSyLajY2GJr92kcE=;
        b=TCrLwesNlyYr3qJI2mA1WjEJI/wUdorGng4vamjNwG2bf4RXPXRvNH5HkQBuyNe70M
         6mnrtEUbldPxdcK7wpAelyx5tnYyHfEtjlceJFmU68gNTBZiDnbjhe1Qt55N8MzEcSNa
         GYMfDu1rKUCgopZ83tgPuDLlnXbHTV3BRPhy8P1aPIjz7HWNcr4sx9P84AcbRBft5hBP
         NFDk2CalRxN5RwRn+n/xWfLOy0CrSBwWuDMJLiLDVt9AykVTPXE8TDmNWBRalPRG7Qfn
         QzL9iTsgp9UwNsrS4jR1xIj0I7JnzBH3L3u/RVrJNqpDO/tP3zR5b8n6kbbVjiYnx27C
         5YAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si276921pfk.103.2019.06.05.18.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:09 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:09 -0700
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
Subject: [PATCH RFC 01/10] fs/locks: Add trace_leases_conflict
Date: Wed,  5 Jun 2019 18:45:34 -0700
Message-Id: <20190606014544.8339-2-ira.weiny@intel.com>
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

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/locks.c                      | 20 ++++++++++++++-----
 include/trace/events/filelock.h | 35 +++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index ec1e4a5df629..0cc2b9f30e22 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1534,11 +1534,21 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 
 static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 {
-	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT))
-		return false;
-	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
-		return false;
-	return locks_conflict(breaker, lease);
+	bool rc;
+
+	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT)) {
+		rc = false;
+		goto trace;
+	}
+	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE)) {
+		rc = false;
+		goto trace;
+	}
+
+	rc = locks_conflict(breaker, lease);
+trace:
+	trace_leases_conflict(rc, lease, breaker);
+	return rc;
 }
 
 static bool
diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
index fad7befa612d..4b735923f2ff 100644
--- a/include/trace/events/filelock.h
+++ b/include/trace/events/filelock.h
@@ -203,6 +203,41 @@ TRACE_EVENT(generic_add_lease,
 		show_fl_type(__entry->fl_type))
 );
 
+TRACE_EVENT(leases_conflict,
+	TP_PROTO(bool conflict, struct file_lock *lease, struct file_lock *breaker),
+
+	TP_ARGS(conflict, lease, breaker),
+
+	TP_STRUCT__entry(
+		__field(void *, lease)
+		__field(void *, breaker)
+		__field(unsigned int, l_fl_flags)
+		__field(unsigned int, b_fl_flags)
+		__field(unsigned char, l_fl_type)
+		__field(unsigned char, b_fl_type)
+		__field(bool, conflict)
+	),
+
+	TP_fast_assign(
+		__entry->lease = lease;
+		__entry->l_fl_flags = lease->fl_flags;
+		__entry->l_fl_type = lease->fl_type;
+		__entry->breaker = breaker;
+		__entry->b_fl_flags = breaker->fl_flags;
+		__entry->b_fl_type = breaker->fl_type;
+		__entry->conflict = conflict;
+	),
+
+	TP_printk("conflict %d: lease=0x%p fl_flags=%s fl_type=%s; breaker=0x%p fl_flags=%s fl_type=%s",
+		__entry->conflict,
+		__entry->lease,
+		show_fl_flags(__entry->l_fl_flags),
+		show_fl_type(__entry->l_fl_type),
+		__entry->breaker,
+		show_fl_flags(__entry->b_fl_flags),
+		show_fl_type(__entry->b_fl_type))
+);
+
 #endif /* _TRACE_FILELOCK_H */
 
 /* This part must be outside protection */
-- 
2.20.1

