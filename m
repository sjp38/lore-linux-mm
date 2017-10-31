Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9456B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:10:41 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id p186so44360409ioe.9
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:10:41 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z2si2069819ita.9.2017.10.31.08.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 08:10:40 -0700 (PDT)
Date: Tue, 31 Oct 2017 16:10:24 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171031151024.uhbaynabzq6k7fbc@hirez.programming.kicks-ass.net>
References: <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
 <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
 <20171031145247.5kjbanjqged34lbp@hirez.programming.kicks-ass.net>
 <20171031145804.ulrpk245ih6t7q7h@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031145804.ulrpk245ih6t7q7h@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Byungchul Park <byungchul.park@lge.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Tue, Oct 31, 2017 at 03:58:04PM +0100, Michal Hocko wrote:
> On Tue 31-10-17 15:52:47, Peter Zijlstra wrote:
> [...]
> > If we want to save those stacks; we have to save a stacktrace on _every_
> > lock acquire, simply because we never know ahead of time if there will
> > be a new link. Doing this is _expensive_.
> > 
> > Furthermore, the space into which we store stacktraces is limited;
> > since memory allocators use locks we can't very well use dynamic memory
> > for lockdep -- that would give recursive and robustness issues.
> 
> Wouldn't stackdepot help here? Sure the first stack unwind will be
> costly but then you amortize that over time. It is quite likely that
> locks are held from same addresses.

I'm not familiar with that; but looking at it, no. It uses alloc_pages()
which has locks in and it has a lock itself.

Also, it seems to index the stack based on the entire stacktrace; which
means you actually have to have the stacktrace first. And doing
stacktraces on every single acquire is horrendously expensive.

The idea just saves on storage, it doesn't help with having to do a
gazillion of unwinds in the first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
