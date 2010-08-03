Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B07936008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:34:20 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o733c0NI024351
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 23:38:00 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o733cf5t113198
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 23:38:41 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o733ce9R011533
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 00:38:41 -0300
Date: Tue, 3 Aug 2010 09:08:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm 1/5] quick lookup memcg by ID
Message-ID: <20100803033838.GE3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100802191304.8e520808.kamezawa.hiroyu@jp.fujitsu.com>
 <20100803032216.GC3863@balbir.in.ibm.com>
 <20100803122158.c01b9921.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100803122158.c01b9921.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-03 12:21:58]:

> On Tue, 3 Aug 2010 08:52:16 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:13:04]:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Now, memory cgroup has an ID per cgroup and make use of it at
> > >  - hierarchy walk,
> > >  - swap recording.
> > > 
> > > This patch is for making more use of it. The final purpose is
> > > to replace page_cgroup->mem_cgroup's pointer to an unsigned short.
> > > 
> > > This patch caches a pointer of memcg in an array. By this, we
> > > don't have to call css_lookup() which requires radix-hash walk.
> > > This saves some amount of memory footprint at lookup memcg via id.
> > >
> > 
> > It is a memory versus speed tradeoff, but if the number of created
> > cgroups is low, it might not be all that slow, besides we do that for
> > swap_cgroup anyway - no?
> >  
> 
> In following patch, pc->page_cgroup is changed from pointer to ID.
> Then, this lookup happens in lru_add/del, for example.
> And, by this, we can place all lookup related things to __read_mostly.
> With css_lookup(), we can't do it and have to be afraid of cache
> behavior.
>

OK, fair enough
 
> I hear there are a users who create 2000+ cgroups and considering
> about "low number" user here is not important.
> This patch is a help for getting _stable_ performance even when there are
> many cgroups.
>

I've heard of one such user on the libcgroup mailing list. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
