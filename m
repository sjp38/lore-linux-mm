Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F058C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E35202133D
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="p1od3tTn";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="nDodF2tW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E35202133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2B3C6B0008; Wed,  3 Apr 2019 22:01:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB31F6B000D; Wed,  3 Apr 2019 22:01:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A7B36B000A; Wed,  3 Apr 2019 22:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49A766B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:16 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n10so967148qtk.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=4EpfoQzzzw77qn7dCDXDDJUXpnn7Bnp/NAwQ6GdLHWQ=;
        b=hGtHl/SWOM9yJiHLV+A1Y5bNJFrI1QwKuZTT1IH0TWt8qxKoHJpuu7S7Bp4ITvpR3L
         11BUlKQfjqVzMi92K9GHr4I32qIUUcUtQi1s2MMXnTc+UdNevVuhnLA2yuuHpr6tOcT5
         c53lYkV4tN0RzVSa5o4xmWyPOoNrxOClfNa/N6WB62eIw/xbkdq3hixHHSkGbyRrK5xG
         XbfooGHmvVC+uMFRRydkjVPuaysqxNcqgKpJCKO19rnZ69Uyh2n4qKwLOT970BT8ZIQ9
         C0c78CNqbuoHIpto2t+dent2/GC05iffKqF43E12hkrcnuhas1RrEfApfq6k8bB6tJsa
         GfkQ==
X-Gm-Message-State: APjAAAVXvQB2esdvWN3UGnYhvvqOwFCddLXtEC+WwGS7ifLqzgKIxNC5
	h8yvv4NZhiPZKKmt+o69XcpIVsxoIsKFGW2aiB/lp3M5f6RqfumXUtm1dpqjMKIkRIg0KVYFdsS
	9IKofVg4+f9ZrLcavBJd18QwS33QcSNqXrzIpTZfInenwaH+S/qV1Fa6vvKMqdSHxVQ==
X-Received: by 2002:ac8:344a:: with SMTP id v10mr3216922qtb.9.1554343276011;
        Wed, 03 Apr 2019 19:01:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTPgKRTZiUdE0kdIwKyVH/N7IJ28T3slgEDPgcUFZpNv6BiTTChFOjez75UmyGrGNw0kNO
X-Received: by 2002:ac8:344a:: with SMTP id v10mr3216841qtb.9.1554343274966;
        Wed, 03 Apr 2019 19:01:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343274; cv=none;
        d=google.com; s=arc-20160816;
        b=nEnoxldTWN4hQae4T0T82iyCVi5rAHP5RqPAk2jTAoBfOs1tApPahgKiTeueaDxXkU
         Bt34f2B1tbFlINsrM9MSCNKx/PBGCWGVyWrgRzpM7iBuibUUffidVEogtz4pcYaJnA3E
         hU1jo1TrRyi2DoFE+/uTYbH3B2A85JfK5Yqs9abXfHmd973uTkaRRZLRpgSKmEznfQD0
         UN3F/UuQliL4PE96pTW0qZfgDCBCB6rjj/wbbQATCyM15lpSslEt6wr+d1qZyxZ+M+H5
         ylOcyEf93OLejenRqDSBdBF56R7sG0cPJNnx7E6GwLyZ+a/hmxxph6X3eeACFaAkgro8
         9S+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=4EpfoQzzzw77qn7dCDXDDJUXpnn7Bnp/NAwQ6GdLHWQ=;
        b=TjkjoHAp3fhj1aMu2yJzjERnH4gKJ51yTMeziB5ldMcTyCnmqwHv1SDDVDAuSlbLBk
         2vaGncNFpLZ0nXTw9ddKOJUTHKBFCm7Fw4jv2mVo+BRU+7GvY6fPqDhyJMrI+CcciGwK
         2I6OGW5P5wtZ8NPCi6ANukm9VmYZrGLCjXhIVRSJ5S9rLFBnuQwfP5Fm5+kuXR3IjyaS
         AhQSmEkFQjs97Lkf/m2wYKPqIfSmlK3Vro6X6JK/qoSFaRx/ZVX91BllvelGmjElW3yy
         6xAMW/bM76AS2E4g+tkFackhQ2ODI1W7niL7rfVBTF0BcPuI1B0jEk838ceyscROeQut
         lV5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=p1od3tTn;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=nDodF2tW;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id u28si930720qta.232.2019.04.03.19.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=p1od3tTn;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=nDodF2tW;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id AAAF5221BF;
	Wed,  3 Apr 2019 22:01:14 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=4EpfoQzzzw77q
	n7dCDXDDJUXpnn7Bnp/NAwQ6GdLHWQ=; b=p1od3tTnJY6BUbGgwrwNqkOZzp7q+
	o6DwVSpwMhxqIKGDeCP7E5zQkDGlCI0y8hAEtS/nzGxKVnZDLZrs7xdQrMjjTqBO
	P5mPv06kOjHwRa7kQPr5QVxSmt+n8ra4tUpqoch9dFrPqBnu1OUPVDDJhu0xoV5I
	KdqJfDwr8/vQmBor5jxfckfOTMXAWOgPjlyztkA/5xZfE3ojZXFKCk6SwjEA+gPR
	7F65EsldaMSOr/6o4tmrb/3t8WUiQMteG4eKBqpP/FasBrdgVMBRGNieyX6qMRdX
	01h1pLwVY478z7ojm696nb4qcOgeiG9TrYwIzk3Wm8zSY5PM38EmJjBlQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=4EpfoQzzzw77qn7dCDXDDJUXpnn7Bnp/NAwQ6GdLHWQ=; b=nDodF2tW
	QaRaADQt2eaHQvTkogTS9TRDdSzKUn+hyDGwYRg4RVHvxSp/7i5INpea0cbjYfFK
	JgZSCYRYsv21ARjce5XdM5SlXDQHCbTQjv0paeuePDNVTMfGpQF2JLx3UeI7LCxG
	XssFt4LoPYsHtDE84rkKPLo4EsDyWwucVIevOAnDcb8l1Z6MlNL5mOxjy/pT6NUo
	orje26OW1bg2G1lTFXk7kzmTeyoZezYs+9h33bZU0Lbnk4wH9n2lGLlNl7Bc4N1b
	xI6jE84PUZX309zo4yL+TWh50v5IgmzqEhA13RzK3b+o4W7gAYEKsvWd8C08xOqN
	0PkOBYWYJS1mpA==
