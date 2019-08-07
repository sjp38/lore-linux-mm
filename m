Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25F0EC606A1
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD75C21871
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tmsRy1Gq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD75C21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5F936B027F; Tue,  6 Aug 2019 21:34:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEC486B0280; Tue,  6 Aug 2019 21:34:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B19316B0281; Tue,  6 Aug 2019 21:34:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71EB56B027F
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:34 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g18so49407922plj.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=swSEQ9kI6LlAC/m4Ypb1JSAurKVsnjosNmhssrjmRGEYCPutJylWTkPcIK2wvcgued
         e4ToCfDeyq+tGwpShYR3fZ0sEC/pYYKsmnBSYvLkgi9YSME4dL/f+zsHmKNA3whx9Tj6
         7ER31X+0zjmPNLRmbbqdlQ66djOyD1yVerNXLvRQHBo0V9qPp7mE4qvjLSqMY3u8Tg9/
         KSkIXqxVz0RoFvcmCLIzChLIIHHoMMeroFEeFioiWaoeqh91OJaNzJM6ZdsO9wfKGh+n
         y7DJmQNfuEv+iePsCNZmqAXX/rPMUcq+BKksEbyKMKHujWXdxLMEJRp/hKiqeGDwrrXv
         RuJw==
X-Gm-Message-State: APjAAAXjVdZlZ4BgJuTY966toR8wLjCXbx0JeTTYjoA77Lm0pLFmSxP7
	ArYUJYkD9ZhCQEeHHrcQILRy8Sk7hZu9nLA2WuwFh5IM8FVVN9vHJM0FRKVi7hkdrGKPGSawxq4
	SlAXgyH4NhkoMmXLals+/bOo6iwlCeu2fKBBdfk3p7mzMk/adV0CHLcw1HCMMsuA4xw==
X-Received: by 2002:a63:89c2:: with SMTP id v185mr5498958pgd.241.1565141674092;
        Tue, 06 Aug 2019 18:34:34 -0700 (PDT)
X-Received: by 2002:a63:89c2:: with SMTP id v185mr5498910pgd.241.1565141673174;
        Tue, 06 Aug 2019 18:34:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141673; cv=none;
        d=google.com; s=arc-20160816;
        b=JOrHwTRHGDnckaYhYaJ6wk711iGZXQ/TYyKVJGTA5QIymVmse1sSz3pY6ajsFSlL7C
         S7jj01XnbElMgtT2So3O11fEfcTSSZkc1U7P83C63BKiz2Vkab+CGs/MnStg0d/Ct17F
         k2sIKoMxoN3Z9oMoLqmus94JXn9erv12BJ9H7K1d3psDV0W9GP/1KGmD44XYcAA89enP
         lrIvTKeFp8uMUplMxAapFMmItr+T+YbxVF5pQeQhs3n8y2l+kPtIO0fHmqRqcX4E9M8e
         pl4tV2Pt+8+J3HwO4oIanLyGdmBc24BswV7ZTrBhajP4y//MZm4cFRzr2kFRNMR8+0Xl
         HBgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=QQqkFi+G/jDaz2mBhsYMO+FecCAETBGAdlc1BdUB9fqRSMNw2f3t/jSsv1GwmcbF9X
         wXydbuurDf9J5dT4ZQ0zjuOhJkUNfbUqgC1bRXbU874Jv/5rGPxXg1wM4uQDSemdBMJb
         R5QAJxBDcjxSRKVOkMyI8yQk6IPIV61k4g1SntZhcgjoLUQ/LcrtgHwuiT2zDPTe3Toe
         tQuIK9nD5UcSdaWCk+cCY4NY56YNx9fkTJq6XQTKeTopZXFJXAm/kzlHav7BYByObNYt
         TOUCBml2ugXaqQ6OkRlWwymE+r8BeCu30/wo1kyT5v7Q7iLPK6if17tnKJQ2lQy+325B
         cZdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tmsRy1Gq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b59sor26444876pjc.19.2019.08.06.18.34.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tmsRy1Gq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=tmsRy1GqXUm98oxjqXOZPjsWspl9AXdfGLJi4f4YSRE4p2Xnzia+lP7gOvMdJeaaOV
         ZMTpzk7cqa5s9Whlhun0Z7Axe9U+exCqGVHdHS/nwzXnj2PJKIWBdXJBCa3H/2BHiz19
         BnEnordNgtmPL4Xz5g5gGRNQFD3awe5Sds/iOUIPfzMq0+Xzzslt2XeYTRCDaqUoB/tZ
         5WSuCY8UmuqBDYfQsynPZOWWiAW9iVZeFmsUs+zlPeiO0OHcuVwV2drvqj8qlA8ICP6u
         9yeV7By6zGvwf0U2BDyf/bSCue82V2u+FVMGjOFTaa85KNQg5C2wQoPnNjOXVsaihczq
         TD/Q==
X-Google-Smtp-Source: APXvYqw2Uz+wsO3yNwpRHMDLbJirCIxZ4A4X8U6+Fg2LdiPaNY42ayE9pYwjEAVQClZpIkVOBc80qg==
X-Received: by 2002:a17:90a:e38f:: with SMTP id b15mr6129518pjz.85.1565141672902;
        Tue, 06 Aug 2019 18:34:32 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:32 -0700 (PDT)
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
Subject: [PATCH v3 30/41] mm/madvise.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:29 -0700
Message-Id: <20190807013340.9706-31-jhubbard@nvidia.com>
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
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3aa069f..1c6881a761a5 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -672,7 +672,7 @@ static int madvise_inject_error(int behavior,
 		 * routine is responsible for pinning the page to prevent it
 		 * from being released back to the page allocator.
 		 */
-		put_page(page);
+		put_user_page(page);
 		ret = memory_failure(pfn, 0);
 		if (ret)
 			return ret;
-- 
2.22.0

