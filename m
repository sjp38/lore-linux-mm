Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 448E2C433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E36B6217F5
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YPOY1YFd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36B6217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66F2E6B0285; Sun,  4 Aug 2019 18:50:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FB316B0286; Sun,  4 Aug 2019 18:50:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44C696B0287; Sun,  4 Aug 2019 18:50:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDE06B0285
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so44988593pla.7
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=t6OHhNqF07ZmCmV3v2bjx3wJJktfHv/VBfIMjXbUnDkBAj+T4ouZUfuSf4YTR8WifQ
         00sUgRtxfgLDZkxJjnMtNMjeZ46AauyHN/pWFlUy6gsknNB2lHBNX271VRPWVrrDQFY+
         HW7SOa/zHXxyKZLLh1D64n1x522Db1qh9MkPAenYsh9LccljOZBSa6fUu54bkVjRWakR
         uIJNBcgTUCGOH4EO/1OvaRtVbW+nedQ8die35vmwKsSJSqL20a9hUydGaDtkLV0dcl49
         w1rYKLwJBKSet+HhTc+WaEFmRkJCpav/jgOZShg/CAi1sW0pFhKDhcPwpMX3GNV1OIzI
         CIBw==
X-Gm-Message-State: APjAAAW0PfUarPlu2bWDMoZhrxb8HfhLXEMlkV3w8Ld4ID1UG9Bb+1YV
	dbwBBVBhM/LFCxood7eHXRzDRpd4VNbGPvcxGjnslKW5eRNOLDSjq31lY9UwB7MfC2K2ZLw1SdV
	faLCJdDPBVNwM6FFOfbhinuz3Y1tovJVEWTgDWL92VzN08e7g6sONyLdNKiBDqmVEAA==
X-Received: by 2002:a63:5b52:: with SMTP id l18mr134196713pgm.21.1564959012547;
        Sun, 04 Aug 2019 15:50:12 -0700 (PDT)
X-Received: by 2002:a63:5b52:: with SMTP id l18mr134196689pgm.21.1564959011763;
        Sun, 04 Aug 2019 15:50:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959011; cv=none;
        d=google.com; s=arc-20160816;
        b=0wPMuBhfrhC/7OYKc8HtL9Se4ncpYOJqNEkiBp1yNGsyP62LcfDXOpOnZjt6C+3U+F
         LuaKtPLqOWBNASJGR5WGb6fDfzxLSq2flWeYt2/HWWGtt0igU6RBahVzP+0FrginSEcC
         7LimvGubB+cLOjSMBVrqBCYueLHp9BDo9inxjAO/sekseFEO+U47APpXtahzHnF7bKw4
         F9i0VE//L84G0POVAt88qmWasGS/sKl4c9Rkh+F3zXRB0Z0u079Q2Nk9qIKmMxUP2EDm
         P0XC3d2v5GuZdbFj5Cnuozbj0mNir7XIeUl3/HXdqHWJ7zzbiKdX6CxGKxuiRikYxSSj
         py9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=K4ShUwLm0ZvbzuZ59fA8ue772fRSvrreqbC7BSlcvCiGhDTue1XSDoJDqUiEXv8Rlm
         vd703HmB4khZCm9nbonjyr6hPOzK84sKo5X4yscsJXLdyLPs4oO/jIvhvIHAVdNqxXJN
         Xho57T0KkE8uhYtOvMtQ0htYnvdPBcZ4CUcbLybByrgPUZFTaFN0SjE0QXppVZPLUaCf
         r0q2ZxeFjAz9F4+2sx21KaIRSoUEq1EfpIgKwPqSsdkaw8GsctgmUtjwXIQ6SoMC7lmj
         Q38lfvVh7lzpeBDfDzvat+F5evywMhuLFhiHzGikJiKG6sgoapR4/gOYSS091RfOrYAP
         DK0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YPOY1YFd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor18554654pjz.15.2019.08.04.15.50.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YPOY1YFd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=YPOY1YFdr7iX/mwZQqcGNXlBs0EVKoyeBFEUqInEu6rA0ndI8Mif+0ZPJeKKJ5iFwE
         NKOF3uvUa5VJ+UGiH9nbc87NqjJWsSl0scr9GeK88ydFUly3DCHseKqxTpEd0IfXvu5q
         jcaFXkdAdHJL26lkS0kDgmBvj/6IRTs5wSna3kfRs+vwcKzTL9APp6Wsc+o3ppVF+IRl
         wjQCOTSjcDQ7GQjBBXsLdt+Iue6eXN2thWrje4Rt9XoDAoEpWZdNECCtZUxO8cwujSm4
         fowCwuwgU3C+BFfj4zTJJ1Y4PbaxN4OhvtwxUy9pYDnCK6XNpmRXg/q/Jb/Qj5fLadYM
         mSpA==
X-Google-Smtp-Source: APXvYqxvM1qX7vPDXvngph7SDjRt5A72CS0QHjJHMrDwzL+npYmbY1LXNKjG2Jciqo+k4AO5Wz8/Mw==
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr15076411pjr.50.1564959011569;
        Sun, 04 Aug 2019 15:50:11 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:11 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH v2 33/34] kernel/events/core.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:14 -0700
Message-Id: <20190804224915.28669-34-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 kernel/events/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 0463c1151bae..7be52bbbfe87 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6426,7 +6426,7 @@ static u64 perf_virt_to_phys(u64 virt)
 			phys_addr = page_to_phys(p) + virt % PAGE_SIZE;
 
 		if (p)
-			put_page(p);
+			put_user_page(p);
 	}
 
 	return phys_addr;
-- 
2.22.0

