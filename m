Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFC25C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:04:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D77F2146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:04:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D77F2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8CA8E0005; Mon,  1 Jul 2019 09:04:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36B0D8E0002; Mon,  1 Jul 2019 09:04:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2817B8E0005; Mon,  1 Jul 2019 09:04:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id E240E8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 09:04:41 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id t19so3056809pgh.6
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 06:04:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PjwkY0TFhYxr5MiGcsw/rDC/BVa2Ya2OgpyYPS/EuBE=;
        b=aR1Q4fIgOCUqZRELM4xAeJAE5uqSmyOO4U08fAsdCQc0P8+Q1/muWp6L00LMuNSewj
         Yis9djxy544dK3pmla2FSidd67GzPlM7YH60iCsDCyAWWs2fXZDztVQUWOFFdGYxQ8XN
         xGF+ZgPfXA3FLwWXQ0iQ9toZYcRQK4/QkGdqsOsWK2B0T2WOosVxnLVTEMakYBASU+cf
         FGAndb/lmPL7L25U+ccXaJQSssmenKNwOxZJmpg/9zwbJa6Mh6Ck3i7lH2tdjq2bo/gY
         lGnds4KxiHh2h+Mbu8gvNwdxGIfle/Vdeq80g8zQHa5HHGVVlZPzkiGw+JpUNXy/Nw5l
         LW1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUrNWaHz2wEhtMScD50sdCByLeAuLqfYVTp6fUDX3RO2EMC7FKq
	avrxDSaYnf5d1ukcYnfbjRm8C5HBU9gHPiVhDRuQ6o5E+r9a6fOvAdmVeqENpUA4CswWkH8p7vA
	H8GjnZv2KyK4oZqht2pgDWlwLZ2WXtbyqf20yxsOqNUPF6+FTlnrkvPjak9Aiqzpk/Q==
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr29534575plb.84.1561986281508;
        Mon, 01 Jul 2019 06:04:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpWBr5bJz7bq96jF1oh5os+aPbwgmpg3s3jKBzOqRuU942I8dPSuUp8GpgYbuYHTHDPSk0
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr29534488plb.84.1561986280622;
        Mon, 01 Jul 2019 06:04:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561986280; cv=none;
        d=google.com; s=arc-20160816;
        b=JAN96AcWYOef54xPmS37ymMqLYShrW1+2+dpS8AkfCyypywNZDPYRdxAUK8gMRemC+
         lNjFfq3TQn//IN1y4exH4+AK9YQQyBXa9lhyDulsq3eIIOUND6DaLPNMeWBME8liEDnA
         JzY02M6ngYQbUx6ZXH9RfBz0Y+7QH1iaKk0gZxbNE6zghfGMM+FCBM6bojIop/taYWZZ
         /F8b4t5UwsI+7JVHhtmZKhFVBZ0GoPPc8dejfBS5TXWDg64l3q+Rvqp6dckqRWa4qhfA
         rrjvPUD0WTmhrCouUURmZo/Iwkk8ciEgUyZbs1ZX+PIUI/GxnY1GowoqIAtOidQFrkUQ
         dFoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PjwkY0TFhYxr5MiGcsw/rDC/BVa2Ya2OgpyYPS/EuBE=;
        b=qmTgdvPszp9ezS52FKc3oAN64qKDoSmgpT53FDomNQn27qlVFbRaMMCXR3bcULdjBU
         /IVdSErYUGQTsf/nlJ8cYzscxRldsyRdPmkJkK83DCs7ce5v9d1u9PqRPNdn+NcpXg/+
         5UGTQLJ4tTPQWflNXVWtbrAgEdXLsKh9+sIqEliOl/o3QnF6zfJsHX2iO5aaaGRITtRT
         6Vu6KP7JQW5tb/XUdNocbgNT8rHiIblpRlBNhPbMgivXl7XM84wIGLR1NmaiWxdguOFy
         mALQU2Iue3bNS5cTeMdS6cixlb+Ql1xYsVpfpIrB/V5PsiGhiSOjpZCH4zooajh7t9X0
         Sqxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v16si11511237pfe.39.2019.07.01.06.04.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 06:04:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav106.sakura.ne.jp (fsav106.sakura.ne.jp [27.133.134.233])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x61D4XJL032760;
	Mon, 1 Jul 2019 22:04:33 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav106.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp);
 Mon, 01 Jul 2019 22:04:33 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x61D4O44032564
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Mon, 1 Jul 2019 22:04:32 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
Date: Mon, 1 Jul 2019 22:04:22 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701111708.GP6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/01 20:17, Michal Hocko wrote:
> On Sat 29-06-19 20:24:34, Tetsuo Handa wrote:
>> Since mpol_put_task_policy() in do_exit() sets mempolicy = NULL,
>> mempolicy_nodemask_intersects() considers exited threads (e.g. a process
>> with dying leader and live threads) as eligible. But it is possible that
>> all of live threads are still ineligible.
>>
>> Since has_intersects_mems_allowed() returns true as soon as one of threads
>> is considered eligible, mempolicy_nodemask_intersects() needs to consider
>> exited threads as ineligible. Since exit_mm() in do_exit() sets mm = NULL
>> before mpol_put_task_policy() sets mempolicy = NULL, we can exclude exited
>> threads by checking whether mm is NULL.
> 
> Ok, this makes sense. For this change
> Acked-by: Michal Hocko <mhocko@suse.com>
> 

But I realized that this patch was too optimistic. We need to wait for mm-less
threads until MMF_OOM_SKIP is set if the process was already an OOM victim. If
we fail to allow the process to reach MMF_OOM_SKIP test, the process will be
ignored by the OOM killer as soon as all threads pass mm = NULL at exit_mm(), for
has_intersects_mems_allowed() returns false unless MPOL_{BIND,INTERLEAVE} is used.

Well, the problem is that exited threads prematurely set mempolicy = NULL.
Since bitmap memory for cpuset_mems_allowed_intersects() path is freed when
__put_task_struct() is called, mempolicy memory for mempolicy_nodemask_intersects()
path should be freed as well when __put_task_struct() is called?

diff --git a/kernel/exit.c b/kernel/exit.c
index a75b6a7..02a60ea 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -897,7 +897,6 @@ void __noreturn do_exit(long code)
 	exit_tasks_rcu_start();
 	exit_notify(tsk, group_dead);
 	proc_exit_connector(tsk);
-	mpol_put_task_policy(tsk);
 #ifdef CONFIG_FUTEX
 	if (unlikely(current->pi_state_cache))
 		kfree(current->pi_state_cache);
diff --git a/kernel/fork.c b/kernel/fork.c
index 6166790..c17e436 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -726,6 +726,7 @@ void __put_task_struct(struct task_struct *tsk)
 	WARN_ON(refcount_read(&tsk->usage));
 	WARN_ON(tsk == current);
 
+	mpol_put_task_policy(tsk);
 	cgroup_free(tsk);
 	task_numa_free(tsk);
 	security_task_free(tsk);

