Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 692B46B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 10:58:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g75so14975275pfg.4
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 07:58:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si1769287plw.666.2017.10.31.07.58.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 07:58:07 -0700 (PDT)
Date: Tue, 31 Oct 2017 15:58:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171031145804.ulrpk245ih6t7q7h@dhcp22.suse.cz>
References: <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031135104.rnlytzawi2xzuih3@hirez.programming.kicks-ass.net>
 <CACT4Y+Zi_Gqh1V7QHzUdRuYQAtNjyNU2awcPOHSQYw9TsCwEsw@mail.gmail.com>
 <20171031145247.5kjbanjqged34lbp@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031145247.5kjbanjqged34lbp@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Byungchul Park <byungchul.park@lge.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Tue 31-10-17 15:52:47, Peter Zijlstra wrote:
[...]
> If we want to save those stacks; we have to save a stacktrace on _every_
> lock acquire, simply because we never know ahead of time if there will
> be a new link. Doing this is _expensive_.
> 
> Furthermore, the space into which we store stacktraces is limited;
> since memory allocators use locks we can't very well use dynamic memory
> for lockdep -- that would give recursive and robustness issues.

Wouldn't stackdepot help here? Sure the first stack unwind will be
costly but then you amortize that over time. It is quite likely that
locks are held from same addresses.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
