Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C3F1C6B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 11:05:26 -0500 (EST)
Received: by ewy7 with SMTP id 7so508263ewy.10
        for <linux-mm@kvack.org>; Fri, 05 Feb 2010 08:05:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100204091938.C2C6.A69D9226@jp.fujitsu.com>
References: <1265227746.24386.15.camel@gandalf.stny.rr.com>
	 <520f0cf11002031212p4f1497e3he82dce3af668e676@mail.gmail.com>
	 <20100204091938.C2C6.A69D9226@jp.fujitsu.com>
Date: Fri, 5 Feb 2010 17:05:24 +0100
Message-ID: <520f0cf11002050805g33af2718y20b4368b0f153e98@mail.gmail.com>
Subject: Re: [RFC][PATCH] vmscan: balance local_irq_disable() and
	local_irq_enable()
From: John Kacur <jkacur@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: rostedt@goodmis.org, lkml <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 4, 2010 at 1:22 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Wed, Feb 3, 2010 at 9:09 PM, Steven Rostedt <rostedt@goodmis.org> wro=
te:
>> > t On Wed, 2010-02-03 at 20:53 +0100, John Kacur wrote:
>> >> Balance local_irq_disable() and local_irq_enable() as well as
>> >> spin_lock_irq() and spin_lock_unlock_irq
>> >>
>> >> Signed-off-by: John Kacur <jkacur@redhat.com>
>> >> ---
>> >> =A0mm/vmscan.c | =A0 =A03 ++-
>> >> =A01 files changed, 2 insertions(+), 1 deletions(-)
>> >>
>> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> index c26986c..b895025 100644
>> >> --- a/mm/vmscan.c
>> >> +++ b/mm/vmscan.c
>> >> @@ -1200,8 +1200,9 @@ static unsigned long shrink_inactive_list(unsig=
ned long max_scan,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_events(KSWAPD_=
STEAL, nr_freed);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSTEAL, zone, nr_=
freed);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
>> >>
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&zone->lru_lock);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_lock);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Put back any unfreeable pages.
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >
>> >
>> > The above looks wrong. I don't know the code, but just by looking at
>> > where the locking and interrupts are, I can take a guess.
>> >
>> > Lets add a little more of the code:
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (current_is_kswapd())
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_events(KSWAP=
D_STEAL, nr_freed);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_zone_vm_events(PGSTEAL, zone, n=
r_freed);
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&zone->lru_lock);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>> >
>> > I'm guessing the __count_zone_vm_events and friends need interrupts
>> > disabled here, probably due to per cpu stuff. But if you enable
>> > interrupts before the spin_lock() you may let an interrupt come in and
>> > invalidate what was done above it.
>> >
>> > So no, I do not think enabling interrupts here is a good thing.
>> >
>>
>> okay, and since we have already done local_irq_disable(), then that is
>> why we only need the spin_lock() and not the spin_lock_irq() flavour?
>
> Yes, spin_lock_irq() is equivalent to spin_lock() + irq_disable().
> Now, we already disabled irq. then, we only need spin_lock().
>
> So, I don't think shrink_inactive_list need any fix.
>

Thanks for the explanation!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
