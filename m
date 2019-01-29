Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 856F9C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4180520869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:34:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4180520869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0D0E8E0002; Tue, 29 Jan 2019 05:34:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBE2A8E0001; Tue, 29 Jan 2019 05:34:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAD2F8E0002; Tue, 29 Jan 2019 05:34:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 932DF8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:34:25 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id k76so10620930oih.13
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:34:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=X0ANd3kr2EJ5r6DJHReQhM3xn4vYjV50f3P1vZBhN+Q=;
        b=kkguvVkFsUhk+mNs0G30nv/JcbTzI9lABInqhQi1RdFUsGgdg/PuFtSY2/ntTyir4Z
         r+htzE79Mh8PQwn8JA0y0G6X9K8faIMM7DYJiCUtXpiBVnFDltG5FuqJlciE7KVlshXP
         v7VSuL8F6t9YPuqHy1w5465AXsRSaez/C42rSf0BfSmYFsaAuoJYOIfAoG1JL+bhzRXu
         C7lhqZ8QHVYYyRyUdHK1l/NmLxyS2YJWVMRZm9DaHecdBpcgugvWKCElO8uGJWtZdPSh
         teTEZHBsRXq95KRzwpMjOZ0RnDw3T5EntTr5j3uOI2/Fvm441+n53kALOW514Y6XaT+E
         bfgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukewGwqaa2o1Z626CT6gwm5YzUOtnGIZvY4VcnakSXYFaJuj3a32
	3na2QbbvWnYofKTMA/caj9dGIbVQr1SFACH3zBdktKMV0UvSn2sY0BYKrmj3TFyJs4I9UKGlVNp
	lrlG5y/hQttcAMj4ne5XqLBneF3doo2cZP0LOtFwXErfdyCJJlSlIY3meElTub7+IZg==
X-Received: by 2002:a9d:2af:: with SMTP id 44mr19592402otl.181.1548758065322;
        Tue, 29 Jan 2019 02:34:25 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Zg3cY5YWxKUqKxhUYBza5XNSADLFKqQes2RK5s1NChjZWik0i/glySz+HUSlFOhJk+XIN
X-Received: by 2002:a9d:2af:: with SMTP id 44mr19592348otl.181.1548758063956;
        Tue, 29 Jan 2019 02:34:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548758063; cv=none;
        d=google.com; s=arc-20160816;
        b=SOiMG7FsfRy7lunMoD1TbGAvsf+anodT9je3t+v8l9TpAD0/D82wd66hBv4xFmNutg
         YiJ+2H/d5THi3vQUMS8g3PpY8usHrJdrcV6pxO2AkGFYegGa5xoMeeurOpmtLxQYA+wU
         w2vT4RJ151XTvGwaWMPMW9GrkCkysnlFs/H0zX1r+bz1/5zsCz6TCyQOBW/c0XIiBtz2
         W4gkWblWRBun0OS12bMA6wa5Q3IJqjMTMTQGOrjUxo6WJ1hJfGEQ/uS7GJkm92lE0kdg
         amMHDRNF6Mwz+LEJhFURdu0BI+VS5r0d0JNebB1lKG0D9j//uV9sJG4rNB6rDuZ1sDt2
         D7mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=X0ANd3kr2EJ5r6DJHReQhM3xn4vYjV50f3P1vZBhN+Q=;
        b=vI30iQjKXEngyuyZBuIr+/3T6rTJn/hSO9v+R7LP58Lk+heL6Ch3gGgYdSVgPk0LrB
         k5rjpuv/y6GqdTjIsPz4moCg0+/o+DwlazKRtl0/wW3Sq68B019pTCHfI0zONukhFGX6
         X9KxWmaZdWfxwnTZZx2nL9w/tfDZEmUkD/mEOGYvPPbksadUnV4dEfmtdK3gVjLK1rf8
         nZpJS3Bs9cCJ/vaRDWPj1jZe11/Cwq0x45AyVLwhjHmBowD7hr43lR41SrAKFzfqoPej
         6JS7TTlEXTEkWw4vEQSe/BwatwPZqPeW7FpqIRNNpOiL6Peeq1YXa4IxRjAZ/itou2xJ
         h2RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w16si6084182otl.261.2019.01.29.02.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 02:34:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav304.sakura.ne.jp (fsav304.sakura.ne.jp [153.120.85.135])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0TAY996049529;
	Tue, 29 Jan 2019 19:34:09 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav304.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp);
 Tue, 29 Jan 2019 19:34:09 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav304.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0TAY4Pw049496
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 29 Jan 2019 19:34:09 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH v3] oom, oom_reaper: do not enqueue same task twice
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>,
        =?UTF-8?Q?Arkadiusz_Mi=c5=9bkiewicz?= <a.miskiewicz@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
        cgroups@vger.kernel.org, Aleksa Sarai <asarai@suse.de>,
        Jay Kamat <jgkamat@fb.com>, Roman Gushchin <guro@fb.com>,
        linux-kernel@vger.kernel.org,
        Linus Torvalds
 <torvalds@linux-foundation.org>,
        linux-mm <linux-mm@kvack.org>
