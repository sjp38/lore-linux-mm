Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CD2DE6B0038
	for <linux-mm@kvack.org>; Sun, 29 Nov 2015 22:31:47 -0500 (EST)
Received: by padhx2 with SMTP id hx2so169850541pad.1
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 19:31:47 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id y17si27039054pfa.33.2015.11.29.19.31.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 29 Nov 2015 19:31:46 -0800 (PST)
Subject: Re: [PATCH] bugfix oom kill init lead panic
References: <1448880869-20506-1-git-send-email-chenjie6@huawei.com>
 <20151129190802.dc66cf35.akpm@linux-foundation.org>
From: "Chenjie (K)" <chenjie6@huawei.com>
Message-ID: <565BC23F.6070302@huawei.com>
Date: Mon, 30 Nov 2015 11:27:59 +0800
MIME-Version: 1.0
In-Reply-To: <20151129190802.dc66cf35.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com, stable@vger.kernel.org

My kernel version is 3.10 ,but the 4.3 is the same
and the newest code is

	for_each_process(p) {
		if (!process_shares_mm(p, mm))
			continue;
		if (same_thread_group(p, victim))
			continue;
		if (unlikely(p->flags & PF_KTHREAD))
			continue;
		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
			continue;

so this not add the i 1/4 ?is_global_init also.

when we vfork (CLONE_VM) a process,the copy_mm
	if (clone_flags & CLONE_VM) {
		atomic_inc(&oldmm->mm_users);
		mm = oldmm;
		goto good_mm;
	}
use the parent mm.




On 2015/11/30 11:08, Andrew Morton wrote:
> On Mon, 30 Nov 2015 18:54:29 +0800 <chenjie6@huawei.com> wrote:
>
>> From: chenjie <chenjie6@huawei.com>
>>
>> when oom happened we can see:
>> Out of memory: Kill process 9134 (init) score 3 or sacrifice child
>> Killed process 9134 (init) total-vm:1868kB, anon-rss:84kB, file-rss:572kB
>> Kill process 1 (init) sharing same memory
>> ...
>> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
>>
>> That's because:
>> 	the busybox init will vfork a process,oom_kill_process found
>> the init not the children,their mm is the same when vfork.
>>
>> ...
>>
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -513,7 +513,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>>   	rcu_read_lock();
>>   	for_each_process(p)
>>   		if (p->mm == mm && !same_thread_group(p, victim) &&
>> -		    !(p->flags & PF_KTHREAD)) {
>> +		    !(p->flags & PF_KTHREAD) && !is_global_init(p)) {
>>   			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>>   				continue;
>
> What kernel version are you using?
>
> I don't think this can happen in current code...
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
