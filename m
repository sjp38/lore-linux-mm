Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id AD6E86B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 05:50:14 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so7197106wes.13
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 02:50:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb12si7143670wib.106.2014.07.09.02.50.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 02:50:13 -0700 (PDT)
Message-ID: <53BD1053.5020401@suse.cz>
Date: Wed, 09 Jul 2014 11:50:11 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407082309040.7374@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/09/2014 08:35 AM, Hugh Dickins wrote:
> On Wed, 9 Jul 2014, Sasha Levin wrote:
>> On 07/02/2014 03:25 PM, akpm@linux-foundation.org wrote:
>>> From: Hugh Dickins <hughd@google.com>
>>> Subject: shmem: fix faulting into a hole while it's punched, take 2
>>
>> I suspect there's something off with this patch, as the shmem_fallocate
>> hangs are back... Pretty much same as before:
>
> Thank you for reporting, but that is depressing news.
>
> I don't see what's wrong with this (take 2) patch,
> and I don't see that it's been garbled in any way in next-20140708.
>
>>
>> [  363.600969] INFO: task trinity-c327:9203 blocked for more than 120 seconds.
>> [  363.605359]       Not tainted 3.16.0-rc4-next-20140708-sasha-00022-g94c7290-dirty #772
>> [  363.609730] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>> [  363.615861] trinity-c327    D 000000000000000b 13496  9203   8559 0x10000004
>> [  363.620284]  ffff8800b857bce8 0000000000000002 ffffffff9dc11b10 0000000000000001
>> [  363.624468]  ffff880104860000 ffff8800b857bfd8 00000000001d7740 00000000001d7740
>> [  363.629118]  ffff880104863000 ffff880104860000 ffff8800b857bcd8 ffff8801eaed8868
>> [  363.633879] Call Trace:
>> [  363.635442]  [<ffffffff9a4dc535>] schedule+0x65/0x70
>> [  363.638638]  [<ffffffff9a4dc948>] schedule_preempt_disabled+0x18/0x30
>> [  363.642833]  [<ffffffff9a4df0a5>] mutex_lock_nested+0x2e5/0x550
>> [  363.646599]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
>> [  363.651319]  [<ffffffff9719b721>] ? get_parent_ip+0x11/0x50
>> [  363.654683]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
>> [  363.658264]  [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350
>
> So it's trying to acquire i_mutex at shmem_fallocate+0x6c...
>
>> [  363.662010]  [<ffffffff971bd96e>] ? put_lock_stats.isra.12+0xe/0x30
>> [  363.665866]  [<ffffffff9730c043>] do_fallocate+0x153/0x1d0
>> [  363.669381]  [<ffffffff972b472f>] SyS_madvise+0x33f/0x970
>> [  363.672906]  [<ffffffff9a4e3f13>] tracesys+0xe1/0xe6
>> [  363.682900] 2 locks held by trinity-c327/9203:
>> [  363.684928]  #0:  (sb_writers#12){.+.+.+}, at: [<ffffffff9730c02d>] do_fallocate+0x13d/0x1d0
>> [  363.715102]  #1:  (&sb->s_type->i_mutex_key#16){+.+.+.}, at: [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350
>
> ...but it already holds i_mutex, acquired at shmem_fallocate+0x6c.
> Am I reading that correctly?

I wonder, why wouldn't lockdep fire here if it was a double lock? I 
assume lockdep is enabled. It seems to me that the lock #1 is being 
printed because it's being acquired, not because it already is acquired. 
__mutex_lock_common() calls mutex_acquire_nest() *before* it actually 
tries to acquire the mutex. So the output is just confusing.

So it would again help to see stacks of other tasks, to see who holds 
the i_mutex and where it's stuck...

Vlastimil

> In my source for next-20140708, the only return from shmem_fallocate()
> which omits to mutex_unlock(&inode->i_mutex) is the "return -EOPNOTSUPP"
> at the top, just before the mutex_lock(&inode->i_mutex).  And inode
> doesn't get reassigned in the middle.
>
> Does 3.16.0-rc4-next-20140708-sasha-00022-g94c7290-dirty look different?
>
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
