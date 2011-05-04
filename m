Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEB486B0023
	for <linux-mm@kvack.org>; Wed,  4 May 2011 17:26:56 -0400 (EDT)
Date: Wed, 4 May 2011 14:26:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4] memcg: reclaim memory from node in round-robin
Message-Id: <20110504142623.8aa3bddb.akpm@linux-foundation.org>
In-Reply-To: <20110428104912.6f86b2ee.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinx+4zXaO3rhHRUzr3m-K-2_NMTQw@mail.gmail.com>
	<20110428093513.5a6970c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110428103705.a284df87.nishimura@mxp.nes.nec.co.jp>
	<20110428104912.6f86b2ee.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, 28 Apr 2011 10:49:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 28 Apr 2011 10:37:05 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > +	if (time_after(mem->next_scan_node_update, jiffies))
> > > +		return;
> > > +
> > Shouldn't it be time_before() or time_after(jiffies, next_scan_node_update) ?
> > 
> > Looks good to me, otherwise.
> > 
> 
> time_after(a, b) returns true when a is after b.....you're right.
> ==
> Now, memory cgroup's direct reclaim frees memory from the current node.
> But this has some troubles. In usual, when a set of threads works in
> cooperative way, they are tend to on the same node. So, if they hit
> limits under memcg, it will reclaim memory from themselves, it may be
> active working set.
> 
> For example, assume 2 node system which has Node 0 and Node 1
> and a memcg which has 1G limit. After some work, file cacne remains and
> and usages are
>    Node 0:  1M
>    Node 1:  998M.
> 
> and run an application on Node 0, it will eats its foot before freeing
> unnecessary file caches.
> 
> This patch adds round-robin for NUMA and adds equal pressure to each
> node. When using cpuset's spread memory feature, this will work very well.
> 
> But yes, better algorithm is appreciated.

That ten-second thing is a gruesome and ghastly hack, but didn't even
get a mention in the patch description?

Talk to us about it.  Why is it there?  What are the implications of
getting it wrong?  What alternatives are there? 

It would be much better to work out the optimum time at which to rotate
the index via some deterministic means.

If we can't think of a way of doing that then we should at least pace
the rotation frequency via something saner than wall-time.  Such as
number-of-pages-scanned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
