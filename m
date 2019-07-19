Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95436C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:07:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D21021849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:07:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="srvP4yGG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D21021849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF5808E000E; Fri, 19 Jul 2019 00:07:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA6AB8E0001; Fri, 19 Jul 2019 00:07:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6E3E8E000E; Fri, 19 Jul 2019 00:07:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0C2B8E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:07:23 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b18so17956352pgg.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:07:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AuML3ZqvUyPeL23iN1l5JzsEwZl5XQbbk20/GqsWZ2s=;
        b=sioAgmXno1ELlDDaX1ibDQVw40uSd5qmnHDjfwdYi3bz7rUD9i+GNEM3N1gnBVhxFY
         7MbwyIy0AaWeZ10iikwVDlhijywt8OL076fyehLi3p1JKD+QboBhI2ATjwi0vqXox08K
         fcQUWHWlmb8lkm/NiRZFO0nJFc4cb/8RBpr8OenkDnWirvDpxf7X2I1DfcYR2Hjp/F36
         db6d1nWFJJoKqkswiiPmrShkjcJDVwsrXhZUzYE7+Be0MRnLqnBw5hRep6wyjWG6s4np
         7Z2L1O4j/Hj1ngF3/XmR5Vy9gRzjri7RkqXRke5IF4rJiFOCOU6GktkB7SYs5UbhaIBL
         vTgQ==
X-Gm-Message-State: APjAAAUQ6MKrUK3tb1IGWFAiP4r+vI1w/hJS9FIM+vFMxhr6t8zEi6jC
	yTv5FfzbCr4duNGYcsIya+bpemvmBC518Wnv883UQGAFH0doHSxU1XiVykiY2HizbNYsyoHrG5+
	ZozcFL2V+vwsKhMaL4fuBf1VfiKxk1vs3t3vVxvLXbV64mcdXifwdZzQShOAIYkA0mw==
X-Received: by 2002:a17:902:2808:: with SMTP id e8mr52418509plb.317.1563509243335;
        Thu, 18 Jul 2019 21:07:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDg+h017g+LcJh2IWdDCUQ3UrCo3Zi/icpNw7D0Kov29BvF2Cy0BvDwGJilEyu+cg/fHSO
X-Received: by 2002:a17:902:2808:: with SMTP id e8mr52418463plb.317.1563509242701;
        Thu, 18 Jul 2019 21:07:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509242; cv=none;
        d=google.com; s=arc-20160816;
        b=ru1kBMrBSFF5l6HHXOc2Bk9jNloS26VK47a79FNCcwhVkskkKcMZYfcwlJkY5y+4+8
         /7D5Se2rz3/X+LU81C2DTInA28uyY5TxcflCfn0kJVPatojB4AUmYuamcj9tk76+R4N1
         jc28Hdqnxz+D3DBYXVcmoFVYufVkTP5zC1wJ7Aq1g/DGmfrkGpgb+ZFJLOysrO7ejPMu
         7wIRukozk55SjOFj4P+iclk0P1nXmCGkuK0kTJABQwK10Pu3exU4+wkPXY2hWcqq5Dw8
         WkD9QuPyz5W98RTFZ3Gjw2H0vr0enjNV8LWDvUTtd3rQLr8ESYfXV6ATz0zKDyhuxYuA
         3ZfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AuML3ZqvUyPeL23iN1l5JzsEwZl5XQbbk20/GqsWZ2s=;
        b=h1fMyxzzkTdImedkToBnxxw7wy/Z0B/co52QxRT6EJt3fA+GG2Kv9bTxRBOZkdKCBe
         7weESt4OaRtoNoNr3g6OnupZKkK3AKFyUQG2Vd5dmBCbXMn8CIQmmsNnj4RO+gz6oTWl
         nVsxNxV1Iv+wLGKRRWzTgsXFblXFtm5+ymOsAw97bQpqiaJU6V2wL9IflcJxMCPL6iN/
         wQ5w6sdP8K4MDwwYJvDOKCEhrg2r5W83/u5vha7+Trroiin8alrR1oq6Aw5WN29Pv2qe
         hSpMH5lt4IHD64XtgdDkI2ZRq7XY8gQsYTyqvu1ddYpctj4Ifr9dnWB3DL3LZggqrs6A
         2SBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=srvP4yGG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f96si1971615plb.339.2019.07.18.21.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:07:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=srvP4yGG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CD60C2189F;
	Fri, 19 Jul 2019 04:07:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509242;
	bh=XIhAftyDr0qptRv/5vX3XaMCpK9LB75kb4/6DTTtdHM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=srvP4yGG1HspSOKxQxAH/ibdwhh3NmHFoStAa9cCpSRKShqFgROY52bG4ULtxxOIv
	 FIm0Cqe4c5goDhP7TSJUer2VXpVyvi2DLFfAfCvcoTcIENUOZJfTXrC3evE9L8q55+
	 mcZsdUywTuAWw8F9JQxodLZlDuySHu/EtJAU5xJ4=
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
Subject: [PATCH AUTOSEL 5.1 140/141] mm: use down_read_killable for locking mmap_sem in access_remote_vm
Date: Fri, 19 Jul 2019 00:02:45 -0400
Message-Id: <20190719040246.15945-140-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040246.15945-1-sashal@kernel.org>
References: <20190719040246.15945-1-sashal@kernel.org>
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
index ab650c21bccd..57402801ab09 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4260,7 +4260,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
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
index 749276beb109..1bd91ceadc82 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1777,7 +1777,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
-- 
2.20.1

