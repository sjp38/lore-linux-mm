Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 163BCC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5CB92087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:07:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5CB92087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E48A8E0004; Tue, 12 Mar 2019 10:07:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E3C8E0002; Tue, 12 Mar 2019 10:07:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30FB98E0004; Tue, 12 Mar 2019 10:07:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 024268E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:07:03 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id e1so1840456iod.23
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:07:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=NaBtJgawskgtSE2C79DuuPgvmqp5bcBIDor0kEeBUEs=;
        b=nfanunBOthBN5t4MZE/Zge2ko+AKBneYARbJIRsZZuFC14SLG/1IMJZ2p0a3/EmNy1
         zPY7GH742m/wp9rVdpsTf8jJSTydCxOr8ifBB7eH6PAzlfHYfJvxtzxobMMkSYmpgIfQ
         hwR+QmnFvXnXjUya/0cnbBQiUEiwPGCls+Sf6l1LnWxipoeryk4Gq7Kc64xZRGy1qCgF
         ukmbP190UwA+Jd61rvO7seYfE5AIDL/2iaIZPlwnb3P3/pjTF5UUPVdpsM/NzIH0Mvum
         f/X56kiDU/EVU2oMFcJdFVfyp0FOdILFk7meisytTm2b7x20yTeVr9GDJKzBkDdz6NCa
         9LSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAVFNGWFEYXigGQNWzvDZinsViqnS9vw6hv97n7J2BSlPYzgLLJE
	HX5G86DXLqmFfdPtzFN6rBjzKZ/VfOWmF2hGCN6FSvFnc4SDpmV+Rae9Q8R22j7VG+FuKJ2BzKE
	cg9SVG2K20AFsyXHeQQ2d6l2j9KHla+aKbJo7Q6kPecBLFOrVR/TTfBwUsXTTWNn1nA==
X-Received: by 2002:a24:ee8c:: with SMTP id b134mr2061245iti.7.1552399622200;
        Tue, 12 Mar 2019 07:07:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0mL5MLmOTdtFrvZUfWAdFpmE7wOYMP+0IK47wORQUVUAEL9H8JeMQZPTfIMN5vBQK+48I
X-Received: by 2002:a24:ee8c:: with SMTP id b134mr2061182iti.7.1552399621075;
        Tue, 12 Mar 2019 07:07:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552399621; cv=none;
        d=google.com; s=arc-20160816;
        b=Yy0J5jWa9a0s8pXzxNLt3LxXKIrICkuAkziKBben30/muJGQkT8YKmc24qyqntOpC0
         tAtWDKjzMGUBM+/wh0GxJm7PdXT+uQF7KPUds+aKJtzUesNICXJtO9Ly4Am8cqfX+qVr
         qWxcW7A97zUBMrsUuakJUNORSC8+pXe3rhGDv0tkzipVoJ3/cfnL636pK8QYgbIwzozb
         Ll4rkqU2i7pKgYgmc1AGWty9+UhnEduMvvfmjgiOXvHfY/RSUm1GrSQPqdet12+E5ID4
         f32L+6Umn45ymJ/A/d3dXf2BblBlGF9099QqntJ2X8Fq0kQjhm13K6AndXqRqv4Xgdkt
         gZqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=NaBtJgawskgtSE2C79DuuPgvmqp5bcBIDor0kEeBUEs=;
        b=mT8BorUlbu5kFnSbrPVv63s2DZ22hmPR2vHdI9q7FHlcEw9hJwWAl7v+CitVfq/gWj
         MAkNyS7MJUbXSvDW86E8zoLgRqSGgR7LbrtpibuXnrS8vHTTblpgBYrjKk07OSyER/22
         FAGewYOgR43uRUFmOQdimJYGUGJglKrZOCtcBHM9FNYwJMPDs9bBcEdWC+mEVy8xZHOq
         h/CNWVnb7YXuKrsDBb+m579HlPPqsEK9x0BeiMhkPSkhfwmNQM/jqoHaO/N5McTniXpT
         a1uDuQ42bpt34FY8DILtOgiW/9WIyYlQAoD3i5+v0LFDIw3fmgqnIBI0jb8oBDrTCDIg
         giIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b25si4328164jaq.39.2019.03.12.07.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 07:07:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav304.sakura.ne.jp (fsav304.sakura.ne.jp [153.120.85.135])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2CE6dW3001504;
	Tue, 12 Mar 2019 23:06:39 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav304.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp);
 Tue, 12 Mar 2019 23:06:38 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2CE6Yql001468
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 12 Mar 2019 23:06:38 +0900 (JST)
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
 <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
 <20190311103012.GB5232@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d9b49a08-5d5a-ec4a-7cb7-c268999a9906@i-love.sakura.ne.jp>
