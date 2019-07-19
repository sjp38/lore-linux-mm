Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3317C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 17:46:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B46D2084D
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 17:46:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="G9TOwr2r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B46D2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEE376B0006; Fri, 19 Jul 2019 13:46:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D77A58E0003; Fri, 19 Jul 2019 13:46:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3F288E0001; Fri, 19 Jul 2019 13:46:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6035D6B0006
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 13:46:39 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id p3so7143726ljp.8
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 10:46:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=1Z3L2rCQwZ1u7nVoekpSRwgzFoMR8NsFTnt2HHesBaM=;
        b=jR6KJdxQti3nha+a8lQmlP6Y91SFXModj9h/dT6ft7w68U/t0mW8+RE9rCjFJP3+v0
         VgUiawVdX4r38Tl8f1XCpe0+1z5pZdRasU5J9nPhkn1kj0CQ8vedStgyjhtlFaxi/MvU
         q0dYJVoVhhGeuObaE+ZKvLqN+Jwf/oPOnW4V9k56b36FlfrJu6M5oIgprKkrGxnW1ew3
         PbBperXuCXTI9/9ht+/fs0gUkHatC8xtfDXHG4u3ejO1go2yVvfwxRIlUR0MAoFjOAls
         930IKFUjvnCt5oM9PYPf2OUzFvpNrYtWPP5ib3kxPr6TyjOwcjQr+xlw6Z0klde6YC9x
         7wEA==
X-Gm-Message-State: APjAAAWTh/Q6EdW8kfZFyCYoK5clk5V0+jVVPuYw17M3bzVUqrJkZKVG
	saXLwf6xMf0/Mq9z8Y/fJ94M4TS9R5h7rgcE/P2l3PM9QFeqOoJKYDR0oo87/LvzBn/aGdeqF0y
	cBl9erC2C/1yWNTSOkchGoqZGAurHVAevar4NFHOneBsHjbl3G7njJLNRIPiQPSDibA==
X-Received: by 2002:ac2:5337:: with SMTP id f23mr25206503lfh.15.1563558398585;
        Fri, 19 Jul 2019 10:46:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrDNFfjv8V3zZmCox8OW3ApS4qW0Z16IMHAMn+z0q6KtuvKFKAYYykQ8ABMYU7G3FK/7Ow
X-Received: by 2002:ac2:5337:: with SMTP id f23mr25206476lfh.15.1563558397702;
        Fri, 19 Jul 2019 10:46:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563558397; cv=none;
        d=google.com; s=arc-20160816;
        b=EOwTunXW44PFSxCVTnnAwzSdg5cZLQvRJcZzHllgCLvTe+uwBhWty0DUN6KP+khqpK
         3FBv7xZ2XmuYtk9EXE/IETOSHJE2+sFAcimf6eV7h2z1sdXHwDkHi+6y2/MKWvlRBDY8
         R4+2cAjvoyPdZzu4s7b9f39d1cj6e8W+jdNoYiy6xcgRg0nV4xAKk0N9FnlbImLIpmCp
         D7Zs0PfKkU0+Vs4S4q7kxKpTrjpZjL7JHLkMFsEJDoZTrObwAPtfoOhtEkkRiit/i0i2
         s4TotiLu7XPtPcwFI9+FjlNkyZzzQECcXwIv51/6gkINmD/ZWcXpMlUGeA+wmEONGuwC
         1RVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject:dkim-signature;
        bh=1Z3L2rCQwZ1u7nVoekpSRwgzFoMR8NsFTnt2HHesBaM=;
        b=ZPfJvdDDe9tBZj3hRxGDqIkladk3zPuMAkJ9iVYdrpRTeXQGJS7+j4UbFODSxQgsi5
         4KD/oS5BORtmfFTs++oBSAIbN4rLWf1XrQW5CfgDQpkoFM+OqLSTLYGwghYcA79VR0CH
         qAExbt/iyRqhL8hBT/lH+qYv4OFcDfxPtJtjQe8Ugm4eoKtyGAlvWIkYtRWbwr/8O7Be
         qtRIqHf1EwLdUjpQ8B1bIWA6fPQlzTvxLnyKRZ5qEDQL19lI4vHXLQygPzlUE9F4US7f
         ZDBwvFz6cPpVIfpXMmzCaP5e4bvPheJnJgJWECGe/LQ1/iuAOuMQjEDZSOXdexo6f68P
         UC2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=G9TOwr2r;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTPS id d26si29660937ljj.123.2019.07.19.10.46.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 10:46:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=G9TOwr2r;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id F1AE52E09F4;
	Fri, 19 Jul 2019 20:46:36 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id ICah43fs8W-kamGWXC8;
	Fri, 19 Jul 2019 20:46:36 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563558396; bh=1Z3L2rCQwZ1u7nVoekpSRwgzFoMR8NsFTnt2HHesBaM=;
	h=Message-ID:Date:To:From:Subject;
	b=G9TOwr2rBmfREw3RPgVRGhOib+9KfKfXg7eGJs92C82XO+TzZdmfUlsdu83GtwFP2
	 Owe7Ncyh2YWSmj+VLAMHq0GEUgfLLCzsgU6lS4EgQ+/5Rp09NDlCi8dyT67snEocI/
	 Ej2WIi+3xDW5HS6wtiZQm1tCkBz1HU6MULzYQ6c8=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38d2:81d0:9f31:221f])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id C9SHlfdlgB-kZIGxdaN;
	Fri, 19 Jul 2019 20:46:35 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH] cgroup writeback: use online cgroup when switching from
 dying bdi_writebacks
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org,
 linux-block@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>,
 cgroups@vger.kernel.org
Date: Fri, 19 Jul 2019 20:46:35 +0300
Message-ID: <156355839560.2063.5265687291430814589.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Offline memory cgroups forbids creation new bdi_writebacks.
Each try wastes cpu cycles and increases contention around cgwb_lock.

For example each O_DIRECT read calls filemap_write_and_wait_range()
if inode has cached pages which tries to switch from dying writeback.

This patch switches inode writeback to closest online parent cgroup.

Fixes: e8a7abf5a5bd ("writeback: disassociate inodes from dying bdi_writebacks")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/fs-writeback.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 542b02d170f8..3af44591a106 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -505,7 +505,7 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 	/* find and pin the new wb */
 	rcu_read_lock();
 	memcg_css = css_from_id(new_wb_id, &memory_cgrp_subsys);
-	if (memcg_css)
+	if (memcg_css && (memcg_css->flags & CSS_ONLINE))
 		isw->new_wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
 	rcu_read_unlock();
 	if (!isw->new_wb)
@@ -579,9 +579,16 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 	/*
 	 * A dying wb indicates that the memcg-blkcg mapping has changed
 	 * and a new wb is already serving the memcg.  Switch immediately.
+	 * If memory cgroup is offline switch to closest online parent.
 	 */
-	if (unlikely(wb_dying(wbc->wb)))
-		inode_switch_wbs(inode, wbc->wb_id);
+	if (unlikely(wb_dying(wbc->wb))) {
+		struct cgroup_subsys_state *memcg_css = wbc->wb->memcg_css;
+
+		while (!(memcg_css->flags & CSS_ONLINE))
+			memcg_css = memcg_css->parent;
+
+		inode_switch_wbs(inode, memcg_css->id);
+	}
 }
 EXPORT_SYMBOL_GPL(wbc_attach_and_unlock_inode);
 

