Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D7B036B0037
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 03:00:01 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so2152156pde.24
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 00:00:01 -0700 (PDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2110848pbb.13
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 23:59:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131010024613.GA10719@localhost>
References: <524E57BA.805@nod.at>
	<52517109.90605@gmx.de>
	<CAMuHMdXrU0e_6AxvdboMkDs+N+tSWD+b8ou92j28c0vsq2eQQA@mail.gmail.com>
	<5251C334.3010604@gmx.de>
	<CAMuHMdUo8dSd4s3089ZDEc485wL1sFxBKLeaExJuqNiQY+S-Lw@mail.gmail.com>
	<5251CF94.5040101@gmx.de>
	<CAMuHMdWs6Y7y12STJ+YXKJjxRF0k5yU9C9+0fiPPmq-GgeW-6Q@mail.gmail.com>
	<525591AD.4060401@gmx.de>
	<5255A3E6.6020100@nod.at>
	<20131009214733.GB25608@quack.suse.cz>
	<20131010024613.GA10719@localhost>
Date: Thu, 10 Oct 2013 08:52:33 +0200
Message-ID: <CAMuHMdWSQrgMtW84QLs1Q96Jg-sYntS9Ohz-sXd3dWhuR2O7mw@mail.gmail.com>
Subject: Re: [uml-devel] BUG: soft lockup for a user mode linux image
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Richard Weinberger <richard@nod.at>, =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Benjamin LaHaise <bcrl@kvack.org>

On Thu, Oct 10, 2013 at 4:46 AM, Fengguang Wu <fengguang.wu@intel.com> wrot=
e:
> On Wed, Oct 09, 2013 at 11:47:33PM +0200, Jan Kara wrote:
>> On Wed 09-10-13 20:43:50, Richard Weinberger wrote:
>> > Am 09.10.2013 19:26, schrieb Toralf F=C3=B6rster:
>> > > On 10/08/2013 10:07 PM, Geert Uytterhoeven wrote:
>> > >> On Sun, Oct 6, 2013 at 11:01 PM, Toralf F=C3=B6rster <toralf.foerst=
er@gmx.de> wrote:
>> > >>>> Hmm, now pages_dirtied is zero, according to the backtrace, but t=
he BUG_ON()
>> > >>>> asserts its strict positive?!?
>> > >>>>
>> > >>>> Can you please try the following instead of the BUG_ON():
>> > >>>>
>> > >>>> if (pause < 0) {
>> > >>>>         printk("pages_dirtied =3D %lu\n", pages_dirtied);
>> > >>>>         printk("task_ratelimit =3D %lu\n", task_ratelimit);
>> > >>>>         printk("pause =3D %ld\n", pause);

>> > >>> I tried it in different ways already - I'm completely unsuccessful=
 in getting any printk output.
>> > >>> As soon as the issue happens I do have a
>> > >>>
>> > >>> BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child0:1521]
>> > >>>
>> > >>> at stderr of the UML and then no further input is accepted. With u=
ml_mconsole I'm however able
>> > >>> to run very basic commands like a crash dump, sysrq ond so on.
>> > >>
>> > >> You may get an idea of the magnitude of pages_dirtied by using a ch=
ain of
>> > >> BUG_ON()s, like:
>> > >>
>> > >> BUG_ON(pages_dirtied > 2000000000);
>> > >> BUG_ON(pages_dirtied > 1000000000);
>> > >> BUG_ON(pages_dirtied > 100000000);
>> > >> BUG_ON(pages_dirtied > 10000000);
>> > >> BUG_ON(pages_dirtied > 1000000);
>> > >>
>> > >> Probably 1 million is already too much for normal operation?
>> > >>
>> > > period =3D HZ * pages_dirtied / task_ratelimit;
>> > >           BUG_ON(pages_dirtied > 2000000000);
>> > >           BUG_ON(pages_dirtied > 1000000000);      <-------------- t=
his is line 1467
>> >
>> > Summary for mm people:
>> >
>> > Toralf runs trinty on UML/i386.
>> > After some time pages_dirtied becomes very large.
>> > More than 1000000000 pages in this case.
>>   Huh, this is really strange. pages_dirtied is passed into
>> balance_dirty_pages() from current->nr_dirtied. So I wonder how a value
>> over 10^9 can get there.
>
> I noticed aio_setup_ring() in the call trace and find it recently
> added a SetPageDirty() call in a loop by commit 36bc08cc01 ("fs/aio:
> Add support to aio ring pages migration"). So added CC to its authors.
>
>> After all that is over 4TB so I somewhat doubt the
>> task was ever able to dirty that much during its lifetime (but correct m=
e
>> if I'm wrong here, with UML and memory backed disks it is not totally
>> impossible)... I went through the logic of handling ->nr_dirtied but
>> I didn't find any obvious problem there. Hum, maybe one thing - what
>> 'task_ratelimit' values do you see in balance_dirty_pages? If that one w=
as
>> huge, we could possibly accumulate huge current->nr_dirtied.
>>
>> > Thus, period =3D HZ * pages_dirtied / task_ratelimit overflows
>> > and period/pause becomes extremely large.

period/pause are signed long, so they become negative instead of
extremely large when overflowing.

>> > It looks like io_schedule_timeout() get's called with a very large tim=
eout.
>> > I don't know why "if (unlikely(pause > max_pause)) {" does not help.

Because pause is now negative.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
