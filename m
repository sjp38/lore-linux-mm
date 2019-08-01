Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 416FDC32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06CE420693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06CE420693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8764C8E0008; Wed, 31 Jul 2019 22:33:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8011B8E0001; Wed, 31 Jul 2019 22:33:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EE208E0008; Wed, 31 Jul 2019 22:33:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD3D8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so38681605plp.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qDztLN89iCHs4hLXE0pbjxysAKrLOIBJlbYdi/SMrE8=;
        b=DxRus41ecjHiRLPDr0MzV8LMYFygp3UqDPrdUN8Ki37sKbEzjJa3zaxUV9C46dwCRO
         yooRlciby7oMR2zHU2+jeTZezLKwRU/N+qPge+/gFl7CH+AxPMO/7PnT7UjfeHOjdbvG
         1WpT4yeX7302HUfKY64JY+Rw6ZBfL85NON3MIbqN6AzqPEYtS8MiU8F5lfkZ6Wt7+AQ8
         OSbRmwnvBXvkthVu3QU1/kgvTg95oDbVRdHh0QNEQlTkgDD1cZnhcw86WL16YiSovuxr
         EBYeQGkNY534Q5V2+xR6VQUQaJf+h8xfomLT6D7g38KJ/nIfvKysTzCz272E8PohB+W7
         v84g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAU/omUCaYyp6tFU0pvwyGr2pUpVpu6q9s/cmz/TNwcThsbiDGSy
	lO6bIvWG2oA4jJ+bNNc3UOiNwYKdPxanOujW3m/XpKQk3N5l9oJ76Loa0la2nqDDJ0qCWIafYwM
	DKiAI9fiMhcIz0n/4IL0cE57cQFC2tlSYEAQUO5LE4e0COiddqAz5w37QzO8EVC8=
X-Received: by 2002:a65:4844:: with SMTP id i4mr5907296pgs.113.1564626808874;
        Wed, 31 Jul 2019 19:33:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsW6CZJWhbr7S1o47j8v7A0UPO9jiNUPKJ2MOQ7xrTrvGlJuUj7SRLpbgNfUcAotbNGBO8
X-Received: by 2002:a65:4844:: with SMTP id i4mr5907247pgs.113.1564626808117;
        Wed, 31 Jul 2019 19:33:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626808; cv=none;
        d=google.com; s=arc-20160816;
        b=j8NhDVaqYahZ7lNGt3O3sOSDvNQmqz1OQV1Sw6Dlf1nJw6v8FKV76JuLGAEpvDZqV0
         lyciqBpQ8O7z+lAbsML70e1hO6aySc0aYCAvecpvl101C6eTZYE10Xmnqt5whuzyFebJ
         GJ7Wgku/HVZrGegxGtphansXz/SStK3zHBcrGTchC8pkGvoa+5m3nWBA5dBvBwjXwwI3
         Lw0VsUcEJHX+1IHufKDAnsaFV6/i24QfZnFaaLqbchYkuKpklNFOj0DN9Qq/4QmjxRz1
         n5/Jrv6Vc/Ac5N7APhrtPpoDMLTZ/TBDYu5kYlnlWiyup0VFH2G3b/1tHQFBoz+AvZzG
         4kIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qDztLN89iCHs4hLXE0pbjxysAKrLOIBJlbYdi/SMrE8=;
        b=mO/fD/WlSdlj3ltKIt0VFFu/6Gxl0vSuK+of/ZEQov/w2ExQBcW1uGPNGUC6F69bYp
         Yti2ibqlDX0RJhgA5PkcnXv4VvgdrW8zfTKQUgYTAJCfSzad+Zsoy0bJS4Q+LDlDG5yj
         3wgTLf/JTM6oYOu6wiDax6NCOpIRYSyBT2fGQKFlWXtiGqrU6Jcgt6SmR0VnGddkmX3K
         TY9ATxj8njDniWoHEsusB9tlb4wCqt0KGPGm5A31ZQsZz3woG0U58/OsPGsfCW6bMgXG
         Zhtfr4/mekWkA4xzlGTrwtUxLxCdByKLRGe7a42Zeu0tSkaxgBTDU57Tlk90ePAh+oE4
         dMag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id n75si2816008pjc.27.2019.07.31.19.33.27
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:28 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id DB35E362329
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:26 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003am-W6; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001kx-Tx; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 09/24] xfs: don't allow log IO to be throttled
Date: Thu,  1 Aug 2019 12:17:37 +1000
Message-Id: <20190801021752.4986-10-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=5HahVxdoFHTWBnBQlCYA:9 a=DiKeHqHhRZ4A:10
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Running metadata intensive workloads, I've been seeing the AIL
pushing getting stuck on pinned buffers and triggering log forces.
The log force is taking a long time to run because the log IO is
getting throttled by wbt_wait() - the block layer writeback
throttle. It's being throttled because there is a huge amount of
metadata writeback going on which is filling the request queue.

IOWs, we have a priority inversion problem here.

Mark the log IO bios with REQ_IDLE so they don't get throttled
by the block layer writeback throttle. When we are forcing the CIL,
we are likely to need to to tens of log IOs, and they are issued as
fast as they can be build and IO completed. Hence REQ_IDLE is
appropriate - it's an indication that more IO will follow shortly.

And because we also set REQ_SYNC, the writeback throttle will no
treat log IO the same way it treats direct IO writes - it will not
throttle them at all. Hence we solve the priority inversion problem
caused by the writeback throttle being unable to distinguish between
high priority log IO and background metadata writeback.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_log.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_log.c b/fs/xfs/xfs_log.c
index 00e9f5c388d3..7bdea629e749 100644
--- a/fs/xfs/xfs_log.c
+++ b/fs/xfs/xfs_log.c
@@ -1723,7 +1723,15 @@ xlog_write_iclog(
 	iclog->ic_bio.bi_iter.bi_sector = log->l_logBBstart + bno;
 	iclog->ic_bio.bi_end_io = xlog_bio_end_io;
 	iclog->ic_bio.bi_private = iclog;
-	iclog->ic_bio.bi_opf = REQ_OP_WRITE | REQ_META | REQ_SYNC | REQ_FUA;
+
+	/*
+	 * We use REQ_SYNC | REQ_IDLE here to tell the block layer the are more
+	 * IOs coming immediately after this one. This prevents the block layer
+	 * writeback throttle from throttling log writes behind background
+	 * metadata writeback and causing priority inversions.
+	 */
+	iclog->ic_bio.bi_opf = REQ_OP_WRITE | REQ_META | REQ_SYNC |
+				REQ_IDLE | REQ_FUA;
 	if (need_flush)
 		iclog->ic_bio.bi_opf |= REQ_PREFLUSH;
 
-- 
2.22.0

