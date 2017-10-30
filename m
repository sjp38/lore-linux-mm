Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6676B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 04:22:16 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r18so12878939pgu.9
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 01:22:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si10311089pfp.81.2017.10.30.01.22.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 01:22:15 -0700 (PDT)
Date: Mon, 30 Oct 2017 09:22:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, Byungchul Park <byungchul.park@lge.com>

[Cc Byungchul. The original full report is
http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com]

Could you have a look please? This smells like a false positive to me.

On Fri 27-10-17 15:42:34, Michal Hocko wrote:
> On Fri 27-10-17 11:44:58, Dmitry Vyukov wrote:
> > On Fri, Oct 27, 2017 at 11:34 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > On Fri 27-10-17 02:22:40, syzbot wrote:
> > >> Hello,
> > >>
> > >> syzkaller hit the following crash on
> > >> a31cc455c512f3f1dd5f79cac8e29a7c8a617af8
> > >> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> > >> compiler: gcc (GCC) 7.1.1 20170620
> > >> .config is attached
> > >> Raw console output is attached.
> > >
> > > I do not see such a commit. My linux-next top is next-20171018
> > >
> > > [...]
> > >> Chain exists of:
> > >>   cpu_hotplug_lock.rw_sem --> &pipe->mutex/1 --> &sb->s_type->i_mutex_key#9
> > >>
> > >>  Possible unsafe locking scenario:
> > >>
> > >>        CPU0                    CPU1
> > >>        ----                    ----
> > >>   lock(&sb->s_type->i_mutex_key#9);
> > >>                                lock(&pipe->mutex/1);
> > >>                                lock(&sb->s_type->i_mutex_key#9);
> > >>   lock(cpu_hotplug_lock.rw_sem);
> > >
> > > I am quite confused about this report. Where exactly is the deadlock?
> > > I do not see where we would get pipe mutex from inside of the hotplug
> > > lock. Is it possible this is just a false possitive due to cross release
> > > feature?
> > 
> > 
> > As far as I understand this CPU0/CPU1 scheme works only for simple
> > cases with 2 mutexes. This seem to have larger cycle as denoted by
> > "the existing dependency chain (in reverse order) is:" section.
> 
> My point was that lru_add_drain_all doesn't take any external locks
> other than lru_lock and that one is not anywhere in the chain AFAICS.
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
