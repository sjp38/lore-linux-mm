Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0786B025E
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 08:01:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 15so2347968pgc.16
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 05:01:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q81si726792pfi.503.2017.11.01.05.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 05:01:12 -0700 (PDT)
Date: Wed, 1 Nov 2017 13:01:01 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171101120101.d6jlzwjks2j3az2v@hirez.programming.kicks-ass.net>
References: <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
 <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
 <20171031145247.5kjbanjqged34lbp@hirez.programming.kicks-ass.net>
 <20171031145804.ulrpk245ih6t7q7h@dhcp22.suse.cz>
 <20171031151024.uhbaynabzq6k7fbc@hirez.programming.kicks-ass.net>
 <20171101085927.GB3172@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171101085927.GB3172@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Wed, Nov 01, 2017 at 05:59:27PM +0900, Byungchul Park wrote:
> On Tue, Oct 31, 2017 at 04:10:24PM +0100, Peter Zijlstra wrote:
> > On Tue, Oct 31, 2017 at 03:58:04PM +0100, Michal Hocko wrote:
> > > On Tue 31-10-17 15:52:47, Peter Zijlstra wrote:
> > > [...]
> > > > If we want to save those stacks; we have to save a stacktrace on _every_
> > > > lock acquire, simply because we never know ahead of time if there will
> > > > be a new link. Doing this is _expensive_.
> > > > 
> > > > Furthermore, the space into which we store stacktraces is limited;
> > > > since memory allocators use locks we can't very well use dynamic memory
> > > > for lockdep -- that would give recursive and robustness issues.
> 
> I agree with all you said.
> 
> But, I have a better idea, that is, to save only the caller's ip of each
> acquisition as an additional information? Of course, it's not enough in
> some cases, but it's cheep and better than doing nothing.
> 
> For example, when building A->B, let's save not only full stack of B,
> but also caller's ip of A together, then use them on warning like:

Like said; I've never really had trouble finding where we take A. And
for the most difficult cases, just the IP isn't too useful either.

So that would solve a non problem while leaving the real problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
