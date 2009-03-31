Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 238316B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:20:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V6KvLH014719
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 15:20:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9003445DE57
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:20:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6801345DE5D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:20:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 26847E18006
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:20:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AFD161DB8040
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:20:56 +0900 (JST)
Date: Tue, 31 Mar 2009 15:19:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 7/8] memcg soft limit LRU reorder
Message-Id: <20090331151929.3d958a95.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090331060607.GH16497@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090327141225.1e483acd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090330075246.GA16497@balbir.in.ibm.com>
	<20090331090023.e1d30a5a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331060607.GH16497@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 11:36:07 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 09:00:23]:
> 
> > On Mon, 30 Mar 2009 13:22:46 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 14:12:25]:
> > > 
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > 
> > > > This patch adds a function to change the LRU order of pages in global LRU
> > > > under control of memcg's victim of soft limit.
> > > > 
> > > > FILE and ANON victim is divided and LRU rotation will be done independently.
> > > > (memcg which only includes FILE cache or ANON can exists.)
> > > > 
> > > > The routine finds specfied number of pages from memcg's LRU and
> > > > move it to top of global LRU. They will be the first target of shrink_xxx_list.
> > > 
> > > This seems to be the core of the patch, but I don't like this very
> > > much. Moving LRU pages of the mem cgroup seems very subtle, why can't
> > > we directly use try_to_free_mem_cgroup_pages()?
> > > 
> > It ignores many things.
> 
> My concern is that such subtle modification to the global LRU 
> 
okay. maybe everyone's concern.

> 1. Can break the age property of elements in the LRU (we have mixed
> ages now in the LRU)

We have to break(change) some, anyway.
I think this kind of LRU-swapping/reorder technique is a popular technique to
give LRU a hint and reordering is one of the least invasive options.
It doesn't affect global LRU other than the order of pages and all statistics
are updated in sane way.


> 2. Can potentially impact lumpy reclaim, since we've mix LRU pages
> from the memory controlelr into the global LRU?
> 

I can't catch what you ask...but I think no influence to lumpty reclaim.
It gathers vicitm pages from neiborhood of a page which should be removed.
Hmm ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
