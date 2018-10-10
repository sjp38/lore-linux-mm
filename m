Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4C66B028B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:56:19 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f9-v6so3770796iok.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:56:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2-v6sor9493696ith.7.2018.10.10.00.56.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 00:56:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1810092106190.83503@chino.kir.corp.google.com>
References: <000000000000dc48d40577d4a587@google.com> <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1810092106190.83503@chino.kir.corp.google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Oct 2018 09:55:57 +0200
Message-ID: <CACT4Y+bmYbNpu3mQR+X52KX+yPD1N2dnZOtd=iu-oETkevQ9RA@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in shmem_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yang Shi <yang.s@alibaba-inc.com>

On Wed, Oct 10, 2018 at 6:11 AM, 'David Rientjes' via syzkaller-bugs
<syzkaller-bugs@googlegroups.com> wrote:
> On Wed, 10 Oct 2018, Tetsuo Handa wrote:
>
>> syzbot is hitting RCU stall due to memcg-OOM event.
>> https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64
>>
>> What should we do if memcg-OOM found no killable task because the allocating task
>> was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires
>> (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
>> OOM header when no eligible victim left") because syzbot was terminating the test
>> upon WARN(1) removed by that commit) is not a good behavior.


You want to say that most of the recent hangs and stalls are actually
caused by our attempt to sandbox test processes with memory cgroup?
The process with oom_score_adj == -1000 is not supposed to consume any
significant memory; we have another (test) process with oom_score_adj
== 0 that's actually consuming memory.
But should we refrain from using -1000? Perhaps it would be better to
use -500/500 for control/test process, or -999/1000?


> Not printing anything would be the obvious solution but the ideal solution
> would probably involve
>
>  - adding feedback to the memcg oom killer that there are no killable
>    processes,
>
>  - adding complete coverage for memcg_oom_recover() in all uncharge paths
>    where the oom memcg's page_counter is decremented, and
>
>  - having all processes stall until memcg_oom_recover() is called so
>    looping back into try_charge() has a reasonable expectation to succeed.
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/alpine.DEB.2.21.1810092106190.83503%40chino.kir.corp.google.com.
> For more options, visit https://groups.google.com/d/optout.
