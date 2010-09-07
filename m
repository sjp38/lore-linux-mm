Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 55C236B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 05:09:04 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o87990r6007649
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Sep 2010 18:09:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 72DC045DE4F
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 18:09:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CC9845DE4C
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 18:09:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 32B271DB8013
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 18:09:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DFCF31DB8014
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 18:08:56 +0900 (JST)
Date: Tue, 7 Sep 2010 18:03:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] big continuous memory allocator v2
Message-Id: <20100907180354.a8dd5669.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100907104635.2a02a1ca@basil.nowhere.org>
References: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
	<87occa9fla.fsf@basil.nowhere.org>
	<20100907172559.496554d8.kamezawa.hiroyu@jp.fujitsu.com>
	<20100907104635.2a02a1ca@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Sep 2010 10:46:35 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> On Tue, 7 Sep 2010 17:25:59 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 07 Sep 2010 09:29:21 +0200
> > Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> > > 
> > > > This is a page allcoator based on memory migration/hotplug code.
> > > > passed some small tests, and maybe easier to read than previous
> > > > one.
> > > 
> > > Maybe I'm missing context here, but what is the use case for this?
> > > 
> > 
> > I hear some drivers want to allocate xxMB of continuous area.(camera?)
> > Maybe embeded guys can answer the question.
> 
> Ok what I wanted to say -- assuming you can make this work
> nicely, and the delays (swap storms?) likely caused by this are not
> too severe, it would be interesting for improving the 1GB pages on x86.
> 

Oh, I didn't consider that. Hmm. If x86 really wants to support 1GB page,
MAX_ORDER should be raised. (I'm sorry if it was already disccused.)


> This would be a major use case and probably be enough
> to keep the code around.
> 
> But it depends on how well it works.
> 
Sure.

> e.g. when the zone is already fully filled how long
> does the allocation of 1GB take?
> 
Maybe not very quick, even slow.

> How about when parallel programs are allocating/freeing
> in it too?
> 
This code doesn't assume that. I wonder I should add mutex because this code
generates IPI for draining some per-cpu lists.

I think 1GB pages should be preallocated as current hugepage does.


> What's the worst case delay under stress?
> 
memory offline itself is robust against stress because it make
pageblock ISOLATED. But memory allocation of 1GB is problem.
I have an idea (see below).

> Does it cause swap storms?
> 
Maybe same as allocating 1GB of memory when memory is full.
It's LRU matter.


> One issue is also that it would be good to be able to decide
> in advance if the OOM killer is likely triggered (and if yes
> reject the allocation in the first place). 
> 

Checking the amount of memory and swap before starts ? 
It sounds nice. I'd like to add something.

Or changing my patche's logic as..

  1. allocates required migration target pages (of 1GB)
  2. start migration to allocated pages.
  3. create a big page. 

Then, we can use some GFP_XXXX at (1) and can do some tuning as usual
vm codes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
