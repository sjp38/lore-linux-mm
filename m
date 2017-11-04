Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E20756B0253
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 04:45:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k9so15967846iok.4
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 01:45:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 78si7432137ioo.217.2017.11.04.01.45.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 04 Nov 2017 01:45:10 -0700 (PDT)
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to loadbalance console writes
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171103072121.3c2fd5ab@vmware.local.home>
	<20171103075404.14f9058a@vmware.local.home>
	<a53b5ca3-507d-87f4-ce31-175e848259b6@nvidia.com>
	<6b1cda44-126d-bf47-66cc-fc80bdb7eb7d@nvidia.com>
	<201711041732.BFE78178.OFFLOtVQMFHSJO@I-love.SAKURA.ne.jp>
In-Reply-To: <201711041732.BFE78178.OFFLOtVQMFHSJO@I-love.SAKURA.ne.jp>
Message-Id: <201711041743.GCG95335.OQFLJMFSHOVFtO@I-love.SAKURA.ne.jp>
Date: Sat, 4 Nov 2017 17:43:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jhubbard@nvidia.com, rostedt@goodmis.org
Cc: vbabka@suse.cz, linux-kernel@vger.kernel.org, peterz@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, yuwang.yuwang@alibaba-inc.com, torvalds@linux-foundation.org, jack@suse.cz, mathieu.desnoyers@efficios.com, penguin-kernel@I-love.SAKURA.ne.jp

Tetsuo Handa wrote:
> John Hubbard wrote:
> > On 11/03/2017 02:46 PM, John Hubbard wrote:
> > > On 11/03/2017 04:54 AM, Steven Rostedt wrote:
> > >> On Fri, 3 Nov 2017 07:21:21 -0400
> > >> Steven Rostedt <rostedt@goodmis.org> wrote:
> > [...]
> > >>
> > >> I'll condense the patch to show what I mean:
> > >>
> > >> To become a waiter, a task must do the following:
> > >>
> > >> +			printk_safe_enter_irqsave(flags);
> > >> +
> > >> +			raw_spin_lock(&console_owner_lock);
> > >> +			owner = READ_ONCE(console_owner);
> > >> +			waiter = READ_ONCE(console_waiter);
> 
> When CPU0 is writing to consoles after "console_owner = current;",
> what prevents from CPU1 and CPU2 concurrently reached this line from
> seeing waiter == false && owner != NULL && owner != current (which will
> concurrently set console_waiter = true and spin = true) without
> using atomic instructions?

Oops. I overlooked that console_owner_lock is held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