References: <6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
 <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
 <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
 <20190127083724.GA18811@dhcp22.suse.cz>
 <ec0d0580-a2dd-f329-9707-0cb91205a216@i-love.sakura.ne.jp>
 <20190127114021.GB18811@dhcp22.suse.cz>
 <e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
 <20190128215315.GA2011@cmpxchg.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5ee34fc6-1485-34f8-8790-903ddabaa809@i-love.sakura.ne.jp>
Date: Tue, 29 Jan 2019 19:34:00 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190128215315.GA2011@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> On Sun, Jan 27, 2019 at 11:57:38PM +0900, Tetsuo Handa wrote:
> > This bug existed since the OOM reaper became invokable from
> > task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
> > but memcg's group oom killing made it easier to trigger this bug by
> > calling wake_oom_reaper() on the same task from one out_of_memory()
> > request.
> 
> This changelog seems a little terse compared to how tricky this is.
> 
> Can you please include an explanation here *how* this bug is possible?
> I.e. the race condition that causes the function te be entered twice
> and the existing re-entrance check in there to fail.

OK. Here is an updated patch. Only changelog part has changed.
I hope this will provide enough information to stable kernel maintainers.
----------
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: oom, oom_reaper: do not enqueue same task twice

Arkadiusz reported that enabling memcg's group oom killing causes strange
memcg statistics where there is no task in a memcg despite the number of
tasks in that memcg is not 0.  It turned out that there is a bug in
wake_oom_reaper() which allows enqueuing same task twice which makes
impossible to decrease the number of tasks in that memcg due to a refcount
leak.

This bug existed since the OOM reaper became invokable from
task_will_free_mem(current) path in out_of_memory() in Linux 4.7,

  T1@P1     |T2@P1     |T3@P1     |OOM reaper
  ----------+----------+----------+------------
                                   # Processing an OOM victim in a different memcg domain.
                        try_charge()
                          mem_cgroup_out_of_memory()
                            mutex_lock(&oom_lock)
             try_charge()
               mem_cgroup_out_of_memory()
                 mutex_lock(&oom_lock)
  try_charge()
    mem_cgroup_out_of_memory()
      mutex_lock(&oom_lock)
                            out_of_memory()
                              oom_kill_process(P1)
                                do_send_sig_info(SIGKILL, @P1)
                                mark_oom_victim(T1@P1)
                                wake_oom_reaper(T1@P1) # T1@P1 is enqueued.
                            mutex_unlock(&oom_lock)
                 out_of_memory()
                   mark_oom_victim(T2@P1)
                   wake_oom_reaper(T2@P1) # T2@P1 is enqueued.
                 mutex_unlock(&oom_lock)
      out_of_memory()
        mark_oom_victim(T1@P1)
        wake_oom_reaper(T1@P1) # T1@P1 is enqueued again due to oom_reaper_list == T2@P1 && T1@P1->oom_reaper_list == NULL.
      mutex_unlock(&oom_lock)
                                   # Completed processing an OOM victim in a different memcg domain.
                                   spin_lock(&oom_reaper_lock)
                                   # T1P1 is dequeued.
                                   spin_unlock(&oom_reaper_lock)

but memcg's group oom killing made it easier to trigger this bug by
calling wake_oom_reaper() on the same task from one out_of_memory()
request.

Fix this bug using an approach used by commit 855b018325737f76 ("oom,
oom_reaper: disable oom_reaper for oom_kill_allocating_task").  As a side
effect of this patch, this patch also avoids enqueuing multiple threads
sharing memory via task_will_free_mem(current) path.

Fixes: af8e15cc85a25315 ("oom, oom_reaper: do not enqueue task if it is on the oom_reaper_list head")
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
Tested-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Aleksa Sarai <asarai@suse.de>
Cc: Jay Kamat <jgkamat@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/sched/coredump.h | 1 +
 mm/oom_kill.c                  | 4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index ec912d0..ecdc654 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -71,6 +71,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
 #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
 #define MMF_OOM_VICTIM		25	/* mm is the oom victim */
+#define MMF_OOM_REAP_QUEUED	26	/* mm was queued for oom_reaper */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9..059e617 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -647,8 +647,8 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	/* mm is already queued? */
+	if (test_and_set_bit(MMF_OOM_REAP_QUEUED, &tsk->signal->oom_mm->flags))
 		return;
 
 	get_task_struct(tsk);
-- 
1.8.3.1

