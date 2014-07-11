Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6571C6B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:23:15 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id 19so357582ykq.19
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 05:23:15 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a64si4292379yhb.117.2014.07.11.05.23.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 05:23:14 -0700 (PDT)
Message-ID: <53BFD708.1040305@oracle.com>
Date: Fri, 11 Jul 2014 08:22:32 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com> <alpine.LSU.2.11.1407092358090.18131@eggly.anvils> <53BE8B1B.3000808@oracle.com> <53BECBA4.3010508@oracle.com> <alpine.LSU.2.11.1407101033280.18934@eggly.anvils> <53BED7F6.4090502@oracle.com> <alpine.LSU.2.11.1407101131310.19154@eggly.anvils> <53BEE345.4090203@oracle.com> <20140711082500.GB20603@laptop.programming.kicks-ass.net>
In-Reply-To: <20140711082500.GB20603@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/11/2014 04:25 AM, Peter Zijlstra wrote:
> On Thu, Jul 10, 2014 at 03:02:29PM -0400, Sasha Levin wrote:
>> What if we move lockdep's acquisition point to after it actually got the
>> lock?
> 
> NAK, you want to do deadlock detection _before_ you're stuck in a
> deadlock.

I didn't suggest to do it in the general case, but just for debugging the issue
we have here.

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

The problem here is that lockdep reports tasks waiting on lock as ones that
already have the lock. So we have a list of about 500 different tasks looking
like this:

[  367.805809] 2 locks held by trinity-c214/9083:
[  367.805811] #0: (sb_writers#9){.+.+.+}, at: do_fallocate (fs/open.c:298)
[  367.805824] #1: (&sb->s_type->i_mutex_key#16){+.+.+.}, at: shmem_fallocate (mm/shmem.c:1738)

While they haven't actually acquired i_mutex, but are merely blocking on it:

[  367.644150] trinity-c214    D 0000000000000002 13528  9083   8490 0x00000000
[  367.644171]  ffff880018757ce8 0000000000000002 ffffffff91a01d70 0000000000000001
[  367.644178]  ffff880018757fd8 00000000001d7740 00000000001d7740 00000000001d7740
[  367.644188]  ffff880006428000 ffff880018758000 ffff880018757cd8 ffff880031fdc210
[  367.644213] Call Trace:
[  367.644218] schedule (kernel/sched/core.c:2832)
[  367.644229] schedule_preempt_disabled (kernel/sched/core.c:2859)
[  367.644237] mutex_lock_nested (kernel/locking/mutex.c:535 kernel/locking/mutex.c:587)
[  367.644240] ? shmem_fallocate (mm/shmem.c:1738)
[  367.644248] ? get_parent_ip (kernel/sched/core.c:2546)
[  367.644255] ? shmem_fallocate (mm/shmem.c:1738)
[  367.644264] shmem_fallocate (mm/shmem.c:1738)
[  367.644268] ? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  367.644280] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  367.644291] ? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  367.644298] do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
[  367.644303] SyS_madvise (mm/madvise.c:335 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  367.644309] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[  367.644315] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[  367.644321] tracesys (arch/x86/kernel/entry_64.S:543)

There's no easy way to see whether a given task is actually holding a lock or
is just blocking on it without going through all those tasks one by one and
looking at their trace.

I agree with you that "The call trace is very clear on it that its not", but
when you have 500 call traces you really want something better than going
through it one call trace at a time.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