X-ME-Sender: <xms:amWlXIzcyy_Kjiex-5cCzRY1Qhuzw78VaKlvBz5CNeFadxi0ps4fjw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:amWlXINuR4QoUb3oJyt4hHALD4HfQgvpGQNiTQOlNSzMEsABvHE9Rg>
    <xmx:amWlXAdcWb0-RBn4x5jIMO-LOw2VGN0zQFaj_ruOA-X1NA2t_kxPUA>
    <xmx:amWlXM5R1PLJZ3Icxlh7-qaYFETg3_m1x53l_FnV8NysfdqEHaz3JQ>
    <xmx:amWlXNK5C4SASQfyV_fgRcJNOaBqC8pc9JGhbMbPi5ZTQdnYxb6AsQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id B77671030F;
	Wed,  3 Apr 2019 22:01:12 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 01/25] mm: migrate: Change migrate_mode to support combination migration modes.
Date: Wed,  3 Apr 2019 19:00:22 -0700
Message-Id: <20190404020046.32741-2-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

No functionality is changed. Prepare for the following patches,
which add parallel, concurrent page migration modes in conjunction
to the existing modes.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 fs/aio.c                     | 10 +++++-----
 fs/f2fs/data.c               |  4 ++--
 fs/hugetlbfs/inode.c         |  2 +-
 fs/iomap.c                   |  2 +-
 fs/ubifs/file.c              |  2 +-
 include/linux/migrate_mode.h |  2 ++
 mm/balloon_compaction.c      |  2 +-
 mm/compaction.c              | 22 +++++++++++-----------
 mm/migrate.c                 | 18 +++++++++---------
 mm/zsmalloc.c                |  2 +-
 10 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 38b741a..0a88dfd 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -389,7 +389,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	 * happen under the ctx->completion_lock. That does not work with the
 	 * migration workflow of MIGRATE_SYNC_NO_COPY.
 	 */
-	if (mode == MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) == MIGRATE_SYNC_NO_COPY)
 		return -EINVAL;
 
 	rc = 0;
