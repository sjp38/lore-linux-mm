Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7070A6B008C
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 15:12:45 -0500 (EST)
Received: by ewy7 with SMTP id 7so1874400ewy.10
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 12:12:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1265227746.24386.15.camel@gandalf.stny.rr.com>
References: <1265226801-6199-1-git-send-email-jkacur@redhat.com>
	 <1265226801-6199-2-git-send-email-jkacur@redhat.com>
	 <1265227746.24386.15.camel@gandalf.stny.rr.com>
Date: Wed, 3 Feb 2010 21:12:46 +0100
Message-ID: <520f0cf11002031212p4f1497e3he82dce3af668e676@mail.gmail.com>
Subject: Re: [RFC][PATCH] vmscan: balance local_irq_disable() and
	local_irq_enable()
From: John Kacur <jkacur@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: rostedt@goodmis.org
Cc: lkml <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 3, 2010 at 9:09 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> t On Wed, 2010-02-03 at 20:53 +0100, John Kacur wrote:
>> Balance local_irq_disable() and local_irq_enable() as well as
>> spin_lock_irq() and spin_lock_unlock_irq
>>
>> Signed-off-by: John Kacur <jkacur@redhat.com>
>> ---
>> =A0mm/vmscan.c | =A0 =A03 ++-
>> =A01 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index c26986c..b895025 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1200,8 +1200,9 @@ static unsigned long shrink_inactive_list(unsigned=
 long max_scan,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_events(KSWAPD_STE=
AL, nr_freed);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSTEAL, zone, nr_fre=
ed);
>> + =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&zone->lru_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Put back any unfreeable pages.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>
>
> The above looks wrong. I don't know the code, but just by looking at
> where the locking and interrupts are, I can take a guess.
>
> Lets add a little more of the code:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (current_is_kswapd())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_events(KSWAPD_S=
TEAL, nr_freed);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_zone_vm_events(PGSTEAL, zone, nr_f=
reed);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&zone->lru_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>
> I'm guessing the __count_zone_vm_events and friends need interrupts
> disabled here, probably due to per cpu stuff. But if you enable
> interrupts before the spin_lock() you may let an interrupt come in and
> invalidate what was done above it.
>
> So no, I do not think enabling interrupts here is a good thing.
>

okay, and since we have already done local_irq_disable(), then that is
why we only need the spin_lock() and not the spin_lock_irq() flavour?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
