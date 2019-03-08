Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 774F2C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 10:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C89FA20854
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 10:22:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C89FA20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 207AE8E0003; Fri,  8 Mar 2019 05:22:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B81B8E0002; Fri,  8 Mar 2019 05:22:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0804D8E0003; Fri,  8 Mar 2019 05:22:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4EB08E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 05:22:11 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id r22so8654183otk.1
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 02:22:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=FD1pJYODPvgXV6JjF7n2NNPq8Fq0qci4uHC6jTHSpZA=;
        b=dfVgYjRrehdmUK46ToVNLzLS8G/kzngP+SYycRwZfgOYzRgK/FC+S2hC54y2TWVT6U
         j76EF6rB3H8hPMFLjEILY+Ndv+nXXk0djeAon9TEJpL3Uuj67aNnHBJuy5XQCNrMlP8q
         NeRZTr7Q+CmYx4MdUmRPo1vpPssBLwH3EFW+6eoxFuWhAPAvQtCYPYsJ8MihOzqse+29
         7YF0ufNdPoGYax9DBXRzXw0GMfcrDtQINYnb0pj5kser1WxUjOqYwrp2hMW2yygXRSdC
         B2NuobDJn649tO0PmaHqMTx3y/JnLzGHhXsZNvKRJTQIey8BNS81z0n6Xtyb0E9ybr6u
         3aQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUjLrXDYkIFQms+kCxAh4kpBtzbgI+XxqCZ4S5W4PkCxofqG3v+
	SpCOfC4FQ+nfmrAv01Xp6cPG2i77Jp5OuvE/OiOnMuHPLcnc58/EPaoTwHLYKzzYpzr0o9aM/pv
	GKQJlKtqXWSOoIqPWJjX3A0wfV79kg3zrUVbDqNcumH4+bN6tjaxIZFCWXIp1UrP0sA==
X-Received: by 2002:a9d:66c8:: with SMTP id t8mr10513684otm.368.1552040531372;
        Fri, 08 Mar 2019 02:22:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqwP1VNyLk73or4NELu4jhiDhQD3tOg6oUD63LL6/f20rl3vfNxnyeorAvyYHXx1lCbwYlZn
X-Received: by 2002:a9d:66c8:: with SMTP id t8mr10513646otm.368.1552040529852;
        Fri, 08 Mar 2019 02:22:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552040529; cv=none;
        d=google.com; s=arc-20160816;
        b=cQ3t4xPMA0T7D0tzTj9Yg2LrLiVYtaqecnjYtSUdz4tEZcjumU+VuTqCkZ6cnNKW3L
         xcTB5jzxva8MCNNkTsI3SLOTz8sWDhZ1Jx3H4WFcNZyXp/MSyX/VbB3o/sO9N9zzr4J2
         JPLRwL1mAe/+ZRHPG8saikQMAgGb/aEl5wpmxvJlrkX9bXCkiedUtsNXVjTIcdSd5TxR
         MSug0XQj9IwI8MfFTNwtHn6SozphwmJKCi/NSohuuk7H7EFsqmXguPrPTInDDkR5B4sj
         heMhmH6XKMFIrDK759UWlmD0wzToWTnvBER9tqOFzUo+lSfGKlOUOZP5xiiQoaD3KFzv
         eLeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=FD1pJYODPvgXV6JjF7n2NNPq8Fq0qci4uHC6jTHSpZA=;
        b=kKH5oYnyjoBV1PAo4sma+J7nUK3eKq/J6bIOuyBdvpb9XpfZCwdvOQNy1UHkq9Fx0h
         d8Vhf+XQJvBzzIgiSUCEK+RagzTVs8tUc6PMrin5ol1GJbQYThGmY2jafyR2GpW13qEA
         kIfDFo+hoFipKO+A+7+a/TrLmO7vhVi8FPzXurMFtKVgzbvoGoz6o4ATc2UMvOF/PI+/
         mU4FHE4/wkUG+4DDbCnm4XWwU48xaZCU3hyTMrcNb85EMwsNLd5hbIQei12+zMjz6fNz
         0OyRFYc4LxddllOM8AGQlSYhxCagjAH7j/UXCM/4sFet/0pY58cZAfUZUcZDK4gwxHkn
         zBwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t185si2980784oib.8.2019.03.08.02.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 02:22:09 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav106.sakura.ne.jp (fsav106.sakura.ne.jp [27.133.134.233])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x28AM2gi001113;
	Fri, 8 Mar 2019 19:22:02 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav106.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp);
 Fri, 08 Mar 2019 19:22:02 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x28ALwdI001079
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 8 Mar 2019 19:22:02 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Teach lockdep about oom_lock.
Date: Fri,  8 Mar 2019 19:22:02 +0900
Message-Id: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since we are not allowed to depend on blocking memory allocations when
oom_lock is already held, teach lockdep to consider that blocking memory
allocations might wait for oom_lock at as early location as possible, and
teach lockdep to consider that oom_lock is held by mutex_lock() than by
mutex_trylock().

Also, since the OOM killer is disabled until the OOM reaper or exit_mmap()
sets MMF_OOM_SKIP, teach lockdep to consider that oom_lock is held when
__oom_reap_task_mm() is called.

This patch should not cause lockdep splats unless there is somebody doing
dangerous things (e.g. from OOM notifiers, from the OOM reaper).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c   |  9 ++++++++-
 mm/page_alloc.c | 13 +++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a24848..759aa4e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -513,6 +513,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	 */
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
+	mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
@@ -544,6 +545,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			tlb_finish_mmu(&tlb, range.start, range.end);
 		}
 	}
+	mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
 
 	return ret;
 }
@@ -1120,8 +1122,13 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
+	if (!mutex_trylock(&oom_lock)) {
+		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
+		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
 		return;
+	}
+	mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
+	mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d0fa5b..25533214 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3793,6 +3793,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
+	mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
+	mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
 
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
@@ -4651,6 +4653,17 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 	fs_reclaim_acquire(gfp_mask);
 	fs_reclaim_release(gfp_mask);
 
+	/*
+	 * Allocation requests which can call __alloc_pages_may_oom() might
+	 * fail to bail out due to waiting for oom_lock.
+	 */
+	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !(gfp_mask & __GFP_NORETRY) &&
+	    (!(gfp_mask & __GFP_RETRY_MAYFAIL) ||
+	     order <= PAGE_ALLOC_COSTLY_ORDER)) {
+		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
+		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
+	}
+
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-- 
1.8.3.1

