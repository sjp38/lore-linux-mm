Date: Thu, 20 Mar 2008 13:46:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/7] memcg: speed up by percpu
Message-Id: <20080320134631.aa5b80f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1205961565.6437.16.camel@lappy>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191852.50b4b569.kamezawa.hiroyu@jp.fujitsu.com>
	<1205961565.6437.16.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008 22:19:25 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > +static inline struct page_cgroup *
> > +get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
> > +{
> > +	unsigned long pfn = page_to_pfn(page);
> > +	struct page_cgroup_cache *pcp;
> > +	struct page_cgroup *ret;
> > +	unsigned long idx = pfn >> PCGRP_SHIFT;
> > +	int hnum = (idx) & (PAGE_CGROUP_NR_CACHE - 1);
> > +
> > +	preempt_disable();
> 
> get_cpu_var()
> 
> > +	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
> > +	if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base)
> > +		ret = pcp->ents[hnum].base + (pfn - (idx << PCGRP_SHIFT));
> > +	else
> > +		ret = NULL;
> > +	preempt_enable();
> 
> put_cpu_var()
> 
> > +	return (ret)? ret : __get_page_cgroup(page, gfpmask, allocate);
> 
> if (!ret)
>   ret = __get_page_cgroup();
> 
> return ret;
> 
ok, I'll fix. 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
