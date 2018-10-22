Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id D44566B0005
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 06:57:08 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id y81-v6so28362474oig.20
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:57:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s14si15725894ote.50.2018.10.22.03.57.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 03:57:07 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] mm, oom: marks all killed tasks as oom victims
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-2-mhocko@kernel.org>
 <201810220758.w9M7wojE016890@www262.sakura.ne.jp>
 <20181022084842.GW18839@dhcp22.suse.cz>
 <f5b257f9-47a5-e071-02fa-ce901bd34b04@i-love.sakura.ne.jp>
 <20181022104341.GY18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <93f99371-cff8-fc31-a594-eecdff299f16@i-love.sakura.ne.jp>
Date: Mon, 22 Oct 2018 19:56:49 +0900
MIME-Version: 1.0
In-Reply-To: <20181022104341.GY18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/10/22 19:43, Michal Hocko wrote:
> On Mon 22-10-18 18:42:30, Tetsuo Handa wrote:
>> On 2018/10/22 17:48, Michal Hocko wrote:
>>> On Mon 22-10-18 16:58:50, Tetsuo Handa wrote:
>>>> Michal Hocko wrote:
>>>>> --- a/mm/oom_kill.c
>>>>> +++ b/mm/oom_kill.c
>>>>> @@ -898,6 +898,7 @@ static void __oom_kill_process(struct task_struct *victim)
>>>>>  		if (unlikely(p->flags & PF_KTHREAD))
>>>>>  			continue;
>>>>>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, PIDTYPE_TGID);
>>>>> +		mark_oom_victim(p);
>>>>>  	}
>>>>>  	rcu_read_unlock();
>>>>>  
>>>>> -- 
>>>>
>>>> Wrong. Either
>>>
>>> You are right. The mm might go away between process_shares_mm and here.
>>> While your find_lock_task_mm would be correct I believe we can do better
>>> by using the existing mm that we already have. I will make it a separate
>>> patch to clarity.
>>
>> Still wrong. p->mm == NULL means that we are too late to set TIF_MEMDIE
>> on that thread. Passing non-NULL mm to mark_oom_victim() won't help.
> 
> Why would it be too late? Or in other words why would this be harmful?
> 

Setting TIF_MEMDIE after exit_mm() completed is too late.

static void exit_mm(void)
{
(...snipped...)
	task_lock(current);
	current->mm = NULL;
	up_read(&mm->mmap_sem);
	enter_lazy_tlb(mm, current);
	task_unlock(current);
	mm_update_next_owner(mm);
	mmput(mm);
	if (test_thread_flag(TIF_MEMDIE))
		exit_oom_victim();
}
