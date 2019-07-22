Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4375DC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:36:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FBBD21993
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:36:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="C4FclbtD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FBBD21993
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43CC56B000A; Mon, 22 Jul 2019 05:36:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EDA38E0001; Mon, 22 Jul 2019 05:36:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 329E96B000D; Mon, 22 Jul 2019 05:36:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id C46166B000A
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:36:11 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id p9so3528673lfo.16
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:36:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=DL5UzA+B5XRB4qh0F2iWC5P1iVbcg0/rElIhEVtbXfg=;
        b=ZakYmBXiNF4VWxl4IkPVdhH6ik3JBM2vwPzyvSah5rq+Gl6EkJUrn1xC7pY63Ksg0q
         wgElowHUki+sOAsOfW13gfjvINYHxERguHjj2wTpfiRVOOzfstZs51jBro8LmWX2M5a0
         kMpvAOVIOiPHmLRel9nCg/4YaXXYVThvtXjGiAbJgr7Gi1qxYtNZle7LWipalVBZ0KZS
         RTT03H4nXDU6nN6T0T7UTVgNL817tVA+lcB6FqkJC1ghmqcQS34SCCbGYSUPBsAId+eV
         6u1uUVyW9KwoVHRT0cJJ2htBb2zjBSNTgTKpr49fBekJL+8a+oUSEd2mos45fUaqN40K
         1Tmw==
X-Gm-Message-State: APjAAAUC535k5nzZTueztlyilS3rj7zCFNkubV15b1TFTFjfPa2RVfQ0
	T6/kHobhWmaXomwBGFwckZjEl8SCvyZZz1OO1ps4j4h6LkRNJjdeA6vZoejGxs5ywhYsgQEDRou
	IHOXD3IA3NeAvwhdjo3Ch66TonWzFZ+Mschchmnvehaqf7L1KbdmJnymyyjJqum/Dvw==
X-Received: by 2002:a2e:b0f0:: with SMTP id h16mr11773623ljl.21.1563788170981;
        Mon, 22 Jul 2019 02:36:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKKPn9+VpjLb+PAEsfoizk2FhsF/nva3EhZBTRj3nkW9LyO8WmKsiLq1kBs2+XoA3vFwkw
X-Received: by 2002:a2e:b0f0:: with SMTP id h16mr11773582ljl.21.1563788170235;
        Mon, 22 Jul 2019 02:36:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788170; cv=none;
        d=google.com; s=arc-20160816;
        b=A4MyiougDIQf0GkQk7impwfPXxI5/ZEaGJe0aHmftt4ii3qZANGH8VvmmFATuQuQgy
         EdPhk713lZBRcE3BgPuGFdbMMtQy2NlRr53cJj3E94pMDlge4HhMAPuDnGrq60jZWJvs
         o57xvOWQ6DFUP0MDa/swNoojI8VWdXzjHLu7VCjUr9wEnMRgv/jTEYImoPmxPOzJeav+
         +BeMr8xC42v1RT5l0AulBxihho+mNcV1u/oMvwdlK12bOWtzOFYgcWSsJiNFu8inWdvv
         WeDbYgPJX8eGuN00DrQTD/qRa+UqGktY3h8o3zIFwsy8A06O0jcJiDmygDlPpU0kZ4sr
         4y9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=DL5UzA+B5XRB4qh0F2iWC5P1iVbcg0/rElIhEVtbXfg=;
        b=ABC0KeZyD2Z2JhgkkvtO0tmiBd6Kh5pMjRg9dGabDQsJuyLPq4REw4RP27bTMG+2C4
         dvpNupPNe8bqXtOc4b56MbozsIoMvnwT0rqFNKeGU7Sg7M4+/6lrF+vWEUF1N4jVF6a0
         DEe16opJceY+ET/xFRD+15EI/1BMXPuS1qNnK40vK4ztFByraCmWvom0YZillVRQ675p
         mrmLFcKKr2hcHcGF0wBHVAmvnqnG7FtTWyXAQWAbYhTp49MStGorBZGhvCaVD1o9JmY+
         GmBwBP9CzVnIfl+92dU35afTSL7WB/kycS1w3I0WTrN//lZjiY0W7jKngXiJu+1RmcVf
         X6tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=C4FclbtD;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTPS id z4si30232701lfj.82.2019.07.22.02.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 02:36:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=C4FclbtD;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 8EF252E1251;
	Mon, 22 Jul 2019 12:36:09 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id piK2rewsgT-a8Nmo53U;
	Mon, 22 Jul 2019 12:36:09 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563788169; bh=DL5UzA+B5XRB4qh0F2iWC5P1iVbcg0/rElIhEVtbXfg=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=C4FclbtDQ5b7smwavzXfTwnAGBDtyvoKz3qJxF/M76PisgHI1mGKIvG4cGohU069H
	 I+8pkq99Gy18EG8atUE+4MtHJf7ZK+4vWOcIFCuhSSGHIaGhFtECkYzI0ajGXe82Ox
	 ixtwBZaI7SGYRKn+koCY2zzBmM5SBCVGXhL8BdLI=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id tCVKM0ss34-a8I48tMX;
	Mon, 22 Jul 2019 12:36:08 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 1/2] mm/filemap: don't initiate writeback if mapping has no
 dirty pages
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 22 Jul 2019 12:36:08 +0300
Message-ID: <156378816804.1087.8607636317907921438.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Functions like filemap_write_and_wait_range() should do nothing if inode
has no dirty pages or pages currently under writeback. But they anyway
construct struct writeback_control and this does some atomic operations
if CONFIG_CGROUP_WRITEBACK=y - on fast path it locks inode->i_lock and
updates state of writeback ownership, on slow path might be more work.
Current this path is safely avoided only when inode mapping has no pages.

For example generic_file_read_iter() calls filemap_write_and_wait_range()
at each O_DIRECT read - pretty hot path.

This patch skips starting new writeback if mapping has no dirty tags set.
If writeback is already in progress filemap_write_and_wait_range() will
wait for it.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/filemap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d0cf700bf201..d9572593e5c7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -408,7 +408,8 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 		.range_end = end,
 	};
 
-	if (!mapping_cap_writeback_dirty(mapping))
+	if (!mapping_cap_writeback_dirty(mapping) ||
+	    !mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
 		return 0;
 
 	wbc_attach_fdatawrite_inode(&wbc, mapping->host);

