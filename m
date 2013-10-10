Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE9A6B0037
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:03:33 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so2094518pbc.25
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 00:03:32 -0700 (PDT)
Date: Thu, 10 Oct 2013 15:03:24 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [uml-devel] BUG: soft lockup for a user mode linux image
Message-ID: <20131010070324.GA24244@localhost>
References: <CAMuHMdXrU0e_6AxvdboMkDs+N+tSWD+b8ou92j28c0vsq2eQQA@mail.gmail.com>
 <5251C334.3010604@gmx.de>
 <CAMuHMdUo8dSd4s3089ZDEc485wL1sFxBKLeaExJuqNiQY+S-Lw@mail.gmail.com>
 <5251CF94.5040101@gmx.de>
 <CAMuHMdWs6Y7y12STJ+YXKJjxRF0k5yU9C9+0fiPPmq-GgeW-6Q@mail.gmail.com>
 <525591AD.4060401@gmx.de>
 <5255A3E6.6020100@nod.at>
 <20131009214733.GB25608@quack.suse.cz>
 <20131010024613.GA10719@localhost>
 <CAMuHMdWSQrgMtW84QLs1Q96Jg-sYntS9Ohz-sXd3dWhuR2O7mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMuHMdWSQrgMtW84QLs1Q96Jg-sYntS9Ohz-sXd3dWhuR2O7mw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Jan Kara <jack@suse.cz>, Richard Weinberger <richard@nod.at>, Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Benjamin LaHaise <bcrl@kvack.org>

On Thu, Oct 10, 2013 at 08:52:33AM +0200, Geert Uytterhoeven wrote:
> On Thu, Oct 10, 2013 at 4:46 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> > On Wed, Oct 09, 2013 at 11:47:33PM +0200, Jan Kara wrote:
> >> On Wed 09-10-13 20:43:50, Richard Weinberger wrote:
> >> > Am 09.10.2013 19:26, schrieb Toralf FA?rster:
> >> > > On 10/08/2013 10:07 PM, Geert Uytterhoeven wrote:
> >> > >> On Sun, Oct 6, 2013 at 11:01 PM, Toralf FA?rster <toralf.foerster@gmx.de> wrote:
> >> > >>>> Hmm, now pages_dirtied is zero, according to the backtrace, but the BUG_ON()
> >> > >>>> asserts its strict positive?!?
> >> > >>>>
> >> > >>>> Can you please try the following instead of the BUG_ON():
> >> > >>>>
> >> > >>>> if (pause < 0) {
> >> > >>>>         printk("pages_dirtied = %lu\n", pages_dirtied);
> >> > >>>>         printk("task_ratelimit = %lu\n", task_ratelimit);
> >> > >>>>         printk("pause = %ld\n", pause);
> 
> >> > >>> I tried it in different ways already - I'm completely unsuccessful in getting any printk output.
> >> > >>> As soon as the issue happens I do have a
> >> > >>>
> >> > >>> BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child0:1521]
> >> > >>>
> >> > >>> at stderr of the UML and then no further input is accepted. With uml_mconsole I'm however able
> >> > >>> to run very basic commands like a crash dump, sysrq ond so on.
> >> > >>
> >> > >> You may get an idea of the magnitude of pages_dirtied by using a chain of
> >> > >> BUG_ON()s, like:
> >> > >>
> >> > >> BUG_ON(pages_dirtied > 2000000000);
> >> > >> BUG_ON(pages_dirtied > 1000000000);
> >> > >> BUG_ON(pages_dirtied > 100000000);
> >> > >> BUG_ON(pages_dirtied > 10000000);
> >> > >> BUG_ON(pages_dirtied > 1000000);
> >> > >>
> >> > >> Probably 1 million is already too much for normal operation?
> >> > >>
> >> > > period = HZ * pages_dirtied / task_ratelimit;
> >> > >           BUG_ON(pages_dirtied > 2000000000);
> >> > >           BUG_ON(pages_dirtied > 1000000000);      <-------------- this is line 1467
> >> >
> >> > Summary for mm people:
> >> >
> >> > Toralf runs trinty on UML/i386.
> >> > After some time pages_dirtied becomes very large.
> >> > More than 1000000000 pages in this case.
> >>   Huh, this is really strange. pages_dirtied is passed into
> >> balance_dirty_pages() from current->nr_dirtied. So I wonder how a value
> >> over 10^9 can get there.
> >
> > I noticed aio_setup_ring() in the call trace and find it recently
> > added a SetPageDirty() call in a loop by commit 36bc08cc01 ("fs/aio:
> > Add support to aio ring pages migration"). So added CC to its authors.
> >
> >> After all that is over 4TB so I somewhat doubt the
> >> task was ever able to dirty that much during its lifetime (but correct me
> >> if I'm wrong here, with UML and memory backed disks it is not totally
> >> impossible)... I went through the logic of handling ->nr_dirtied but
> >> I didn't find any obvious problem there. Hum, maybe one thing - what
> >> 'task_ratelimit' values do you see in balance_dirty_pages? If that one was
> >> huge, we could possibly accumulate huge current->nr_dirtied.
> >>
> >> > Thus, period = HZ * pages_dirtied / task_ratelimit overflows
> >> > and period/pause becomes extremely large.
> 
> period/pause are signed long, so they become negative instead of
> extremely large when overflowing.

Yeah. For that we have underflow detect as well: 

                if (pause < min_pause) {
                        ...
                        break;
                }

So we'll break out of the loop -- but yeah, whether the break is the
right behavior on underflow is still questionable.

> >> > It looks like io_schedule_timeout() get's called with a very large timeout.
> >> > I don't know why "if (unlikely(pause > max_pause)) {" does not help.
> 
> Because pause is now negative.

So here io_schedule_timeout() won't be called with negative pause.

And if ever io_schedule_timeout() calls schedule_timeout() with
negative timeout, the latter will emit a warning and break out, too:

                if (timeout < 0) {
                        printk(KERN_ERR "schedule_timeout: wrong timeout "
                                "value %lx\n", timeout);
                        dump_stack();
                        current->state = TASK_RUNNING;
                        goto out;
                }

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
