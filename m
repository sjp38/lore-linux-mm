Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 777DB6B0261
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 11:35:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so57981669wma.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:35:28 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id 124si2773884ljj.101.2016.07.14.08.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 08:35:27 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id f93so67257097lfi.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:35:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160714132258.GA1333@redhat.com>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz> <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
 <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com>
 <20160712071927.GD14586@dhcp22.suse.cz> <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com>
 <57851224.2020902@yandex-team.ru> <CABAubTiVb8j8wEbcr16FAJnBxxS7QzghpPiJUcmV+=Ji=QgL=A@mail.gmail.com>
 <20160714132258.GA1333@redhat.com>
From: Shayan Pooya <shayan@liveve.org>
Date: Thu, 14 Jul 2016 08:35:25 -0700
Message-ID: <CABAubTh_5aLxaEYYyFivoatJLN35K8Gy1fHKG=8FL8XFrv61Sw@mail.gmail.com>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> Well, but we can't do this. And "as expected" is actually just wrong. I still
> think that the whole FAULT_FLAG_USER logic is not right. This needs another email.

I meant as expected from the content of the patch :) I think
Konstantin agrees that this patch cannot be merged upstream.

> fork() should not fail because there is a memory hog in the same memcg. Worse,
> pthread_create() can kill the caller by the same reason. And we have the same
> or even worse problem with ->clear_child_tid, pthread_join() can hang forever.
> Unlikely we want to kill the application in this case ;)
>
> And in fact I think that the problem has nothing to do with set/claer_child_tid
> in particular.
>
> I am just curious... can you reproduce the problem reliably? If yes, can you try
> the patch below ? Just in case, this is not the real fix in any case...

Yes. It deterministically results in hung processes in vanilla kernel.
I'll try this patch.


> --- x/kernel/sched/core.c
> +++ x/kernel/sched/core.c
> @@ -2793,8 +2793,11 @@ asmlinkage __visible void schedule_tail(struct task_struct *prev)
>         balance_callback(rq);
>         preempt_enable();
>
> -       if (current->set_child_tid)
> +       if (current->set_child_tid) {
> +               mem_cgroup_oom_enable();
>                 put_user(task_pid_vnr(current), current->set_child_tid);
> +               mem_cgroup_oom_disable();
> +       }
>  }
>
>  /*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
