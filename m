Date: Sat, 12 May 2007 20:04:28 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070512160428.GA173@tv-sign.ru>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl> <20070511230023.GA449@tv-sign.ru> <1178977276.6810.59.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1178977276.6810.59.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 05/12, Peter Zijlstra wrote:
>
> +static inline void rw_mutex_readers_dec(struct rw_mutex *rw_mutex)
> +{
> +	percpu_counter_dec(&rw_mutex->readers);
> +	smp_wmb();
> +}
>
> +void rw_mutex_read_unlock(struct rw_mutex *rw_mutex)
> +{
> +	rw_mutex_readers_dec(rw_mutex);
> +	/*
> +	 * on the slow path;
> +	 * nudge the writer waiting for the last reader to go away
> +	 */
> +	if (unlikely(rw_mutex_reader_slow(rw_mutex)))
> +		rw_mutex_writer_wake(rw_mutex);
> +}
>
> +void rw_mutex_write_lock_nested(struct rw_mutex *rw_mutex, int subclass)
> +{
> +	mutex_lock_nested(&rw_mutex->write_mutex, subclass);
> +
> +	/*
> +	 * block new readers
> +	 */
> +	mutex_lock_nested(&rw_mutex->read_mutex, subclass);
> +	rw_mutex_status_set(rw_mutex, RW_MUTEX_READER_SLOW);
> +	/*
> +	 * and wait for all current readers to go away
> +	 */
> +	rw_mutex_writer_wait(rw_mutex, (rw_mutex_readers(rw_mutex) == 0));
> +}

I think this is still not right, but when it comes to barriers we
need a true expert (Paul cc-ed).

this code roughly does (the only reader does unlock)

	READER			WRITER

	readers = 0;		state = 1;
	wmb();			wmb();
	CHECK(state != 0)	CHECK(readers == 0)

We need to ensure that we can't miss both CHECKs. Either reader
should see RW_MUTEX_READER_SLOW, o writer sees "readers == 0"
and does not sleep.

In that case both barriers should be converted to smp_mb(). There
was a _long_ discussion about STORE-MB-LOAD behaviour, and experts
seem to believe everething is ok.

Another question. Isn't it possible to kill rw_mutex->status ?

I have a vague feeling you can change the code so that

	rw_mutex_reader_slow() <=> "->waiter != NULL"

, but I am not sure.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
