Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79F656B0261
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 12:51:55 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id r65so44970158qkd.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:51:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o28si2682405qtb.120.2016.07.12.09.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 09:51:54 -0700 (PDT)
Date: Tue, 12 Jul 2016 18:52:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
	process in the same cgroup
Message-ID: <20160712165215.GB4557@redhat.com>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com> <20160711064150.GB5284@dhcp22.suse.cz> <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com> <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com> <20160712071927.GD14586@dhcp22.suse.cz> <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com> <57851224.2020902@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57851224.2020902@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Shayan Pooya <shayan@liveve.org>, Michal Hocko <mhocko@kernel.org>, koct9i@gmail.com, cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 07/12, Konstantin Khlebnikov wrote:
>
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -2808,8 +2808,9 @@ asmlinkage __visible void schedule_tail(struct task_struct *prev)
>         balance_callback(rq);
>         preempt_enable();
>
> -       if (current->set_child_tid)
> -               put_user(task_pid_vnr(current), current->set_child_tid);
> +       if (current->set_child_tid &&
> +           put_user(task_pid_vnr(current), current->set_child_tid))
> +               force_sig(SIGSEGV, current);
>  }
>
> Add Oleg into CC. IIRR he had some ideas how to fix this. =)

Heh. OK, OK, thank you Konstantin ;)

I'll try to recall tomorrow, but iirc I only have some ideas of how
we can happily blame the FAULT_FLAG_USER logic.

d, in this particular case, perhaps glibc/set_child_tid too because
(again, iirc) it would nice to simply kill it, it is only used for
some sanity checks...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
