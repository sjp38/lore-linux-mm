Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8D2396B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 03:19:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAA8JjAd005085
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 10 Nov 2009 17:19:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 425F245DE56
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:19:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A14245DE52
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:19:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DDDAE1DB803F
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:19:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A6851DB8043
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:19:44 +0900 (JST)
Date: Tue, 10 Nov 2009 17:17:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v2
Message-Id: <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110163419.361E.A69D9226@jp.fujitsu.com>
	<20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009 17:03:38 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 10 Nov 2009 16:40:55 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 10 Nov 2009 16:39:02 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > > > +
> > > > > > +	/* Check this allocation failure is caused by cpuset's wall function */
> > > > > > +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > > > > > +			high_zoneidx, nodemask)
> > > > > > +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
> > > > > >  			return CONSTRAINT_CPUSET;
> > > > > 
> > > > > If cpuset and MPOL_BIND are both used, Probably CONSTRAINT_MEMORY_POLICY is
> > > > > better choice.
> > > > 
> > > > No. this memory allocation is failed by limitation of cpuset's alloc mask.
> > > > Not from mempolicy.
> > > 
> > > But CONSTRAINT_CPUSET doesn't help to free necessary node memory. It isn't
> > > your fault. original code is wrong too. but I hope we should fix it.
> > > 
> I think so too.
> 
> > Hmm, maybe fair enough.
> > 
> > My 3rd version will use "kill always current(CONSTRAINT_MEMPOLICY does this)
> > if it uses mempolicy" logic.
> > 
> "if it uses mempoicy" ?
> You mean "kill allways current if memory allocation has failed by limitation of
> cpuset's mask"(i.e. CONSTRAINT_CPUSET case) ?
> 

No. "kill always current process if memory allocation uses mempolicy"
regardless of cpuset. If the task doesn't use mempolicy allocation,
usual CONSTRAINT_CPUSET/CONSTRAINT_NONE oom handler will be invoked.

Now, without patch, CONSTRAINT_MEMPOLICY is not returned at all. I'd
like to limit the scope of this patch to return it. If it's returned,
current will be killed.

Finally, we'll have to consinder "how to manage oom under cpuset"
problem, again. It's not handled in good way, now.

The main problems are...
   - Cpuset allows intersection of nodes among groups. 
   - Task can be migrated to other cpuset withoug moving memory.
   - We don't have per-node-rss information per task.

Then,
   - We have to scan all tasks.
   - We have to invoke Totally-Random-Innocent-Task-Killer and pray that
     someone bad will be killed.

IMHO, "find correct one" is too heavy to the kernel (under cpuset).
If we can have notifier to userland, some daemon can check numa_maps of all
tasks and will do something reasonbale.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
