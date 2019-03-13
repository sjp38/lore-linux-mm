Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 472D1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7C052173C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wNnlPQ/w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7C052173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1EF8E0005; Wed, 13 Mar 2019 15:11:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9391C8E0001; Wed, 13 Mar 2019 15:11:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DBC38E0005; Wed, 13 Mar 2019 15:11:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF688E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:11:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y1so3318176pgo.0
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:11:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pPIycjxVsX3Ze4vTm38GWRDVORu3ZQrzKvzouG/Fgt0=;
        b=a9043htE3rgvHyDrFVtltyOq0tQ2i0ya92fO+zJT8bEVQn/yUaEp8LrrGqOSvg5u3s
         ML146KHCoo/OQBuT/9V4QT8xUmiyL298Qbzjn94cjh5Sj1nljXah4yTu+YS4Nnvqb/uE
         jrOx6nVhnwp2hUQ/vebeP393yc0yHwlK7PbutVDeqb0bEmGhWCU+g5xDI8TxnXYFPUKx
         u5ef/PVpOdan1wmQ7dhM3YnM38bhOWsnS2hYhlWSTtmSkoGyrP45fM8GIVxTpEprBv1x
         l7/RsXAVQCXkkn2E5InX0/qwrgwV7Pv2rPs0EdgrEFgJkU1JQJrD0P14vhXDmDiPf5J+
         wwag==
X-Gm-Message-State: APjAAAUk8Lf6+dD4NfPxtzuaE7QKIJAeADYZa23QNVZz8IEkz1iOqiyy
	c8nKbogXKSiTk0XbyRXFsPx1BIb0zNfA/8kwJYU/21Lr2AUKHs8lUru+K0x0zBIJ0EWW7QEzQ0h
	5jD2j/xLoG+1Dzj7FYbwcPSgn/cQ0+KYmiumNe5qXpilJElbivRAyukp7BLH1yQpatA==
X-Received: by 2002:a17:902:29ca:: with SMTP id h68mr3066331plb.297.1552504304831;
        Wed, 13 Mar 2019 12:11:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjnw6uh93/rnZQ/giI3qGJQMYY78Ont5ef6RhOBpz34Z1H9+WoNVBHNMEqgVrnONo8OrYI
X-Received: by 2002:a17:902:29ca:: with SMTP id h68mr3066267plb.297.1552504304055;
        Wed, 13 Mar 2019 12:11:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504304; cv=none;
        d=google.com; s=arc-20160816;
        b=hQXNFqwgau06pdR97v6fuPYNxIMYpiAUBkv9r+GwQTBNyiPr8vZj4Tusm3GRbWbPdt
         x8oZ5nyTotKHZRVTdvBogqBYqBUiLJXELi5ufiUARZx1h1nUeuFZXRY8WFGxpU6F2x7c
         niR8fEvYiCbuoNdj6zYs2orvB1m4+Yqe9kxCDNb5XDc9MKkhjZnuk8dn59PIcKITg/h6
         HaMeCNKkeuj3uoH4VBEMaKX+H1Gz3NylrzUHalldEvVDhQzz1B5uA6emE4ocDqNKexe5
         sf2HvI8TA1g8N6Kd6Gjy9LpMzNXSmOH0VKsT9iQLSoJQxK0cd60hQQDI29podBga0a9s
         DG5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pPIycjxVsX3Ze4vTm38GWRDVORu3ZQrzKvzouG/Fgt0=;
        b=MkqXD4WJHGIRMiGDXuP2qtB9uB43ZAhdc4K9beRUtync7SsGCYjGDPbYtjBj51gh9a
         xK9bS/q7FG1Vofe3LhhA31jdxYXtqUuRJSwTpl4pHmoAuz3uaRU0U5d2oR5bdoRoVqAd
         GEJpYtjs0R8+jv4q2dcOrC+Jrc+obzXWoKy6A7ANcJP6TnzCQTC3tOYxW6ooohjK7B1/
         9j/hPAZ5UhPHjf9bUxJlMjzmOEsPOu3Z0cQeqAZEOKVnCaVX30rDJ4SntT9xghsoEujo
         9fxJ1+Eut/EWfX3a88VKIASAxDCASpciZq/sI8SJ3sPncMbCgoYOxuPmfRc3Q9WZnpLi
         msDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="wNnlPQ/w";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v6si11189312plo.129.2019.03.13.12.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:11:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="wNnlPQ/w";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 20AB9213A2;
	Wed, 13 Mar 2019 19:11:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504303;
	bh=/uP16jNlmCtvaeiTKwrjdK+zw3IfqialZn0qnVCqR9E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=wNnlPQ/wjJnsMM5pJPfKBIRyGgiKOF867/IQpbcFpJKyO2+RUXDRViHHlPQIDtn2H
	 aFP55Eog2AP47I+aSi7tAoC/Bx91NxpL+lVi0L0lXK1oo9/mn7mbFPbvYWVo6X4zma
	 PrbrLEF02TEYsEgN9oYoi19SyBPIGhqfPjXCYaOg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 37/60] tmpfs: fix link accounting when a tmpfile is linked in
Date: Wed, 13 Mar 2019 15:09:58 -0400
Message-Id: <20190313191021.158171-37-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191021.158171-1-sashal@kernel.org>
References: <20190313191021.158171-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Darrick J. Wong" <darrick.wong@oracle.com>

[ Upstream commit 1062af920c07f5b54cf5060fde3339da6df0cf6b ]

tmpfs has a peculiarity of accounting hard links as if they were
separate inodes: so that when the number of inodes is limited, as it is
by default, a user cannot soak up an unlimited amount of unreclaimable
dcache memory just by repeatedly linking a file.

But when v3.11 added O_TMPFILE, and the ability to use linkat() on the
fd, we missed accommodating this new case in tmpfs: "df -i" shows that
an extra "inode" remains accounted after the file is unlinked and the fd
closed and the actual inode evicted.  If a user repeatedly links
tmpfiles into a tmpfs, the limit will be hit (ENOSPC) even after they
are deleted.

Just skip the extra reservation from shmem_link() in this case: there's
a sense in which this first link of a tmpfile is then cheaper than a
hard link of another file, but the accounting works out, and there's
still good limiting, so no need to do anything more complicated.

Link: http://lkml.kernel.org/r/alpine.LSU.2.11.1902182134370.7035@eggly.anvils
Fixes: f4e0c30c191 ("allow the temp files created by open() to be linked to")
Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Reported-by: Matej Kupljen <matej.kupljen@gmail.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/shmem.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 5d07e0b1352f..7872e3b75e57 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2852,10 +2852,14 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
 	 * No ordinary (disk based) filesystem counts links as inodes;
 	 * but each new link needs a new dentry, pinning lowmem, and
 	 * tmpfs dentries cannot be pruned until they are unlinked.
+	 * But if an O_TMPFILE file is linked into the tmpfs, the
+	 * first link must skip that, to get the accounting right.
 	 */
-	ret = shmem_reserve_inode(inode->i_sb);
-	if (ret)
-		goto out;
+	if (inode->i_nlink) {
+		ret = shmem_reserve_inode(inode->i_sb);
+		if (ret)
+			goto out;
+	}
 
 	dir->i_size += BOGO_DIRENT_SIZE;
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_time(inode);
-- 
2.19.1

