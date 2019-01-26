Return-Path: <SRS0=Pe7y=QC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC419C282C7
	for <linux-mm@archiver.kernel.org>; Sat, 26 Jan 2019 13:11:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F7AC21872
	for <linux-mm@archiver.kernel.org>; Sat, 26 Jan 2019 13:11:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F7AC21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F058A8E00FA; Sat, 26 Jan 2019 08:11:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDCC68E00F9; Sat, 26 Jan 2019 08:11:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF2878E00FA; Sat, 26 Jan 2019 08:11:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id B643D8E00F9
	for <linux-mm@kvack.org>; Sat, 26 Jan 2019 08:11:11 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t83so6104403oie.16
        for <linux-mm@kvack.org>; Sat, 26 Jan 2019 05:11:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Hsx9krwA9P8nQNKjs4bhZ+Iq/VrFfAd1tSDsq96+7Po=;
        b=GB3xx5kIEhGUOGsSZGyt24/iRWT55237CqbQUv7k/oSaY+f03AG4v/+gjhr5s7t6R3
         NyTsyEtYejMEwQLFc/bNZQRsVjYneWEwwwMpDrC5Q13uu/CC4CX1THUpQuI7uI8Ydcva
         k2o+xTgKzdFEgPIWWHjB5syCu6YcxPNuoMtgTgSr8t/3dsHeC0ZaCmYkHu4HrW3LWwLw
         yBBG6eTVMXihHVHIsVWAfwzIDrU4Z26IxsnZWHSLi/V+Ru2sFmPAiCzK20HDcLX+5Rxx
         352Y2e6I5teBcfZjhRZALLfVrh/V298TFQ9L8vZZsK611sQ0STPMr2R6MwvKMZbdFS7z
         GhiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuYGxPCeQmvtvhTS4FBTWbY8M+ue6/15ZutmIoiOeJdVFDw3R480
	rzD32ZN0exx4rw6r5n7SV3BXO19HXV4lcgyjV339TY9TQpMy5Z/RdkSqIT+ExsHwuUVlNWdByRI
	xBazSVFl2CC6wXTFzmmoS6ubymiI5Sxyvf5pEISBsyehH6ErabPWFS04CFiCZJCBOkA==
X-Received: by 2002:aca:e386:: with SMTP id a128mr948516oih.79.1548508271336;
        Sat, 26 Jan 2019 05:11:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6fF6GzCwq4I86EVXS8ZV+OGwe0ZbGhvTS1WBl0YAcWtE3sd5ESGJUSR6+Q5uf0ciefspvL
X-Received: by 2002:aca:e386:: with SMTP id a128mr948483oih.79.1548508270390;
        Sat, 26 Jan 2019 05:11:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548508270; cv=none;
        d=google.com; s=arc-20160816;
        b=Zc+LtQAIeaPBG4QDaeCo/poFTVYtuITm0UE2jZPd+qf7sig+KTy/ByYP4Q1bt57i8Z
         aYFEDhqlfQLiNnWYTZXYNdGWwFs4jCEAiSPlsFG03BCg/+ahc7noEPUrB3RZyaJo5aei
         pk3PdQ0k5jMNFFjaDMScG40FOka05dQntck6u/HKqoUeF/lPu3l9j4T0+ZYCh7FUxK5o
         PJfwJduqh+IAxf0FtRESexmUY5IhKEbMhnSZvehT5LZB8Mtlc4rB6rLuReW+ZBpZebca
         uc0KhKHPp9GfNSfI27pkXBCMaGWF3ADpvJB0Xv3H9AT+sVj3+O6I70wgFkdNXnJFdyt5
         TfRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Hsx9krwA9P8nQNKjs4bhZ+Iq/VrFfAd1tSDsq96+7Po=;
        b=YiLGWrA9SMAHGj2iQzxk2ORsXjR62GiX82U4UTWMramGM1PhUiUIDFNTAea7A+AOTN
         iDi4azGANYzJ55ADjCnbWoymcjMAawwP2mbxdt6lqHupLBWWlkFiQ0cwtDD3KU3FikDP
         sAbxTF11cAYV+zwxd4T7c+05dgFyf+GAu3Z+1hW5JEZekGJgWdKHFdKJraJURD7RYpSW
         5DKLfdMD2EIqCpW/WOaDJbxuq/o8pRN+BXc/BXbEO3wmVvyKFAugj/uQqo+hk0NXzsfS
         TxgvYiA2n+6qwiDzIOsSBqRRNXyUrlAuBLeInAZCKnJoNPsYyHqV5dd80+ZchI5WHEkH
         7Kdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q205si2625807oib.203.2019.01.26.05.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Jan 2019 05:11:10 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav110.sakura.ne.jp (fsav110.sakura.ne.jp [27.133.134.237])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0QDAwU1056613;
	Sat, 26 Jan 2019 22:10:58 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav110.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav110.sakura.ne.jp);
 Sat, 26 Jan 2019 22:10:58 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav110.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0QDAqKU056376
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 26 Jan 2019 22:10:57 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: [PATCH v2] oom, oom_reaper: do not enqueue same task twice
To: =?UTF-8?Q?Arkadiusz_Mi=c5=9bkiewicz?= <a.miskiewicz@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org,
        Aleksa Sarai <asarai@suse.de>, Jay Kamat <jgkamat@fb.com>,
        Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
        Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-mm <linux-mm@kvack.org>
