Subject: Re: [PATCH 04/10] lib: percpu_counter_mod64
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070421025517.d9f9bc14.akpm@linux-foundation.org>
References: <20070420155154.898600123@chello.nl>
	 <20070420155502.787144532@chello.nl>
	 <20070421025517.d9f9bc14.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Sat, 21 Apr 2007 13:02:26 +0200
Message-Id: <1177153346.2934.36.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 2007-04-21 at 02:55 -0700, Andrew Morton wrote:
> On Fri, 20 Apr 2007 17:51:58 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Add percpu_counter_mod64() to allow large modifications.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  include/linux/percpu_counter.h |    9 +++++++++
> >  lib/percpu_counter.c           |   28 ++++++++++++++++++++++++++++
> >  2 files changed, 37 insertions(+)
> > 
> > Index: linux-2.6/include/linux/percpu_counter.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/percpu_counter.h	2007-04-12 13:54:55.000000000 +0200
> > +++ linux-2.6/include/linux/percpu_counter.h	2007-04-12 14:00:21.000000000 +0200
> > @@ -36,6 +36,7 @@ static inline void percpu_counter_destro
> >  }
> >  
> >  void percpu_counter_mod(struct percpu_counter *fbc, s32 amount);
> > +void percpu_counter_mod64(struct percpu_counter *fbc, s64 amount);
> >  s64 percpu_counter_sum(struct percpu_counter *fbc);
> >  
> >  static inline s64 percpu_counter_read(struct percpu_counter *fbc)
> > @@ -81,6 +82,14 @@ percpu_counter_mod(struct percpu_counter
> >  	preempt_enable();
> >  }
> >  
> > +static inline void
> > +percpu_counter_mod64(struct percpu_counter *fbc, s64 amount)
> > +{
> > +	preempt_disable();
> > +	fbc->count += amount;
> > +	preempt_enable();
> > +}
> > +
> >  static inline s64 percpu_counter_read(struct percpu_counter *fbc)
> >  {
> >  	return fbc->count;
> > Index: linux-2.6/lib/percpu_counter.c
> > ===================================================================
> > --- linux-2.6.orig/lib/percpu_counter.c	2006-07-31 13:07:38.000000000 +0200
> > +++ linux-2.6/lib/percpu_counter.c	2007-04-12 14:17:12.000000000 +0200
> > @@ -25,6 +25,34 @@ void percpu_counter_mod(struct percpu_co
> >  }
> >  EXPORT_SYMBOL(percpu_counter_mod);
> >  
> > +void percpu_counter_mod64(struct percpu_counter *fbc, s64 amount)
> > +{
> > +	long count;
> > +	s32 *pcount;
> > +	int cpu;
> > +
> > +	if (amount >= FBC_BATCH || amount <= -FBC_BATCH) {
> > +		spin_lock(&fbc->lock);
> > +		fbc->count += amount;
> > +		spin_unlock(&fbc->lock);
> > +		return;
> > +	}
> 
> This is wrong, a little.
> 
> If the counter was at -FBC_BATCH/2 and the caller passed in FBC_BATCH, we
> could just set the cpu-local counter to FBC_BATCH/2 instead of going for
> the lock.
> 
> Probably doesn't matter though.

Right, I could have taken along the current percpu offset.

> > +	cpu = get_cpu();
> > +	pcount = per_cpu_ptr(fbc->counters, cpu);
> > +	count = *pcount + amount;
> > +	if (count >= FBC_BATCH || count <= -FBC_BATCH) {
> > +		spin_lock(&fbc->lock);
> > +		fbc->count += count;
> > +		*pcount = 0;
> > +		spin_unlock(&fbc->lock);
> > +	} else {
> > +		*pcount = count;
> > +	}
> > +	put_cpu();
> > +}
> > +EXPORT_SYMBOL(percpu_counter_mod64);
> 
> Bloaty.  Surely we won't be needing this on 32-bit kernels?  Even monster
> PAE has only 64,000,000 pages and won't be using deltas of more than 4
> gigapages?
> 
> <Does even 64-bit need to handle 4 gigapages in a single hit?  /me suspects
> another changelog bug>

Yeah, /me chastises himself for that...

This is because percpu_counter is s64 instead of the native long; I need
to halve the counter at some point (bdi_writeout_norm) and do that by
subtracting half the current value.

If percpu_counter_mod is limited to s32 this might not always work
(although in practice it might just fit).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
