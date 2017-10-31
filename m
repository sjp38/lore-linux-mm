Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 692266B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 10:53:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v78so16999643pgb.18
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 07:53:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o9si1686835pge.179.2017.10.31.07.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 07:53:00 -0700 (PDT)
Date: Tue, 31 Oct 2017 15:52:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171031145247.5kjbanjqged34lbp@hirez.programming.kicks-ass.net>
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
 <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Byungchul Park <byungchul.park@lge.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Tue, Oct 31, 2017 at 04:55:32PM +0300, Dmitry Vyukov wrote:

> I noticed that for a simple 2 lock deadlock lockdep prints only 2
> stacks.

3, one of which is useless :-)

For the AB-BA we print where we acquire A (#0) where we acquire B while
holding A #1 and then where we acquire B while holding A the unwind at
point of splat.

The #0 trace is useless.

> FWIW in user-space TSAN we print 4 stacks for such deadlocks,
> namely where A was locked, where B was locked under A, where B was
> locked, where A was locked under B. It makes it easier to figure out
> what happens. However, for this report it seems to be 8 stacks this
> way. So it's probably hard either way.

Right, its a question of performance and overhead I suppose. Lockdep
typically only saves a stack trace when it finds a new link.

So only when we find the AB relation do we save the stacktrace; which
reflects the location where we acquire B. But by that time we've lost
where it was we acquire A.

If we want to save those stacks; we have to save a stacktrace on _every_
lock acquire, simply because we never know ahead of time if there will
be a new link. Doing this is _expensive_.

Furthermore, the space into which we store stacktraces is limited;
since memory allocators use locks we can't very well use dynamic memory
for lockdep -- that would give recursive and robustness issues.

Also, its usually not too hard to find the site where we took A if we
know the site of AB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
