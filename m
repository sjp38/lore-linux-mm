Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7722C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:11:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A02E2218BB
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:11:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Qo6+nRkj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A02E2218BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 381178E0012; Fri, 19 Jul 2019 00:11:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 333FC8E0001; Fri, 19 Jul 2019 00:11:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 221DF8E0012; Fri, 19 Jul 2019 00:11:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E263D8E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:11:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so17934539pfw.16
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:11:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pfm7qZcXtiCG4z8TWVHfefcsgrR5VCIuMlvWmvellx0=;
        b=tgEHhmFP7uFASFfl1FvH4sMFl8Gdr9EwvDY7rPaHmsiwidEnHHmwSenUF2VpzrvauB
         gpkeKwMNITzvEd3xWrf+vAqz/WrVVznDs7o/9LBNs7KYfrdqUOSiNYz4Ai7nT83c2UmZ
         TyuCaCXDczMcFR5GxazVpZqzLSO305q3ms+ekChyYZqI4qVlSQLkmNUC42WOLwM1bjXH
         6sf8SsUMkYwISFPa4tABMxzw4eFurcsgV3f+zuf0iOGAlfR0pG4iyAWsIcf8YDXk4Guu
         z7nsh1lUFzCNT8W1Fr+ASz9WQW1gQQyNrd7fS4+kk8ZW2z82OhyZLWW9g1xqjH8UdCVv
         +wmQ==
X-Gm-Message-State: APjAAAWP74k/JKEboyyZdmQihfWZ17LD8hksBcFOx93y8JRo8dHWieuC
	HA5nNy2I8VkpUhwb5NQnhfA8lqjhYqp7RP5PuLfWIlVzR0zzBp0rzELEM0MQ5OAVUNpGutAP8kT
	T/usloD/HCpZMFkxY4cDSOpJqmpS1qMAOeSa5KK2eAqOFx9dSc/O2MJbPa7ZvV1cKwA==
X-Received: by 2002:a65:5584:: with SMTP id j4mr21441062pgs.258.1563509470520;
        Thu, 18 Jul 2019 21:11:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIH+pgn/PkS2Opou1TO0k71Wq+TtqnZnkwkJMntqfmi3oHOkhpU+ewhWFqiGHp7h/gYqDo
X-Received: by 2002:a65:5584:: with SMTP id j4mr21441018pgs.258.1563509469776;
        Thu, 18 Jul 2019 21:11:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509469; cv=none;
        d=google.com; s=arc-20160816;
        b=vXEE1zMihvXxB/8WOXugCxe+X5zzX+u2OeVDd54Ddst/8utxCWPU53F/DnjOnh8OUa
         Jf6F/nG0j7U3iQyPYHa8eVWIvpLSG78UhiuoJcaL3bsrdGlfrrPpwVcNfIK4qZ5ma9im
         o55T5Ey4LhKQXxRTw/XgJZ/Oz5Zy9havglcGWHotX2DWWnFDU+2OENHGTB0geIcl9TbE
         FLl9rF6I7selq2B8OT6EMg6sxkVtsOSX3FFeNXukVW0LH2LWQvvEDDThl8cBYCTQf+Iq
         AalGDdLXnyYiplYJfGlul6m0eyMNQ8GKIdIkUTxawxAlBz8zQbvOsY7m1kK662rlY13l
         qlkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pfm7qZcXtiCG4z8TWVHfefcsgrR5VCIuMlvWmvellx0=;
        b=oL4P4rqdQq6xR/5Y3sa6ufmFqbR9rrhi1D9S3RP12jdeJYLCN2etTzzI0Gek8VDZjb
         BTDUZ1JODogQ2R3tnL4tPfvY7le8vOoSva7qCj9A7b8J34qboj68xuEZg5nEFOGPb0Mm
         ZRtpkid9CNtdGIRlBAJJ4PxTG5toOzJs4/MZ5lrR9eGepW4YxeHD/eM6GUJdI65tax0e
         D2D+7+OCFvbz+ec48ZWeuPFwLZGkapX9mfcO5wSE0bh+vNR4j2hajCpsgn/eRPic9BUi
         iJefWraU82DFLJWhk1cBzAhVZGpXuqacI/hO0Y915ScJUfTR9jJlFMO6apwAn2yadKzx
         +Lug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Qo6+nRkj;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h99si3128657pje.83.2019.07.18.21.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:11:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Qo6+nRkj;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D682121872;
	Fri, 19 Jul 2019 04:11:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509468;
	bh=ayNMgFyXiftuip0Uxel5UmXwcABdBHOMaIPv9xzWQSo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Qo6+nRkjkjO/LNYSE9MHCDPglUMV4XD4WsEMR7jOFp5/KIycU6JFUAUqCBgG+Yptz
	 5oakQhx9R8Ka2GSyIAjZSNqBbKuQIOHoNckgtoCfGnnEFAPrpk2msTUpKQ8CVDOWTZ
	 oR2n9SPwYbXu+l4OrWK4OOHNC7j4RTNfLZCNbM68=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	=?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Roman Gushchin <guro@fb.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 101/101] mm: use down_read_killable for locking mmap_sem in access_remote_vm
Date: Fri, 19 Jul 2019 00:07:32 -0400
Message-Id: <20190719040732.17285-101-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040732.17285-1-sashal@kernel.org>
References: <20190719040732.17285-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

[ Upstream commit 1e426fe28261b03f297992e89da3320b42816f4e ]

This function is used by ptrace and proc files like /proc/pid/cmdline and
/proc/pid/environ.

Access_remote_vm never returns error codes, all errors are ignored and
only size of successfully read data is returned.  So, if current task was
killed we'll simply return 0 (bytes read).

Mmap_sem could be locked for a long time or forever if something goes
wrong.  Using a killable lock permits cleanup of stuck tasks and
simplifies investigation.

Link: http://lkml.kernel.org/r/156007494202.3335.16782303099589302087.stgit@buzz
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reviewed-by: Michal Koutný <mkoutny@suse.com>
Acked-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Roman Gushchin <guro@fb.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory.c | 4 +++-
 mm/nommu.c  | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e0010cb870e0..fb5655b518c9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4491,7 +4491,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
+
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
diff --git a/mm/nommu.c b/mm/nommu.c
index e4aac33216ae..1d63ecfc98c5 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1779,7 +1779,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
-- 
2.20.1

