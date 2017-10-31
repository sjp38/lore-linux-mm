Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDC26B025F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:55:54 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j17so43088554iod.18
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:55:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i86sor796498ioo.204.2017.10.31.06.55.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 06:55:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
References: <089e0825eec8955c1f055c83d476@google.com> <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz> <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R> <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz> <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Oct 2017 16:55:32 +0300
Message-ID: <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
Subject: Re: possible deadlock in lru_add_drain_all
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Byungchul Park <byungchul.park@lge.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Tue, Oct 31, 2017 at 4:51 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Oct 31, 2017 at 02:13:33PM +0100, Michal Hocko wrote:
>> On Mon 30-10-17 16:10:09, Peter Zijlstra wrote:
>
>> > However, that splat translates like:
>> >
>> >     __cpuhp_setup_state()
>> > #0    cpus_read_lock()
>> >       __cpuhp_setup_state_cpuslocked()
>> > #1      mutex_lock(&cpuhp_state_mutex)
>> >
>> >
>> >
>> >     __cpuhp_state_add_instance()
>> > #2    mutex_lock(&cpuhp_state_mutex)
>>
>> this should be #1 right?
>
> Yes
>
>> >       cpuhp_issue_call()
>> >         cpuhp_invoke_ap_callback()
>> > #3        wait_for_completion()
>> >
>> >                                             msr_device_create()
>> >                                               ...
>> > #4                                              filename_create()
>> > #3                                          complete()
>> >
>> >
>> >
>> >     do_splice()
>> > #4    file_start_write()
>> >       do_splice_from()
>> >         iter_file_splice_write()
>> > #5        pipe_lock()
>> >           vfs_iter_write()
>> >             ...
>> > #6            inode_lock()
>> >
>> >
>> >
>> >     sys_fcntl()
>> >       do_fcntl()
>> >         shmem_fcntl()
>> > #5        inode_lock()
>
> And that #6
>
>> >           shmem_wait_for_pins()
>> >             if (!scan)
>> >               lru_add_drain_all()
>> > #0              cpus_read_lock()
>> >
>> >
>> >
>> > Which is an actual real deadlock, there is no mixing of up and down.
>>
>> thanks a lot, this made it more clear to me. It took a while to
>> actually see 0 -> 1 -> 3 -> 4 -> 5 -> 0 cycle. I have only focused
>> on lru_add_drain_all while it was holding the cpus lock.
>
> Yeah, these things are a pain to read, which is why I always construct
> something like the above first.


I noticed that for a simple 2 lock deadlock lockdep prints only 2
stacks. FWIW in user-space TSAN we print 4 stacks for such deadlocks,
namely where A was locked, where B was locked under A, where B was
locked, where A was locked under B. It makes it easier to figure out
what happens. However, for this report it seems to be 8 stacks this
way. So it's probably hard either way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
