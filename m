Subject: Re: [PATCH 6/7] memcg: speed up by percpu
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1205961565.6437.16.camel@lappy>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080314191852.50b4b569.kamezawa.hiroyu@jp.fujitsu.com>
	 <1205961565.6437.16.camel@lappy>
Content-Type: text/plain
Date: Wed, 19 Mar 2008 22:41:56 +0100
Message-Id: <1205962916.6437.36.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, apw <apw@shadowen.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-03-19 at 22:19 +0100, Peter Zijlstra wrote:

> > +static void save_result(struct page_cgroup  *base, unsigned long idx)
> > +{
> > +	int hash = idx & (PAGE_CGROUP_NR_CACHE - 1);
> > +	struct page_cgroup_cache *pcp;
> > +	/* look up is done under preempt_disable(). then, don't call
> > +	   this under interrupt(). */
> > +	preempt_disable();
> > +	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
> > +	pcp->ents[hash].idx = idx;
> > +	pcp->ents[hash].base = base;
> > +	preempt_enable();
> > +}

Another instance where get_cpu_var(), put_cpu_var() would be preferable.

Raw preempt_{disable,enable)() calls are discouraged, because just as
the BKL they are opaque, they don't tell us what data is protected from
what, or if we rely upon interaction with the RCU grace period or things
like that.

These things are a pain to sort out if you try to change the preemption
model after a few years.

Ingo, does it make sense to make checkpatch.pl warn about raw
preempt_{disable,enable} calls?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
