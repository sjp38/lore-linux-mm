Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2D17C28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7A9920874
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7A9920874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F39C46B0278; Wed,  5 Jun 2019 21:45:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25566B0279; Wed,  5 Jun 2019 21:45:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4E6E6B027A; Wed,  5 Jun 2019 21:45:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89EB26B0278
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:27 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i33so497958pld.15
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6od4TDbdqx+LT3047SpEutXdAzWkr/YDgVOMjEtHNxg=;
        b=ixXURW4TArC65jE9EKP8S1T9RE1ZVCdEkGxa6nhqZsj/U98SK0qpdvKLwwab78NAT0
         M59olF47hO0x7VuA5zcZ1Is/17nxVmb/jMYp7bzUzBAmwgel1Oi458fahuCB0Cia8B+U
         /yGZEG9/dGK0k8beriZF8O4R6TYW9y+mw8zulDOyap5l+PNBQhi/hsD1PDfLk4t7Bhq1
         K3/6Jsxpa+FxstoWjp8aCF1fMCbPQKRb31ldReME4SnZB4Y+Wg9DCJ/xB8C63WsG56dW
         HaAwCdp6z9c7+dkScHOEglnp5Hm8sBPG/rhFBvE+tHQem/SpCEy+hw0NPo0zG9LXDBTl
         x/jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXrqB26+3NmebIYA/dY5d/SCdEQVLLIEGej3GwhCp3i/pmBnWYg
	ZKKh6sj3cNVxMGaOr/4LJ7qUIDOFB2mxsh8xK6juszlcau2GvzLk2VABF9nknEB9UZfSM7lvxe4
	BzAgYOq4aSByYgHl1ylqi2ilfjYCM3byf1u80NOk0B1a2vKtLoYZr25xuM6FPZo7z5A==
X-Received: by 2002:a17:90a:d3d2:: with SMTP id d18mr13052088pjw.5.1559785527205;
        Wed, 05 Jun 2019 18:45:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDe7l/rkn8YE6SEHNe2A81U1x3sx8md/P6JgKx8LbN3VgnPpyVijQq4vu7DHTDKtBslxlZ
X-Received: by 2002:a17:90a:d3d2:: with SMTP id d18mr13052024pjw.5.1559785526059;
        Wed, 05 Jun 2019 18:45:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785526; cv=none;
        d=google.com; s=arc-20160816;
        b=iyaPl3CUu+oQZuVdl0VZlbFYFSiA9ub0TrFXIhIpZ58fbxAIAR6syUfbMl3nFk1xJa
         kHbxKJ+sX67XUvjfCnY3xm42Szjsw9FPPq4XUp+Qa7RrEHIgYUTewzpjhuElifNZhOhu
         3ZZA0VfOoKMG2Eka8zvNtaWaTRVA9h3nn3VitUvPYSQZiY7FI5GaIFtHEw2pNG/FCEPW
         eI6HXxm+uFFmE13UN7OlDbYvnCISdCk/gA3AR1riwCLI5RGrU3EMy0xzjMutDTADY53g
         z6S7xbErzXvY2cUdj6K3/EPv01tzRhbZMQbE+XZV18fmmtZ1cFzjERSnCcHNayor7qZg
         dhtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6od4TDbdqx+LT3047SpEutXdAzWkr/YDgVOMjEtHNxg=;
        b=0+jCpbVbdd/LQ9jJUuTh8TaavRa4TmFVQ3GRZCBTJSPWO/KjnceHIDMIX+3qSFIYW+
         GIAOdVkS8flSnIqji0PYxPm5ZYQc9WBLPTF+Gw9qrpMG7bq83ApdKvYJ1xMt4N09zcnv
         v+HIPCyYCnGzx8CMY89KtpvM/pz5Gj30TXtO7rM7yJiFADoEtL6YupsN22EPRAM50l71
         8xiduHslgXHzuXEcxcWHdAaDBisd29+vZ1xx2TGVXAK3Ou+ZAqvfdlSkgmIjKjRKDJjb
         JRqElE01anRJUGxqnJl3ey9wq8dx88SApFHo8zft8TRNquZSvNSD657z7G9kkpvB438Y
         IYAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 71si254942plf.156.2019.06.05.18.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:25 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:24 -0700
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
Subject: [PATCH RFC 09/10] fs/xfs: Fail truncate if pages are GUP pinned
Date: Wed,  5 Jun 2019 18:45:42 -0700
Message-Id: <20190606014544.8339-10-ira.weiny@intel.com>
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

If pages are actively gup pinned fail the truncate operation.  To
support an application who wishes to removing a pin upon SIGIO reception
we must change the order of breaking layout leases with respect to DAX
layout leases.

Check for a GUP pin on the page being truncated and return ETXTBSY if it
is GUP pinned.

Change the order of XFS break leased layouts and break DAX layouts.

Select EXPORT_BLOCK_OPS for FS_DAX to ensure that
xfs_break_lease_layouts() is defined for FS_DAX as well as pNFS.

Update comment for xfs_break_lease_layouts()

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/Kconfig        |  1 +
 fs/xfs/xfs_file.c |  8 ++++++--
 fs/xfs/xfs_pnfs.c | 14 +++++++-------
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index f1046cf6ad85..c54b0b88abbf 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -49,6 +49,7 @@ config FS_DAX
 	select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
 	select FS_IOMAP
 	select DAX
+	select EXPORTFS_BLOCK_OPS
 	help
 	  Direct Access (DAX) can be used on memory-backed block devices.
 	  If the block device supports DAX and the filesystem supports DAX,
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 350eb5546d36..1dc61c98f7cd 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -756,6 +756,9 @@ xfs_break_dax_layouts(
 	if (!page)
 		return 0;
 
+	if (page_gup_pinned(page))
+		return -ETXTBSY;
+
 	*retry = true;
 	return ___wait_var_event(&page->_refcount,
 			atomic_read(&page->_refcount) == 1, TASK_INTERRUPTIBLE,
@@ -779,10 +782,11 @@ xfs_break_layouts(
 		retry = false;
 		switch (reason) {
 		case BREAK_UNMAP:
-			error = xfs_break_dax_layouts(inode, &retry, off, len);
+			error = xfs_break_leased_layouts(inode, iolock, &retry);
 			if (error || retry)
 				break;
-			/* fall through */
+			error = xfs_break_dax_layouts(inode, &retry, off, len);
+			break;
 		case BREAK_WRITE:
 			error = xfs_break_leased_layouts(inode, iolock, &retry);
 			break;
diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
index bde2c9f56a46..e70d24d12cbf 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -21,14 +21,14 @@
 #include "xfs_pnfs.h"
 
 /*
- * Ensure that we do not have any outstanding pNFS layouts that can be used by
- * clients to directly read from or write to this inode.  This must be called
- * before every operation that can remove blocks from the extent map.
- * Additionally we call it during the write operation, where aren't concerned
- * about exposing unallocated blocks but just want to provide basic
+ * Ensure that we do not have any outstanding pNFS or longterm GUP layouts that
+ * can be used by clients to directly read from or write to this inode.  This
+ * must be called before every operation that can remove blocks from the extent
+ * map.  Additionally we call it during the write operation, where aren't
+ * concerned about exposing unallocated blocks but just want to provide basic
  * synchronization between a local writer and pNFS clients.  mmap writes would
- * also benefit from this sort of synchronization, but due to the tricky locking
- * rules in the page fault path we don't bother.
+ * also benefit from this sort of synchronization, but due to the tricky
+ * locking rules in the page fault path we don't bother.
  */
 int
 xfs_break_leased_layouts(
-- 
2.20.1

