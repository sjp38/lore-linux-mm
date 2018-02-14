Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 914276B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:44:37 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id f3so5966092wmc.8
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:44:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m11si2740498wmc.150.2018.02.14.07.44.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Feb 2018 07:44:36 -0800 (PST)
Date: Wed, 14 Feb 2018 16:44:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20180214154433.GD3443@dhcp22.suse.cz>
References: <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
 <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
 <20171031145247.5kjbanjqged34lbp@hirez.programming.kicks-ass.net>
 <20171031145804.ulrpk245ih6t7q7h@dhcp22.suse.cz>
 <20171031151024.uhbaynabzq6k7fbc@hirez.programming.kicks-ass.net>
 <20171101085927.GB3172@X58A-UD3R>
 <20171101120101.d6jlzwjks2j3az2v@hirez.programming.kicks-ass.net>
 <20171101235456.GA3928@X58A-UD3R>
 <CACT4Y+bvUmjkGDqoOGtMSBfqvbwF4=e8ZyiYYfq0kiVov8Ebiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bvUmjkGDqoOGtMSBfqvbwF4=e8ZyiYYfq0kiVov8Ebiw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Wed 14-02-18 15:01:38, Dmitry Vyukov wrote:
> On Thu, Nov 2, 2017 at 12:54 AM, Byungchul Park <byungchul.park@lge.com> wrote:
> > On Wed, Nov 01, 2017 at 01:01:01PM +0100, Peter Zijlstra wrote:
> >> On Wed, Nov 01, 2017 at 05:59:27PM +0900, Byungchul Park wrote:
> >> > On Tue, Oct 31, 2017 at 04:10:24PM +0100, Peter Zijlstra wrote:
> >> > > On Tue, Oct 31, 2017 at 03:58:04PM +0100, Michal Hocko wrote:
> >> > > > On Tue 31-10-17 15:52:47, Peter Zijlstra wrote:
> >> > > > [...]
> >> > > > > If we want to save those stacks; we have to save a stacktrace on _every_
> >> > > > > lock acquire, simply because we never know ahead of time if there will
> >> > > > > be a new link. Doing this is _expensive_.
> >> > > > >
> >> > > > > Furthermore, the space into which we store stacktraces is limited;
> >> > > > > since memory allocators use locks we can't very well use dynamic memory
> >> > > > > for lockdep -- that would give recursive and robustness issues.
> >> >
> >> > I agree with all you said.
> >> >
> >> > But, I have a better idea, that is, to save only the caller's ip of each
> >> > acquisition as an additional information? Of course, it's not enough in
> >> > some cases, but it's cheep and better than doing nothing.
> >> >
> >> > For example, when building A->B, let's save not only full stack of B,
> >> > but also caller's ip of A together, then use them on warning like:
> >>
> >> Like said; I've never really had trouble finding where we take A. And
> >
> > Me, either, since I know the way. But I've seen many guys who got
> > confused with it, which is why I suggested it.
> >
> > But, leave it if you don't think so.
> >
> >> for the most difficult cases, just the IP isn't too useful either.
> >>
> >> So that would solve a non problem while leaving the real problem.
> 
> 
> Hi,
> 
> What's the status of this? Was any patch submitted for this?

This http://lkml.kernel.org/r/20171116120535.23765-1-mhocko@kernel.org?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
