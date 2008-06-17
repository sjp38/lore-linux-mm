Date: Tue, 17 Jun 2008 19:00:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: reduce usage at change limit
Message-Id: <20080617190055.2b55ba0b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080617130656.bcd3ca85.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080617123144.ce5a74fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20080617123604.c8cb1bd5.kamezawa.hiroyu@jp.fujitsu.com>
	<48573397.608@linux.vnet.ibm.com>
	<20080617130656.bcd3ca85.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Jun 2008 13:06:56 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 17 Jun 2008 09:16:31 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > KAMEZAWA Hiroyuki wrote:
> > > Reduce the usage of res_counter at the change of limit.
> > > 
> > > Changelog v4 -> v5.
> > >  - moved "feedback" alogrithm from res_counter to memcg.
> > > 
> > > Background:
> > >  - Now, mem->usage is not reduced at limit change. So, the users will see
> > >    usage > limit case in memcg every time. This patch fixes it.
> > > 
> > >  Before:
> > >  - no usage change at setting limit.
> > >  - setting limit always returns 0 even if usage can never be less than zero.
> > >    (This can happen when memory is locked or there is no swap.)
> > >  - This is BUG, I think.
> > >  After:
> > >  - usage will be less than new limit at limit change.
> > >  - set limit returns -EBUSY when the usage cannot be reduced.
> > > 
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > ---
> > >  Documentation/controllers/memory.txt |    3 -
> > >  mm/memcontrol.c                      |   68 ++++++++++++++++++++++++++++-------
> > >  2 files changed, 56 insertions(+), 15 deletions(-)
> > > 
> > > Index: mm-2.6.26-rc5-mm3/mm/memcontrol.c
> > > ===================================================================
> > > --- mm-2.6.26-rc5-mm3.orig/mm/memcontrol.c
> > > +++ mm-2.6.26-rc5-mm3/mm/memcontrol.c
> > > @@ -852,18 +852,30 @@ out:
> > >  	css_put(&mem->css);
> > >  	return ret;
> > >  }
> > > +/*
> > > + * try to set limit and reduce usage if necessary.
> > > + * returns 0 at success.
> > > + * returns -EBUSY if memory cannot be dropped.
> > > + */
> > > 
> > > -static int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
> > > +static inline int mem_cgroup_resize_limit(struct cgroup *cont,
> > > +					unsigned long long val)
> > >  {
> > > -	*tmp = memparse(buf, &buf);
> > > -	if (*buf != '\0')
> > > -		return -EINVAL;
> > > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> > > +	int retry_count = 0;
> > > +	int progress;
> > > 
> > > -	/*
> > > -	 * Round up the value to the closest page size
> > > -	 */
> > > -	*tmp = ((*tmp + PAGE_SIZE - 1) >> PAGE_SHIFT) << PAGE_SHIFT;
> > > -	return 0;
> > > +retry:
> > > +	if (!res_counter_set_limit(&memcg->res, val))
> > > +		return 0;
> > > +	if (retry_count == MEM_CGROUP_RECLAIM_RETRIES)
> > > +		return -EBUSY;
> > > +
> > > +	cond_resched();
> > 
> > Do we really need this? We do have cond_resched in shrink_page_list(),
> > shrink_active_list(), do we need it here as well?
> > 
> I'd like to add this when adding a busy loop. But ok, will remove.
> 
> > > +	progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
> > > +	if (!progress)
> > > +		retry_count++;
> > > +	goto retry;
> > 
> > I don't like upward goto's. Can't we convert this to a nice do {} while or
> > while() loop?
> > 
> Hmm, ok.
> 
> I'll repost later, today.
> 
I'll postpone this until -mm is settled ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
