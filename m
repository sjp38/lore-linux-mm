Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4314B6B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:57:49 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r6so5745958pfk.9
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:57:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 92-v6sor39699pli.74.2018.02.14.07.57.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 07:57:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180214154433.GD3443@dhcp22.suse.cz>
References: <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
 <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
 <20171031145247.5kjbanjqged34lbp@hirez.programming.kicks-ass.net>
 <20171031145804.ulrpk245ih6t7q7h@dhcp22.suse.cz> <20171031151024.uhbaynabzq6k7fbc@hirez.programming.kicks-ass.net>
 <20171101085927.GB3172@X58A-UD3R> <20171101120101.d6jlzwjks2j3az2v@hirez.programming.kicks-ass.net>
 <20171101235456.GA3928@X58A-UD3R> <CACT4Y+bvUmjkGDqoOGtMSBfqvbwF4=e8ZyiYYfq0kiVov8Ebiw@mail.gmail.com>
 <20180214154433.GD3443@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 14 Feb 2018 16:57:27 +0100
Message-ID: <CACT4Y+bMaQx3yoXYS6pxKzpU-vfTqN0hdhuigfRjMQVV24awew@mail.gmail.com>
Subject: Re: possible deadlock in lru_add_drain_all
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Wed, Feb 14, 2018 at 4:44 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> > > > [...]
>> >> > > > > If we want to save those stacks; we have to save a stacktrace on _every_
>> >> > > > > lock acquire, simply because we never know ahead of time if there will
>> >> > > > > be a new link. Doing this is _expensive_.
>> >> > > > >
>> >> > > > > Furthermore, the space into which we store stacktraces is limited;
>> >> > > > > since memory allocators use locks we can't very well use dynamic memory
>> >> > > > > for lockdep -- that would give recursive and robustness issues.
>> >> >
>> >> > I agree with all you said.
>> >> >
>> >> > But, I have a better idea, that is, to save only the caller's ip of each
>> >> > acquisition as an additional information? Of course, it's not enough in
>> >> > some cases, but it's cheep and better than doing nothing.
>> >> >
>> >> > For example, when building A->B, let's save not only full stack of B,
>> >> > but also caller's ip of A together, then use them on warning like:
>> >>
>> >> Like said; I've never really had trouble finding where we take A. And
>> >
>> > Me, either, since I know the way. But I've seen many guys who got
>> > confused with it, which is why I suggested it.
>> >
>> > But, leave it if you don't think so.
>> >
>> >> for the most difficult cases, just the IP isn't too useful either.
>> >>
>> >> So that would solve a non problem while leaving the real problem.
>>
>>
>> Hi,
>>
>> What's the status of this? Was any patch submitted for this?
>
> This http://lkml.kernel.org/r/20171116120535.23765-1-mhocko@kernel.org?

Thanks

Let's tell syzbot:

#syz fix: mm: drop hotplug lock from lru_add_drain_all()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
