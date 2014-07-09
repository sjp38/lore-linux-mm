Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB81900009
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 08:53:34 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so9280688pad.9
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 05:53:33 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bj7si7306728pdb.152.2014.07.09.05.53.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 05:53:32 -0700 (PDT)
Message-ID: <53BD39FC.7040205@oracle.com>
Date: Wed, 09 Jul 2014 08:47:56 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils> <53BD1053.5020401@suse.cz>
In-Reply-To: <53BD1053.5020401@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/09/2014 05:50 AM, Vlastimil Babka wrote:
> On 07/09/2014 08:35 AM, Hugh Dickins wrote:
>> On Wed, 9 Jul 2014, Sasha Levin wrote:
>>> [  363.600969] INFO: task trinity-c327:9203 blocked for more than 120 seconds.
>>> [  363.605359]       Not tainted 3.16.0-rc4-next-20140708-sasha-00022-g94c7290-dirty #772
>>> [  363.609730] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>>> [  363.615861] trinity-c327    D 000000000000000b 13496  9203   8559 0x10000004
>>> [  363.620284]  ffff8800b857bce8 0000000000000002 ffffffff9dc11b10 0000000000000001
>>> [  363.624468]  ffff880104860000 ffff8800b857bfd8 00000000001d7740 00000000001d7740
>>> [  363.629118]  ffff880104863000 ffff880104860000 ffff8800b857bcd8 ffff8801eaed8868
>>> [  363.633879] Call Trace:
>>> [  363.635442]  [<ffffffff9a4dc535>] schedule+0x65/0x70
>>> [  363.638638]  [<ffffffff9a4dc948>] schedule_preempt_disabled+0x18/0x30
>>> [  363.642833]  [<ffffffff9a4df0a5>] mutex_lock_nested+0x2e5/0x550
>>> [  363.646599]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
>>> [  363.651319]  [<ffffffff9719b721>] ? get_parent_ip+0x11/0x50
>>> [  363.654683]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
>>> [  363.658264]  [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350
>>
>> So it's trying to acquire i_mutex at shmem_fallocate+0x6c...
>>
>>> [  363.662010]  [<ffffffff971bd96e>] ? put_lock_stats.isra.12+0xe/0x30
>>> [  363.665866]  [<ffffffff9730c043>] do_fallocate+0x153/0x1d0
>>> [  363.669381]  [<ffffffff972b472f>] SyS_madvise+0x33f/0x970
>>> [  363.672906]  [<ffffffff9a4e3f13>] tracesys+0xe1/0xe6
>>> [  363.682900] 2 locks held by trinity-c327/9203:
>>> [  363.684928]  #0:  (sb_writers#12){.+.+.+}, at: [<ffffffff9730c02d>] do_fallocate+0x13d/0x1d0
>>> [  363.715102]  #1:  (&sb->s_type->i_mutex_key#16){+.+.+.}, at: [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350
>>
>> ...but it already holds i_mutex, acquired at shmem_fallocate+0x6c.
>> Am I reading that correctly?
> 
> I wonder, why wouldn't lockdep fire here if it was a double lock? I assume lockdep is enabled. It seems to me that the lock #1 is being printed because it's being acquired, not because it already is acquired. __mutex_lock_common() calls mutex_acquire_nest() *before* it actually tries to acquire the mutex. So the output is just confusing.

Nope, it's not a double lock - it's easy to misread lockdep output here.

lockdep marks locks as held even before they are actually acquired:

	static __always_inline int __sched
	__mutex_lock_common(struct mutex *lock, long state, unsigned int subclass,
	                    struct lockdep_map *nest_lock, unsigned long ip,
	                    struct ww_acquire_ctx *ww_ctx, const bool use_ww_ctx)
	{
	        struct task_struct *task = current;
	        struct mutex_waiter waiter;
	        unsigned long flags;
	        int ret;

	        preempt_disable();
	        mutex_acquire_nest(&lock->dep_map, subclass, 0, nest_lock, ip); <=== Lock marked as acquired

This is done to avoid races where the lock is actually acquired but not showing up
in lockdep.

So this trace should be read as: "We acquired sb_writers in do_fallocate() and are
blocked waiting to lock i_mutex in shmem_fallocate".

> So it would again help to see stacks of other tasks, to see who holds the i_mutex and where it's stuck...

The stacks print got garbled due to having large amount of tasks and too low of a
console buffer. I've fixed that and will update when (if) the problem reproduces.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
