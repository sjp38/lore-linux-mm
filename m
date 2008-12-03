Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mB3EJYBV011871
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:49:34 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3EJYSl1409048
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 19:49:34 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id mB3EJXuS031235
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 01:19:33 +1100
Date: Wed, 3 Dec 2008 19:49:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 11/11] memcg: show reclaim_stat
Message-ID: <20081203141931.GH17701@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081201211905.1CEB.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081202180525.2023892c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081202180525.2023892c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-02 18:05:25]:

> On Mon,  1 Dec 2008 21:19:49 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > added following four field to memory.stat file.
> > 
> >   - recent_rotated_anon
> >   - recent_rotated_file
> >   - recent_scanned_anon
> >   - recent_scanned_file
> > 
> > it is useful for memcg reclaim debugging.
> > 
> I'll put this under CONFIG_DEBUG_VM.
>

I think they'll be useful even outside for tasks that need to take
decisions, it will be nice to see what sort of reclaim is going on. I
would like to see them outside, there is no cost associated with them
and assuming we'll not change the LRU logic very frequently, we don't
need to be afraid of breaking ABI either :)
 
> Thanks,
> -Kame
> 
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   25 +++++++++++++++++++++++++
> >  1 file changed, 25 insertions(+)
> > 
> > Index: b/mm/memcontrol.c
> > ===================================================================
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1799,6 +1799,31 @@ static int mem_control_stat_show(struct 
> >  
> >  	cb->fill(cb, "inactive_ratio", mem_cont->inactive_ratio);
> >  
> > +	{
> > +		int nid, zid;
> > +		struct mem_cgroup_per_zone *mz;
> > +		unsigned long recent_rotated[2] = {0, 0};
> > +		unsigned long recent_scanned[2] = {0, 0};
> > +
> > +		for_each_online_node(nid)
> > +			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> > +				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
> > +
> > +				recent_rotated[0] +=
> > +					mz->reclaim_stat.recent_rotated[0];
> > +				recent_rotated[1] +=
> > +					mz->reclaim_stat.recent_rotated[1];
> > +				recent_scanned[0] +=
> > +					mz->reclaim_stat.recent_scanned[0];
> > +				recent_scanned[1] +=
> > +					mz->reclaim_stat.recent_scanned[1];
> > +			}
> > +		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
> > +		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
> > +		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
> > +		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
> > +	}
> > +
> >  	return 0;
> >  }
> >  
> > 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
