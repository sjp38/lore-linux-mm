Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E57A6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 06:09:59 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w12-v6so17854951plp.9
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:09:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 12-v6sor21142376pfm.46.2018.10.22.03.09.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 03:09:58 -0700 (PDT)
Date: Mon, 22 Oct 2018 19:09:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181022100952.GA1147@jagdpanzerIV>
References: <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
 <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
 <20181004074442.GA12879@jagdpanzerIV>
 <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
 <20181004085515.GC12879@jagdpanzerIV>
 <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: sergey.senozhatsky.work@gmail.com, Petr Mladek <pmladek@suse.com>, rostedt@goodmis.org, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (10/21/18 11:09), Daniel Wang wrote:
> 
> Just got back from vacation. Thanks for the continued discussion. Just so
> I understand the current state. Looks like we've got a pretty good explanation
> of what's going on (though not completely sure), and backporting Steven's
> patches is still the way to go?

Up to -stable maintainers.

Note, with or without Steven's patch, the non-reentrable consoles are
still non-reentrable, so the deadlock is still there:

	spin_lock_irqsave(&port->lock, flags)
	 <NMI>
	  panic()
	   console_flush_on_panic()
	    spin_lock_irqsave(&port->lock, flags)		// deadlock


// And I wouldn't mind to have more reviews/testing on [1].


Another deadlock scenario could be the following one:

	printk()
	 console_trylock()
	  down_trylock()
	   raw_spin_lock_irqsave(&sem->lock, flags)
	    <NMI>
	     panic()
	      console_flush_on_panic()
	       console_trylock()
	        raw_spin_lock_irqsave(&sem->lock, flags)	// deadlock

There are no patches addressing this one at the moment. And it's
unclear if you are hitting this scenario.


> I see that Sergey had sent an RFC series for similar things. Are those
> trying to solve the deadlock problem in a different way?

Umm, I wouldn't call it "another way". It turns non-reentrant serial
consoles to re-entrable ones. Did you test patch [1] from that series
on you environment, by the way?

[1] lkml.kernel.org/r/20181016050428.17966-2-sergey.senozhatsky@gmail.com

	-ss