@@ -1300,10 +1300,10 @@ static long read_events(struct kioctx *ctx, long min_nr, long nr,
  *	Create an aio_context capable of receiving at least nr_events.
  *	ctxp must not point to an aio_context that already exists, and
  *	must be initialized to 0 prior to the call.  On successful
- *	creation of the aio_context, *ctxp is filled in with the resulting 
+ *	creation of the aio_context, *ctxp is filled in with the resulting
  *	handle.  May fail with -EINVAL if *ctxp is not initialized,
- *	if the specified nr_events exceeds internal limits.  May fail 
- *	with -EAGAIN if the specified nr_events exceeds the user's limit 
+ *	if the specified nr_events exceeds internal limits.  May fail
+ *	with -EAGAIN if the specified nr_events exceeds the user's limit
  *	of available events.  May fail with -ENOMEM if insufficient kernel
  *	resources are available.  May fail with -EFAULT if an invalid
  *	pointer is passed for ctxp.  Will fail with -ENOSYS if not
@@ -1373,7 +1373,7 @@ COMPAT_SYSCALL_DEFINE2(io_setup, unsigned, nr_events, u32 __user *, ctx32p)
 #endif
 
 /* sys_io_destroy:
- *	Destroy the aio_context specified.  May cancel any outstanding 
+ *	Destroy the aio_context specified.  May cancel any outstanding
  *	AIOs and block on completion.  Will fail with -ENOSYS if not
  *	implemented.  May fail with -EINVAL if the context pointed to
  *	is invalid.
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 97279441..e7f0e3a 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -2792,7 +2792,7 @@ int f2fs_migrate_page(struct address_space *mapping,
 
 	/* migrating an atomic written page is safe with the inmem_lock hold */
 	if (atomic_written) {
-		if (mode != MIGRATE_SYNC)
+		if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC)
 			return -EBUSY;
 		if (!mutex_trylock(&fi->inmem_lock))
 			return -EAGAIN;
@@ -2825,7 +2825,7 @@ int f2fs_migrate_page(struct address_space *mapping,
 		f2fs_clear_page_private(page);
 	}
 
-	if (mode != MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
 		migrate_page_states(newpage, page);
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index ec32fec..04ba8bb 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -885,7 +885,7 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 		set_page_private(page, 0);
 	}
 
-	if (mode != MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
 		migrate_page_states(newpage, page);
diff --git a/fs/iomap.c b/fs/iomap.c
index abdd18e..8ee3f9f 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -584,7 +584,7 @@ iomap_migrate_page(struct address_space *mapping, struct page *newpage,
 		SetPagePrivate(newpage);
 	}
 
-	if (mode != MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
 		migrate_page_states(newpage, page);
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 5d2ffb1..2bb8788 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1490,7 +1490,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
 		SetPagePrivate(newpage);
 	}
 
-	if (mode != MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
 		migrate_page_states(newpage, page);
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 883c992..59d75fc 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -17,6 +17,8 @@ enum migrate_mode {
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
 	MIGRATE_SYNC_NO_COPY,
+
+	MIGRATE_MODE_MASK = 3,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index ef858d5..5acb55f 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -158,7 +158,7 @@ int balloon_page_migrate(struct address_space *mapping,
 	 * is unlikely to be use with ballon pages. See include/linux/hmm.h for
 	 * user of the MIGRATE_SYNC_NO_COPY mode.
 	 */
-	if (mode == MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) == MIGRATE_SYNC_NO_COPY)
 		return -EINVAL;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83..bfcbe08 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -408,7 +408,7 @@ static void update_cached_migrate(struct compact_control *cc, unsigned long pfn)
 
 	if (pfn > zone->compact_cached_migrate_pfn[0])
 		zone->compact_cached_migrate_pfn[0] = pfn;
-	if (cc->mode != MIGRATE_ASYNC &&
+	if ((cc->mode & MIGRATE_MODE_MASK) != MIGRATE_ASYNC &&
 	    pfn > zone->compact_cached_migrate_pfn[1])
 		zone->compact_cached_migrate_pfn[1] = pfn;
 }
@@ -475,7 +475,7 @@ static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
 						struct compact_control *cc)
 {
 	/* Track if the lock is contended in async mode */
-	if (cc->mode == MIGRATE_ASYNC && !cc->contended) {
+	if (((cc->mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC) && !cc->contended) {
 		if (spin_trylock_irqsave(lock, *flags))
 			return true;
 
@@ -792,7 +792,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	 */
 	while (unlikely(too_many_isolated(pgdat))) {
 		/* async migration should just abort */
-		if (cc->mode == MIGRATE_ASYNC)
+		if ((cc->mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC)
 			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -803,7 +803,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 	cond_resched();
 
-	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
+	if (cc->direct_compaction && ((cc->mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC)) {
 		skip_on_failure = true;
 		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
 	}
@@ -1117,7 +1117,7 @@ static bool suitable_migration_source(struct compact_control *cc,
 	if (pageblock_skip_persistent(page))
 		return false;
 
-	if ((cc->mode != MIGRATE_ASYNC) || !cc->direct_compaction)
+	if (((cc->mode & MIGRATE_MODE_MASK) != MIGRATE_ASYNC) || !cc->direct_compaction)
 		return true;
 
 	block_mt = get_pageblock_migratetype(page);
@@ -1216,7 +1216,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 		return;
 
 	/* Minimise scanning during async compaction */
-	if (cc->direct_compaction && cc->mode == MIGRATE_ASYNC)
+	if (cc->direct_compaction && (cc->mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC)
 		return;
 
 	/* Pageblock boundaries */
@@ -1448,7 +1448,7 @@ static void isolate_freepages(struct compact_control *cc)
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
 	low_pfn = pageblock_end_pfn(cc->migrate_pfn);
-	stride = cc->mode == MIGRATE_ASYNC ? COMPACT_CLUSTER_MAX : 1;
+	stride = (cc->mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC ? COMPACT_CLUSTER_MAX : 1;
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -1734,7 +1734,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
-		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+		(((cc->mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC) ? ISOLATE_ASYNC_MIGRATE : 0);
 	bool fast_find_block;
 
 	/*
@@ -1907,7 +1907,7 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 			 * to sync compaction, as async compaction operates
 			 * on pageblocks of the same migratetype.
 			 */
-			if (cc->mode == MIGRATE_ASYNC ||
+			if ((cc->mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC ||
 					IS_ALIGNED(cc->migrate_pfn,
 							pageblock_nr_pages)) {
 				return COMPACT_SUCCESS;
@@ -2063,7 +2063,7 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 	unsigned long start_pfn = cc->zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
-	const bool sync = cc->mode != MIGRATE_ASYNC;
+	const bool sync = (cc->mode & MIGRATE_MODE_MASK) != MIGRATE_ASYNC;
 	bool update_cached;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
@@ -2195,7 +2195,7 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 			 * order-aligned block, so skip the rest of it.
 			 */
 			if (cc->direct_compaction &&
-						(cc->mode == MIGRATE_ASYNC)) {
+						((cc->mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC)) {
 				cc->migrate_pfn = block_end_pfn(
 						cc->migrate_pfn - 1, cc->order);
 				/* Draining pcplists is useless in this case */
diff --git a/mm/migrate.c b/mm/migrate.c
index ac6f493..c161c03 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -691,7 +691,7 @@ int migrate_page(struct address_space *mapping,
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
 
-	if (mode != MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) !=  MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
 		migrate_page_states(newpage, page);
@@ -707,7 +707,7 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 	struct buffer_head *bh = head;
 
 	/* Simple case, sync compaction */
-	if (mode != MIGRATE_ASYNC) {
+	if ((mode & MIGRATE_MODE_MASK) != MIGRATE_ASYNC) {
 		do {
 			lock_buffer(bh);
 			bh = bh->b_this_page;
@@ -804,7 +804,7 @@ static int __buffer_migrate_page(struct address_space *mapping,
 
 	SetPagePrivate(newpage);
 
-	if (mode != MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) !=  MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
 		migrate_page_states(newpage, page);
@@ -895,7 +895,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
-		switch (mode) {
+		switch (mode & MIGRATE_MODE_MASK) {
 		case MIGRATE_SYNC:
 		case MIGRATE_SYNC_NO_COPY:
 			break;
@@ -911,7 +911,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	 */
 	if (page_has_private(page) &&
 	    !try_to_release_page(page, GFP_KERNEL))
-		return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
+		return (mode & MIGRATE_MODE_MASK) == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
 
 	return migrate_page(mapping, newpage, page, mode);
 }
@@ -1009,7 +1009,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	bool is_lru = !__PageMovable(page);
 
 	if (!trylock_page(page)) {
-		if (!force || mode == MIGRATE_ASYNC)
+		if (!force || ((mode & MIGRATE_MODE_MASK) == MIGRATE_ASYNC))
 			goto out;
 
 		/*
@@ -1038,7 +1038,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		switch (mode) {
+		switch (mode & MIGRATE_MODE_MASK) {
 		case MIGRATE_SYNC:
 		case MIGRATE_SYNC_NO_COPY:
 			break;
@@ -1303,9 +1303,9 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (!trylock_page(hpage)) {
-		if (!force)
+		if (!force || ((mode & MIGRATE_MODE_MASK) != MIGRATE_SYNC))
 			goto out;
-		switch (mode) {
+		switch (mode & MIGRATE_MODE_MASK) {
 		case MIGRATE_SYNC:
 		case MIGRATE_SYNC_NO_COPY:
 			break;
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0787d33..018bb51 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1981,7 +1981,7 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	 * happen under the zs lock, which does not work with
 	 * MIGRATE_SYNC_NO_COPY workflow.
 	 */
-	if (mode == MIGRATE_SYNC_NO_COPY)
+	if ((mode & MIGRATE_MODE_MASK) == MIGRATE_SYNC_NO_COPY)
 		return -EINVAL;
 
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
-- 
2.7.4

