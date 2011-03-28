Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E02A58D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:17:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9A1003EE0B6
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:17:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 82B3345DE50
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:17:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 634F345DE4F
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:17:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5341C1DB803E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:17:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 118AA1DB802F
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:17:55 +0900 (JST)
Date: Mon, 28 Mar 2011 18:11:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: update documentation to describe usage_in_bytes
Message-Id: <20110328181127.b8a2a1c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110328074341.GA5693@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
	<20110321093419.GA26047@tiehlicka.suse.cz>
	<20110321102420.GB26047@tiehlicka.suse.cz>
	<20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110322104723.fd81dddc.nishimura@mxp.nes.nec.co.jp>
	<20110322073150.GA12940@tiehlicka.suse.cz>
	<20110323092708.021d555d.nishimura@mxp.nes.nec.co.jp>
	<20110323133517.de33d624.kamezawa.hiroyu@jp.fujitsu.com>
	<20110328085508.c236e929.nishimura@mxp.nes.nec.co.jp>
	<20110328132550.08be4389.nishimura@mxp.nes.nec.co.jp>
	<20110328074341.GA5693@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 28 Mar 2011 09:43:42 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 28-03-11 13:25:50, Daisuke Nishimura wrote:
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > Update the meaning of *.usage_in_bytes. They doesn't show the actual usage of
> > RSS+Cache(+Swap). They show the res_counter->usage for memory and memory+swap.
> 
> Don't we want to add why this is not rss+cache? The reason is really non
> trivial for somebody who is not familiar with the code and with the fact
> that we are heavily caching charges.
> 
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  Documentation/cgroups/memory.txt |   16 ++++++++++++++--
> >  1 files changed, 14 insertions(+), 2 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index 7781857..ab7d4c1 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -52,8 +52,10 @@ Brief summary of control files.
> >   tasks				 # attach a task(thread) and show list of threads
> >   cgroup.procs			 # show list of processes
> >   cgroup.event_control		 # an interface for event_fd()
> > - memory.usage_in_bytes		 # show current memory(RSS+Cache) usage.
> > - memory.memsw.usage_in_bytes	 # show current memory+Swap usage
> > + memory.usage_in_bytes		 # show current res_counter usage for memory
> > +				 (See 5.5 for details)
> > + memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
> > +				 (See 5.5 for details)
> >   memory.limit_in_bytes		 # set/show limit of memory usage
> >   memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
> >   memory.failcnt			 # show the number of memory usage hits limits
> > @@ -453,6 +455,16 @@ memory under it will be reclaimed.
> >  You can reset failcnt by writing 0 to failcnt file.
> >  # echo 0 > .../memory.failcnt
> >  
> > +5.5 usage_in_bytes
> > +
> > +As described in 2.1, memory cgroup uses res_counter for tracking and limiting
> > +the memory usage. memory.usage_in_bytes shows the current res_counter usage for
> > +memory, and DOESN'T show a actual usage of RSS and Cache. It is usually bigger
> > +than the actual usage for a performance improvement reason. 
> 
> Isn't an explicit mention about caching charges better?
> 

It's difficult to distinguish which is spec. and which is implemnation details...

My one here ;)
==
5.5 usage_in_bytes

For efficiency, as other kernel components, memory cgroup uses some optimization to
avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
method and doesn't show 'exact' value of usage, it's an fuzz value for efficient
access. (Of course, when necessary, it's synchronized.)
In usual, the value (RSS+CACHE) in memory.stat shows more exact value. IOW,
usage_in_bytes is less exact than memory.stat. The error will be larger on the larger
hardwares which have many cpus and tasks.
==

Hmm ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
