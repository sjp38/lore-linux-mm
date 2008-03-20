Date: Thu, 20 Mar 2008 09:08:26 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 6/7] memcg: speed up by percpu
Message-ID: <20080320090810.GA12798@shadowen.org>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314191852.50b4b569.kamezawa.hiroyu@jp.fujitsu.com> <1205961565.6437.16.camel@lappy> <1205962916.6437.36.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1205962916.6437.36.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 19, 2008 at 10:41:56PM +0100, Peter Zijlstra wrote:
> On Wed, 2008-03-19 at 22:19 +0100, Peter Zijlstra wrote:
> 
> > > +static void save_result(struct page_cgroup  *base, unsigned long idx)
> > > +{
> > > +	int hash = idx & (PAGE_CGROUP_NR_CACHE - 1);
> > > +	struct page_cgroup_cache *pcp;
> > > +	/* look up is done under preempt_disable(). then, don't call
> > > +	   this under interrupt(). */
> > > +	preempt_disable();
> > > +	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
> > > +	pcp->ents[hash].idx = idx;
> > > +	pcp->ents[hash].base = base;
> > > +	preempt_enable();
> > > +}
> 
> Another instance where get_cpu_var(), put_cpu_var() would be preferable.
> 
> Raw preempt_{disable,enable)() calls are discouraged, because just as
> the BKL they are opaque, they don't tell us what data is protected from
> what, or if we rely upon interaction with the RCU grace period or things
> like that.
> 
> These things are a pain to sort out if you try to change the preemption
> model after a few years.
> 
> Ingo, does it make sense to make checkpatch.pl warn about raw
> preempt_{disable,enable} calls?

That signature would likely be detectable even if all preempt_disable()s
were not reportable.  I do wonder looking at the shape of that whether
there is a ganged version for where you want more than one variable; I
can't see one.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
