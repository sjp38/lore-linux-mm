Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5236B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 20:31:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 45D473EE0BB
	for <linux-mm@kvack.org>; Fri, 20 May 2011 09:31:13 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 27E1B45DD6E
	for <linux-mm@kvack.org>; Fri, 20 May 2011 09:31:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06C9C45DF60
	for <linux-mm@kvack.org>; Fri, 20 May 2011 09:31:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC2A9E08001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 09:31:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B4A6E08007
	for <linux-mm@kvack.org>; Fri, 20 May 2011 09:31:12 +0900 (JST)
Date: Fri, 20 May 2011 09:24:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3 3/3] memcg: add memory.numastat api for numa
 statistics
Message-Id: <20110520092424.1f1b514f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTincQttGR_o3Q6dxsq91+Ew12gYEOg@mail.gmail.com>
References: <1305826360-2167-1-git-send-email-yinghan@google.com>
	<1305826360-2167-3-git-send-email-yinghan@google.com>
	<20110520085152.e518ac71.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTincQttGR_o3Q6dxsq91+Ew12gYEOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 19 May 2011 17:11:49 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, May 19, 2011 at 4:51 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 19 May 2011 10:32:40 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > The new API exports numa_maps per-memcg basis. This is a piece of useful
> > > information where it exports per-memcg page distribution across real numa
> > > nodes.
> > >
> > > One of the usecase is evaluating application performance by combining
> > this
> > > information w/ the cpu allocation to the application.
> > >
> > > The output of the memory.numastat tries to follow w/ simiar format of
> > numa_maps
> > > like:
> > >
> > > total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > > file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > > anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > >
> > > $ cat /dev/cgroup/memory/memory.numa_stat
> > > total=246594 N0=18225 N1=72025 N2=26378 N3=129966
> > > file=221728 N0=15030 N1=60804 N2=23238 N3=122656
> > > anon=21120 N0=2937 N1=7733 N2=3140 N3=7310
> > >
> >
> > Hmm ? this doesn't seem consistent....Isn't this log updated ?
> >
> 
> Nope. This is the V3 i posted w/ updated testing result.
> 

Did you get this log while applications are running and LRU are changing ?
See N1, 72505 != 60804 + 7733. big error.

Could you clarify why total != file + anon ? 
Does the number seems consistent when the system is calm ?

BTW, I wonder why unevictable is not shown...
mem_cgroup_node_nr_lru_pages() counts unevictable into it because of for_each_lru().

There are 2 ways.
 1. show unevictable
 2. use for_each_evictable_lru().

I vote for 1.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
