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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D76AC32756
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B04ED21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UuxFmnJc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B04ED21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E3406B02A8; Tue,  6 Aug 2019 21:34:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71EF96B02AA; Tue,  6 Aug 2019 21:34:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5770D6B02AB; Tue,  6 Aug 2019 21:34:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 007AA6B02A8
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h3so56036413pgc.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=A5i3Rg5kn+067MlNxvjupwCb7OvZHoHIUYxhc992JlI=;
        b=tS5oplpcZmvreqzINlzrycuHmY1MUjcjuWxvUAX6OQgSBx2pSsklzT0efZrPABUAix
         /Bmt8k6cLX6BOPA399xrWNH7LOJsxO8X4AIzMGoeUbewyA4PQxPUdIYWV//S4PNsqm2x
         oj/BAuj0kcM3WqDWBWuX4RtPRQXHT6rTzQqERyPQ0wbHFD0vgfvFKmDGJNXH80SvGk6q
         oKGJ5Z7ZEy8KwWQTyjaLTgpUDU0P5Qs+NmIyLw26qr9gCk5FG1cdoPb/gDowtvwn2AFV
         VBRvPX6EXxkNjHZQHElFt33iZyUY7DTQH+/aKbiVbEcIHfX47DbT7zM3b2R9J2OG4gNJ
         Ej3A==
X-Gm-Message-State: APjAAAUgb0bv/DmFUlgRfLm2aFRzlqSwC8n7px49GusYixfJZTbbjDrw
	srwtaDV2BPR45o117voJ3vMcTUld+y/Gh6BqfKPOrNdxywrsFaML4B4N/Sw4lFy9/3the02Yt0u
	JLUxDVGa6l8Xh6WxmpcF09Rwf0q5gtGc4ZyFqye89SXqANoxcM03FeY+JzOEaBcf4ZQ==
X-Received: by 2002:a62:8494:: with SMTP id k142mr6666367pfd.75.1565141689688;
        Tue, 06 Aug 2019 18:34:49 -0700 (PDT)
X-Received: by 2002:a62:8494:: with SMTP id k142mr6666327pfd.75.1565141688884;
        Tue, 06 Aug 2019 18:34:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141688; cv=none;
        d=google.com; s=arc-20160816;
        b=DJ1ufWP0xnRgj0TqT0UibpraWoDVTn3QVfQbRUJd0GMlFT5C9E7oujE42GZnceoy6p
         0H1fhJrsP4RS68lSWjMQeE92Cf9wozbLddAl6pMJ8Kv/YrIwj9NX/hV448FujJBLGoiw
         /6ACIfuhJYiDTgH7Uq7R1EqgiLtM7BCg/S1aooIWQ24uLxeqRXWtdCuKG05qoMXNDbt8
         HGejMVVavgedUb1xG457NiOYZBLVKrZt/VzLfDr+A8gvb8aWilPS8osKKCKSrxZVFFN0
         ZYG8Kxz3+73Erdi4acgNFBeMwBzOKCTEMnL9wmqHcfGCSHzMPppI0n5QTq+CSWra8Qod
         jh4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=A5i3Rg5kn+067MlNxvjupwCb7OvZHoHIUYxhc992JlI=;
        b=DRKhr4vUgk+5/94F9MpHpLNgkXbLVMhe0FHZiU9zTWZbfw7ZqYXdftjQaoV8NVtpzS
         ZDjWHF//7Fw5XMeVfLVxvbolY+dhe+ONRKdl6XbwBLoNDTkby84yUN6V62ViJfIO6w59
         f5GiO193KLBEx6B4QTSGHWfjps6GSF0harWC8SxUf57xbHo4x3SqYg1c+oRI93sQZxpv
         4g3oeREyKxEb8UPm6SMnU5o7c7kZ4ts3wE72P3vSTU8TtyRxLzxvzU5VtTCVhNTmSpjp
         Y7IDRXgmsTOLi0ER06M3luVsjRrQ4cr9eK8TQtY6MN1pFSX9k99l370Ta3F3UWrqTx6l
         1cXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UuxFmnJc;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor48954776pfd.46.2019.08.06.18.34.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UuxFmnJc;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=A5i3Rg5kn+067MlNxvjupwCb7OvZHoHIUYxhc992JlI=;
        b=UuxFmnJcCEiWt0xY93+zMuXrIr0kVOIbVkqb6dZDNdX573lgx/iGModXW3xzK9pGPY
         cX+tzVZPKgXMZcfG6ZQsPBSt7kseMu7toLWYUmZdBZq9AOoIRDIMFVmbrRQtXe8+kp+2
         xuf5cY8DkN1gTDTxNyizBF6w883Echl9BWKspGn3wAfNIa3ZXNbfw60ziAuU+jfpWm00
         aE3B42LRws0QrKz6yT/I5rdSznH6+bxJbanBI1rpoulc0fyM/bumlMmxK+EefqH3NUEF
         FOd2q6meN4oVnduhVeiU1hQqU48TiRdVBcpR/X7lAMOhtHAMxLBvoHxdz/5tEjOACTof
         BpeA==
X-Google-Smtp-Source: APXvYqxXaYo+gh0YYtTix+CeaO6wRH87rvrphHjKjanKlk0flLMZdWbR1kBDDX6DGd+bDWORU88dWA==
X-Received: by 2002:a62:82c2:: with SMTP id w185mr6984715pfd.202.1565141688648;
        Tue, 06 Aug 2019 18:34:48 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:48 -0700 (PDT)
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
	Andrea Arcangeli <aarcange@redhat.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	David Rientjes <rientjes@google.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	zhong jiang <zhongjiang@huawei.com>
Subject: [PATCH v3 40/41] mm/mempolicy.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:39 -0700
Message-Id: <20190807013340.9706-41-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: zhong jiang <zhongjiang@huawei.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f48693f75b37..76a8e935e2e6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -832,7 +832,7 @@ static int lookup_node(struct mm_struct *mm, unsigned long addr)
 	err = get_user_pages_locked(addr & PAGE_MASK, 1, 0, &p, &locked);
 	if (err >= 0) {
 		err = page_to_nid(p);
-		put_page(p);
+		put_user_page(p);
 	}
 	if (locked)
 		up_read(&mm->mmap_sem);
-- 
2.22.0