References: <df806a77-3327-9db5-8be2-976fde1c84e5@gmail.com>
 <20190117122535.njcbqhlmzozdkncw@mikami>
 <1d36b181-cbaf-6694-1a31-2f7f55d15675@gmail.com>
 <96ef6615-a5df-30af-b4dc-417a18ca63f1@gmail.com>
 <1cdbef13-564d-61a6-95f4-579d2cad243d@gmail.com>
 <20190125163731.GJ50184@devbig004.ftw2.facebook.com>
 <a95d004a-4358-7efc-6d21-12aac4411b32@gmail.com>
 <480296c4-ed7a-3265-e84a-298e42a0f1d5@I-love.SAKURA.ne.jp>
 <6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
 <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
Date: Sat, 26 Jan 2019 22:10:52 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190126131052.6gJrKtIQoKnpiLufUmpzm8Mg5-_tM9syO8M-QEw0g7Q@z>

On 2019/01/26 20:29, Arkadiusz Miśkiewicz wrote:
> On 26/01/2019 12:09, Tetsuo Handa wrote:
>> Arkadiusz, will you try this patch?
> 
> 
> Works. Several tries and always getting 0 pids.current after ~1s.
> 

Thank you for testing.

I updated this patch to use tsk->signal->oom_mm (a snapshot of
tsk->mm saved by mark_oom_victim(tsk)) rather than raw tsk->mm
so that we don't need to worry about possibility of changing
tsk->mm across multiple wake_oom_reaper(tsk) calls.



From 9c9e935fc038342c48461aabca666f1b544e32b1 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 26 Jan 2019 21:57:25 +0900
Subject: [PATCH v2] oom, oom_reaper: do not enqueue same task twice

Arkadiusz reported that enabling memcg's group oom killing causes
strange memcg statistics where there is no task in a memcg despite
the number of tasks in that memcg is not 0. It turned out that there
is a bug in wake_oom_reaper() which allows enqueuing same task twice
which makes impossible to decrease the number of tasks in that memcg
due to a refcount leak.

This bug existed since the OOM reaper became invokable from
task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
but memcg's group oom killing made it easier to trigger this bug by
calling wake_oom_reaper() on the same task from one out_of_memory()
request.

Fix this bug using an approach used by commit 855b018325737f76
("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task").
As a side effect of this patch, this patch also avoids enqueuing
multiple threads sharing memory via task_will_free_mem(current) path.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
Tested-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
Fixes: af8e15cc85a25315 ("oom, oom_reaper: do not enqueue task if it is on the oom_reaper_list head")
---
 mm/oom_kill.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9..057bfee 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -505,14 +505,6 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	bool ret = true;
 
-	/*
-	 * Tell all users of get_user/copy_from_user etc... that the content
-	 * is no longer stable. No barriers really needed because unmapping
-	 * should imply barriers already and the reader would hit a page fault
-	 * if it stumbled over a reaped memory.
-	 */
-	set_bit(MMF_UNSTABLE, &mm->flags);
-
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
@@ -647,8 +639,13 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	/*
+	 * Tell all users of get_user/copy_from_user etc... that the content
+	 * is no longer stable. No barriers really needed because unmapping
+	 * should imply barriers already and the reader would hit a page fault
+	 * if it stumbled over a reaped memory.
+	 */
+	if (test_and_set_bit(MMF_UNSTABLE, &tsk->signal->oom_mm->flags))
 		return;
 
 	get_task_struct(tsk);
-- 
1.8.3.1

