Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31FF8C43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 06:03:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8A48207E0
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 06:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8A48207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F23B8E0003; Sat,  9 Mar 2019 01:03:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A0108E0002; Sat,  9 Mar 2019 01:03:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5696A8E0003; Sat,  9 Mar 2019 01:03:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3C28E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 01:03:07 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 42so10071692otv.5
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 22:03:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FbF7MD3z/nKCy7zZ9y6+lRpsICZtKDbZ9LDcq7g1BN4=;
        b=klZE7D2ItW8oOLcla7q07R8qFDe5gj3BO4LfZPAEq+VgbH5c28EckV9n6VtqpwUpKc
         PS0Q6SqeSrdsQDMaQQWouj992VfLFWXEbMZKWAr13/BL6eed+MIPPp75OBw+2bBR90ul
         /DajQ1Nha4NPmqg1PNB79AvCu4aVNGUp6PExTBRbLfU/lsOx5caVIwP3ZTxo2NBQJhl7
         C3e+u8jntTbyYGw4n47dG7nX6efEw40FTtr/NIcbZ5J2CzPHPFBsLIKClJPGJS/pBv5i
         1zelHpyj82qs8/g6E1TR59LibWEcgWJldm4X9Z9IvOqJj6XQ+qh/U/Kzd3XzQDeWaHHt
         dVqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXgcuzfJCYZIcMaKYF353dCJ4Pw/phgGoTq9XDrRneaftM35Shf
	4OEaV9ol0jfIyDyR6KFHnp5ud5llNTRP5FuT2P9Xjiq+44xGTka3Jcvn4RCfI1qLPjG6yzNKkSA
	9Vf11qku8SiVz2SSA50MVV/mK1S25jA4KPrlSBPeAQMh4oNHYdCO6D7kzIlzOYbsW0w==
X-Received: by 2002:a9d:51c9:: with SMTP id d9mr14450502oth.94.1552111386705;
        Fri, 08 Mar 2019 22:03:06 -0800 (PST)
X-Google-Smtp-Source: APXvYqwWUC6u9eaii7486wHlVo6TzJ2bEGFzH3qQoYotDLPExRyCtVou3NaWQ93PWENNYseUtdBF
X-Received: by 2002:a9d:51c9:: with SMTP id d9mr14450453oth.94.1552111385584;
        Fri, 08 Mar 2019 22:03:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552111385; cv=none;
        d=google.com; s=arc-20160816;
        b=d6VtrEcV44jhF+bk5Yd+4fYNbsI+pcAXIThDqFFJl0+PfgEHVVon5AVCY8UN94jFeP
         OH+6D8r3bhbIPy/0JCPJYgPQDd1//arX+ViDEiX5cvzH9TVkY/NoEga2J/M7BIUM0wLw
         Ad57stAGq09/TriWq3MyR8ZBCBKS0KJgy40/sJZpYqQ/GRZUFYaxPtzBVkVwbSEIEpAu
         NCMmezr9n+glqeJDx9ByXxt6p5jPb2hM37Hxt1tbKKulWNSHHqF/yJmOXDpBB9q7Jzo/
         GNl0sy4UMJt+Qe4R9taLnI7ARdormSKNhl7VWrIM8ZMY9PaNIxjZj0qFu1zkmsi8F/yv
         dPIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FbF7MD3z/nKCy7zZ9y6+lRpsICZtKDbZ9LDcq7g1BN4=;
        b=Cqjp0C5uq8crTH/FW3sbHx+6rWBsDK/fG7ZL4uzpHB4aA5zB19Djs0C5c9vRRs+LSd
         n4iZTYg6/N6xqpdPNDuiCib0MvkgPjHdIAYzUDlTTbxMzYkZ5JLnjR05eOiFxaSRdnGB
         tb8XXI2a77o7aX/8EaZ+NqReAH1njtBZW2XShAPtLhtP6iext6Zts0PeQEa+IsO+7Sa4
         eQB92fLENgKm8GN7sY/r8RiI4MsAjz5KV0P0PJGjnXtPXRJIilmGnSpe9iuqFo0VcGHc
         NwRzDBvHNTEK5mOl629ADEqX0oCC+FW8NExFz8eATJrs//+LnrL8e2oTA7lhE9bXdLph
         xXhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f30si4089271otb.274.2019.03.08.22.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 22:03:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav404.sakura.ne.jp (fsav404.sakura.ne.jp [133.242.250.103])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2962WCG079986;
	Sat, 9 Mar 2019 15:02:32 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav404.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp);
 Sat, 09 Mar 2019 15:02:32 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2962NfU079894
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 9 Mar 2019 15:02:32 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org,
        linux-mm@kvack.org
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz> <20190308115802.GJ5232@dhcp22.suse.cz>
 <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
 <20190308151327.GU5232@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
