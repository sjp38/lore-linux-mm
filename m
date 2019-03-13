Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9257FC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 499CA2184D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aMg2S837"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 499CA2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6C298E0009; Wed, 13 Mar 2019 15:14:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF93B8E0001; Wed, 13 Mar 2019 15:14:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C975B8E0009; Wed, 13 Mar 2019 15:14:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8548D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:14:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v2so3203343pfn.14
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:14:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pJKiQk357oAcXp3KKWkVAzzOhVCJGYy56/xmN9rAYUk=;
        b=Pg9RQIE0idwsi2+3D0i2RGjgkZI8nc1MI3R6pp9J3qTV+85cQvA+LrR3ClbHRaz9qC
         3Uz/VMpc4OrgRXD221weYUhWErCdP854uvdgF2TQWxfaYMBQtuBkqPoygJis0bq3YDTP
         1Mzfk9/Dn/xrZdE9+vEMb9wUs8g1oI2kYgY93Wd9Iv0WvslIL6vz7FBf4RD+YvMJEzcI
         r+IbqMbznrPK+kXZpp7P/pIrut//yf7Yvc91xy1IJBBr7CCrhskJHhuatYudGjD3BJVv
         c99WBJiLqj1/eafv3GZOJRI8WBDLb9vBhu1bTPY7h5GExxKsbNgtKyTrbmwKqilzKAdB
         GSKw==
X-Gm-Message-State: APjAAAXki/mTPCb8D9+Q1Ub27FqJWyzoVJCPYZjK3TiMBCaGz1zFVyHD
	5XY/mvJPRGGuhh7Y7t74urL63VIuwuMU9A7jo9Lw7iqRud6p3/1pFQTLhKs3rxVMN46uNsQc5GM
	NhT2TO/BsEm68ZmV4MRDVbLt8a+JpXBJlcAW+YfSeUR1afqgFp5G5ogxBZj2CYt9UOw==
X-Received: by 2002:a65:6203:: with SMTP id d3mr18678402pgv.109.1552504449155;
        Wed, 13 Mar 2019 12:14:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyopgVRX4Tq42WW01qUSn+u66qlgHeYj+FqFazpFauNbAQIZaHH51/O7NmDZyIq/2lQePTI
X-Received: by 2002:a65:6203:: with SMTP id d3mr18678344pgv.109.1552504448377;
        Wed, 13 Mar 2019 12:14:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504448; cv=none;
        d=google.com; s=arc-20160816;
        b=WBefgPcT8rX9BaAq1FWZFqdohNT/E9IIolNuc0OVL/PfNGRClxbvLIi2/wV+naexQs
         mwxwTj1MavuNYulL0hDhFiUKIlZ0yGkK9V1TW4x+Cf7/zZvbRP45WyKXTR9RTZwbsC2F
         jeLEk4vIgEZrirmRmN3fTLUC3dymdCzKM7WIdF3PM1xvfBq6sSQQE1Ph6vAP2UHQ3O4n
         2F0KKnBSlnET9IBKHo3fS1xgknMAyJCccEGPmc+bV48L9RH9/gcLUP3BSllSmUXTDFn5
         19ceFgceaTnQ8a/l8IqrthAbSbN9Wcfb5uYFdoxYmSb6a5kN4Bhni3AzQrznzSoWa6zV
         mMiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pJKiQk357oAcXp3KKWkVAzzOhVCJGYy56/xmN9rAYUk=;
        b=mAjn8mcrR6unXqJZba2u+kLOrxlNBNN48vXqxDqIb/0e4TOwN7Tn+SwQs7JQyAJikZ
         gqr/bKSwNwdBn2GxoR4f8bCgtqpmIkL/JIfSbqJBGrjCe440oXQR9YmGOSD0VP3bmJG8
         J/3EAicloOaXxSZjlI8OMcnsXxQGQ5szxqvCOnBl/tNForSPOkOOkVrL8BMWzhJQTjiU
         3GH4GrSBiRr8Shly9l/rhvZRdxD7eYt6i7Z4xxn8bZRt0pSIMy55iBLIZjGkm9jy/UTs
         dB/hWN80vEm6JFE2F9R/Ekxzwb+dwsxpYKevH0b78euSR9cj9NcfFwAA1PGl/Dqa4JXq
         3S1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aMg2S837;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 136si11590222pfu.221.2019.03.13.12.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:14:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aMg2S837;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5C2BB20693;
	Wed, 13 Mar 2019 19:14:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504448;
	bh=PGAJHHfMO/uQra3LQRAE0sC8/48hmjneCCbrtR81tCU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=aMg2S837/KhVrDBnl4D1PGPQhMAvqrm+IqOTcdGMgm5dXVTugQO0G7rpIRAv8P1re
	 /saMyJZmbdt8Th2i4EkrV9UdG/lCCRlp4rLZjpROyvdwsV4ufn9OaAvmrQzuKngYAM
	 Co558MxwcXlG+POK6ptjrtHcJzBw9kgZifAlaN8k=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 29/48] tmpfs: fix link accounting when a tmpfile is linked in
Date: Wed, 13 Mar 2019 15:12:31 -0400
Message-Id: <20190313191250.158955-29-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191250.158955-1-sashal@kernel.org>
References: <20190313191250.158955-1-sashal@kernel.org>
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
index b6cf0e8e685b..bf13966b009c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2901,10 +2901,14 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
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

