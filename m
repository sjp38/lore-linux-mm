Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F7BF6B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 20:22:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4Q0Lxu4026836
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 26 May 2010 09:22:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 336312E68C1
	for <linux-mm@kvack.org>; Wed, 26 May 2010 09:21:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B34A1EF082
	for <linux-mm@kvack.org>; Wed, 26 May 2010 09:21:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A05A3E18002
	for <linux-mm@kvack.org>; Wed, 26 May 2010 09:21:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F5851DB8038
	for <linux-mm@kvack.org>; Wed, 26 May 2010 09:21:58 +0900 (JST)
Date: Wed, 26 May 2010 09:17:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: oom killer rewrite
Message-Id: <20100526091740.953090a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1005250231460.8045@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
	<20100520092717.0c3d8f3f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1005250231460.8045@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010 02:42:14 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 20 May 2010, KAMEZAWA Hiroyuki wrote:
> 
> > I've pointed out that "normalized" parameter doesn't seem to work well in some
> > situaion (in cluster). I hope you'll have an extra interface as
> > 
> > 	echo 3G > /proc/<pid>/oom_indemification
> > 
> > to allow users have "absolute value" setting.
> > (If the admin know usual memory usage of an application, we can only
> >  add badness to extra memory usage.)
> > 
> > To be honest, I can't fully understand why we need _normalized_ parameter. Why
> > oom_adj _which is now used_ is not enough for setting "relative importance" ?
> > 
> 
> The only sane badness heuristic will be one that effectively compares all 
> eligible tasks for oom kill in a way that are relative to one another; I'm 
> concerned that a tunable that is based on a pure memory quantity requires 
> specific knowledge of the system (or memcg, cpuset, etc) capacity before 
> it is meaningful.  In other words, I opted to use a relative proportion so 
> that when tasks are constrained to cpusets or memcgs or mempolicies they 
> become part of a "virtualized system" where the proportion is then used in 
> calculation of the total amount of system RAM, memcg limit, cpuset mems 
> capacities, etc, without knowledge of what that value actually is.  So 
> "echo 3G" may be valid in your example when not constrained to any cgroup 
> or mempolicy but becomes invalid if I attach it to a cpuset with a single 
> node of 1G capacity.  When oom_score_adj, we can specify the proportion 
> "of the resources that the application has access to" in comparison to 
> other applications that share those resources to determine oom killing 
> priority.  I think that's a very powerful interface and your suggestion 
> could easily be implemented in userspace with a simple divide, thus we 
> don't need kernel support for it.
> 
I know admins will be able to write a script. But, my point is
"please don't force admins to write such a hacky scripts."

For example, an admin uses an application which always use 3G bytes adn it's
valid and sane use for the application. When he run it on a server with
4G system and 8G system, he has to change the value for oom_score_adj.


One good point of old oom_adj is that it's not influenced by environment.
Then, X-window applications set it's oom_adj to be fixed value. 
IIUC, they're hardcoded with fixed value, now. 

Even if my customer may use only OOM_DISABLE, I think using oom_score_adj
is too difficult for usual users.


Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