Date: Sat, 9 Mar 2019 15:02:22 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190308151327.GU5232@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/03/08 20:58, Michal Hocko wrote:
> OK, that makes sense to me. I cannot judge the implementation because I
> am not really familiar with lockdep machinery. Could you explain how it
> doesn't trigger for all other allocations?

This is same with why fs_reclaim_acquire()/fs_reclaim_release() doesn't trigger
for all other allocations. Any allocation request which might involve __GFP_FS
reclaim passes "struct lockdep_map __fs_reclaim_map", and lockdep records it.

>
> Also why it is not sufficient to add the lockdep annotation prior to the
> trylock in __alloc_pages_may_oom?

This is same with why fs_reclaim_acquire()/fs_reclaim_release() is called from
prepare_alloc_pages(). If an allocation request which might involve __GFP_FS
__perform_reclaim() succeeded before actually calling __perform_reclaim(), we
fail to pass "struct lockdep_map __fs_reclaim_map" (which makes it difficult to
check whether there is possibility of deadlock). Likewise, if an allocation
request which might call __alloc_pages_may_oom() succeeded before actually
calling __alloc_pages_may_oom(), we fail to pass oom_lock.lockdep_map (which
makes it difficult to check whether there is possibility of deadlock).

Strictly speaking, there is

	if (tsk_is_oom_victim(current) &&
	    (alloc_flags == ALLOC_OOM ||
	     (gfp_mask & __GFP_NOMEMALLOC)))
		goto nopage;

case where failing to hold oom_lock at __alloc_pages_may_oom() does not
cause a problem. But I think that we should not check tsk_is_oom_victim()
at prepare_alloc_pages().

> It would be also great to pull it out of the code flow and hide it
> behind a helper static inline. Something like
> lockdep_track_oom_alloc_reentrant or a like.

OK. Here is v2 patch.



From ec8d0accf15b4566c065ca8c63a4e1185f0a0c78 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 9 Mar 2019 09:55:08 +0900
Subject: [PATCH v2] mm,oom: Teach lockdep about oom_lock.

Since a thread which succeeded to hold oom_lock must not involve blocking
memory allocations, teach lockdep to consider that blocking memory
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
 include/linux/oom.h | 16 ++++++++++++++++
 mm/oom_kill.c       |  9 ++++++++-
 mm/page_alloc.c     |  5 +++++
 3 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index d079920..8544c23 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -56,6 +56,22 @@ struct oom_control {
 
 extern struct mutex oom_lock;
 
+static inline void oom_reclaim_acquire(gfp_t gfp_mask, unsigned int order)
+{
+	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !(gfp_mask & __GFP_NORETRY) &&
+	    (!(gfp_mask & __GFP_RETRY_MAYFAIL) ||
+	     order <= PAGE_ALLOC_COSTLY_ORDER))
+		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
+}
+
+static inline void oom_reclaim_release(gfp_t gfp_mask, unsigned int order)
+{
+	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !(gfp_mask & __GFP_NORETRY) &&
+	    (!(gfp_mask & __GFP_RETRY_MAYFAIL) ||
+	     order <= PAGE_ALLOC_COSTLY_ORDER))
+		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
+}
+
 static inline void set_current_oom_origin(void)
 {
 	current->signal->oom_flag_origin = true;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a24848..11be7da 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -513,6 +513,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	 */
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
+	oom_reclaim_acquire(GFP_KERNEL, 0);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
@@ -544,6 +545,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			tlb_finish_mmu(&tlb, range.start, range.end);
 		}
 	}
+	oom_reclaim_release(GFP_KERNEL, 0);
 
 	return ret;
 }
@@ -1120,8 +1122,13 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
+	if (!mutex_trylock(&oom_lock)) {
+		oom_reclaim_acquire(GFP_KERNEL, 0);
+		oom_reclaim_release(GFP_KERNEL, 0);
 		return;
+	}
+	oom_reclaim_release(GFP_KERNEL, 0);
+	oom_reclaim_acquire(GFP_KERNEL, 0);
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d0fa5b..e8853a19 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3793,6 +3793,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
+	oom_reclaim_release(gfp_mask, order);
+	oom_reclaim_acquire(gfp_mask, order);
 
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
@@ -4651,6 +4653,9 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 	fs_reclaim_acquire(gfp_mask);
 	fs_reclaim_release(gfp_mask);
 
+	oom_reclaim_acquire(gfp_mask, order);
+	oom_reclaim_release(gfp_mask, order);
+
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-- 
1.8.3.1

