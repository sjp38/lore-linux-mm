Date: Sat, 21 Apr 2007 12:21:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04/10] lib: percpu_counter_mod64
Message-Id: <20070421122139.f5259c82.akpm@linux-foundation.org>
In-Reply-To: <1177153346.2934.36.camel@lappy>
References: <20070420155154.898600123@chello.nl>
	<20070420155502.787144532@chello.nl>
	<20070421025517.d9f9bc14.akpm@linux-foundation.org>
	<1177153346.2934.36.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 21 Apr 2007 13:02:26 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > > +	cpu = get_cpu();
> > > +	pcount = per_cpu_ptr(fbc->counters, cpu);
> > > +	count = *pcount + amount;
> > > +	if (count >= FBC_BATCH || count <= -FBC_BATCH) {
> > > +		spin_lock(&fbc->lock);
> > > +		fbc->count += count;
> > > +		*pcount = 0;
> > > +		spin_unlock(&fbc->lock);
> > > +	} else {
> > > +		*pcount = count;
> > > +	}
> > > +	put_cpu();
> > > +}
> > > +EXPORT_SYMBOL(percpu_counter_mod64);
> > 
> > Bloaty.  Surely we won't be needing this on 32-bit kernels?  Even monster
> > PAE has only 64,000,000 pages and won't be using deltas of more than 4
> > gigapages?
> > 
> > <Does even 64-bit need to handle 4 gigapages in a single hit?  /me suspects
> > another changelog bug>
> 
> Yeah, /me chastises himself for that...
> 
> This is because percpu_counter is s64 instead of the native long; I need
> to halve the counter at some point (bdi_writeout_norm) and do that by
> subtracting half the current value.

ah, the mysterious bdi_writeout_norm().

I don't think it's possible to precisely halve a percpu_counter - there has
to be some error involved.  I guess that's acceptable within the
inscrutable bdi_writeout_norm().

otoh, there's a chance that the attempt to halve the counter will take the
counter negative, due to races.  Does the elusive bdi_writeout_norm()
handle that?  If not, it should.  If it does, then there should be comments
around the places where this is being handled, because it is subtle, and unobvious,
and others might break it by accident.

> If percpu_counter_mod is limited to s32 this might not always work
> (although in practice it might just fit).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
