Date: Mon, 29 Sep 2008 11:55:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][RFC] memory.min_usage again
Message-Id: <20080929115513.5db72cfd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080929004332.13B0083F2@siro.lan>
References: <20080912184630.35773102.kamezawa.hiroyu@jp.fujitsu.com>
	<20080929004332.13B0083F2@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, containers@lists.osdl.org, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Sep 2008 09:43:32 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> > > 
> > > I would prefer to see some heuristics around such a feature, mostly around the
> > > priority that do_try_to_free_pages() to determine how desperate we are for
> > > reclaiming memory.
> > > 
> > Taking "priority" of memory reclaim path into account is good.
> > 
> > ==
> > static unsigned long shrink_inactive_list(unsigned long max_scan,
> >                         struct zone *zone, struct scan_control *sc,
> >                         int priority, int file)
> > ==
> > How about ignore min_usage if "priority < DEF_PRIORITY - 2" ?
> 
> are you suggesting ignoring mlock etc as well in that case?
> 

No. Just freeing pages, which are usually freed is good.

==
int mem_cgroup_canreclaim(struct page *page, struct mem_cgroup *mem1,
			  int priority)
{
	struct page_cgroup *pc;
	int result = 1;

	if (mem1 != NULL)
		return 1;
	/* global lru is busy ? */
        if (priority < DEF_PEIORITY - 1)
		return 1;
        ....
}
==
Maybe min_usage can works as *soft* mlock by this.

Or another idea.
Making memory.min_usage as memory.reclaim_priority_level and allows

  priority_level == 0 => can_reclaim() returns 1 always.
  priority_level == 1 => can_reclaim returns 1 if priority < DEF_PRIORITY-1.
  priority_level == 2 => can_reclaim returns 1 if priority < DEF_PRIORITY-2.

(and only 0,1,2 are allowed.)

setting min_usage will not be prefered by lru management people.
This can work as "advice" to global lru.

Hmm ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
