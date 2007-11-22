Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [4/10]
 calculate mapped ratio for memory cgroup
In-Reply-To: Your message of "Thu, 22 Nov 2007 17:40:15 +0900"
	<20071122174015.c5ef61ae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071122174015.c5ef61ae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20071122084647.485981CEE98@siro.lan>
Date: Thu, 22 Nov 2007 17:46:47 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 22 Nov 2007 17:34:20 +0900 (JST)
> yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> 
> > > > > +	/* usage is recorded in bytes */
> > > > > +	total = mem->res.usage >> PAGE_SHIFT;
> > > > > +	rss = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> > > > > +	return (rss * 100) / total;
> > > > 
> > > > Never tried 64 bit division on a 32 bit system. I hope we don't
> > > > have to resort to do_div() sort of functionality.
> > > > 
> > > Hmm, maybe it's better to make these numebrs be just "long".
> > > I'll try to change per-cpu-counter implementation.
> > > 
> > > Thanks,
> > > -Kame
> > 
> > besides that, i think 'total' can be zero here.
> > 
> Ah, This is what I do now.
> ==
> +/*
> + * Calculate mapped_ratio under memory controller. This will be used in
> + * vmscan.c for deteremining we have to reclaim mapped pages.
> + */
> +int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
> +{
> +       long total, rss;
> +
> +       /*
> +        * usage is recorded in bytes. But, here, we assume the number of
> +        * physical pages can be represented by "long" on any arch.
> +        */
> +       total = (long) (mem->res.usage >> PAGE_SHIFT);
> +       rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> +       return (int)((rss * 100L) / total);
> +}
> ==
> 
> maybe works well.
> 
> -Kame

i meant that "/ total" can cause a division-by-zero exception.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