Date: Tue, 12 Mar 2019 23:06:33 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190311103012.GB5232@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/03/11 19:30, Michal Hocko wrote:
> On Sat 09-03-19 15:02:22, Tetsuo Handa wrote:
>> Since a thread which succeeded to hold oom_lock must not involve blocking
>> memory allocations, teach lockdep to consider that blocking memory
>> allocations might wait for oom_lock at as early location as possible, and
>> teach lockdep to consider that oom_lock is held by mutex_lock() than by
>> mutex_trylock().
> 
> This is still really hard to understand. Especially the last part of the
> sentence. The lockdep will know that the lock is held even when going
> via trylock. I guess you meant to say that
> 	mutex_lock(oom_lock)
> 	  allocation
> 	    mutex_trylock(oom_lock)
> is not caught by the lockdep, right?

Right.

> 
>> Also, since the OOM killer is disabled until the OOM reaper or exit_mmap()
>> sets MMF_OOM_SKIP, teach lockdep to consider that oom_lock is held when
>> __oom_reap_task_mm() is called.
> 
> It would be good to mention that the oom reaper acts as a guarantee of a
> forward progress and as such it cannot depend on any memory allocation
> and that is why this context is marked. This would be easier to
> understand IMHO.

OK. Here is v3 patch.

From 250bbe28bc3e9946992d960bb90a351a896a543b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 12 Mar 2019 22:58:41 +0900
Subject: [PATCH v3] mm,oom: Teach lockdep about oom_lock.

Since a thread which succeeded to hold oom_lock must not involve blocking
memory allocations, teach lockdep to consider that blocking memory
allocations might wait for oom_lock at as early location as possible.

Lockdep can't detect possibility of deadlock when mutex_trylock(&oom_lock)
failed, for we assume that somebody else is still able to make a forward
progress. Thus, teach lockdep to consider that mutex_trylock(&oom_lock) as
mutex_lock(&oom_lock).

Since the OOM killer is disabled when __oom_reap_task_mm() is in progress,
a thread which is calling __oom_reap_task_mm() must not involve blocking
memory allocations. Thus, teach lockdep about that.

This patch should not cause lockdep splats unless there is somebody doing
dangerous things (e.g. from OOM notifiers, from the OOM reaper).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h | 12 ++++++++++++
 mm/oom_kill.c       | 28 +++++++++++++++++++++++++++-
 mm/page_alloc.c     | 16 ++++++++++++++++
 3 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index d079920..04aa46b 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -56,6 +56,18 @@ struct oom_control {
 
 extern struct mutex oom_lock;
 
+static inline void oom_reclaim_acquire(gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_DIRECT_RECLAIM)
+		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
+}
+
+static inline void oom_reclaim_release(gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_DIRECT_RECLAIM)
+		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
+}
+
 static inline void set_current_oom_origin(void)
 {
 	current->signal->oom_flag_origin = true;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a24848..6f53bb6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -513,6 +513,14 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	 */
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
+	/*
+	 * Since this function acts as a guarantee of a forward progress,
+	 * current thread is not allowed to involve (even indirectly via
+	 * dependency) __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation from
+	 * this function, for such allocation will have to wait for this
+	 * function to complete when __alloc_pages_may_oom() is called.
+	 */
+	oom_reclaim_acquire(GFP_KERNEL);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
@@ -544,6 +552,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			tlb_finish_mmu(&tlb, range.start, range.end);
 		}
 	}
+	oom_reclaim_release(GFP_KERNEL);
 
 	return ret;
 }
@@ -1120,8 +1129,25 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
+	if (!mutex_trylock(&oom_lock)) {
+		/*
+		 * This corresponds to prepare_alloc_pages(). Lockdep will
+		 * complain if e.g. OOM notifier for global OOM by error
+		 * triggered pagefault OOM path.
+		 */
+		oom_reclaim_acquire(GFP_KERNEL);
+		oom_reclaim_release(GFP_KERNEL);
 		return;
+	}
+	/*
+	 * Teach lockdep to consider that current thread is not allowed to
+	 * involve (even indirectly via dependency) __GFP_DIRECT_RECLAIM &&
+	 * !__GFP_NORETRY allocation from this function, for such allocation
+	 * will have to wait for completion of this function when
+	 * __alloc_pages_may_oom() is called.
+	 */
+	oom_reclaim_release(GFP_KERNEL);
+	oom_reclaim_acquire(GFP_KERNEL);
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d0fa5b..c23ae76d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3793,6 +3793,14 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
+	/*
+	 * Teach lockdep to consider that current thread is not allowed to
+	 * involve (even indirectly via dependency) __GFP_DIRECT_RECLAIM &&
+	 * !__GFP_NORETRY allocation from this context, for such allocation
+	 * will have to wait for this function to complete.
+	 */
+	oom_reclaim_release(gfp_mask);
+	oom_reclaim_acquire(gfp_mask);
 
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
@@ -4651,6 +4659,14 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 	fs_reclaim_acquire(gfp_mask);
 	fs_reclaim_release(gfp_mask);
 
+	/*
+	 * Since __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation might call
+	 * __alloc_pages_may_oom(), teach lockdep to record that current thread
+	 * might forever retry until holding oom_lock succeeds.
+	 */
+	oom_reclaim_acquire(gfp_mask);
+	oom_reclaim_release(gfp_mask);
+
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-- 
1.8.3.1

