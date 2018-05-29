Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3326F6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 11:48:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7-v6so9209517pfi.8
        for <linux-mm@kvack.org>; Tue, 29 May 2018 08:48:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j6-v6si26430902pgc.509.2018.05.29.08.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 08:48:22 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
References: <20180515091655.GD12670@dhcp22.suse.cz>
 <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
 <20180518122045.GG21711@dhcp22.suse.cz>
 <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
 <20180522061850.GB20020@dhcp22.suse.cz>
 <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
 <20180529071736.GI27180@dhcp22.suse.cz>
 <20180529081639.GM27180@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <40a5a42f-6812-b4ee-a72e-7f01dc9de464@i-love.sakura.ne.jp>
Date: Tue, 29 May 2018 23:33:13 +0900
MIME-Version: 1.0
In-Reply-To: <20180529081639.GM27180@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, guro@fb.com
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On 2018/05/29 17:16, Michal Hocko wrote:
> With the full changelog. This can be either folded into the respective
> patch or applied on top.
> 
>>From 0bd619e7a68337c97bdaed288e813e96a14ba339 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 29 May 2018 10:09:33 +0200
> Subject: [PATCH] mm, memcg, oom: fix pre-mature allocation failures
> 
> Tetsuo has noticed that "mm, oom: cgroup-aware OOM killer" can lead to a
> pre-mature allocation failure if the cgroup aware oom killer is enabled
> and select_victim_memcg doesn't pick up any memcg to kill because there
> is a memcg already being killed. oc->chosen_memcg will become INFLIGHT_VICTIM
> and oom_kill_memcg_victim will bail out early. oc->chosen_task will
> stay NULL, however, and out_of_memory will therefore return false which
> forces __alloc_pages_may_oom to not set did_some_progress and the page
> allocator backs out and fails the allocation.
> U
> Fix this by checking both chosen_task and chosen_memcg in out_of_memory
> and return false only when _both_ are NULL.

I don't like this patch. It is not easy to understand and is fragile to
future changes. Currently the only case !!oc->chosen can become false is that
there was no eligible tasks when SysRq-f was requested or memcg OOM occurred.

	/* Found nothing?!?! Either we hang forever, or we panic. */
	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {

With this patch applied, what happens if
mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc) forgot to set
oc->chosen_memcg to NULL and called select_bad_process(oc) and reached

        /* Found nothing?!?! Either we hang forever, or we panic. */
        if (!oc->chosen_task && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {

but did not trigger panic() because of is_sysrq_oom(oc) || is_memcg_oom(oc)
and reached the last "!!(oc->chosen_task | oc->chosen_memcg)" line?
It will by error return "true" when no eligible tasks found...

Don't make return conditions complicated.
The appropriate fix is to kill "delay" and "goto out;" now! My patch does it!!
