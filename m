Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE4B8C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 12:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8003C2086C
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 12:27:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8003C2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F40C78E0007; Mon, 28 Jan 2019 07:27:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEFAE8E0001; Mon, 28 Jan 2019 07:27:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDD4D8E0007; Mon, 28 Jan 2019 07:27:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id BADB18E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:27:46 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id a62so8866272oii.23
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 04:27:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=IPsrxOh9fwpUlxI13AoEKO6stESu0pWTX5wGLwdEvPo=;
        b=GBsrn5YhlkS2GsshPf9/7J3DYNc7nGeIu80+7xU3PSY2QbRitlGstCPGZa5MnizO1X
         G1iucWSeMvhLVHesCCGotu1/XErze8EUlOcWTSidKYW6PpmUljnqUt8xASRLPvx9DIe5
         AGaIro/Hv0erXKBOQ4NGmavUDWT6F1jG+MRJrq+duG2Bg/kN0g+nRZwuWNZEf3U2CaAV
         Ya+yaV+nctlANA2eAHjoXRv/6V9gmKUCri2VvgCthqr7vqec5Hf8g5/LnvIDZDpSmxFK
         gp7arA6KWGIxwsAcnHHU4h5908/LzQtZrNaUTyG4leq2BDiaYORGl4gzHi42FvY7dGhh
         tbLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhengbin13@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhengbin13@huawei.com
X-Gm-Message-State: AJcUukdeUh7jgIYcuCBIRRIZZHfysEQvFGZ/fUNy8vcLQGOqYpKUK9Ti
	/fXoZwXogUyB+2wcroAFPlskMAA6b0pThty64zUfESvlzGRXCVHbDJTYRoM3p2p1aF2j3TRIPPr
	/SzvG6gfCSJIGNv0TMCMyOtKlt2XEQOJV2kvm07t8WYiOP9e5lKP+VNlZtWw6hwz7zg==
X-Received: by 2002:a9d:4c8b:: with SMTP id m11mr15349899otf.111.1548678466442;
        Mon, 28 Jan 2019 04:27:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6jtJy9XmCuOEu395r5EpepI9tc2Kegojn2NQHjDib0UL32+02nzYpBc7xRgWRkhwiDBCj6
X-Received: by 2002:a9d:4c8b:: with SMTP id m11mr15349877otf.111.1548678465729;
        Mon, 28 Jan 2019 04:27:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548678465; cv=none;
        d=google.com; s=arc-20160816;
        b=tzEN1H6vRttXrIedcP18xddwbifu3GxX3yhbfo/lghedhlSxWJldWX0MlFNphqpCTS
         I+rTlQgnhs0dIXSk3zivMPsdX0GcSWgGLpJuKLizNYGxjcmXtUslegCrOKz3a6UIlPTz
         1GeslumwiAC65Pvv4JBS35qU2yCn6VNT9O4MsCiO8ctNPChXJ2djHSVRAZRaZ4I1MZ3J
         QlAWb1s5ax7w1tOg+MfuVF5gKUggiKaRhPItqmh4l0se6Dly4V1sEVrK5saEEUirkoR6
         lUqCkVbqO4LrlZIJWoKiMnEiA8S1R9LhTpnVDE6O8CGyA1angm+sazHnor8RF2S4Kg7j
         vTzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=IPsrxOh9fwpUlxI13AoEKO6stESu0pWTX5wGLwdEvPo=;
        b=vVfskvR28qux/hNTVZLlSti63KJK0WhzV3EHhYZkV6uMgZVqkLO5uMO8848ddAZfRz
         Ie9fBD4DYDo9PxxmeQEymIX3KBuBKdhDQhCVX/iWmCMRWCbu5h0Dn2g4FQflnuwYRXOa
         wr+pmGPnaJ870BuqFy7/mI4tj1NANnRgdyGMsI5LSWTa1QnXsHXX12IK5t8Xg2XIKcXO
         6lrHjZNhcCLB92WFDOYFJHI/znjrpwL6mCh2qpl3jUd7yDsS+CyYEbi0GcmvT9d04ecg
         Yo8SPOCOxa2PYz1XqmM2lVmb0+byrVhRCUrUkKx74wMLROxg0x278eZF57waT58vSflv
         6caA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhengbin13@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhengbin13@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id v68si4781561oif.156.2019.01.28.04.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 04:27:45 -0800 (PST)
Received-SPF: pass (google.com: domain of zhengbin13@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhengbin13@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhengbin13@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 0DD3E6AAAB325446A95F;
	Mon, 28 Jan 2019 20:27:38 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Mon, 28 Jan 2019
 20:27:32 +0800
From: zhengbin <zhengbin13@huawei.com>
To: <akpm@linux-foundation.org>, <willy@infradead.org>,
	<darrick.wong@oracle.com>, <amir73il@gmail.com>, <david@fromorbit.com>,
	<hannes@cmpxchg.org>, <jrdr.linux@gmail.com>, <hughd@google.com>,
	<linux-mm@kvack.org>
CC: <houtao1@huawei.com>, <yi.zhang@huawei.com>, <zhengbin13@huawei.com>
Subject: [PATCH] mm/filemap: pass inclusive 'end_byte' parameter to filemap_range_has_page
Date: Mon, 28 Jan 2019 20:31:19 +0800
Message-ID: <1548678679-18122-1-git-send-email-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128123119.hxJ3xj0-StIvzrug1FRQtS_TGwXaNbBBx2WdEhys25o@z>

The 'end_byte' parameter of filemap_range_has_page is required to be
inclusive, so follow the rule.

Signed-off-by: zhengbin <zhengbin13@huawei.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323..a236bf3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3081,7 +3081,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from)
 	if (iocb->ki_flags & IOCB_NOWAIT) {
 		/* If there are pages to writeback, return */
 		if (filemap_range_has_page(inode->i_mapping, pos,
-					   pos + write_len))
+					   pos + write_len - 1))
 			return -EAGAIN;
 	} else {
 		written = filemap_write_and_wait_range(mapping, pos,
--
2.7.4

