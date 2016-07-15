Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5A5B6B0262
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 12:59:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so77365086lfi.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:59:00 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id u123si7173629lja.31.2016.07.15.09.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 09:58:59 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l69so2847386lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:58:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABAubTh_5aLxaEYYyFivoatJLN35K8Gy1fHKG=8FL8XFrv61Sw@mail.gmail.com>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz> <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
 <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com>
 <20160712071927.GD14586@dhcp22.suse.cz> <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com>
 <57851224.2020902@yandex-team.ru> <CABAubTiVb8j8wEbcr16FAJnBxxS7QzghpPiJUcmV+=Ji=QgL=A@mail.gmail.com>
 <20160714132258.GA1333@redhat.com> <CABAubTh_5aLxaEYYyFivoatJLN35K8Gy1fHKG=8FL8XFrv61Sw@mail.gmail.com>
From: Shayan Pooya <shayan@liveve.org>
Date: Fri, 15 Jul 2016 09:58:58 -0700
Message-ID: <CABAubTjjD6nmAtMNze5O6-bE-ivMmb24Jd4u2mMpBZFBFR1CnA@mail.gmail.com>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

>> I am just curious... can you reproduce the problem reliably? If yes, can you try
>> the patch below ? Just in case, this is not the real fix in any case...
>
> Yes. It deterministically results in hung processes in vanilla kernel.
> I'll try this patch.

I'll have to correct this. I can reproduce this issue easily on
high-end servers and normal laptops. But for some reason it does not
happen very often in vmware guests (maybe related to lower
parallelism).

>> --- x/kernel/sched/core.c
>> +++ x/kernel/sched/core.c
>> @@ -2793,8 +2793,11 @@ asmlinkage __visible void schedule_tail(struct task_struct *prev)
>>         balance_callback(rq);
>>         preempt_enable();
>>
>> -       if (current->set_child_tid)
>> +       if (current->set_child_tid) {
>> +               mem_cgroup_oom_enable();
>>                 put_user(task_pid_vnr(current), current->set_child_tid);
>> +               mem_cgroup_oom_disable();
>> +       }
>>  }
>>
>>  /*

I tried this patch and I still see the same stuck processes (assuming
that's what you were curious about).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
