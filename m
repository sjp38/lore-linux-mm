Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD81B6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:06:37 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2V64hW1029763
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:04:43 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2V66TsB377054
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:06:30 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2V66Tib030234
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:06:29 +1100
Date: Tue, 31 Mar 2009 11:36:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 7/8] memcg soft limit LRU reorder
Message-ID: <20090331060607.GH16497@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com> <20090327141225.1e483acd.kamezawa.hiroyu@jp.fujitsu.com> <20090330075246.GA16497@balbir.in.ibm.com> <20090331090023.e1d30a5a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090331090023.e1d30a5a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 09:00:23]:

> On Mon, 30 Mar 2009 13:22:46 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 14:12:25]:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > This patch adds a function to change the LRU order of pages in global LRU
> > > under control of memcg's victim of soft limit.
> > > 
> > > FILE and ANON victim is divided and LRU rotation will be done independently.
> > > (memcg which only includes FILE cache or ANON can exists.)
> > > 
> > > The routine finds specfied number of pages from memcg's LRU and
> > > move it to top of global LRU. They will be the first target of shrink_xxx_list.
> > 
> > This seems to be the core of the patch, but I don't like this very
> > much. Moving LRU pages of the mem cgroup seems very subtle, why can't
> > we directly use try_to_free_mem_cgroup_pages()?
> > 
> It ignores many things.

My concern is that such subtle modification to the global LRU 

1. Can break the age property of elements in the LRU (we have mixed
ages now in the LRU)
2. Can potentially impact lumpy reclaim, since we've mix LRU pages
from the memory controlelr into the global LRU?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
