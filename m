Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id EEE2C900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 04:33:29 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so681838wgg.12
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 01:33:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si2820735wja.141.2014.07.11.01.33.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 01:33:20 -0700 (PDT)
Message-ID: <53BFA14B.4010203@suse.cz>
Date: Fri, 11 Jul 2014 10:33:15 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com> <alpine.LSU.2.11.1407092358090.18131@eggly.anvils> <53BE8B1B.3000808@oracle.com> <53BECBA4.3010508@oracle.com> <alpine.LSU.2.11.1407101033280.18934@eggly.anvils> <53BED7F6.4090502@oracle.com> <alpine.LSU.2.11.1407101131310.19154@eggly.anvils> <53BEE345.4090203@oracle.com> <20140711082500.GB20603@laptop.programming.kicks-ass.net>
In-Reply-To: <20140711082500.GB20603@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/11/2014 10:25 AM, Peter Zijlstra wrote:
> On Thu, Jul 10, 2014 at 03:02:29PM -0400, Sasha Levin wrote:
>> What if we move lockdep's acquisition point to after it actually got the
>> lock?
>
> NAK, you want to do deadlock detection _before_ you're stuck in a
> deadlock.
>
>> We'd miss deadlocks, but we don't care about them right now. Anyways, doesn't
>> lockdep have anything built in to allow us to separate between locks which
>> we attempt to acquire and locks that are actually acquired?
>>
>> (cc PeterZ)
>>
>> We can treat locks that are in the process of being acquired the same as
>> acquired locks to avoid races, but when we print something out it would
>> be nice to have annotation of the read state of the lock.
>
> I'm missing the problem here I think.

Quoting Hugh from previous mail in this thread:

>> >
>> > [  363.600969] INFO: task trinity-c327:9203 blocked for more than 120 seconds.
>> > [  363.605359]       Not tainted 3.16.0-rc4-next-20140708-sasha-00022-g94c7290-dirty #772
>> > [  363.609730] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>> > [  363.615861] trinity-c327    D 000000000000000b 13496  9203   8559 0x10000004
>> > [  363.620284]  ffff8800b857bce8 0000000000000002 ffffffff9dc11b10 0000000000000001
>> > [  363.624468]  ffff880104860000 ffff8800b857bfd8 00000000001d7740 00000000001d7740
>> > [  363.629118]  ffff880104863000 ffff880104860000 ffff8800b857bcd8 ffff8801eaed8868
>> > [  363.633879] Call Trace:
>> > [  363.635442]  [<ffffffff9a4dc535>] schedule+0x65/0x70
>> > [  363.638638]  [<ffffffff9a4dc948>] schedule_preempt_disabled+0x18/0x30
>> > [  363.642833]  [<ffffffff9a4df0a5>] mutex_lock_nested+0x2e5/0x550
>> > [  363.646599]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
>> > [  363.651319]  [<ffffffff9719b721>] ? get_parent_ip+0x11/0x50
>> > [  363.654683]  [<ffffffff972a4d7c>] ? shmem_fallocate+0x6c/0x350
>> > [  363.658264]  [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350
>
> So it's trying to acquire i_mutex at shmem_fallocate+0x6c...
>
>> > [  363.662010]  [<ffffffff971bd96e>] ? put_lock_stats.isra.12+0xe/0x30
>> > [  363.665866]  [<ffffffff9730c043>] do_fallocate+0x153/0x1d0
>> > [  363.669381]  [<ffffffff972b472f>] SyS_madvise+0x33f/0x970
>> > [  363.672906]  [<ffffffff9a4e3f13>] tracesys+0xe1/0xe6
>> > [  363.682900] 2 locks held by trinity-c327/9203:
>> > [  363.684928]  #0:  (sb_writers#12){.+.+.+}, at: [<ffffffff9730c02d>] do_fallocate+0x13d/0x1d0
>> > [  363.715102]  #1:  (&sb->s_type->i_mutex_key#16){+.+.+.}, at: [<ffffffff972a4d7c>] shmem_fallocate+0x6c/0x350
>
> ...but it already holds i_mutex, acquired at shmem_fallocate+0x6c.
> Am I reading that correctly?

The output looks like mutex #1 is already taken, but actually the 
process is sleeping when trying to take it. It appears that the output 
has taken mutex_acquire_nest() action into account, but doesn't 
distinguish if lock_acquired() already happened or not.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
