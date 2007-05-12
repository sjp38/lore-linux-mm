Date: Sat, 12 May 2007 22:03:21 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070512180321.GA320@tv-sign.ru>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl> <20070511230023.GA449@tv-sign.ru> <1178977276.6810.59.camel@twins> <20070512160428.GA173@tv-sign.ru> <1178989068.19461.3.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1178989068.19461.3.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 05/12, Peter Zijlstra wrote:
>
> On Sat, 2007-05-12 at 20:04 +0400, Oleg Nesterov wrote:
> > 
> > this code roughly does (the only reader does unlock)
> > 
> > 	READER			WRITER
> > 
> > 	readers = 0;		state = 1;
> > 	wmb();			wmb();
> > 	CHECK(state != 0)	CHECK(readers == 0)
> > 
> > We need to ensure that we can't miss both CHECKs. Either reader
> > should see RW_MUTEX_READER_SLOW, o writer sees "readers == 0"
> > and does not sleep.
> > 
> > In that case both barriers should be converted to smp_mb(). There
> > was a _long_ discussion about STORE-MB-LOAD behaviour, and experts
> > seem to believe everething is ok.
> 
> Ah, but note that both those CHECK()s have a rmb(), so that ends up
> being:
> 
> 	READER				WRITER
> 
> 	readers = 0;			state = 1;
> 	wmb();				wmb();
> 
> 	rmb();				rmb();		
> 	if (state != 0)			if (readers == 0)
> 
> and a wmb+rmb is a full mb, right?

I used to think the same, but this is wrong: wmb+rmb != mb. wmb+rmb
doesn't provide LOAD,STORE or STORE,LOAD ordering.

for example,

	LOAD;
	rmb(); wmb();
	STORE;

it is still possible that STORE comes before LOAD. At least this
is my understanding.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
