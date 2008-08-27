Date: Wed, 27 Aug 2008 10:26:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 10/14] memcg: replace res_counter
Message-Id: <20080827102640.dee6ab9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080827094426.2398d8c6.nishimura@mxp.nes.nec.co.jp>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203919.1aee02fc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080827094426.2398d8c6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Aug 2008 09:44:26 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> > @@ -356,7 +447,7 @@ int mem_cgroup_calc_mapped_ratio(struct 
> >  	 * usage is recorded in bytes. But, here, we assume the number of
> >  	 * physical pages can be represented by "long" on any arch.
> >  	 */
> > -	total = (long) (mem->res.usage >> PAGE_SHIFT) + 1L;
> > +	total = (long) (mem->res.pages >> PAGE_SHIFT) + 1L;
> I don't think this shift is needed.
> 
Oh, yes! thanks.

> >  	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> >  	return (int)((rss * 100L) / total);
> >  }
> 
> 
> > @@ -880,8 +971,12 @@ int mem_cgroup_resize_limit(struct mem_c
> >  	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> >  	int progress;
> >  	int ret = 0;
> > +	unsigned long new_lim = (unsigned long)(val >> PAGE_SHIFT);
> >  
> > -	while (res_counter_set_limit(&memcg->res, val)) {
> > +	if (val & PAGE_SIZE)
> > +		new_lim += 1;
> > +
> I'm sorry I can't understand here.
> 
> Should it be "val & (PAGE_SIZE-1)"?
> 
yes...will fix.

Thanks,
-Kame


> > +	while (mem_counter_set_pages_limit(memcg, new_lim)) {
> >  		if (signal_pending(current)) {
> >  			ret = -EINTR;
> >  			break;
> 
> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
