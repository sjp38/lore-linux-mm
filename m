Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAD86B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:09:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so29437517wma.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:09:01 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id p203si9394686wmg.104.2016.07.13.01.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 01:09:00 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id f65so17666974wmi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:09:00 -0700 (PDT)
Date: Wed, 13 Jul 2016 10:08:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Message-ID: <20160713080858.GD28723@dhcp22.suse.cz>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz>
 <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
 <CABAubTjGhUXMeAnFgW8LGck1tgvtu12Zb9fx5BRhDWNjZ7SYLQ@mail.gmail.com>
 <20160712071927.GD14586@dhcp22.suse.cz>
 <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABAubTg91qrUd4DO7T2SiJQBK9ypuhP0+F-091ZxtmonjaaYWg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shayan Pooya <shayan@liveve.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, koct9i@gmail.com, cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 12-07-16 08:35:06, Shayan Pooya wrote:
> >> With strace, when running 500 concurrent mem-hog tasks on the same
> >> kernel, 33 of them failed with:
> >>
> >> strace: ../sysdeps/nptl/fork.c:136: __libc_fork: Assertion
> >> `THREAD_GETMEM (self, tid) != ppid' failed.
> >>
> >> Which is: https://sourceware.org/bugzilla/show_bug.cgi?id=15392
> >> And discussed before at: https://lkml.org/lkml/2015/2/6/470 but that
> >> patch was not accepted.
> >
> > OK, so the problem is that the oom killed task doesn't report the futex
> > release properly? If yes then I fail to see how that is memcg specific.
> > Could you try to clarify what you consider a bug again, please? I am not
> > really sure I understand this report.
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

OK, I see! Thanks for the clarification. So the bug is that put_user
return value is ignored. Let's see whether Konstantin's patch will be
accepted or Oleg comes with something else.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
