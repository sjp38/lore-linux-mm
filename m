Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D75F900001
	for <linux-mm@kvack.org>; Fri,  6 May 2011 02:19:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 55F433EE0BB
	for <linux-mm@kvack.org>; Fri,  6 May 2011 15:19:40 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C37F45DE53
	for <linux-mm@kvack.org>; Fri,  6 May 2011 15:19:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 19B9445DE50
	for <linux-mm@kvack.org>; Fri,  6 May 2011 15:19:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C9871DB8037
	for <linux-mm@kvack.org>; Fri,  6 May 2011 15:19:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B4B291DB803E
	for <linux-mm@kvack.org>; Fri,  6 May 2011 15:19:39 +0900 (JST)
Date: Fri, 6 May 2011 15:13:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv4] memcg: reclaim memory from node in round-robin
Message-Id: <20110506151302.a7256987.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110504142623.8aa3bddb.akpm@linux-foundation.org>
References: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinx+4zXaO3rhHRUzr3m-K-2_NMTQw@mail.gmail.com>
	<20110428093513.5a6970c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110428103705.a284df87.nishimura@mxp.nes.nec.co.jp>
	<20110428104912.6f86b2ee.kamezawa.hiroyu@jp.fujitsu.com>
	<20110504142623.8aa3bddb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Wed, 4 May 2011 14:26:23 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 28 Apr 2011 10:49:12 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 28 Apr 2011 10:37:05 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > +	if (time_after(mem->next_scan_node_update, jiffies))
> > > > +		return;
> > > > +
> > > Shouldn't it be time_before() or time_after(jiffies, next_scan_node_update) ?
> > > 
> > > Looks good to me, otherwise.
> > > 
> > 
> > time_after(a, b) returns true when a is after b.....you're right.
> > ==
> > Now, memory cgroup's direct reclaim frees memory from the current node.
> > But this has some troubles. In usual, when a set of threads works in
> > cooperative way, they are tend to on the same node. So, if they hit
> > limits under memcg, it will reclaim memory from themselves, it may be
> > active working set.
> > 
> > For example, assume 2 node system which has Node 0 and Node 1
> > and a memcg which has 1G limit. After some work, file cacne remains and
> > and usages are
> >    Node 0:  1M
> >    Node 1:  998M.
> > 
> > and run an application on Node 0, it will eats its foot before freeing
> > unnecessary file caches.
> > 
> > This patch adds round-robin for NUMA and adds equal pressure to each
> > node. When using cpuset's spread memory feature, this will work very well.
> > 
> > But yes, better algorithm is appreciated.
> 
> That ten-second thing is a gruesome and ghastly hack, but didn't even
> get a mention in the patch description?
> 
> Talk to us about it.  Why is it there?  What are the implications of
> getting it wrong?  What alternatives are there? 
> 

Ah, sorry I couldn't think of fix to that levet, I posted.

> It would be much better to work out the optimum time at which to rotate
> the index via some deterministic means.
> 
> If we can't think of a way of doing that then we should at least pace
> the rotation frequency via something saner than wall-time.  Such as
> number-of-pages-scanned.
> 


What I think now is using reclaim_stat or usigng some fairness based on
the ratio of inactive file caches. We can calculate the total sum of
recalaim_stat which gives us a scan_ratio for a whole memcg. And we can
calculate LRU rotate/scan ratio per node. If rotate/scan ratio is small,
it will be a good candidate of reclaim target. Hmm,

  - check which memory(anon or file) should be scanned.
    (If file is too small, rotate/scan ratio of file is meaningless.)
  - check rotate/scan ratio of each nodes.
  - calculate weights for each nodes (by some logic ?)
  - give a fair scan w.r.t node's weight.

Hmm, I'll have a study on this.

Thanks.
-Kame













--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
