Date: Mon, 25 Feb 2008 14:46:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [7/7] per cpu fast
 lookup
Message-Id: <20080225144620.e9b83a51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225053640.8C1131E3C63@siro.lan>
References: <20080225121849.191ac900.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225053640.8C1131E3C63@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, taka@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 14:36:40 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > +
> > +static void save_result(struct page_cgroup  *base, unsigned long idx)
> > +{
> > +	int hash = idx & (PAGE_CGROUP_NR_CACHE - 1);
> > +	struct page_cgroup_cache *pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
> > +	preempt_disable();
> > +	pcp->ents[hash].idx = idx;
> > +	pcp->ents[hash].base = base;
> > +	preempt_enable();
> 
> preempt_disable after __get_cpu_var doesn't make much sense.
> it should be get_cpu_var and put_cpu_var.
> 
I'm sorry that local_cpu_var doesn't take id of local cpu. 
will fix.


> > -struct page_cgroup *get_page_cgroup(struct page *page, gfp_t gfpmask);
> > +struct page_cgroup *__get_page_cgroup(struct page *page, gfp_t gfpmask);
> > +
> > +static inline struct page_cgroup *
> > +get_page_cgroup(struct page *page, gfp_t gfpmask)
> > +{
> > +	unsigned long pfn = page_to_pfn(page);
> > +	struct page_cgroup_cache *pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
> > +	struct page_cgroup *ret;
> > +	unsigned long idx = pfn >> PCGRP_SHIFT;
> > +	int hnum = (idx) & (PAGE_CGROUP_NR_CACHE - 1);
> > +
> > +	preempt_disable();
> > +	if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base)
> > +		ret = pcp->ents[hnum].base + (pfn - (idx << PCGRP_SHIFT));
> > +	else
> > +		ret = NULL;
> > +	preempt_enable();
> 
> ditto.
> 

Thank you for pointing out.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
