Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 24F6A6B007E
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 05:30:06 -0500 (EST)
Date: Mon, 1 Mar 2010 11:30:01 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 1/2] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100301103001.GB2087@linux>
References: <1267224751-6382-1-git-send-email-arighi@develer.com>
 <1267224751-6382-2-git-send-email-arighi@develer.com>
 <20100301170535.2f1db0ed.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100301170535.2f1db0ed.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vivek Goyal <vgoyal@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 05:05:35PM +0900, Daisuke Nishimura wrote:
> On Fri, 26 Feb 2010 23:52:30 +0100, Andrea Righi <arighi@develer.com> wrote:
> > Infrastructure to account dirty pages per cgroup and add dirty limit
> > interfaces in the cgroupfs:
> > 
> >  - Active write-out: memory.dirty_ratio, memory.dirty_bytes
> >  - Background write-out: memory.dirty_background_ratio, memory.dirty_background_bytes
> > 
> It looks good for me in general.
> 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > ---
> >  include/linux/memcontrol.h |   74 +++++++++-
> >  mm/memcontrol.c            |  354 ++++++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 399 insertions(+), 29 deletions(-)
> > 
> 
> (snip)
> 
> > +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +	struct mem_cgroup_page_stat stat = {};
> > +	struct mem_cgroup *memcg;
> > +
> I think it would be better to add "if (mem_cgroup_disabled())".

Agreed.

> 
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (memcg) {
> > +		/*
> > +		 * Recursively evaulate page statistics against all cgroup
> > +		 * under hierarchy tree
> > +		 */
> > +		stat.item = item;
> > +		mem_cgroup_walk_tree(memcg, &stat, mem_cgroup_page_stat_cb);
> > +	} else
> > +		stat.value = -ENOMEM;
> > +	rcu_read_unlock();
> > +
> > +	return stat.value;
> > +}
> > +
> >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> >  {
> >  	int *val = data;
> > @@ -1263,10 +1419,10 @@ static void record_last_oom(struct mem_cgroup *mem)
> >  }
> >  
> >  /*
> > - * Currently used to update mapped file statistics, but the routine can be
> > - * generalized to update other statistics as well.
> > + * Generalized routine to update memory cgroup statistics.
> >   */
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +void mem_cgroup_update_stat(struct page *page,
> > +			enum mem_cgroup_stat_index idx, int val)
> >  {
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> ditto.

Agreed.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
