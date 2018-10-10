Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0846B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:33:36 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id v125-v6so5211448ita.7
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:33:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j201-v6sor11725775itj.5.2018.10.10.02.33.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 02:33:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181010091309.GE5873@dhcp22.suse.cz>
References: <000000000000dc48d40577d4a587@google.com> <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1810092106190.83503@chino.kir.corp.google.com>
 <CACT4Y+bmYbNpu3mQR+X52KX+yPD1N2dnZOtd=iu-oETkevQ9RA@mail.gmail.com> <20181010091309.GE5873@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Oct 2018 11:33:14 +0200
Message-ID: <CACT4Y+Y1AAw3M7_weNDZ5eb5ON_bj-sYFHNJmQa0i4uKEy4W5Q@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in shmem_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yang Shi <yang.s@alibaba-inc.com>

On Wed, Oct 10, 2018 at 11:13 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 10-10-18 09:55:57, Dmitry Vyukov wrote:
>> On Wed, Oct 10, 2018 at 6:11 AM, 'David Rientjes' via syzkaller-bugs
>> <syzkaller-bugs@googlegroups.com> wrote:
>> > On Wed, 10 Oct 2018, Tetsuo Handa wrote:
>> >
>> >> syzbot is hitting RCU stall due to memcg-OOM event.
>> >> https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64
>> >>
>> >> What should we do if memcg-OOM found no killable task because the allocating task
>> >> was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires
>> >> (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
>> >> OOM header when no eligible victim left") because syzbot was terminating the test
>> >> upon WARN(1) removed by that commit) is not a good behavior.
>>
>>
>> You want to say that most of the recent hangs and stalls are actually
>> caused by our attempt to sandbox test processes with memory cgroup?
>> The process with oom_score_adj == -1000 is not supposed to consume any
>> significant memory; we have another (test) process with oom_score_adj
>> == 0 that's actually consuming memory.
>> But should we refrain from using -1000? Perhaps it would be better to
>> use -500/500 for control/test process, or -999/1000?
>
> oom disable on a task (especially when this is the only task in the
> memcg) is tricky. Look at the memcg report
> [  935.562389] Memory limit reached of cgroup /syz0
> [  935.567398] memory: usage 204808kB, limit 204800kB, failcnt 6081
> [  935.573768] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
> [  935.580650] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
> [  935.586923] Memory cgroup stats for /syz0: cache:152KB rss:176336KB rss_huge:163840KB shmem:344KB mapped_file:264KB dirty:0KB writeback:0KB swap:0KB inactive_anon:260KB active_anon:176448KB inactive_file:4KB active_file:0KB
>
> There is still somebody holding anonymous (THP) memory. If there is no
> other eligible oom victim then it must be some of the oom disabled ones.
> You have suppressed the task list information so we do not know who that
> might be though.
>
> So it looks like there is some misconfiguration or a bug in the oom
> victim selection.


I afraid KASAN can interfere with memory accounting/OMM killing too.
KASAN quarantines up to 1/32-th of physical memory (in our case
7.5GB/32 = 230MB) that is already freed by the task, but as far as I
understand is still accounted against memcg. So maybe making cgroup
limit >> quarantine size will help to resolve this too.

But of course there can be a plain memory leak too.
