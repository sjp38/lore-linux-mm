Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2148AC5ACAD
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2455217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eS3YB7ZT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2455217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 153266B02A6; Tue,  6 Aug 2019 21:34:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B7546B02A8; Tue,  6 Aug 2019 21:34:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D11056B02A9; Tue,  6 Aug 2019 21:34:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 969EE6B02A6
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so47077997pgh.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=H0Etnn7JHR8H7TocLV05oLauZ77NAi3PGTTr9FTaKTw=;
        b=M0KSyJ7cfV/MptM0is4bMG1nm2GC0NTBHLBzE5VqPUfbjlg9X1RgrP4KBD2wRJiWG5
         1P0hgx88tU2kV6ifp7dYBA5hf8QZmZ6sbuHVnx+g7W3cCaDg8tmEfrQj7lfsNhoQgWSv
         WX9a0k3qQ5+DjMgjadfzh+ZJRB90lFKQTzu2Mdb3sMH+f2L7RHprf97u4NVLZ4YOLWkJ
         +iS6dTHzIwKUNuQo7APckuw/kyg40nWmjXOiYkdRUp+DLuO/9DZHCfjGz31AHt095aKS
         UaaPffMuOd29ERE4kz9fXmBKh/8ddHebhMsnosKTuNLVmVPMjw0WwrC7y9FQEf3sb7f0
         L/XA==
X-Gm-Message-State: APjAAAVjQTSfGDljZUHF5jaPwDleYj9zYlZY+46CUJDify+68WVF2e7z
	NZaUeR769l+D8sw7zXG23mFUWESglS21Wm1dr52GZ4S+JiQEP3G0Wz67jdkfLjh+cSqcoymNQKT
	Ui6yvtCUF5loL6NONO693BKo24fYCUJ3VyARUEZgQ5M2gsZSVFcHL6YkC9Qe+5nxJ/Q==
X-Received: by 2002:a17:902:204:: with SMTP id 4mr5743901plc.178.1565141688285;
        Tue, 06 Aug 2019 18:34:48 -0700 (PDT)
X-Received: by 2002:a17:902:204:: with SMTP id 4mr5743846plc.178.1565141687243;
        Tue, 06 Aug 2019 18:34:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141687; cv=none;
        d=google.com; s=arc-20160816;
        b=jd7YdA2J4cjEl291R4n5iZ4Cda3vKv6XQL891yOFiVnoeMTcIt57+ub/rfd7J7W4Qm
         h9BtId584uJsBDaaxs7MXPEnsssWmFVmcKqVtu0qF4rP5/MCL1zM/HZ/8260RleBDAG4
         W9qXzC7u4a8qrLYDGOtNF63NlY3hKw7+UdUt46OOS3lEQoI+HHQY4UE9fWwjaVy3wWyt
         9G6GffXVZlMAD9SKphvxPgV+KDi5QbdOf4gKZiCqESSycELgJYEbMNicZvATf7xHe0ql
         OEAjT9a2uMm521TOW/jzZblxwWxTjyA02rviPE395uDHG89ihcPu7kOXYEAR5rnTdTum
         dRDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=H0Etnn7JHR8H7TocLV05oLauZ77NAi3PGTTr9FTaKTw=;
        b=t73vjaG/bMaCLwq37yQiPr9BUXhFjTt9hp5fEZ1EZUyM0UH+1JE9RFsgtoJ2ocUFsi
         D5RGpED54ZUPbU4paAcvwsLQ4VZPESvFq0V+jUucOu0w782cNQKkTXPeR/OojH2Nho19
         4ko8z5uyJPgzLhpB0JAhpPaJJkeYsPiTE765fRPKUktLO5WhRLw94nDNvJAIbpPReozg
         dImOZUWmqgOX0x/piDmW6shb7wrDhjYl+PDTnz+5vKMnJR2cfUEWBoNuZgLJmBu1ulBs
         L3L5dAp7cZ+DqZLNtNx9mwaGedR7PW/v/zXPBKpjMiN1g40cwLYZIbY7AU9CV8oYVUDZ
         k4Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eS3YB7ZT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a25sor67370876pfi.29.2019.08.06.18.34.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eS3YB7ZT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=H0Etnn7JHR8H7TocLV05oLauZ77NAi3PGTTr9FTaKTw=;
        b=eS3YB7ZT4YXwuCcgQbB/xbD+n10dBypw+iZZVQIUwi66vhDfcSIp39QkGkG7an7OJl
         OiukENJvNGRlLtpSvoOFB7XysgcSlBHri3dSlfLLl2JoybffI8wnImTZeHQEdnORxVLa
         EBXGZhIf+YSKbjfkupoovScD765pOoXW+wmQ3q47Y78G67P4azJFj7Z03p0IlFla0TF0
         WGS9epzDu3lNP0Hir82G8T/Dsucq+VMZQ717BtULEmOp/zZ+HeTgTfaZfag+K5X0r5bl
         +CKlJZyT3xTot1t0x6sX+RloIZlzVtbmPtAqvydRbxbh9+Ay6+ppy+Ss6WRVBPk23UrF
         ZgCQ==
X-Google-Smtp-Source: APXvYqzWWP/A0o9J09jCJjajCJWgGO/EPyZUANiBcpDufZXSuOwgzfu98JYNHWmK3CJ1oF9MD+qnUg==
X-Received: by 2002:aa7:8201:: with SMTP id k1mr6559788pfi.97.1565141687010;
        Tue, 06 Aug 2019 18:34:47 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:46 -0700 (PDT)
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
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 39/41] mm/mlock.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:38 -0700
Message-Id: <20190807013340.9706-40-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Daniel Black <daniel@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/mlock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index a90099da4fb4..b980e6270e8a 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -345,7 +345,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 				get_page(page); /* for putback_lru_page() */
 				__munlock_isolated_page(page);
 				unlock_page(page);
-				put_page(page); /* from follow_page_mask() */
+				put_user_page(page); /* from follow_page_mask() */
 			}
 		}
 	}
@@ -467,7 +467,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		if (page && !IS_ERR(page)) {
 			if (PageTransTail(page)) {
 				VM_BUG_ON_PAGE(PageMlocked(page), page);
-				put_page(page); /* follow_page_mask() */
+				put_user_page(page); /* follow_page_mask() */
 			} else if (PageTransHuge(page)) {
 				lock_page(page);
 				/*
@@ -478,7 +478,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				 */
 				page_mask = munlock_vma_page(page);
 				unlock_page(page);
-				put_page(page); /* follow_page_mask() */
+				put_user_page(page); /* follow_page_mask() */
 			} else {
 				/*
 				 * Non-huge pages are handled in batches via
-- 
2.22.0

