Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id E38F96B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 09:52:55 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i12so335638079ywa.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 06:52:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z185si16282894qkc.32.2016.07.18.06.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 06:52:55 -0700 (PDT)
Date: Mon, 18 Jul 2016 15:53:10 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
	process in the same cgroup
Message-ID: <20160718135309.GC25380@redhat.com>
References: <20160711064150.GB5284@dhcp22.suse.cz> <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com> <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com> <20160712071927.GD14586@dhcp22.suse.cz> <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com> <57851224.2020902@yandex-team.ru> <CABAubTiVb8j8wEbcr16FAJnBxxS7QzghpPiJUcmV+=Ji=QgL=A@mail.gmail.com> <20160714132258.GA1333@redhat.com> <CABAubTh_5aLxaEYYyFivoatJLN35K8Gy1fHKG=8FL8XFrv61Sw@mail.gmail.com> <CABAubTjjD6nmAtMNze5O6-bE-ivMmb24Jd4u2mMpBZFBFR1CnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABAubTjjD6nmAtMNze5O6-bE-ivMmb24Jd4u2mMpBZFBFR1CnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shayan Pooya <shayan@liveve.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 07/15, Shayan Pooya wrote:
>
> >> --- x/kernel/sched/core.c
> >> +++ x/kernel/sched/core.c
> >> @@ -2793,8 +2793,11 @@ asmlinkage __visible void schedule_tail(struct task_struct *prev)
> >>         balance_callback(rq);
> >>         preempt_enable();
> >>
> >> -       if (current->set_child_tid)
> >> +       if (current->set_child_tid) {
> >> +               mem_cgroup_oom_enable();
> >>                 put_user(task_pid_vnr(current), current->set_child_tid);
> >> +               mem_cgroup_oom_disable();
> >> +       }
> >>  }
> >>
> >>  /*
>
> I tried this patch and I still see the same stuck processes (assuming
> that's what you were curious about).

Of course. Because I am stupid. Firtsly, I forgot to include another
change in fault.c. And now I see that change was wrong anyway.

I'll try to make another debugging patch today later, but let me repeat
that it won't fix the real problem anyway.

Thanks, and sorry for wasting your time.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
