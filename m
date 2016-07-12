Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDBF86B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:52:06 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so14548112lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:52:06 -0700 (PDT)
Received: from forwardcorp1h.cmail.yandex.net (forwardcorp1h.cmail.yandex.net. [2a02:6b8:0:f35::e5])
        by mx.google.com with ESMTPS id p15si4473991lfp.301.2016.07.12.08.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 08:52:05 -0700 (PDT)
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz>
 <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
 <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com>
 <20160712071927.GD14586@dhcp22.suse.cz>
 <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <57851224.2020902@yandex-team.ru>
Date: Tue, 12 Jul 2016 18:52:04 +0300
MIME-Version: 1.0
In-Reply-To: <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shayan Pooya <shayan@liveve.org>, Michal Hocko <mhocko@kernel.org>, koct9i@gmail.com
Cc: cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>

On 12.07.2016 18:35, Shayan Pooya wrote:
>>> With strace, when running 500 concurrent mem-hog tasks on the same
>>> kernel, 33 of them failed with:
>>>
>>> strace: ../sysdeps/nptl/fork.c:136: __libc_fork: Assertion
>>> `THREAD_GETMEM (self, tid) != ppid' failed.
>>>
>>> Which is: https://sourceware.org/bugzilla/show_bug.cgi?id=15392
>>> And discussed before at: https://lkml.org/lkml/2015/2/6/470 but that
>>> patch was not accepted.
>>
>> OK, so the problem is that the oom killed task doesn't report the futex
>> release properly? If yes then I fail to see how that is memcg specific.
>> Could you try to clarify what you consider a bug again, please? I am not
>> really sure I understand this report.
>
> It looks like it is just a very easy way to reproduce the problem that
> Konstantin described in that lkml thread. That patch was not accepted
> and I see no other fixes for that issue upstream. Here is a copy of
> his root-cause analysis from said thread:
>
> Whole sequence looks like: task calls fork, glibc calls syscall clone with
> CLONE_CHILD_SETTID and passes pointer to TLS THREAD_SELF->tid as argument.
> Child task gets read-only copy of VM including TLS. Child calls put_user()
> to handle CLONE_CHILD_SETTID from schedule_tail(). put_user() trigger page
> fault and it fails because do_wp_page()  hits memcg limit without invoking
> OOM-killer because this is page-fault from kernel-space.  Put_user returns
> -EFAULT, which is ignored.  Child returns into user-space and catches here
> assert (THREAD_GETMEM (self, tid) != ppid), glibc tries to print something
> but hangs on deadlock on internal locks. Halt and catch fire.
>
>

Yep. Bug still not fixed in upstream. In our kernel I've plugged it with this:

--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2808,8 +2808,9 @@ asmlinkage __visible void schedule_tail(struct task_struct *prev)
         balance_callback(rq);
         preempt_enable();

-       if (current->set_child_tid)
-               put_user(task_pid_vnr(current), current->set_child_tid);
+       if (current->set_child_tid &&
+           put_user(task_pid_vnr(current), current->set_child_tid))
+               force_sig(SIGSEGV, current);
  }

Add Oleg into CC. IIRR he had some ideas how to fix this. =)

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
