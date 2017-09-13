Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C77386B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 10:33:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id q132so306394lfe.1
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:33:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k203sor3041998lfg.1.2017.09.13.07.33.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 07:33:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b132f9d1-8898-5301-b7e5-1b3d622e4993@yandex-team.ru>
References: <149570810989.203600.9492483715840752937.stgit@buzz>
 <20170605085011.GJ9248@dhcp22.suse.cz> <80c9060f-bf80-51fb-39c0-b36f273c0c9c@yandex-team.ru>
 <1969140653.911396.1505278286673@mail.yahoo.com> <b132f9d1-8898-5301-b7e5-1b3d622e4993@yandex-team.ru>
From: Pintu Kumar <pintu.ping@gmail.com>
Date: Wed, 13 Sep 2017 20:03:46 +0530
Message-ID: <CAOuPNLive8aAL4UdE1==p6yzU3=7WPLiJp+SPX-L9YwemwGo9A@mail.gmail.com>
Subject: Re: [PATCH v2] mm/oom_kill: count global and memory cgroup oom kills
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: PINTU KUMAR <pintu_agarwal@yahoo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Roman Guschin <guroan@gmail.com>, David Rientjes <rientjes@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pintu Kumar <pintu.ping@gmail.com>

On Wed, Sep 13, 2017 at 1:05 PM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> On 13.09.2017 07:51, PINTU KUMAR wrote:
>>
>>
>>
>> Hi,
>>
>> I have submitted a similar patch 2 years ago (Oct/2015).
>> But at that time the patch was rejected.
>> Here is the history:
>> https://lkml.org/lkml/2015/10/1/372
>>
>> Now I see the similar patch got accepted. At least the initial idea and
>> the objective were same.
>> Even I were not included here.
>> On one side I feel happy that my initial idea got accepted now.
>> But on the other side it really hurts :(
>>
>
> If this makes you feel better: mine version also fixes uncertainty in memory
> cgroup statistics.
>

Yes, my initial version was also just about global oom counter. And
planning to add more later. But initial version itself was rejected.
Sometimes its really painful to know how same ideas are treated differently :(

Anyways, thanks for this version. I think it is really helpful as per
my experience.
Specially in production system where logs are disabled and no root
access. But still we can access the /proc/vmstat fields.
This was my point.


>>
>> Thanks,
>> Pintu
>>
>>
>> On Monday 5 June 2017, 7:57:57 PM IST, Konstantin Khlebnikov
>> <khlebnikov@yandex-team.ru> wrote:
>>
>>
>> On 05.06.2017 11:50, Michal Hocko wrote:
>>  > On Thu 25-05-17 13:28:30, Konstantin Khlebnikov wrote:
>>  >> Show count of oom killer invocations in /proc/vmstat and count of
>>  >> processes killed in memory cgroup in knob "memory.events"
>>  >> (in memory.oom_control for v1 cgroup).
>>  >>
>>  >> Also describe difference between "oom" and "oom_kill" in memory
>>  >> cgroup documentation. Currently oom in memory cgroup kills tasks
>>  >> iff shortage has happened inside page fault.
>>  >>
>>  >> These counters helps in monitoring oom kills - for now
>>  >> the only way is grepping for magic words in kernel log.
>>  >
>>  > Yes this is less than optimal and the counter sounds like a good step
>>  > forward. I have 2 comments to the patch though.
>>  >
>>  > [...]
>>  >
>>  >> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>  >> index 899949bbb2f9..42296f7001da 100644
>>  >> --- a/include/linux/memcontrol.h
>>  >> +++ b/include/linux/memcontrol.h
>>  >> @@ -556,8 +556,11 @@ static inline void
>> mem_cgroup_count_vm_event(struct mm_struct *mm,
>>  >>
>>  >>      rcu_read_lock();
>>  >>      memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
>>  >> -    if (likely(memcg))
>>  >> +    if (likely(memcg)) {
>>  >>          this_cpu_inc(memcg->stat->events[idx]);
>>  >> +        if (idx == OOM_KILL)
>>  >> +            cgroup_file_notify(&memcg->events_file);
>>  >> +    }
>>  >>      rcu_read_unlock();
>>  >
>>  > Well, this is ugly. I see how you want to share the global counter and
>>  > the memcg event which needs the notification. But I cannot say this
>>  > would be really easy to follow. Can we have at least a comment in
>>  > memcg_event_item enum definition?
>>
>> Yep, this is a little bit ugly.
>> But this funciton is static-inline and idx always constant so resulting
>> code is fine.
>>
>>  >
>>  >> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>>  >> index 04c9143a8625..dd30a045ef5b 100644
>>  >> --- a/mm/oom_kill.c
>>  >> +++ b/mm/oom_kill.c
>>  >> @@ -876,6 +876,11 @@ static void oom_kill_process(struct oom_control
>> *oc, const char *message)
>>  >>      /* Get a reference to safely compare mm after task_unlock(victim)
>> */
>>  >>      mm = victim->mm;
>>  >>      mmgrab(mm);
>>  >> +
>>  >> +    /* Raise event before sending signal: reaper must see this */
>>  >> +    count_vm_event(OOM_KILL);
>>  >> +    mem_cgroup_count_vm_event(mm, OOM_KILL);
>>  >> +
>>  >>      /*
>>  >>      * We should send SIGKILL before setting TIF_MEMDIE in order to
>> prevent
>>  >>      * the OOM victim from depleting the memory reserves from the user
>>  >
>>  > Why don't you count tasks which share mm with the oom victim?
>>
>> Yes, this makes sense. But these kills are not logged thus counter will
>> differs from logged events.
>> Also these tasks might live in different cgroups, so counting to mm owner
>> isn't correct.
>>
>>
>>  > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>>  > index 0e2c925e7826..9a95947a60ba 100644
>>  > --- a/mm/oom_kill.c
>>  > +++ b/mm/oom_kill.c
>>  > @@ -924,6 +924,8 @@ static void oom_kill_process(struct oom_control
>> *oc, const char *message)
>>  >          */
>>  >          if (unlikely(p->flags & PF_KTHREAD))
>>  >              continue;
>>  > +        count_vm_event(OOM_KILL);
>>  > +        count_memcg_event_mm(mm, OOM_KILL);
>>  >          do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>>  >      }
>>  >      rcu_read_unlock();
>>  >
>>  > Other than that looks good to me.
>>  > Acked-by: Michal Hocko <mhocko@suse.com>
>>  >
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
