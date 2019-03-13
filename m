Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35E25C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E76302183F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="N0ZaUrPA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E76302183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 986FC8E0015; Wed, 13 Mar 2019 15:17:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90EEE8E0001; Wed, 13 Mar 2019 15:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 825288E0015; Wed, 13 Mar 2019 15:17:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42B1D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:17:29 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 19so3224517pfo.10
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:17:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=diNyZ80TivjNLVU6mc1bQI2wwjeWIsamOLAE/Yi88EA=;
        b=Iq1MkR9bUhxJbM5BZkgp0ctH+VV33DR1YPP6pR7+bqEM77iTCROU2JRRhc8o+btmhh
         MFSIN+Eq1YFVgAKyxRNAM4lKhND1i9cD/fW7PNTAQaQ0iTMHr9tRo43DJfof6IxwYxh4
         Ryf4/cEA7XG+IQ6kxc7T8t8tDNvEzxZWpOABa3tD6lEM89c9nFRCgCpQldWGUHNSwull
         ZBer2/fWODZJxIWSbF7pOBvwpDjzRe8f6jCHGAvZsdPlYpOlMxqpMB+JQzGsQEwysw6s
         SkU4mekjLDJtjtV275xIyZo2jUeapRlqdhJ0rkVx6y76EJCkebeTlbvh4JTAcSjG3dnr
         wpmA==
X-Gm-Message-State: APjAAAWh+2R2ibMKImWulPBRTRjAMDo56V5QBZAKYfyXmPEJ/FTJxH6T
	zCGZvcoGgCJ3e0PD55HqTFpsZWKV3AmvimQXjY8etWOgPr/2NK/Ue+YqyJScUtu6n/Oi0s0dTZJ
	UxLS8LP7/3OLY6T0MIUdMFZ/BLpSE1S81UMyiCYjEhs+mb12hR5dzrrQECY9Wm5d5wg==
X-Received: by 2002:a65:60c1:: with SMTP id r1mr28090675pgv.137.1552504648896;
        Wed, 13 Mar 2019 12:17:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIWZuOyNyOJgpR+Uc/IGoqGUw9V+keYoeoe20pJTpLFmY+F75aCDp0xsVBZ1/lAXswr1VT
X-Received: by 2002:a65:60c1:: with SMTP id r1mr28090619pgv.137.1552504648044;
        Wed, 13 Mar 2019 12:17:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504648; cv=none;
        d=google.com; s=arc-20160816;
        b=u70lzHuK0W3wstJS7X9g8NvXwNHw0/cX0rXF2duT6HlbYC0DkqHodL5e3saiNFM3HM
         70FzYtzaJusosVNq69jVcHJlhlzvfPud9BJuGp09MQFU+Vwn3JKRMAuq5evhuLMpKb2n
         uXNDDBKOVhNw4ggkeltMDWWrJBEia8wEgnvTlq1B7+Yymkz8JuKo45zuWYHjGvQTidHv
         gCzeO16l0f0K7iz2LYWGZ6PHPF59tzZCbWgzxp51Aq6pfXw7UeUUk80P0Q3CjAhCBQnl
         REUnKrS+KiclzZEfIImTzhQ8zGxc2DQuoF/jbvu+lzdNjjffxYy5G/tshQaPB7EM4S4g
         6egg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=diNyZ80TivjNLVU6mc1bQI2wwjeWIsamOLAE/Yi88EA=;
        b=d4mEORQ0RGzok4911oSsjRlcGWDJeo5G1NaBA77rM4dQmg0G3/wjuhAZBX5jIwj2RY
         CyHWed8xQav1AhK0Og0sAg2l2KKQaj7EEVM883pGjaoN4UrMZOpmOjt+e1uulrLbJwmx
         ecObR37MAXsBRrAdhdUIamxTWa3pZVUGAARjsV2fdmsqxXqpl6A9MVtlc51zi+e2YzEz
         u82d1FYKE3h34HKEuS4Y8XbsvGkwOKFYFVmnzbtK9OqL5dm1jnIoeCM6x5zLfzOZXGCs
         S9IWGPp6ii9XwPG/2M0ltMzHAI3IDL7f07mYaJ30OGPBl3CbkK+5CT/Bzc/fpRS3hzgz
         W5Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=N0ZaUrPA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s35si11122855pgl.101.2019.03.13.12.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:17:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=N0ZaUrPA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E59AB213A2;
	Wed, 13 Mar 2019 19:17:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504647;
	bh=cMruLuTHffGShCUsZgPG1R/CKP0eN+ygbegnL/7eI8c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=N0ZaUrPA1CmcgoCWyTQMGQnvnzVceLq7o+UdfMf3rfYq94viViY9pa2BEYRiWuYF9
	 7ZqJyGHcjXty8yoyPrVCqAdU+CPBn5HC/QUYKsTNcIm61mewwDta+vNxl4SDecHsIu
	 p9o2TvrbBCdjFFqErn1Sg6HpABIjZ5DERz9VFJcM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 13/24] tmpfs: fix link accounting when a tmpfile is linked in
Date: Wed, 13 Mar 2019 15:16:36 -0400
Message-Id: <20190313191647.160171-13-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191647.160171-1-sashal@kernel.org>
References: <20190313191647.160171-1-sashal@kernel.org>
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
index 9b17bd4cbc5e..214773472530 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2902,10 +2902,14 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
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

