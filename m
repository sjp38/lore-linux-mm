Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEA168E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:37:18 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id c33so6143742otb.18
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:37:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h18si9756363otq.317.2019.01.11.07.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 07:37:17 -0800 (PST)
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
 <20190109120212.GT31793@dhcp22.suse.cz>
 <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
 <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
 <20190111113354.GD14956@dhcp22.suse.cz>
 <0d67b389-91e2-18ab-b596-39361b895c89@i-love.sakura.ne.jp>
 <20190111133401.GA6997@dhcp22.suse.cz>
 <d9f7b139-d51b-93ae-b5ad-856fd9f2c168@i-love.sakura.ne.jp>
 <20190111150703.GI14956@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <baa43a5a-6cae-bc4e-5911-13d4bfcd32f2@i-love.sakura.ne.jp>
Date: Sat, 12 Jan 2019 00:37:05 +0900
MIME-Version: 1.0
In-Reply-To: <20190111150703.GI14956@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 2019/01/12 0:07, Michal Hocko wrote:
> On Fri 11-01-19 23:31:18, Tetsuo Handa wrote:
>> The OOM killer invoked by [ T9694] called printk() but didn't kill anything.
>> Instead, SIGINT from Ctrl-C killed all thread groups sharing current->mm.
> 
> I still do not get it. Those other processes are not sharing signals.
> Or is it due to injecting the signal too all of them with the proper
> timing?

Pressing Ctrl-C between after task_will_free_mem(p) in oom_kill_process() and
before __oom_kill_process() (e.g. dump_header()) made fatal_signal_pending() = T
for all of them.

> Anyway, could you update your patch and abstract 
> 	if (unlikely(tsk_is_oom_victim(current) ||
> 		     fatal_signal_pending(current) ||
> 		     current->flags & PF_EXITING))
> 
> in try_charge and reuse it in mem_cgroup_out_of_memory under the
> oom_lock with an explanation please?

I don't think doing so makes sense, for

  tsk_is_oom_victim(current) = T && fatal_signal_pending(current) == F

can't happen for mem_cgroup_out_of_memory() under the oom_lock, and
current->flags cannot get PF_EXITING when current is inside
mem_cgroup_out_of_memory(). fatal_signal_pending(current) alone is
appropriate for mem_cgroup_out_of_memory() under the oom_lock because

  tsk_is_oom_victim(current) = F && fatal_signal_pending(current) == T

can happen there.

Also, doing so might become wrong in future, for mem_cgroup_out_of_memory()
is also called from memory_max_write() which does not bail out upon
PF_EXITING. I don't think we can call memory_max_write() after current
thread got PF_EXITING, but nobody knows what change will happen in future.
