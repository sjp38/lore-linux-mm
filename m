Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9545AC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 11:25:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45FC220828
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 11:25:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45FC220828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CB446B0003; Sat, 29 Jun 2019 07:25:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87A558E0003; Sat, 29 Jun 2019 07:25:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7911B8E0002; Sat, 29 Jun 2019 07:25:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f206.google.com (mail-pg1-f206.google.com [209.85.215.206])
	by kanga.kvack.org (Postfix) with ESMTP id 433486B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 07:25:12 -0400 (EDT)
Received: by mail-pg1-f206.google.com with SMTP id u4so838503pgb.20
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 04:25:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=bcptAn60yozY9FO9Bsz3DV1ARxK/t4vX2HlD6mBoQAs=;
        b=oohKzahvV7JQTCdShieh9vb/DKOeKnNIHoRDT95V3zABIFAk6bfT+daL0zBqOXJ64l
         ffvCER/QHqaX4SJN753fajeCvzUbKSHwwSwmQn4nds7GnKWX1T9fXmA56uQXanuzY918
         Ts9JVThYUqcJ31nTzQCUt1sNMvdbZB1gBveje4vag2Uq2Ubjg3RUKY6TH/cRwRCfPJSr
         CGdYgDKhZnJrX75YZ8NVNXs2AntJ8c9QE1wFxjIQM98IyzmoUnPGT0vMRVpLF5noUbfK
         +iVSjlC30EnwzohXxLyjQCzo7qI/uSUQjYshAPEIygaRdeiOpIyrQzsEOstqgJE9zqwf
         olUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXxKDFXGTcaq3I8i7URLjNemAYDUxP2UTDfTcavzCI/iLKUdX/l
	NgZcbFYj4us0BpGw4YG7Zy1dLFal7YPve6mjvtat7LMezJv7022cI5G8KKpmqUS8VAzqwBbx+Fb
	82lF4De22mfSPYqvCW4sggcBobLps+u8+kT+CEgJjTba9WvJiGO4i/uqIPgk0nmJx5g==
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr16443298plb.316.1561807511824;
        Sat, 29 Jun 2019 04:25:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkd59q09sXvIfKd1o1s3gP9W11sfO7vtNom++OjGeR5t3pyQhJ9JxkOGgNcKDUWbxplq5o
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr16443231plb.316.1561807510721;
        Sat, 29 Jun 2019 04:25:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561807510; cv=none;
        d=google.com; s=arc-20160816;
        b=Hg4DaYFHhDpznnBXL5AqqTBztUcuWaJxQzMeCsgydOdOy1i9gmEFtlHOkqERERk3Bj
         KMAxhuKVKf25xcbyspstz39JjYXCVGUmoFAJ3pnDitqd9ynsyBN0jxiwu98xcBjQoCdW
         0xhtrAVXqWvA0Eiyw1EZ3/FjdQqrtZWhe9yBKYbPvoTAnIwtwzlKROhNG6BwQwMA7Mfm
         Ao565OYLYYNNO8/3OApMbFKxtmCO2+dK/c82dOC7qMGEKMKb6hH7dR+j9Npcr7zPsSJ/
         NI3CqHBJZmiOTL5exS+ZTSmoVlzzifahX0mLpsgA5ztCo67nDp07teo0AgAsTgZqNr3d
         2xaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=bcptAn60yozY9FO9Bsz3DV1ARxK/t4vX2HlD6mBoQAs=;
        b=LWwOdIdxy1pHcScVlFI13CHKwS92Nz+6DAmtuhGJy73xnNP9Sks1roi3k32bZ6SswR
         yd4GnYYZROF2jfvlfer05bZ+QJ4nruHhrp91sWZqa72MoMgOkDTRdFo7/rRUBRNatAfl
         jeuzYgu6AkVzQYTs3CY/FyPah5LRrkVblMvXXanwosVS5JoGZzoBhWUiv0ptKFciBCgf
         oA1wMWA4cdhYy7A6HQjPKjlVTqT9NQ0t3o1jH3nL/n8JnWD5gKSwAMuksm8drmzO3d/G
         QyclXKx6lf67irRQm4aVDdxNL1SC8CMHzhoFfD/jbE1GbmnPxVkgv16DHUGazoSfmzdb
         O+jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p125si5293888pfp.35.2019.06.29.04.25.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 04:25:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav304.sakura.ne.jp (fsav304.sakura.ne.jp [153.120.85.135])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5TBOlxC054115;
	Sat, 29 Jun 2019 20:24:47 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav304.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp);
 Sat, 29 Jun 2019 20:24:47 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5TBOgA9054083
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Sat, 29 Jun 2019 20:24:47 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Date: Sat, 29 Jun 2019 20:24:34 +0900
Message-Id: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since mpol_put_task_policy() in do_exit() sets mempolicy = NULL,
mempolicy_nodemask_intersects() considers exited threads (e.g. a process
with dying leader and live threads) as eligible. But it is possible that
all of live threads are still ineligible.

Since has_intersects_mems_allowed() returns true as soon as one of threads
is considered eligible, mempolicy_nodemask_intersects() needs to consider
exited threads as ineligible. Since exit_mm() in do_exit() sets mm = NULL
before mpol_put_task_policy() sets mempolicy = NULL, we can exclude exited
threads by checking whether mm is NULL.

While at it, since mempolicy_nodemask_intersects() is called by only
has_intersects_mems_allowed(), it is guaranteed that mask != NULL.

BTW, are there processes where some of threads use MPOL_{BIND,INTERLEAVE}
and the rest do not use MPOL_{BIND,INTERLEAVE} ? If no, we can use
find_lock_task_mm() instead of for_each_thread() for mask != NULL case
in has_intersects_mems_allowed().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/mempolicy.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 01600d8..938f0a0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1974,11 +1974,10 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 					const nodemask_t *mask)
 {
 	struct mempolicy *mempolicy;
-	bool ret = true;
+	bool ret;
 
-	if (!mask)
-		return ret;
 	task_lock(tsk);
+	ret = tsk->mm;
 	mempolicy = tsk->mempolicy;
 	if (!mempolicy)
 		goto out;
-- 
1.8.3.1

