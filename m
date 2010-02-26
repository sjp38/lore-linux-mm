Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 272EC6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 20:13:23 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1Q1DJdf023207
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 26 Feb 2010 10:13:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0872545DE4F
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 10:13:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D8FC845DE54
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 10:13:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BA3A71DB8038
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 10:13:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 765231DB803C
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 10:13:18 +0900 (JST)
Date: Fri, 26 Feb 2010 10:09:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
Message-Id: <20100226100944.1c2aa738.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002251228140.18861@router.home>
References: <20100211953.850854588@firstfloor.org>
	<20100211205404.085FEB1978@basil.firstfloor.org>
	<20100215061535.GI5723@laptop>
	<20100215103250.GD21783@one.firstfloor.org>
	<20100215104135.GM5723@laptop>
	<20100215105253.GE21783@one.firstfloor.org>
	<20100215110135.GN5723@laptop>
	<alpine.DEB.2.00.1002191222320.26567@router.home>
	<20100220090154.GB11287@basil.fritz.box>
	<alpine.DEB.2.00.1002240949140.26771@router.home>
	<4B862623.5090608@cs.helsinki.fi>
	<alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002251228140.18861@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Feb 2010 12:30:26 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 25 Feb 2010, David Rientjes wrote:
> 
> > I don't see how memory hotadd with a new node being onlined could have
> > worked fine before since slab lacked any memory hotplug notifier until
> > Andi just added it.
> 
> AFAICR The cpu notifier took on that role in the past.
> 
> If what you say is true then memory hotplug has never worked before.
> Kamesan?
> 
In this code,

 int node = numa_node_id();

node is got by its CPU.

At node hotplug, following order should be kept.
	Add:   memory -> cpu
	Remove: cpu -> memory

cpus must be onlined after memory. At least, we online cpus only after
memory. Then, we(our heavy test on RHEL5) never see this kind of race.


I'm sorry if my answer misses your point.

Thanks,
-Kame
 

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
