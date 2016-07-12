Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 902A66B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 18:57:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so22456990wma.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:57:52 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 130si1811805lfa.364.2016.07.12.15.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 15:57:51 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id a10so2391976lfb.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:57:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57851224.2020902@yandex-team.ru>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz> <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
 <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com>
 <20160712071927.GD14586@dhcp22.suse.cz> <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com>
 <57851224.2020902@yandex-team.ru>
From: Shayan Pooya <shayan@liveve.org>
Date: Tue, 12 Jul 2016 15:57:50 -0700
Message-ID: <CABAubTiVb8j8wEbcr16FAJnBxxS7QzghpPiJUcmV+=Ji=QgL=A@mail.gmail.com>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Michal Hocko <mhocko@kernel.org>, koct9i@gmail.com, cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>

> Yep. Bug still not fixed in upstream. In our kernel I've plugged it with
> this:
>
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -2808,8 +2808,9 @@ asmlinkage __visible void schedule_tail(struct
> task_struct *prev)
>         balance_callback(rq);
>         preempt_enable();
>
> -       if (current->set_child_tid)
> -               put_user(task_pid_vnr(current), current->set_child_tid);
> +       if (current->set_child_tid &&
> +           put_user(task_pid_vnr(current), current->set_child_tid))
> +               force_sig(SIGSEGV, current);
>  }

I just verified that with your patch there is no hung processes and I
see processes getting SIGSEGV as expected.
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
